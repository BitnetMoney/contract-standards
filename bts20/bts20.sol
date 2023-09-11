// SPDX-License-Identifier: MIT
/* Contract standard implementation by Masayoshi Kobayashi */

pragma solidity ^0.8.21;

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

/* BTS20 contract implementation */
contract BTS20 is IBTS20 {
    /* State variables */
    address private _owner;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    /* Mappings for account balances and allowances */
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    /* Events */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /* Contract constructor */
    constructor(
        string memory tokenName, 
        string memory tokenSymbol, 
        uint8 tokenDecimals, 
        uint256 initialSupply
    ) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = tokenDecimals;
        _totalSupply = initialSupply * 10 ** uint256(tokenDecimals);
        _balances[msg.sender] = _totalSupply;
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /* Modifier to allow only the owner to execute certain functions */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /* Check if the sender is the owner */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /* Allows the current owner to relinquish control */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /* Allows the current owner to transfer ownership */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /* Implementation of IBTS20 interface */

    /* Getters for token properties */
    function name() external view override returns (string memory) {
        return _name;
    }
    function symbol() external view override returns (string memory) {
        return _symbol;
    }
    function decimals() external view override returns (uint8) {
        return _decimals;
    }
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    /* Transfer tokens to a recipient */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(recipient != address(0), "BTS20: transfer to the zero address");
        require(_balances[msg.sender] >= amount, "BTS20: insufficient balance");

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    /* Approve an allowance for a spender */
    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /* Transfer tokens from one account to another */
    function transferFrom(
        address sender, 
        address recipient, 
        uint256 amount
    ) external override returns (bool) {
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

    /* Increase the allowance for a spender */
    function increaseAllowance(address spender, uint256 addedValue) external override returns (bool) {
        _allowances[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    /* Decrease the allowance for a spender */
    function decreaseAllowance(address spender, uint256 subtractedValue) external override returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "BTS20: decreased allowance below zero");

        _allowances[msg.sender][spender] = currentAllowance - subtractedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }
}
