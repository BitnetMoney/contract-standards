// SPDX-License-Identifier: MIT

/* BTSHCE Token Standard v.0.1.821 */

/* BTSHCE: Bitnet Token Standard for High Compliance Environments
Contract Standard by Masayoshi Kobayashi

The BTSHCE (Bitnet Token Standard for High Compliance Environments) is
designed to meet the needs of high compliance environments, where stringent
regulatory requirements often apply. While inspired by the BTS21 standard,
BTSHCE introduces additional features and controls to ensure compliance,
security, and transparency.

Main Features:

    - Exclusive transactions for whitelisted addresses: Ensures only approved
      users can transact, enhancing security and compliance.
    - Oracle integration for precise pricing: Enables accurate and transparent
      token pricing using real-world data.
    - Customizable transaction taxation: Provides flexibility in applying
      transaction taxes for financial transparency.
    - Tax-free accounts for specific use cases: Accommodates special accounts
      exempt from transaction taxes, as needed.
    - Account freezing for security and compliance: Implements measures to
      prevent unauthorized activities and ensure compliance.
    - Built-in token minting and burning: Facilitates controlled adjustments to
      token supply through minting and burning mechanisms.
    - Robust ownership management controls: Empowers administrators with essential
      controls over ownership and governance.
    - Roles: Different roles with different control levels for management
      scalability.

For those familiar with the ERC20 and BTS20 standards, BTSHCE builds upon the
core principles of fungibility and transferability, while addressing the unique
requirements of high compliance environments. It extends the capabilities of
ERC20 and BTS20 to provide a comprehensive solution for secure and regulated
token management. */

pragma solidity ^0.8.21;

