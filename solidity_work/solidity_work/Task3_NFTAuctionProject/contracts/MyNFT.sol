// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {
    uint256 public tokenIdCounter;

    constructor() ERC721("MyNFT", "MNFT") Ownable(msg.sender){}

    /// @notice 铸造 NFT
    function mint(address to) external onlyOwner {
        tokenIdCounter++;
        _safeMint(to, tokenIdCounter);
    }
}
