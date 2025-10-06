const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("NFT Auction Market", function () {
  let nft, factory, auction, owner, bidder1, bidder2, erc20, priceFeed;

  beforeEach(async function () {
    [owner, bidder1, bidder2] = await ethers.getSigners();

    // 部署 NFT
    const MyNFT = await ethers.getContractFactory("MyNFT");
    nft = await MyNFT.deploy();
    await nft.deployed();

    // 铸造 NFT 给 owner
    await nft.mint(owner.address);

    // 部署 ERC20 模拟代币
    const ERC20Mock = await ethers.getContractFactory("ERC20Mock");
    erc20 = await ERC20Mock.deploy("MockUSD", "MUSD", owner.address, ethers.utils.parseEther("10000"));
    await erc20.deployed();

    // 部署价格预言机模拟
    const PriceFeedMock = await ethers.getContractFactory("PriceFeedMock");
    priceFeed = await PriceFeedMock.deploy();
    await priceFeed.deployed();

    // 部署拍卖工厂
    const AuctionFactory = await ethers.getContractFactory("AuctionFactory");
    factory = await AuctionFactory.deploy();
    await factory.deployed();

    // 使用工厂创建拍卖
    await factory.createAuction(nft.address, 1, erc20.address, priceFeed.address);
    const auctionAddress = await factory.getAllAuctions();
    const Auction = await ethers.getContractFactory("Auction");
    auction = Auction.attach(auctionAddress[0]);
  });

  it("should place bids and end auction", async function () {
    // 给 bidder1 代币
    await erc20.transfer(bidder1.address, ethers.utils.parseEther("1000"));
    await erc20.connect(bidder1).approve(auction.address, ethers.utils.parseEther("1000"));

    // bidder1 出价
    await auction.connect(bidder1).placeBid(ethers.utils.parseEther("100"));

    // 检查最高出价
    const highestBid = await auction.highestBid();
    expect(highestBid.bidder).to.equal(bidder1.address);

    // 出价更高的 bidder2
    await erc20.transfer(bidder2.address, ethers.utils.parseEther("2000"));
    await erc20.connect(bidder2).approve(auction.address, ethers.utils.parseEther("2000"));
    await auction.connect(bi
