// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Test, console2} from "forge-std/Test.sol";

import {RCCStake} from "../contracts/RCCStake.sol";
// RCC is ERC20 contract
import {RCC} from "../contracts/shared/MockRCC.sol";

contract RCCStakeTest is Test {
    RCCStake RCCStake;
    RCC RCC;

    fallback() external payable {
    }

    receive() external payable {
    }

    function setUp() public {
        RCC = new RCC();
        RCCStake = new RCCStake();
        RCCStake.initialize
        (
            RCC,
            100,
            100000000,
            3000000000000000000
        );
    }

    function test_AddPool() public {
        // Add nativeCurrency pool
        address _stTokenAddress = address(0x0);
        uint256 _poolWeight = 100;
        uint256 _minDepositAmount = 100;
        uint256 _withdrawLockedBlocks = 100;
        bool _withUpdate = true;

        RCCStake.addPool(_stTokenAddress, _poolWeight, _minDepositAmount, _withdrawLockedBlocks, _withUpdate);

        (
          address stTokenAddress, 
          uint256 poolWeight, 
          uint256 lastRewardBlock,
          uint256 accRCCPerShare,
          uint256 stTokenAmount,
          uint256 minDepositAmount, 
          uint256 withdrawLockedBlocks
        )  = RCCStake.pool(0);
        assertEq(stTokenAddress, _stTokenAddress);
        assertEq(poolWeight, _poolWeight);
        assertEq(minDepositAmount, _minDepositAmount);
        assertEq(withdrawLockedBlocks, _withdrawLockedBlocks);
        assertEq(stTokenAmount, 0);
        assertEq(lastRewardBlock, 100);
        assertEq(accRCCPerShare, 0);
    }

    function test_massUpdatePools() public {
        test_AddPool();
        RCCStake.massUpdatePools();
        (
          address stTokenAddress, 
          uint256 poolWeight, 
          uint256 lastRewardBlock,
          uint256 accRCCPerShare,
          uint256 stTokenAmount,
          uint256 minDepositAmount, 
          uint256 withdrawLockedBlocks
        )  = RCCStake.pool(0);
        assertEq(minDepositAmount, 100);
        assertEq(withdrawLockedBlocks, 100);
        assertEq(lastRewardBlock, 100);

        vm.roll(1000);
        RCCStake.massUpdatePools();
        (
          stTokenAddress, 
          poolWeight, 
          lastRewardBlock,
          accRCCPerShare,
          stTokenAmount,
          minDepositAmount, 
          withdrawLockedBlocks
        )  = RCCStake.pool(0);
        assertEq(minDepositAmount, 100);
        assertEq(withdrawLockedBlocks, 100);
        assertEq(lastRewardBlock, 1000);
    }

    function test_SetPoolWeight() public {
        test_AddPool();
        uint256 preTotalPoolWeight = RCCStake.totalPoolWeight();
        
        
        RCCStake.setPoolWeight(0, 200, false);
        (
          address stTokenAddress, 
          uint256 poolWeight, 
          uint256 lastRewardBlock,
          uint256 accRCCPerShare,
          uint256 stTokenAmount,
          uint256 minDepositAmount, 
          uint256 withdrawLockedBlocks
        )  = RCCStake.pool(0);
        uint256 totalPoolWeight = RCCStake.totalPoolWeight();
        uint256 expectedTotalPoolWeight = preTotalPoolWeight - 100 + 200;
        assertEq(poolWeight, 200);
        assertEq(totalPoolWeight, expectedTotalPoolWeight);
    }

    function test_DepositnativeCurrency() public {
        test_AddPool();
        (
          address stTokenAddress, 
          uint256 poolWeight, 
          uint256 lastRewardBlock,
          uint256 accRCCPerShare,
          uint256 stTokenAmount,
          uint256 minDepositAmount, 
          uint256 withdrawLockedBlocks
        ) = RCCStake.pool(0);
        uint256 prePoolStTokenAmount = stTokenAmount;

        (
          uint256 stAmount,
          uint256 finishedRCC,
          uint256 pendingRCC
        ) = RCCStake.user(0, address(this));
        uint256 preStAmount = stAmount;
        uint256 preFinishedRCC = finishedRCC;
        uint256 prePendingRCC = pendingRCC;

        // First deposit
        address(RCCStake).call{value: 100}(
          abi.encodeWithSignature("depositnativeCurrency()")
        );
        (
          stTokenAddress, 
          poolWeight, 
          lastRewardBlock,
          accRCCPerShare,
          stTokenAmount,
          minDepositAmount, 
          withdrawLockedBlocks
        )  = RCCStake.pool(0);

        (
          stAmount,
          finishedRCC,
          pendingRCC
        ) = RCCStake.user(0, address(this));

        uint256 expectedStAmount = preStAmount + 100;
        uint256 expectedFinishedRCC = preFinishedRCC;
        uint256 expectedTotoalStTokenAmount = prePoolStTokenAmount + 100;

        assertEq(stAmount, expectedStAmount);
        assertEq(finishedRCC, expectedFinishedRCC);
        assertEq(stTokenAmount, expectedTotoalStTokenAmount);

        // more deposit
        address(RCCStake).call{value: 200 ether}(
          abi.encodeWithSignature("depositnativeCurrency()")
        );

        vm.roll(2000000);
        RCCStake.unstake(0, 100);
        address(RCCStake).call{value: 300 ether}(
          abi.encodeWithSignature("depositnativeCurrency()")
        );

        vm.roll(3000000);
        RCCStake.unstake(0, 100);
        address(RCCStake).call{value: 400 ether}(
          abi.encodeWithSignature("depositnativeCurrency()")
        );

        vm.roll(4000000);
        RCCStake.unstake(0, 100);
        address(RCCStake).call{value: 500 ether}(
          abi.encodeWithSignature("depositnativeCurrency()")
        );

        vm.roll(5000000);
        RCCStake.unstake(0, 100);
        address(RCCStake).call{value: 600 ether}(
          abi.encodeWithSignature("depositnativeCurrency()")
        );

        vm.roll(6000000);
        RCCStake.unstake(0, 100);
        address(RCCStake).call{value: 700 ether}(
          abi.encodeWithSignature("depositnativeCurrency()")
        );

        RCCStake.withdraw(0);
    }

    function test_Unstake() public {
        test_DepositnativeCurrency();
        
        vm.roll(1000);
        RCCStake.unstake(0, 100);

        (
          uint256 stAmount,
          uint256 finishedRCC,
          uint256 pendingRCC
        ) = RCCStake.user(0, address(this));
        assertEq(stAmount, 0);
        assertEq(finishedRCC, 0);
        assertGt(pendingRCC, 0);

        (
          address stTokenAddress, 
          uint256 poolWeight, 
          uint256 lastRewardBlock,
          uint256 accRCCPerShare,
          uint256 stTokenAmount,
          uint256 minDepositAmount, 
          uint256 withdrawLockedBlocks
        ) = RCCStake.pool(0);

        uint256 expectStTokenAmount = 0;
        assertEq(stTokenAmount, expectStTokenAmount);
    }

    function test_Withdraw() public {
        test_Unstake();
        uint256 preContractBalance = address(RCCStake).balance;
        uint256 preUserBalance = address(this).balance;
      
        vm.roll(10000);
        RCCStake.withdraw(0);

        uint256 postContractBalance = address(RCCStake).balance;
        uint256 postUserBalance = address(this).balance;
        assertLt(postContractBalance, preContractBalance);
        assertGt(postUserBalance, preUserBalance);
    }

    function test_ClaimAfterDeposit() public {
        test_DepositnativeCurrency();
        RCC.transfer(address(RCCStake), 100000000000);
        uint256 preUserRCCBalance = RCC.balanceOf(address(this));

        vm.roll(10000);
        RCCStake.claim(0);

        uint256 postUserRCCBalance = RCC.balanceOf(address(this));
        assertGt(postUserRCCBalance, preUserRCCBalance);
    }

    function test_ClaimAfterUnstake() public {
        test_Unstake();
        RCC.transfer(address(RCCStake), 100000000000);
        uint256 preUserRCCBalance = RCC.balanceOf(address(this));

        vm.roll(10000);
        RCCStake.claim(0);

        uint256 postUserRCCBalance = RCC.balanceOf(address(this));
        assertGt(postUserRCCBalance, preUserRCCBalance);
    }

    function test_ClaimAfterWithdraw() public {
        test_Withdraw();
        RCC.transfer(address(RCCStake), 100000000000);
        uint256 preUserRCCBalance = RCC.balanceOf(address(this));

        vm.roll(10000);
        RCCStake.claim(0);

        uint256 postUserRCCBalance = RCC.balanceOf(address(this));
        assertGt(postUserRCCBalance, preUserRCCBalance);
    }

    function addPool(uint256 index, address stTokenAddress) public {
        address _stTokenAddress = stTokenAddress;
        uint256 _poolWeight = 100;
        uint256 _minDepositAmount = 100;
        uint256 _withdrawLockedBlocks = 100;
        bool _withUpdate = true;

        RCCStake.addPool(_stTokenAddress, _poolWeight, _minDepositAmount, _withdrawLockedBlocks, _withUpdate);
    }
}