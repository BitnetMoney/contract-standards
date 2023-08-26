// SPDX-License-Identifier: MIT
// Contract standard implementation by Masayoshi Kobayashi

pragma solidity ^0.8.18;

contract BTS21 {
    // Token information
    string private _tokenName;
    string private _tokenSymbol;
    uint8 private _tokenDecimals;
    uint256 private _tokenTotalSupply;

    // Account balances and allowances
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Mapping to track frozen accounts
    mapping(address => bool) private _frozenAccounts; // Mapping for frozen accounts

    // Mapping to track oracle addresses
    mapping(address => bool) private _oracles; // Mapping for oracles

    // Oracle price variable
    uint256 public oraclePrice; // Oracle price variable

    address private _owner; // Owner's address

    bool private _notEntered; // Variable to prevent reentrant calls

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event FrozenAccount(address indexed account, bool isFrozen); // Event for frozen account state change
    event OracleAdded(address indexed oracle); // Event for oracle addition
    event OracleRemoved(address indexed oracle); // Event for oracle removal

    // Modifier for only the owner
    modifier onlyOwner() {
        require(isOwner(), "BTS21: caller is not the owner");
        _;
    }

    // Modifier for non-reentrant functions
    modifier nonReentrant() {
        require(_notEntered, "BTS21: reentrant call");
        _notEntered = false;
        _;
        _notEntered = true;
    }

    // Constructor to initialize token details
    constructor(string memory name, string memory symbol, uint8 decimals, uint256 initialSupply) {
        _tokenName = name;
        _tokenSymbol = symbol;
        _tokenDecimals = decimals;
        _tokenTotalSupply = initialSupply * 10 ** uint256(decimals);
        _balances[msg.sender] = _tokenTotalSupply;
        _owner = msg.sender;
        _notEntered = true;
    }

    // Getter function for contract owner
    function owner() public view returns (address) {
        return _owner;
    }

    // Check if the caller is the owner
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    // Renounce ownership of the contract
    function renounceOwnership() public onlyOwner {
        _owner = address(0);
    }

    // Transfer ownership of the contract to a new address
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "BTS21: new owner is the zero address");
        _owner = newOwner;
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

    // Function to freeze/unfreeze an account, accessible only by the owner
    function freezeAccount(address account, bool isFrozen) external onlyOwner {
        _frozenAccounts[account] = isFrozen;
        emit FrozenAccount(account, isFrozen);
    }

    // Function to set the oracle price of the token, accessible only by oracles
    function setOraclePrice(uint256 price) external onlyOracle {
        oraclePrice = price;
    }

    // Function to add an oracle, accessible only by the owner
    function addOracle(address oracle) external onlyOwner {
        require(oracle != address(0), "BTS21: oracle address cannot be zero");
        _oracles[oracle] = true;
        emit OracleAdded(oracle);
    }

    // Function to remove an oracle, accessible only by the owner
    function removeOracle(address oracle) external onlyOwner {
        _oracles[oracle] = false;
        emit OracleRemoved(oracle);
    }

    // Function to check if an address is an oracle
    function isOracle(address account) external view returns (bool) {
        return _oracles[account];
    }

    // Modifier to check if the caller is an oracle
    modifier onlyOracle() {
        require(_oracles[msg.sender], "BTS21: caller is not an oracle");
        _;
    }
}
