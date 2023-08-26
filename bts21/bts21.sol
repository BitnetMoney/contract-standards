// SPDX-License-Identifier: MIT
// Contract standard implementation by Masayoshi Kobayashi

pragma solidity ^0.8.18;

contract BTS21 {
    // Token metadata
    string private _tokenName;
    string private _tokenSymbol;
    uint8 private _tokenDecimals;
    uint256 private _tokenTotalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _frozenAccounts;
    mapping(address => bool) private _oracles;

    uint256 public oraclePrice;
    address private _owner;
    bool private _notEntered;
    bool private _freezeEnabled;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event FrozenAccount(address indexed account, bool isFrozen);
    event OracleAdded(address indexed oracle);
    event OracleRemoved(address indexed oracle);

    // Modifiers
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

    // Constructor
    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals,
        uint256 initialSupply,
        bool enableFreezeOnDeployment
    ) {
        _tokenName = tokenName;
        _tokenSymbol = tokenSymbol;
        _tokenDecimals = tokenDecimals;
        _tokenTotalSupply = initialSupply * 10 ** uint256(tokenDecimals);
        _balances[msg.sender] = _tokenTotalSupply;
        _owner = msg.sender;
        _notEntered = true;
        _freezeEnabled = enableFreezeOnDeployment;
    }

    // Ownership functions
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

    // Token functions
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

    // Freezing functions
    function freezeAccount(address account, bool isFrozen) external onlyOwner {
        require(_freezeEnabled, "BTS21: freezing is disabled");
        require(account != address(0), "BTS21: cannot freeze zero address");
        
        _frozenAccounts[account] = isFrozen;
        emit FrozenAccount(account, isFrozen);
    }

    // Oracle functions
    function setOraclePrice(uint256 newPrice) external {
        require(_oracles[msg.sender], "BTS21: caller is not an oracle");
        oraclePrice = newPrice;
    }

    function addOracle(address newOracle) external onlyOwner {
        require(newOracle != address(0), "BTS21: new oracle is the zero address");
        _oracles[newOracle] = true;
        emit OracleAdded(newOracle);
    }

    function removeOracle(address oracle) external onlyOwner {
        require(oracle != address(0), "BTS21: oracle is the zero address");
        require(_oracles[oracle], "BTS21: address is not an oracle");

        _oracles[oracle] = false;
        emit OracleRemoved(oracle);
    }

    // Token metadata functions
    function name() public view returns (string memory) {
        return _tokenName;
    }

    function symbol() public view returns (string memory) {
        return _tokenSymbol;
    }

    function decimals() public view returns (uint8) {
        return _tokenDecimals;
    }

    function totalSupply() public view returns (uint256) {
        return _tokenTotalSupply;
    }
}
