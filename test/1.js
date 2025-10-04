// test/1.js
import { expect } from "chai";
import pkg from "hardhat";
const { ethers, deployments } = pkg;

describe("NFT Auction Flow", function () {

  it("Should deploy contracts, mint NFTs, create auction, bid and end auction", async function () {

    // 部署所有脚本
    await deployments.fixture("deployNftAuction"); 
    const NftAuctionProxy = await deployments.get("NftAuctionProxy");

    const [signer, buyer] = await ethers.getSigners();

    // 1️⃣ 部署 ERC721
    const TestERC721 = await ethers.getContractFactory("TestERC721");
    const testERC721 = await TestERC721.deploy();
    await testERC721.waitForDeployment();
    const testERC721Address = await testERC721.getAddress();
    console.log("TestERC721 deployed to:", testERC721Address);

    // Mint 10 个 NFT 给 signer
    for (let i = 0; i < 10; i++) {
      await testERC721.mint(signer.address, i + 1);
    }

    const tokenId = 1;

    // 2️⃣ 获取拍卖合约实例
    const nftAuction = await ethers.getContractAt(
      "NftAuction",
      NftAuctionProxy.address
    );

    // 创建拍卖
    await nftAuction.createAuction(
      100 * 1000,  // 起拍价
      ethers.parseEther("0.000000000000001"), // 最小加价
      testERC721Address,
      tokenId
    );

    const auction = await nftAuction.auctions(0);
    console.log("创建拍卖成功:", auction);

    // 3️⃣ 购买者参与拍卖
    await nftAuction.connect(buyer).placeBid(0, {
      value: ethers.parseEther("0.000000000000002")
    });

    // 等待 10 秒（模拟拍卖结束）
    await new Promise(resolve => setTimeout(resolve, 10000));

    // 结束拍卖
    await nftAuction.endAuction(0);

    // 4️⃣ 验证拍卖结果
    const auctionResult = await nftAuction.auctions(0);
    console.log("拍卖结果:", auctionResult);

    expect(auctionResult.highestBidder).to.equal(buyer.address);
    expect(auctionResult.highestBid).to.equal(
      ethers.parseEther("0.000000000000002")
    );

    // 5️⃣ 验证 NFT 新归属
    const newOwner = await testERC721.ownerOf(tokenId);
    console.log("NFT新归属:", newOwner);
    expect(newOwner).to.equal(buyer.address);
  });
});
