const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  // 部署 NFT 合约
  const MyNFT = await ethers.getContractFactory("MyNFT");
  const nft = await MyNFT.deploy();
  await nft.deployed();
  console.log("MyNFT deployed to:", nft.address);

  // 部署工厂合约
  const AuctionFactory = await ethers.getContractFactory("AuctionFactory");
  const factory = await AuctionFactory.deploy();
  await factory.deployed();
  console.log("AuctionFactory deployed to:", factory.address);

  // 可升级拍卖合约模板部署 (UUPS)
  const Auction = await ethers.getContractFactory("Auction");
  const auctionProxy = await upgrades.deployProxy(Auction, [], { initializer: false });
  await auctionProxy.deployed();
  console.log("Auction (proxy) deployed to:", auctionProxy.address);

  console.log("Deployment completed!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
