// SPDX-License-Identifier: MIT
// Contract standard implementation by Masayoshi Kobayashi

pragma solidity ^0.8.18;

// Ownable contract implementation
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

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// BTS20 Token Contract
contract BTS20 is Ownable {
    // Private variables to store token information
    string private _tokenName;
    string private _tokenSymbol;
    uint8 private _tokenDecimals;
    uint256 private _tokenTotalSupply;

    // Mapping to track balances of token holders
    mapping(address => uint256) private _balances;
    
    // Mapping to track approved allowances for spending tokens
    mapping(address => mapping(address => uint256)) private _allowances;

    // Events to emit when transfers or approvals occur
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Constructor to initialize token details and assign initial supply
    constructor(string memory name, string memory symbol, uint8 decimals, uint256 initialSupply) {
        _tokenName = name;
        _tokenSymbol = symbol;
        _tokenDecimals = decimals;
        _tokenTotalSupply = initialSupply * 10 ** uint256(decimals);
        _balances[msg.sender] = _tokenTotalSupply;
    }

    // Getter functions for token information
    function getTokenName() external view returns (string memory) {
        return _tokenName;
    }

    function getTokenSymbol() external view returns (string memory) {
        return _tokenSymbol;
    }

    function getTokenDecimals() external view returns (uint8) {
        return _tokenDecimals;
    }

    function getTokenTotalSupply() external view returns (uint256) {
        return _tokenTotalSupply;
    }

    // Function to retrieve balance of a token holder
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    // Function to transfer tokens to another address
    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(recipient != address(0), "BTS20: transfer to the zero address");
        require(_balances[msg.sender] >= amount, "BTS20: insufficient balance");

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // Function to approve a spender to spend a certain amount of tokens on behalf of the caller
    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Function to transfer tokens from one address to another with allowance
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(sender != address(0), "BTS20: transfer from the zero address");
        require(recipient != address(0), "BTS20: transfer to the zero address");
        require(_balances[sender] >= amount, "BTS20: insufficient balance");
        require(_allowances[sender][msg.sender] >= amount, "BTS20: allowance exceeded");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Function to increase the allowance for a spender
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _allowances[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    // Function to decrease the allowance for a spender
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "BTS20: decreased allowance below zero");

        _allowances[msg.sender][spender] = currentAllowance - subtractedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }
}
