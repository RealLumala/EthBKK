// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract CSAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint public reserve0;
    uint public reserve1;

    function swap() external {}
    function addLiquidity() external {}
    function removeLiquidity() external {}
}