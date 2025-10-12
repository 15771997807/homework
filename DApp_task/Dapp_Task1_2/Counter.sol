// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Counter {
    uint256 public count;

    // 读取计数器
    function getCount() public view returns (uint256) {
        return count;
    }

    // 增加计数器
    function increment() public {
        count += 1;
    }
}
