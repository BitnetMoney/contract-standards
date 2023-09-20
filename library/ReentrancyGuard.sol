// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ReentrancyGuard {
    bool private _notEntered;

    constructor () {
        _notEntered = true;
    }

    // Modifier to prevent reentrant calls
    modifier nonReentrant() {
        // Check if the function is not currently being executed
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Set the status to indicate that the function is currently being executed
        _notEntered = false;
        
        // Execute the function
        _;

        // Reset the status to indicate that the function has completed
        _notEntered = true;
    }
}
