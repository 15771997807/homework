// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface IPriceFeed {
    function getLatestPrice(address token) external view returns (uint256);
}

contract Auction is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    struct Bid {
        address bidder;
        uint256 amount;
    }

    IERC721Upgradeable public nft;
    uint256 public tokenId;
    address public seller;
    IERC20Upgradeable public erc20;
    IPriceFeed public priceFeed;

    uint256 public highestBidUSD;
    Bid public highestBid;
    bool public ended;

    event BidPlaced(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(
        address _nft,
        uint256 _tokenId,
        address _erc20,
        address _priceFeed,
        address _seller
    ) public initializer {
        __Ownable_init(msg.sender); // 初始化 OwnableUpgradeable

        nft = IERC721Upgradeable(_nft);
        tokenId = _tokenId;
        erc20 = IERC20Upgradeable(_erc20);
        priceFeed = IPriceFeed(_priceFeed);
        seller = _seller;
        ended = false;

        // 将 NFT 转入拍卖合约
        nft.transferFrom(seller, address(this), tokenId);
    }

    function placeBid(uint256 amount) external {
        require(!ended, "Auction ended");

        uint256 usdPrice = (amount * priceFeed.getLatestPrice(address(erc20))) / 1e18;
        require(usdPrice > highestBidUSD, "Bid too low");

        // 返还上一个出价者
        if (highestBid.amount > 0) {
            erc20.transfer(highestBid.bidder, highestBid.amount);
        }

        erc20.transferFrom(msg.sender, address(this), amount);

        highestBid = Bid(msg.sender, amount);
        highestBidUSD = usdPrice;

        emit BidPlaced(msg.sender, amount);
    }

    function endAuction() external onlyOwner {
        require(!ended, "Auction already ended");
        ended = true;

        nft.transferFrom(address(this), highestBid.bidder, tokenId);
        erc20.transfer(seller, highestBid.amount);

        emit AuctionEnded(highestBid.bidder, highestBid.amount);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
