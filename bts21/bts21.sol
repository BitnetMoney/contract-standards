// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Import Ownable and ReentrancyGuard from the specified repositories
import "https://raw.githubusercontent.com/BitnetMoney/contract-standards/main/library/Ownable.sol";
import "https://github.com/BitnetMoney/contract-standards/library/ReentrancyGuard.sol";

contract BTS21 is Ownable, ReentrancyGuard {
    string private _tokenName;
    string private _tokenSymbol;
    uint8 private _tokenDecimals;
    uint256 private _tokenTotalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _frozenAccounts; // Mapping for frozen accounts

    uint256 public oraclePrice; // Oracle price variable

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event FrozenAccount(address indexed account, bool isFrozen); // Event for frozen account state change

    constructor(string memory name, string memory symbol, uint8 decimals, uint256 initialSupply) {
        _tokenName = name;
        _tokenSymbol = symbol;
        _tokenDecimals = decimals;
        _tokenTotalSupply = initialSupply * 10 ** uint256(decimals);
        _balances[msg.sender] = _tokenTotalSupply;
    }

    // Getter functions for token details
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

    // Balance of an account
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    // Transfer function with reentrancy protection
    function transfer(address recipient, uint256 amount) external nonReentrant returns (bool) {
        require(!_frozenAccounts[msg.sender], "BTS21: sender account is frozen");
        require(!_frozenAccounts[recipient], "BTS21: recipient account is frozen");
        require(recipient != address(0), "BTS21: transfer to the zero address");
        require(_balances[msg.sender] >= amount, "BTS21: insufficient balance");

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // Approve allowance for spender
    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Transfer from approved allowance with reentrancy protection
    function transferFrom(address sender, address recipient, uint256 amount) external nonReentrant returns (bool) {
        require(!_frozenAccounts[sender], "BTS21: sender account is frozen");
        require(!_frozenAccounts[recipient], "BTS21: recipient account is frozen");
        require(sender != address(0), "BTS21: transfer from the zero address");
        require(recipient != address(0), "BTS21: transfer to the zero address");
        require(_balances[sender] >= amount, "BTS21: insufficient balance");
        require(_allowances[sender][msg.sender] >= amount, "BTS21: allowance exceeded");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Increase allowance for spender
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _allowances[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    // Decrease allowance for spender
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "BTS21: decreased allowance below zero");

        _allowances[msg.sender][spender] = currentAllowance - subtractedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    // Function to freeze/unfreeze an account
    function freezeAccount(address account, bool isFrozen) external onlyOwner {
        _frozenAccounts[account] = isFrozen;
        emit FrozenAccount(account, isFrozen);
    }

    // Function to set the oracle price of the token
    function setOraclePrice(uint256 price) external onlyOwner {
        oraclePrice = price;
    }

    // Transfer ownership to another address
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "BTS21: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    // Renounce ownership
    function renounceOwnership() external onlyOwner {
        _renounceOwnership();
    }
}
