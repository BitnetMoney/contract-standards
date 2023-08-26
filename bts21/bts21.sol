// SPDX-License-Identifier: MIT
// Contract standard implementation by Masayoshi Kobayashi

pragma solidity ^0.8.18;

contract BTS21 {
    // Token metadata
    string private _tokenName;
    string private _tokenSymbol;
    uint8 private _tokenDecimals;
    uint256 private _tokenTotalSupply;

    // Balances and allowances
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Account freezing and oracle control
    mapping(address => bool) private _frozenAccounts;
    mapping(address => bool) private _oracles;

    // Oracle pricing
    uint256 public oraclePrice;

    // Contract owner and reentrancy check
    address private _owner;
    bool private _notEntered;

    // Freezing functionality flag
    bool private _freezeEnabled;

    // Events for tracking transfers, approvals, account freezing, oracle additions, and removals
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

    // Constructor to initialize the token with initial supply and optional freeze flag
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 initialSupply,
        bool freezeEnabled
    ) {
        _tokenName = name;
        _tokenSymbol = symbol;
        _tokenDecimals = decimals;
        _tokenTotalSupply = initialSupply * 10**uint256(decimals);
        _balances[msg.sender] = _tokenTotalSupply;
        _owner = msg.sender;
        _notEntered = true;
        _freezeEnabled = freezeEnabled;
    }

    // Function to determine the contract owner
    function owner() public view returns (address) {
        return _owner;
    }

    // Function to check if the caller is the owner
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    // Function to renounce ownership (making the owner address zero)
    function renounceOwnership() public onlyOwner {
        _owner = address(0);
    }

    // Function to transfer ownership to a new address
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "BTS21: new owner is the zero address");
        _owner = newOwner;
    }

    // Function to get the balance of a specific account
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    // Function to transfer tokens to a recipient
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

    // Function to approve an allowance for a spender
    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Function to transfer tokens on behalf of the owner
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

    // Function to increase allowance for a spender
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _allowances[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    // Function to decrease allowance for a spender
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "BTS21: decreased allowance below zero");

        _allowances[msg.sender][spender] = currentAllowance - subtractedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    // Function to freeze or unfreeze an account, only callable by the owner
    function freezeAccount(address account, bool isFrozen) external onlyOwner {
        require(_freezeEnabled, "BTS21: freezing is disabled");
        require(!_frozenAccounts[msg.sender] && !_frozenAccounts[account], "BTS21: cannot freeze accounts");

        _frozenAccounts[account] = isFrozen;
        emit FrozenAccount(account, isFrozen);
    }

    // Function to set oracle price, only callable by an oracle
    function setOraclePrice(uint256 price) external onlyOracle {
        oraclePrice = price;
    }

    // Function to add an oracle, only callable by the owner
    function addOracle(address oracle) external onlyOwner {
        require(oracle != address(0), "BTS21: oracle address cannot be zero");
        _oracles[oracle] = true;
        emit OracleAdded(oracle);
    }

    // Function to remove an oracle, only callable by the owner
    function removeOracle(address oracle) external onlyOwner {
        _oracles[oracle] = false;
        emit OracleRemoved(oracle);
    }

    // Function to check if an address is an oracle
    function isOracle(address account) external view returns (bool) {
        return _oracles[account];
    }

    // Modifier to restrict access to oracles
    modifier onlyOracle() {
        require(_oracles[msg.sender], "BTS21: caller is not an oracle");
        _;
    }

    // Function to enable or disable freezing functionality, only callable by the owner
    function enableFreezing(bool enabled) external onlyOwner {
        _freezeEnabled = enabled;
    }
}
