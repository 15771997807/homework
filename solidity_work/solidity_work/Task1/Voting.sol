// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

//创建一个名为Voting的合约，包含以下功能：
// 一个mapping来存储候选人的得票数
// 一个vote函数，允许用户投票给某个候选人
// 一个getVotes函数，返回某个候选人的得票数
// 一个resetVotes函数，重置所有候选人的得票数

contract Voting {
    mapping(string => uint256) public votes; // 存储候选人的得票数
    string[] public candidates; // 存储候选人列表

    //管理员地址
    address public owner;

    constructor(string[] memory _candidates) {
        owner = msg.sender;
        candidates = _candidates;
    }
    //投票给某个候选人
    function vote(string memory candidate) public {
        //校验（候选人需要必须存在）
        require(candidateExists(candidate), "Candidate does not exist");
        votes[candidate] += 1;
    }
    //获取候选人票数
    function getVotes(string memory candidate) public view returns (uint256) {
        require(candidateExists(candidate), "Candidate does not exist");
        return votes[candidate];
    }
    //判断候选人是否存在
    function candidateExists(
        string memory candidate
    ) internal view returns (bool) {
        for (uint i = 0; i < candidates.length; i++) {
            if (
                keccak256(abi.encodePacked(candidates[i])) ==
                keccak256(abi.encodePacked(candidate))
            ) {
                return true;
            }
        }
        return false;
    }
    function getCandidates() public view returns (string[] memory) {
        return candidates;
    }
}
