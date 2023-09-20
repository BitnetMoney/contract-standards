// SPDX-License-Identifier: MIT
// Contract standard implementation by Masayoshi Kobayashi

/**
 * @title BTS21 Token Interface
 * @dev Interface for the BTS21 token standard.
 * @notice This interface defines the functions and events required by the BTS21 token standard.
 * @notice BTS21 Token Standard v.0.2.818
 */

pragma solidity ^0.8.18;

// Interface for the BTS21 token
interface IBTS21 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function ownerAddress() external view returns (address);
    function isOwner() external view returns (bool);
    function renounceOwnership() external;
    function transferOwnership(address newOwner) external;
    function freezeAccount(address account, bool isFrozen) external;
    function disableFreezing() external;
    function isFreezingEnabled() external view returns (bool);
    function setOraclePrice(uint256 newPrice) external;
    function addOracle(address newOracle) external;
    function removeOracle(address oracle) external;
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}