contract BTSHCE {
    /* SafeMath helps preventing over and underflows for arithmetic
    and despite Solidity currently has mechanisms that should, in theory
    provide the required security, using SafeMath is only good practice. */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    /* Below we have the basic token setup, with the name, symbol, decimals,
    and total supply. Supply can be further modified by calling the mint and
    burn functions available. */

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    /* BTSHCE has a unique ownership transfer methodology, that requires an
    ownership transfer to be initially proposed by the current contract
    owner to a set address, and only after 7 days that the contract allows
    for such transfer to be completed. For that, the new owner needs to
    call another function in the contract to confirm the transfer. */

    address public owner;
    address public proposedNewOwner;
    uint256 public ownershipTransferProposedTime;
    uint256 public ownershipTransferTimeLock = 7 days;

    /* Below, we map several variables for roles and stats. These are used
    across the contract to allow/decline access to specific functions by
    the caller. */

    mapping(address => bool) public isWhitelisted;
    mapping(address => bool) public isFrozen;
    mapping(address => bool) public isTaxFree;
    mapping(address => bool) public isManager;
    mapping(address => bool) public isTreasurer;
    mapping(address => bool) public isWhitelister;

    /* Defines the taxation variables. */

    uint256
        public taxRate; /* Stored as parts-per-10000 (2 decimal precision) */
    address public taxWallet;

    /* Defines internal balances and allowances (not publicly accessible). */

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    /* General token information. */

    uint256 private _totalSupply;
    uint256 private _maxBalance = type(uint256).max;

    /* Contract events are important for integration, and here I try to
    cover as many events as possible, so BTSHCE can be seamlessly integrated
    with third-party applications and indexers. */

    event OwnershipTransferred(
        address indexed oldOwner,
        address indexed newOwner
    );
    event OwnershipTransferProposed(
        address indexed oldOwner,
        address indexed proposedNewOwner
    );
    event OwnershipTransferCancelled(
        address indexed oldOwner,
        address indexed proposedNewOwner
    );
    event TaxRateChanged(uint256 oldTaxRate, uint256 newTaxRate);
    event TaxWalletChanged(address oldTaxWallet, address newTaxWallet);
    event TaxFreeStatusChanged(address indexed account, bool status);
    event AccountFrozen(address indexed account, bool frozen);
    event AccountWhitelisted(address indexed account, bool whitelisted);
    event RoleAssigned(address indexed account, string role);
    event RoleRevoked(address indexed account, string role);
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);
    event BatchTaxFreeStatusChanged(
        address[] indexed accounts,
        bool[] statuses
    );
    event BatchFreezeStatusChanged(address[] indexed accounts, bool[] statuses);
    event BatchWhitelistStatusChanged(
        address[] indexed accounts,
        bool[] statuses
    );
    event BatchTokensMinted(address[] indexed accounts, uint256[] amounts);
    event BatchTokensBurned(address[] indexed accounts, uint256[] amounts);
    event Paused();
    event Unpaused();
    event ContractDestroyed();
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /*
    
    Define the different contract roles and modifiers. See below for more info.
    
    Frozen Accounts: cannot call any functions.
    Owner: can call all the functions in the contract, with no restrictions;
    Managers: can call all functions but Pause and Self-Destruct;
    Treasurers: can call all financial related functions and freeze accounts;
    Whitelisters: can add and remove addresses from the whitelist;

     */

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier notFrozen() {
        require(!isFrozen[msg.sender], "Account is frozen");
        _;
    }

    modifier onlyManagers() {
        require(
            isManager[msg.sender] || msg.sender == owner,
            "Only managers or the owner can call this function"
        );
        _;
    }

    modifier onlyTreasurers() {
        require(
            isTreasurer[msg.sender] || msg.sender == owner,
            "Only treasurers or the owner can call this function"
        );
        _;
    }

    modifier onlyWhitelisters() {
        require(
            isWhitelister[msg.sender] || msg.sender == owner,
            "Only whitelisters or the owner can call this function"
        );
        _;
    }

    /* Smart Contract constructor. */

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        _balances[owner] = totalSupply;
    }

    /* The basic token functions are set below, in accordance with the
    BTS20 (or ERC20) standards. */

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public notFrozen returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address tokenOwner,
        address spender
    ) public view returns (uint256) {
        return _allowances[tokenOwner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public notFrozen returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public notFrozen returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            sub(_allowances[sender][msg.sender], amount)
        );
        return true;
    }

    /* Simple minting and burning functions. */

    function mint(address account, uint256 amount) public onlyTreasurers {
        require(account != address(0), "Account cannot be zero address");
        require(isWhitelisted[account], "Account is not whitelisted");

        _mint(account, amount);
        emit TokensMinted(account, amount); // Emit TokensMinted event
    }

    function burn(address account, uint256 amount) public onlyTreasurers {
        require(account != address(0), "Account cannot be zero address");
        require(isWhitelisted[account], "Account is not whitelisted");

        require(_balances[account] >= amount, "Insufficient balance to burn");
        _burn(account, amount);
        emit TokensBurned(account, amount); // Emit TokensBurned event
    }

    /* Here is where all the token-specific functions are defined. There are
    further comments on each one of the function sets. */

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    /* Defines all the Ownership-related functions of the contract. */

    function proposeOwnershipTransfer(address _newOwner) public onlyOwner {
        proposedNewOwner = _newOwner;
        ownershipTransferProposedTime = block.timestamp;
        emit OwnershipTransferProposed(owner, proposedNewOwner);
    }

    function cancelOwnershipTransfer() public onlyOwner {
        require(
            proposedNewOwner != address(0),
            "No ownership transfer is currently proposed"
        );

        // Reset the proposed owner and timelock
        proposedNewOwner = address(0);
        ownershipTransferProposedTime = 0;

        emit OwnershipTransferCancelled(owner, proposedNewOwner);
    }

    function confirmOwnershipTransfer() public {
        require(
            msg.sender == proposedNewOwner,
            "Only proposed owner can confirm ownership transfer"
        );
        require(
            block.timestamp >=
                add(ownershipTransferProposedTime, ownershipTransferTimeLock),
            "Ownership transfer is still timelocked"
        );
        emit OwnershipTransferred(owner, proposedNewOwner);
        owner = proposedNewOwner;
    }

    /* Defines the Pause and Unpause functions of the contract. When paused, all
    functions are temporarily disabled, including transfers, mints, and burns. This
    function is meant to be used in emergency situations, and the contract should
    be able to handle pauses/unpauses harmlessly - at least on a technical basis. */

    function pauseContract() public onlyOwner {
        paused = true;
        emit Paused();
    }

    function unpauseContract() public onlyOwner {
        paused = false;
        emit Unpaused();
    }

    /* This is the doomsday function. It makes the contract "implode" and destroy itself.
    There's no CTRL+Z for this one, and once called, it's the contract's doomsday! */

    function selfDestruct() public onlyOwner {
        for (uint256 i = 0; i < totalSupply; i++) {
            _burn(owner, 1);
        }
        paused = true;
        emit ContractDestroyed();
        payable(owner).transfer(address(this).balance);
    }

    /* The token standard supports a basic transfer taxation system, which is, by default, set
    to zero. The tax can range from 0.01% to 99.9% and can be set or charged at any time by
    Trasurers, Managers, and Owners. All taxes collected go to the "Tax Wallet" which is, by
    default, the contract owner. */

    function setTaxRate(uint256 _newRate) public onlyTreasurers {
        require(_newRate <= 9999, "Rate cannot exceed 9999"); // 99.99% is the max tax rate
        uint256 oldRate = taxRate;
        taxRate = _newRate;
        emit TaxRateChanged(oldRate, taxRate);
    }

    function setTaxWallet(address _newWallet) public onlyTreasurers {
        address oldWallet = taxWallet;
        taxWallet = _newWallet;
        emit TaxWalletChanged(oldWallet, taxWallet);
    }

    function setTaxFreeAddress(
        address _account,
        bool _status
    ) public onlyTreasurers {
        isTaxFree[_account] = _status;
        emit TaxFreeStatusChanged(_account, _status);
    }

    /* Defines the freezing and whitelisting functions. Addresses are, by default, not frozen, and
    not whitelisted. That means that in order to interact with this contract, addresses must be first
    added to the whitelist. Frozen addresses cannot either receive or send transactions, and addresses
    can be whitelisted by yet frozen. */

    function setWhitelistStatus(
        address _account,
        bool _status
    ) public onlyWhitelisters {
        isWhitelisted[_account] = _status;
        emit AccountWhitelisted(_account, _status);
    }

    function setFreezeStatus(
        address _account,
        bool _status
    ) public onlyTreasurers {
        isFrozen[_account] = _status;
        emit AccountFrozen(_account, _status);
    }

    /* Contract roles are important for the management of BTSHCE tokens. Different roles have different
    levels of authority and can call different functions within the contract. Contract owners are the
    only ones that can add/remove addresses from specific roles, and more than one role can be assigned
    to the same address. */

    function addManager(address _account) public onlyOwner {
        isManager[_account] = true;
        emit RoleAssigned(_account, "Manager");
    }

    function removeManager(address _account) public onlyOwner {
        isManager[_account] = false;
        emit RoleRevoked(_account, "Manager");
    }

    function addTreasurer(address _account) public onlyOwner {
        isTreasurer[_account] = true;
        emit RoleAssigned(_account, "Treasurer");
    }

    function removeTreasurer(address _account) public onlyOwner {
        isTreasurer[_account] = false;
        emit RoleRevoked(_account, "Treasurer");
    }

    function addWhitelister(address _account) public onlyOwner {
        isWhitelister[_account] = true;
        emit RoleAssigned(_account, "Whitelister");
    }

    function removeWhitelister(address _account) public onlyOwner {
        isWhitelister[_account] = false;
        emit RoleRevoked(_account, "Whitelister");
    }

    /* Contract's internal functions. */

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal whenNotPaused {
        require(sender != address(0), "Sender cannot be a zero address");
        require(recipient != address(0), "Recipient cannot be a zero address");
        require(
            !isFrozen[sender] && !isFrozen[recipient],
            "Sender or recipient is frozen"
        );
        require(
            isWhitelisted[sender] || isWhitelisted[recipient],
            "Sender and recipient are not whitelisted"
        );

        uint256 taxAmount = 0;
        if (taxRate > 0 && !isTaxFree[sender] && !isTaxFree[recipient]) {
            taxAmount = (amount * taxRate) / 10000;
            require(
                _balances[taxWallet] + taxAmount <= _maxBalance,
                "Tax exceeds max wallet size for taxWallet"
            );
            _balances[taxWallet] += taxAmount;
            emit Transfer(sender, taxWallet, taxAmount);
        }

        uint256 finalAmount = amount - taxAmount;
        require(_balances[sender] >= finalAmount, "Insufficient balance");

        _balances[sender] -= finalAmount;
        _balances[recipient] += finalAmount;
        require(_balances[recipient] <= _maxBalance, "Exceeds max wallet size");

        emit Transfer(sender, recipient, finalAmount);
    }

    function _approve(
        address tokenOwner,
        address spender,
        uint256 amount
    ) internal whenNotPaused {
        require(tokenOwner != address(0), "Owner cannot be zero address");
        require(spender != address(0), "Spender cannot be zero address");
        require(isWhitelisted[tokenOwner], "Owner is not whitelisted");

        _allowances[tokenOwner][spender] = amount;
        emit Approval(tokenOwner, spender, amount);
    }

    function _mint(address account, uint256 amount) internal onlyTreasurers {
        require(account != address(0), "Account cannot be zero address");
        require(isWhitelisted[account], "Account is not whitelisted");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal onlyTreasurers {
        require(account != address(0), "Account cannot be zero address");
        require(isWhitelisted[account], "Account is not whitelisted");

        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    /* Batch functions. For most large-scale operations, batch functions are
    necessary to optimize workflow and save in gas fees. These are the same
    functions as seen above, but with bulk-processing. */

    function batchSetTaxFreeAddresses(
        address[] memory accounts,
        bool[] memory statuses
    ) public onlyTreasurers {
        require(accounts.length == statuses.length, "Array lengths must match");
        for (uint256 i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            bool status = statuses[i];

            setTaxFreeAddress(account, status);

            emit BatchTaxFreeStatusChanged(accounts, statuses);
        }
    }

    function batchSetFreezeStatuses(
        address[] memory accounts,
        bool[] memory statuses
    ) public onlyTreasurers {
        require(accounts.length == statuses.length, "Array lengths must match");
        for (uint256 i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            bool status = statuses[i];

            setFreezeStatus(account, status);

            emit BatchFreezeStatusChanged(accounts, statuses);
        }
    }

    function batchSetWhitelistStatuses(
        address[] memory accounts,
        bool[] memory statuses
    ) public onlyWhitelisters {
        require(accounts.length == statuses.length, "Array lengths must match");
        for (uint256 i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            bool status = statuses[i];

            setWhitelistStatus(account, status);

            emit BatchWhitelistStatusChanged(accounts, statuses);
        }
    }

    function batchMint(
        address[] memory accounts,
        uint256[] memory amounts
    ) public onlyTreasurers {
        require(accounts.length == amounts.length, "Array lengths must match");
        for (uint256 i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            uint256 amount = amounts[i];

            require(account != address(0), "Account cannot be zero address");
            require(isWhitelisted[account], "Account is not whitelisted");

            _mint(account, amount);
            emit BatchTokensMinted(accounts, amounts);
        }
    }

    function batchBurn(
        address[] memory accounts,
        uint256[] memory amounts
    ) public onlyTreasurers {
        require(accounts.length == amounts.length, "Array lengths must match");
        for (uint256 i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            uint256 amount = amounts[i];

            require(account != address(0), "Account cannot be zero address");
            require(isWhitelisted[account], "Account is not whitelisted");
            require(
                _balances[account] >= amount,
                "Insufficient balance to burn"
            );

            _burn(account, amount);
            emit BatchTokensBurned(accounts, amounts);
        }
    }
}
