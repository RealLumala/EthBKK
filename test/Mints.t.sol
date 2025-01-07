// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Mints} from "../src/Mints.sol";

contract MintsTest is Test {
    Mints public mints;

    function setUp() public {
        mints = new Mints();
        mints.setNumber(0);
    }

    function test_Increment() public {
        mints.increment();
        assertEq(mints.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        mints.setNumber(x);
        assertEq(mints.number(), x);
    }
}
