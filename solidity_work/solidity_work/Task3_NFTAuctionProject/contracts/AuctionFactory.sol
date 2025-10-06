// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "./Auction.sol";

contract AuctionFactory {
    address public implementation; // Auction 实现合约地址
    address[] public allAuctions;

    event AuctionCreated(address auction, address seller);

    constructor(address _implementation) {
        implementation = _implementation;
    }

    function createAuction(
        address nft,
        uint256 tokenId,
        address erc20,
        address priceFeed
    ) external {
        // 构造初始化数据
        bytes memory data = abi.encodeWithSelector(
            Auction.initialize.selector,
            nft,
            tokenId,
            erc20,
            priceFeed,
            msg.sender
        );

        // 部署可升级 Proxy
        ERC1967Proxy proxy = new ERC1967Proxy(implementation, data);
        allAuctions.push(address(proxy));

        emit AuctionCreated(address(proxy), msg.sender);
    }

    function getAllAuctions() external view returns (address[] memory) {
        return allAuctions;
    }
}
