// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract IERC20 {
    function transfer(address to, uint value) virtual external returns (bool);
    function transferFrom(address from, address to, uint value) external virtual returns (bool);
    function approve(address spender, uint value) external virtual returns (bool);
    function allowance(address owner, address spender) external virtual view returns (uint);
    function balanceOf(address owner) external virtual view returns (uint);
    function totalSupply() external virtual view returns (uint);
}


// // check for consistency with main contracts
// contract IERC20Detailed is IERC20 {
//     string public name;
//     string public symbol;
//     uint8 public decimals;

//     constructor(string memory name_, string memory symbol_, uint8 decimals_) {
//         name = name_;
//         symbol = symbol_;
//         decimals = decimals_;
//     }
// }


// // check for addendum quote contracts