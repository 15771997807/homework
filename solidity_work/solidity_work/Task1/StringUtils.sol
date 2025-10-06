// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

// 反转字符串 (Reverse String)
// 题目描述：反转一个字符串。输入 "abcde"，输出 "edcba"

contract StringUtils {

    //反转字符串
    function reverseString(string memory str) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        uint256 n = strBytes.length;
        for (uint256 i = 0; i < n/2 ; i++) {
            //交换前后字符串
            bytes1 temp = strBytes[i];
            strBytes[i] = strBytes[n - i - 1];
            strBytes[n - i - 1] = temp;
        }
        return string(strBytes);
    }


}