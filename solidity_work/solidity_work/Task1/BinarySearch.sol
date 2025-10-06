// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
// 二分查找 (Binary Search)
// 题目描述：在一个有序数组中查找目标值。
contract BinarySearch {
    function binarySearch(
        uint256[] memory arr,
        uint256 target
    ) public pure returns (int256) {
        int256 left = 0;
        int256 right = int256(arr.length) - 1;
        while (left <= right) {
            int256 mid = left + (right - left) / 2;
            uint256 midVal = arr[uint256(mid)];

            if (midVal == target) {
                return mid; //找到返回下标
            } else if (midVal < target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }
        return -1; //没找到
    }
}
