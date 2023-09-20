// SPDX-License-Identifier: MIT
/* Contract standard implementation by Masayoshi Kobayashi */

/* BTS20 Interface v.0.2.818 */

pragma solidity ^0.8.18;

/* Interface for BTS20, defining the necessary methods and events */
interface IBTS20 {
    /* Getter methods for token properties */
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    
    /* Token transaction methods */
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    /* Methods to manage allowances */
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
}