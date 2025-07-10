// SPDX-License-Identifier: MIT                    
pragma solidity ^0.8.0;                           

// 编写一个 Bank 合约，实现功能：
// 可以通过 Metamask 等钱包直接给 Bank 合约地址存款
// 在 Bank 合约记录每个地址的存款金额
// 编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
// 用数组记录存款金额的前 3 名用户
// 请提交完成项目代码或 github 仓库地址。

contract Bank {
        mapping (address => uint256)public balances;
        address public owner;
        address[3] public topUsers;
        uint[3] public topAmounts;

    constructor(){
        owner = msg.sender;
        }

    receive() external  payable {
        balances[msg.sender] +=msg.value;
        updateTopUsers(msg.sender);
    }

    function withdraw() public  {
        require(msg.sender == owner,"not the owner"); //提示不是管理员
        payable(owner).transfer(address(this).balance);
    }

    function updateTopUsers(address user) internal {
    uint256 amount = balances[user];

    for (uint i = 0; i < 3; i++) {
        if (topUsers[i] == user) {
            topAmounts[i] = amount;
            return;
        }
    }

    for (uint i = 0; i < 3; i++) {
        if (amount > topAmounts[i]) {
            for (uint j = 2; j > i; j--) {
                topUsers[j] = topUsers[j - 1];
                topAmounts[j] = topAmounts[j - 1];
            }
            topUsers[i] = user;
            topAmounts[i] = amount;
            break;
        }
    }
}

}
