// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BeggingContract {
    // 合约拥有者
    address public owner;

    // 记录每个捐赠者的捐赠金额
    mapping(address => uint256) private donations;

    // 用于排行榜
    address[] private donors;

    // 事件：记录每次捐赠
    event Donation(address indexed donor, uint256 amount);

    // 修饰符：限制只有合约拥有者可以调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    // 构造函数：部署时设置拥有者
    constructor() {
        owner = msg.sender;
    }

    // 可捐赠函数
    function donate() external payable {
        require(msg.value > 0, "Donate a positive amount");
        
        // 首次捐赠加入 donors 数组
        if (donations[msg.sender] == 0) {
            donors.push(msg.sender);
        }

        donations[msg.sender] += msg.value;

        emit Donation(msg.sender, msg.value);
    }

    // 查询某个地址的捐赠金额
    function getDonation(address _donor) external view returns (uint256) {
        return donations[_donor];
    }

    // 合约拥有者提款
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner).transfer(balance);
    }

    // 捐赠排行榜 - 返回前3名捐赠者及金额
    function topDonors() external view returns (address[3] memory topAddresses, uint256[3] memory topAmounts) {
        address[] memory sortedDonors = donors;
        uint256 n = sortedDonors.length;

        // 简单冒泡排序（适合少量数据）
        for (uint256 i = 0; i < n; i++) {
            for (uint256 j = i + 1; j < n; j++) {
                if (donations[sortedDonors[j]] > donations[sortedDonors[i]]) {
                    address temp = sortedDonors[i];
                    sortedDonors[i] = sortedDonors[j];
                    sortedDonors[j] = temp;
                }
            }
        }

        for (uint256 k = 0; k < 3; k++) {
            if (k < n) {
                topAddresses[k] = sortedDonors[k];
                topAmounts[k] = donations[sortedDonors[k]];
            } else {
                topAddresses[k] = address(0);
                topAmounts[k] = 0;
            }
        }
    }
}
