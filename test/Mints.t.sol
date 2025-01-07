// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Mints} from "../src/Mints.sol";

contract MintsTest is Test {
    Mints mints;

    function setUp() public {
        mints = new Mints();
    }

    function testMint() public {
        address user = address(0x123);

        // Simulate sending a transaction from the user
        vm.startPrank(user);
        
        // Call the mint function
        mints.mint();

        // Check that the event was emitted
        vm.expectEmit(true, true, false, true);
        emit Minted(user);
        
        // Call mint again to check if it emits again
        mints.mint();
        
        vm.stopPrank();
    }

    function testMintEvent() public {
        address user = address(0x123);

        // Simulate sending a transaction from the user
        vm.startPrank(user);
        
        // Expecting an event to be emitted
        vm.expectEmit(true, true, false, true);
        emit Minted(user);
        
        // Call the mint function
        mints.mint();
        
        vm.stopPrank();
    }
}
