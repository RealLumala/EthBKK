// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Mints} from "../src/Mints.sol";

contract MintsScript is Script {
    Mints public mints;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        mints = new Mints();

        vm.stopBroadcast();
    }
}
