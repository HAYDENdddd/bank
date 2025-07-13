// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    mapping(address => uint256) public balances;
    address public owner;
    address[3] public  topUsers;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        //接收ETH
        balances[msg.sender] += msg.value;
        updateTopUsers(msg.sender);
    }

    function updateTopUsers(address user) internal {
        // 检查用户是否已经在前3名中
        bool userExists = false;
        for (uint i = 0; i < 3; i++) {
            if (topUsers[i] == user) {
                userExists = true;
                break;
            }
        }

        // 如果用户不在前3名中，尝试插入
        if (!userExists) {
            for (uint i = 0; i < 3; i++) {
                if (
                    topUsers[i] == address(0) ||
                    balances[user] > balances[topUsers[i]]
                ) {
                    // 向后移动元素
                    for (uint j = 2; j > i; j--) {
                        topUsers[j] = topUsers[j - 1];
                    }
                    topUsers[i] = user;
                    break;
                }
            }
        }
        // 如果用户已存在，重新排序
        else {
            // 简单的冒泡排序来重新排列前3名
            for (uint i = 0; i < 2; i++) {
                for (uint j = 0; j < 2 - i; j++) {
                    if (
                        topUsers[j] != address(0) &&
                        topUsers[j + 1] != address(0) &&
                        balances[topUsers[j]] < balances[topUsers[j + 1]]
                    ) {
                        address temp = topUsers[j];
                        topUsers[j] = topUsers[j + 1];
                        topUsers[j + 1] = temp;
                    }
                }
            }
        }
    }

    function getBalance() public view returns (uint256) {
        //查询合约余额
        return address(this).balance;
    }

    function withdraw() public onlyOwner {
        //合约提现
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Transfer failed");
    }

    function withdrawUser() public {
        //用户提钱
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Balance not enough");
        balances[msg.sender] = 0; 
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
    }

    // 查询用户余额
    function getUserBalance(address user) public view returns (uint256) {
        return balances[user];
    }

    // 查询前3名用户
    function getTopUsers() public view returns (address[3] memory) {
        return topUsers;
    }
}
