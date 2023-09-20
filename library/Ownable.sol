// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// This is a basic Ownable contract that allows transferring ownership.
contract Ownable {
    // The address of the current owner.
    address private _owner;

    // An event to log ownership transfers.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Constructor to set the initial owner to the contract deployer.
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    // Function to get the address of the current owner.
    function owner() public view returns (address) {
        return _owner;
    }
}
