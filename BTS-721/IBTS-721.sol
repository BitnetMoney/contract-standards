// SPDX-License-Identifier: MIT
// Contract standard implementation by Masayoshi Kobayashi

/* @version BTS721 Interface v.0.2.821 */

pragma solidity ^0.8.21;

/* Interface for BTS721, defining the necessary methods and events */
interface IBTS721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function ownerOf(uint256 tokenId) external view returns (address);
    function balanceOf(address owner) external view returns (uint256);
    function baseURI() external view returns (string memory);
    function mint(address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    function getApproved(uint256 tokenId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}