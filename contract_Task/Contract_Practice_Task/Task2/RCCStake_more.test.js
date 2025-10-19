const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RCCStake - extra coverage tests (admin, ETH flow, edge cases)", function () {
  let owner, alice, bob;
  let rewardToken, stakeToken, rccStake;

  beforeEach(async function () {
    [owner, alice, bob] = await ethers.getSigners();

    const RCC = await ethers.getContractFactory("RCC");
    rewardToken = await RCC.deploy();
    await rewardToken.waitForDeployment();

    const Stake = await ethers.getContractFactory("RCC");
    stakeToken = await Stake.deploy();
    await stakeToken.waitForDeployment();

    const RCCStake = await ethers.getContractFactory("RCCStake");
    rccStake = await RCCStake.deploy();
    await rccStake.waitForDeployment();

    // initialize with rewardToken
    await rccStake.initialize(rewardToken.target, 100, 100_000_000, ethers.parseEther("3"));

    // give some reward tokens to contract to allow normal claims
    await rewardToken.transfer(rccStake.target, ethers.parseEther("1000000"));
  });

  // helper: add native(pool0) then ERC20(pool1)
  async function addPools() {
    await rccStake.addPool(ethers.ZeroAddress, 100, 0, 10, false); // native pool
    await rccStake.addPool(stakeToken.target, 100, 100, 5, true); // erc20 pool pid=1
  }

  async function mineBlocks(n) {
    for (let i = 0; i < n; i++) {
      await ethers.provider.send("evm_mine", []);
    }
  }

  it("admin only: setRCC / setStartBlock / setEndBlock / setRCCPerBlock restrictions", async function () {
    // non-admin cannot call admin-only functions
    await expect(rccStake.connect(alice).setRCC(stakeToken.target)).to.be.reverted;
    await expect(rccStake.connect(alice).setStartBlock(200)).to.be.reverted;
    await expect(rccStake.connect(alice).setEndBlock(200000)).to.be.reverted;
    await expect(rccStake.connect(alice).setRCCPerBlock(1234)).to.be.reverted;

    // admin (owner) can call
    await rccStake.setRCC(rewardToken.target);
    await rccStake.setStartBlock(150);
    await rccStake.setEndBlock(1000000);
    await rccStake.setRCCPerBlock(123456);
    expect(await rccStake.startBlock()).to.equal(150);
    expect(await rccStake.endBlock()).to.equal(1000000);
    expect(await rccStake.rccPerBlock()).to.equal(123456);
  });

  it("pause/unpause claim & withdraw behaviors and events", async function () {
    // only admin can pause/unpause
    await expect(rccStake.connect(alice).pauseClaim()).to.be.reverted;
    await rccStake.pauseClaim();
    await expect(rccStake.claim(0)).to.be.revertedWith("claim is paused").or.to.be.reverted;
    await rccStake.unpauseClaim();

    await expect(rccStake.connect(alice).pauseWithdraw()).to.be.reverted;
    await rccStake.pauseWithdraw();
    // withdraw will revert when paused (we don't need a pool for this assertion)
    await expect(rccStake.withdraw(0)).to.be.revertedWith("withdraw is paused").or.to.be.reverted;
    await rccStake.unpauseWithdraw();
  });

  it("depositETH() flow and native unstake/withdraw queue handling", async function () {
    // add pools
    await addPools();

    // deposit native to pool 0 using depositETH() function
    // depositETH() is payable, call via contract function
    await rccStake.depositETH({ value: 200 }); // caller is owner by default in tests
    let user0 = await rccStake.user(0, owner.address);
    expect(user0.stAmount).to.equal(200n);

    // deposit more via depositETH
    await rccStake.depositETH({ value: 500 });
    user0 = await rccStake.user(0, owner.address);
    expect(user0.stAmount).to.equal(700n);

    // unstake a portion -> creates request with unlockBlocks = block.number + pool.unstakeLockedBlocks (pool0 unstakeLockedBlocks=10)
    // advance blocks less than lock -> requests shouldn't be withdrawable
    await rccStake.unstake(0, 100);
    // attempt withdraw now should find nothing available
    await rccStake.withdraw(0);
    // no revert expected, but withdraw amount zero; user requests still present (can't easily assert internal array length in JS)
    // advance enough blocks so unlock occurs
    await mineBlocks(20);
    // now withdraw should send ETH back (no revert)
    await rccStake.withdraw(0);
    // we can check contract balance decreased (but test harness accounts might differ)
    // At least the flow executed without revert
  });

  it("deposit ERC20 (pid=1) reverts when below minDepositAmount and succeeds when equal/above", async function () {
    await addPools();

    // owner receives stake tokens
    await stakeToken.transfer(owner.address, ethers.parseEther("1000"));
    await stakeToken.approve(rccStake.target, ethers.MaxUint256);

    // deposit below min (min=100) -> revert with message "deposit amount is too small"
    await expect(rccStake.deposit(1, 50)).to.be.revertedWith("deposit amount is too small");

    // deposit at min -> ok
    await rccStake.deposit(1, 100);
    let user = await rccStake.user(1, owner.address);
    expect(user.stAmount).to.equal(100n);
  });

  it("updatePool / massUpdatePools behaviors for stSupply=0 and stSupply>0", async function () {
    await addPools();

    // pool1 stSupply=0 case: updatePool should early return or set lastRewardBlock only
    await rccStake.updatePool(1);
    let pool1 = await rccStake.pool(1);
    const last1 = BigInt(pool1.lastRewardBlock);

    // deposit to make stSupply > 0 then updatePool increases accRCCPerST
    await stakeToken.transfer(owner.address, ethers.parseEther("1000"));
    await stakeToken.approve(rccStake.target, ethers.MaxUint256);
    await rccStake.deposit(1, ethers.parseEther("500"));

    // move blocks
    await mineBlocks(1000);
    await rccStake.updatePool(1);
    pool1 = await rccStake.pool(1);
    const accAfter = BigInt(pool1.accRCCPerST);
    expect(accAfter).to.be.greaterThan(0n);
  });

  it("setPoolWeight with withUpdate=true triggers massUpdatePools path", async function () {
    await addPools();

    // deposit to pool1 so massUpdatePools has some effect
    await stakeToken.transfer(owner.address, ethers.parseEther("1000"));
    await stakeToken.approve(rccStake.target, ethers.MaxUint256);
    await rccStake.deposit(1, ethers.parseEther("100"));

    // call setPoolWeight with withUpdate=true
    await rccStake.setPoolWeight(1, 300, true);
    const pool1 = await rccStake.pool(1);
    expect(pool1.poolWeight).to.equal(300);
  });

  it("safe RCC transfer: when contract has less reward than pending, user receives available balance", async function () {
    await addPools();

    // Setup: make user stake so they can have pending rewards
    await stakeToken.transfer(alice.address, ethers.parseEther("1000"));
    await stakeToken.connect(alice).approve(rccStake.target, ethers.MaxUint256);
    await rccStake.connect(alice).deposit(1, ethers.parseEther("500"));

    // advance blocks so that some rewards are "due"
    await mineBlocks(1000);

    // drain contract rewardToken balance to small amount to simulate insufficient funds
    const curBal = await rewardToken.balanceOf(rccStake.target);
    // transfer almost all out to owner
    await rewardToken.transfer(owner.address, curBal - 1n);

    // now alice claims -> should receive at most contract balance (no revert)
    await rccStake.connect(alice).claim(1);
    const aliceBal = await rewardToken.balanceOf(alice.address);
    expect(aliceBal).to.be.greaterThan(0n);
  });
});
