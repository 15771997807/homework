// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

// 合并两个有序数组 (Merge Sorted Array)
// 题目描述：将两个有序数组合并为一个有序数组。

contract MergeSortedArray {
    function mergeSorted(uint256[]memory arr1,uint256[]memory arr2)public pure  returns(uint256[]memory){
        uint256 n1=arr1.length;
        uint256 n2=arr2.length;
        uint256[]memory merged=new uint256[](n1+n2);

        uint256 i=0;
        uint256 j=0;
        uint256 k=0;

while (i<n1&&j<n2){
    if (arr1[i]<=arr2[j]){
        merged[k]=arr1[i];
        i++;
    }else{
        merged[k]=arr2[j];
        j++;
    }
    k++;
}
//如果arr2有剩余元素
while(j<n2){
    merged[k]=arr2[j];
    j++;
    k++;
}
return merged;
    }

}