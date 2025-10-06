// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPriceFeed {
    /// @notice 返回 token 的美元价格（18 小数）
    function getLatestPrice(address token) external view returns (uint256);
}
