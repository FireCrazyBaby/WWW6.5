// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_BaseDepositBox.sol";

contract BasicDepositBox is BaseDepositBox {
    
    // 【修复点】：严格对齐接口里的 pure 和 returns (string memory)
    function getBoxType() external pure override returns (string memory) {
        return "Basic";
    }
}
