// SPDX-License-Identifier: MIT
// Contract standard implementation by Masayoshi Kobayashi

/* @version BTS21 Token Standard v.0.2.821 */

pragma solidity ^0.8.21;

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

contract BTS21 is IBTS21 {
    string private _tokenName;
    string private _tokenSymbol;
    uint8 private _tokenDecimals;
    uint256 private _tokenTotalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _frozenAccounts;
    mapping(address => bool) private _oracles;

    uint256 public oraclePrice;
    address private _ownerAddress;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    bool private _freezeEnabled;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event FrozenAccount(address indexed account, bool isFrozen);
    event OracleAdded(address indexed oracle);
    event OracleRemoved(address indexed oracle);
    event FreezingDisabled();

    modifier onlyOwner() {
        require(isOwner(), "BTS21: caller is not the owner");
        _;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "BTS21: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

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
        _ownerAddress = msg.sender;
        _status = _NOT_ENTERED;
        _freezeEnabled = enableFreezeOnDeployment;
    }

    function ownerAddress() public view override returns (address) {
        return _ownerAddress;
    }

    function isOwner() public view override returns (bool) {
        return msg.sender == _ownerAddress;
    }

    function renounceOwnership() public override onlyOwner {
        _ownerAddress = address(0);
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "BTS21: new owner is the zero address");
        _ownerAddress = newOwner;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override nonReentrant returns (bool) {
        require(!_frozenAccounts[msg.sender], "BTS21: sender account is frozen");
        require(!_frozenAccounts[recipient], "BTS21: recipient account is frozen");
        require(recipient != address(0), "BTS21: transfer to the zero address");
        require(_balances[msg.sender] >= amount, "BTS21: insufficient balance");

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override nonReentrant returns (bool) {
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
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    function allowance(address _owner, address spender) external view override returns (uint256) {
        return _allowances[_owner][spender];
    }

    function freezeAccount(address account, bool isFrozen) external override onlyOwner {
        require(_freezeEnabled, "BTS21: freezing is disabled");
        require(account != address(0), "BTS21: cannot freeze zero address");
        _frozenAccounts[account] = isFrozen;
        emit FrozenAccount(account, isFrozen);
    }

    function disableFreezing() external override onlyOwner {
        _freezeEnabled = false;
        emit FreezingDisabled();
    }

    function isFreezingEnabled() external view override returns (bool) {
        return _freezeEnabled;
    }

    function setOraclePrice(uint256 newPrice) external override {
        require(_oracles[msg.sender], "BTS21: caller is not an oracle");
        oraclePrice = newPrice;
    }

    function addOracle(address newOracle) external override onlyOwner {
        require(newOracle != address(0), "BTS21: new oracle is the zero address");
        _oracles[newOracle] = true;
        emit OracleAdded(newOracle);
    }

    function removeOracle(address oracle) external override onlyOwner {
        require(oracle != address(0), "BTS21: oracle is the zero address");
        require(_oracles[oracle], "BTS21: address is not an oracle");
        _oracles[oracle] = false;
        emit OracleRemoved(oracle);
    }

    function name() external view override returns (string memory) {
        return _tokenName;
    }

    function symbol() external view override returns (string memory) {
        return _tokenSymbol;
    }

    function decimals() external view override returns (uint8) {
        return _tokenDecimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tokenTotalSupply;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}