// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function _beforeTokenTransfer(address /*from*/, address /*to*/, uint256 /*tokenId*/, uint256 /*amount*/) internal virtual {
        // Empty function for potential override in derived contracts
    }
}

