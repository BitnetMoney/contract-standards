// SPDX-License-Identifier: MIT
// Contract standard implementation by Masayoshi Kobayashi

pragma solidity ^0.8.18;

/*
Ownable contract serves as a base contract that provides basic authorization control,
simplifying the implementation of user permissions.
*/
contract Ownable {
    // State variable to store the contract's owner.
    address private _owner;

    // Event to log the transfer of ownership.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /*
    Constructor to set the initial owner of the contract to be the sender.
    */
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /*
    Public view function to check the current owner of the contract.
    */
    function owner() public view returns (address) {
        return _owner;
    }

    /*
    Modifier to make a function callable only by the owner.
    */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /*
    Public view function to check if the caller is the owner of the contract.
    */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /*
    Public function to renounce the contract's ownership. 
    Be cautious as this cannot be undone.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /*
    Public function to transfer ownership to a new address.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /*
    Internal function to handle the logic involved in transferring ownership.
    */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/*
BTS20 contracts represent basic ERC20 token implementations with added ownership capabilities.
*/
contract BTS20 is Ownable {
    // Private state variables to store the token information.
    string private _tokenName;
    string private _tokenSymbol;
    uint8 private _tokenDecimals;
    uint256 private _tokenTotalSupply;

    // Mapping to keep track of token holders' balances.
    mapping(address => uint256) private _balances;
    
    // Mapping to keep track of allowed third-party spenders and their allowances.
    mapping(address => mapping(address => uint256)) private _allowances;

    // Events to log transfers and approvals.
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /*
    Constructor to initialize the token's properties and assign the total supply to the contract's deployer.
    */
    constructor(string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals, uint256 initialSupply) {
        _tokenName = tokenName;
        _tokenSymbol = tokenSymbol;
        _tokenDecimals = tokenDecimals;
        _tokenTotalSupply = initialSupply * 10 ** uint256(tokenDecimals);
        _balances[msg.sender] = _tokenTotalSupply;
    }

    /*
    External view function to get the name of the token.
    */
    function name() external view returns (string memory) {
        return _tokenName;
    }

    /*
    External view function to get the symbol of the token.
    */
    function symbol() external view returns (string memory) {
        return _tokenSymbol;
    }

    /*
    External view function to get the decimals of the token.
    */
    function decimals() external view returns (uint8) {
        return _tokenDecimals;
    }

    /*
    External view function to get the total supply of the token.
    */
    function totalSupply() external view returns (uint256) {
        return _tokenTotalSupply;
    }

    /*
    External view function to get the token balance of a given account.
    */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /*
    Function to transfer tokens from the caller to a recipient.
    */
    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(recipient != address(0), "BTS20: transfer to the zero address");
        require(_balances[msg.sender] >= amount, "BTS20: insufficient balance");

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    /*
    Function to approve a spender to spend a certain amount of tokens on behalf of the caller.
    */
    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /*
    Function to transfer tokens from an address to another, taking into account the allowance mechanism.
    */
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

    /*
    Function to increase the allowance of a given spender.
    */
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _allowances[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    /*
    Function to decrease the allowance of a given spender.
    */
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "BTS20: decreased allowance below zero");

        _allowances[msg.sender][spender] = currentAllowance - subtractedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }
}
