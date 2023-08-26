// SPDX-License-Identifier: MIT
// Contract standard implementation by Masayoshi Kobayashi

pragma solidity ^0.8.18;

contract BTS21 {
    string private _tokenName;
    string private _tokenSymbol;
    uint8 private _tokenDecimals;
    uint256 private _tokenTotalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _frozenAccounts; // Mapping for frozen accounts
    mapping(address => bool) private _oracles; // Mapping for oracles

    uint256 public oraclePrice; // Oracle price variable

    address private _owner;

    bool private _notEntered;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event FrozenAccount(address indexed account, bool isFrozen); // Event for frozen account state change
    event OracleAdded(address indexed oracle); // Event for oracle addition
    event OracleRemoved(address indexed oracle); // Event for oracle removal

    modifier onlyOwner() {
        require(isOwner(), "BTS21: caller is not the owner");
        _;
    }

    modifier nonReentrant() {
        require(_notEntered, "BTS21: reentrant call");
        _notEntered = false;
        _;
        _notEntered = true;
    }

    constructor(string memory name, string memory symbol, uint8 decimals, uint256 initialSupply) {
        _tokenName = name;
        _tokenSymbol = symbol;
        _tokenDecimals = decimals;
        _tokenTotalSupply = initialSupply * 10 ** uint256(decimals);
        _balances[msg.sender] = _tokenTotalSupply;
        _owner = msg.sender;
        _notEntered = true;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "BTS21: new owner is the zero address");
        _owner = newOwner;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

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

    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

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

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _allowances[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "BTS21: decreased allowance below zero");

        _allowances[msg.sender][spender] = currentAllowance - subtractedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function freezeAccount(address account, bool isFrozen) external onlyOwner {
        _frozenAccounts[account] = isFrozen;
        emit FrozenAccount(account, isFrozen);
    }

    function setOraclePrice(uint256 price) external onlyOracle {
        oraclePrice = price;
    }

    function addOracle(address oracle) external onlyOwner {
        require(oracle != address(0), "BTS21: oracle address cannot be zero");
        _oracles[oracle] = true;
        emit OracleAdded(oracle);
    }

    function removeOracle(address oracle) external onlyOwner {
        _oracles[oracle] = false;
        emit OracleRemoved(oracle);
    }

    function isOracle(address account) external view returns (bool) {
        return _oracles[account];
    }

    modifier onlyOracle() {
        require(_oracles[msg.sender], "BTS21: caller is not an oracle");
        _;
    }
}
