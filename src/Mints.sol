// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


// contracts to soon rely on named imports
contract Mints {
    event Minted(address indexed to);

    function mint() external {
        emit Minted(msg.sender);
    }
}

// q Is it having many named imports?
// a No, it is not having any named imports yet from OZ.
