// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


// contracts to soon rely on named imports
contract Mints {
    event Minted(address indexed to);

    function mint() external {
        emit Minted(msg.sender);
    }

    function delayRelease() external {
        // Wait until initiator calla are made
        // follow thru with all commands
    }
}

// q Is it having many named imports?
// a No, it is not having any named imports yet from OZ.

// q is it compliant with upcoming ERCs like 7777 and 7807
// make adjustments and reservations for ERC 3643