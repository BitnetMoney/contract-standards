// SPDX-License-Identifier: MIT
// Contract standard implementation by Masayoshi Kobayashi

/**
 * @title BTS21 Token Standard
 * @dev Solidity implementation for the BTS21 token standard.
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

/**
 * @title BTS21 Token Contract
 * @dev Implementation of the BTS21 token standard.
 */
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

    // Transfer event
    event Transfer(address indexed from, address indexed to, uint256 value);
    // Approval event
    event Approval(address indexed owner, address indexed spender, uint256 value);
    // FrozenAccount event
    event FrozenAccount(address indexed account, bool isFrozen);
    // OracleAdded event
    event OracleAdded(address indexed oracle);
    // OracleRemoved event
    event OracleRemoved(address indexed oracle);
    // FreezingDisabled event
    event FreezingDisabled();

    /**
     * @dev Modifier to restrict functions to the owner only.
     */
    modifier onlyOwner() {
        require(isOwner(), "BTS21: caller is not the owner");
        _;
    }

    /**
     * @dev Modifier to prevent reentrant calls.
     */
    modifier nonReentrant() {
        require(_status != _ENTERED, "BTS21: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Constructor to initialize the token with initial values.
     * @param tokenName The name of the token.
     * @param tokenSymbol The symbol of the token.
     * @param tokenDecimals The number of decimal places for the token.
     * @param initialSupply The initial supply of tokens.
     * @param enableFreezeOnDeployment Whether freezing is enabled on deployment.
     */
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

    /**
     * @return The address of the owner.
     */
    function ownerAddress() public view override returns (address) {
        return _ownerAddress;
    }

    /**
     * @return Whether the caller is the owner.
     */
    function isOwner() public view override returns (bool) {
        return msg.sender == _ownerAddress;
    }

    /**
     * @dev Allows the owner to renounce ownership.
     */
    function renounceOwnership() public override onlyOwner {
        _ownerAddress = address(0);
    }

    /**
     * @dev Allows the owner to transfer ownership to a new address.
     * @param newOwner The address of the new owner.
     */
    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "BTS21: new owner is the zero address");
        _ownerAddress = newOwner;
    }

    /**
     * @dev Returns the balance of the specified account.
     * @param account The address of the account.
     * @return The balance of the account.
     */
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Transfers tokens to a recipient.
     * @param recipient The address of the recipient.
     * @param amount The amount of tokens to transfer.
     * @return A boolean indicating success.
     */
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

    /**
     * @dev Approves the spender to spend tokens on behalf of the owner.
     * @param spender The address of the spender.
     * @param amount The amount of tokens to approve.
     * @return A boolean indicating success.
     */
    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev Transfers tokens from a sender to a recipient.
     * @param sender The address of the sender.
     * @param recipient The address of the recipient.
     * @param amount The amount of tokens to transfer.
     * @return A boolean indicating success.
     */
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

    /**
     * @dev Increases the allowance for a spender.
     * @param spender The address of the spender.
     * @param addedValue The amount to increase the allowance by.
     * @return A boolean indicating success.
     */
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    /**
     * @dev Decreases the allowance for a spender.
     * @param spender The address of the spender.
     * @param subtractedValue The amount to decrease the allowance by.
     * @return A boolean indicating success.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    /**
     * @dev Returns the allowance of the spender for the owner.
     * @param _owner The address of the owner.
     * @param spender The address of the spender.
     * @return The allowance.
     */
    function allowance(address _owner, address spender) external view override returns (uint256) {
        return _allowances[_owner][spender];
    }

    /**
     * @dev Freezes or unfreezes an account.
     * @param account The address of the account.
     * @param isFrozen Whether to freeze or unfreeze the account.
     */
    function freezeAccount(address account, bool isFrozen) external override onlyOwner {
        require(_freezeEnabled, "BTS21: freezing is disabled");
        require(account != address(0), "BTS21: cannot freeze zero address");
        _frozenAccounts[account] = isFrozen;
        emit FrozenAccount(account, isFrozen);
    }

    /**
     * @dev Disables freezing of accounts.
     */
    function disableFreezing() external override onlyOwner {
        _freezeEnabled = false;
        emit FreezingDisabled();
    }

    /**
     * @return Whether freezing is enabled.
     */
    function isFreezingEnabled() external view override returns (bool) {
        return _freezeEnabled;
    }

    /**
     * @dev Sets the oracle price.
     * @param newPrice The new oracle price.
     */
    function setOraclePrice(uint256 newPrice) external override {
        require(_oracles[msg.sender], "BTS21: caller is not an oracle");
        oraclePrice = newPrice;
    }

    /**
     * @dev Adds a new oracle.
     * @param newOracle The address of the new oracle.
     */
    function addOracle(address newOracle) external override onlyOwner {
        require(newOracle != address(0), "BTS21: new oracle is the zero address");
        _oracles[newOracle] = true;
        emit OracleAdded(newOracle);
    }

    /**
     * @dev Removes an oracle.
     * @param oracle The address of the oracle to be removed.
     */
    function removeOracle(address oracle) external override onlyOwner {
        require(oracle != address(0), "BTS21: oracle is the zero address");
        require(_oracles[oracle], "BTS21: address is not an oracle");
        _oracles[oracle] = false;
        emit OracleRemoved(oracle);
    }

    /**
     * @return The name of the token.
     */
    function name() external view override returns (string memory) {
        return _tokenName;
    }

    /**
     * @return The symbol of the token.
     */
    function symbol() external view override returns (string memory) {
        return _tokenSymbol;
    }

    /**
     * @return The number of decimal places for the token.
     */
    function decimals() external view override returns (uint8) {
        return _tokenDecimals;
    }

    /**
     * @return The total supply of the token.
     */
    function totalSupply() external view override returns (uint256) {
        return _tokenTotalSupply;
    }

    /**
     * @dev Internal function to approve a spender.
     * @param owner The address of the owner.
     * @param spender The address of the spender.
     * @param amount The allowance amount.
     */
    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
