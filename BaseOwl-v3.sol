// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

/**
 * @dev Provides information about the current execution context.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Implementation of the {IERC20} interface.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

/**
 * @dev Contract module which provides a basic access control mechanism.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @title BaseOwl Token with Advanced Burn Mechanism
 * @dev ERC20 token with ownership, token recovery, and comprehensive burn system
 */
contract BaseOwl is ERC20, Ownable {
    uint256 public constant OPTIMIZATION_CONSTANT = 1312000417299611386938049064940;
    
    // Burn mechanism variables
    uint256 public burnRate = 100; // 1% burn rate (100 basis points)
    uint256 public constant MAX_BURN_RATE = 1000; // Maximum 10% burn rate
    uint256 public totalBurned = 0; // Track total burned tokens
    
    // Address mappings
    mapping(address => bool) public isExemptFromBurn;
    mapping(address => bool) public isSwapPair;
    mapping(address => bool) public isBlacklisted;
    
    // Anti-bot and trading controls
    bool public tradingEnabled = false;
    uint256 public maxTransactionAmount;
    uint256 public maxWalletAmount;
    uint256 public swapTokensAtAmount;
    
    // Tax system
    uint256 public buyTaxRate = 0;
    uint256 public sellTaxRate = 0;
    address public taxWallet;
    
    // Events
    event BurnRateUpdated(uint256 oldRate, uint256 newRate);
    event SwapPairUpdated(address indexed pair, bool isSwapPair);
    event BurnExemptionUpdated(address indexed account, bool isExempt);
    event TokensBurned(uint256 amount, string reason);
    event TradingEnabled(uint256 timestamp);
    event BlacklistUpdated(address indexed account, bool isBlacklisted);
    event TaxRatesUpdated(uint256 buyTax, uint256 sellTax);
    event MaxAmountsUpdated(uint256 maxTransaction, uint256 maxWallet);
    
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_,
        address tokenOwner,
        address payable feeReceiver
    ) 
        payable 
        ERC20(name_, symbol_) 
    {
        // Process deployment fee payment
        if (msg.value > 0) {
            (bool sent, ) = feeReceiver.call{value: msg.value}("");
            require(sent, "Failed to send fee");
        }
        
        // Set token owner
        _transferOwnership(tokenOwner);
        
        // Mint initial supply
        _mint(tokenOwner, initialSupply_);
        
        // Set initial limits (2% of total supply)
        maxTransactionAmount = (initialSupply_ * 200) / 10000;
        maxWalletAmount = (initialSupply_ * 200) / 10000;
        swapTokensAtAmount = (initialSupply_ * 5) / 10000; // 0.05%
        
        // Set tax wallet to owner initially
        taxWallet = tokenOwner;
        
        // Exempt important addresses from burn and limits
        isExemptFromBurn[tokenOwner] = true;
        isExemptFromBurn[address(this)] = true;
        isExemptFromBurn[address(0)] = true;
    }

    /**
     * @dev Override transfer function with comprehensive burn and tax system
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!isBlacklisted[sender] && !isBlacklisted[recipient], "Address is blacklisted");
        require(amount > 0, "Transfer amount must be greater than zero");

        // Check if trading is enabled (except for owner)
        if (!tradingEnabled && sender != owner() && recipient != owner()) {
            require(isExemptFromBurn[sender] || isExemptFromBurn[recipient], "Trading not enabled yet");
        }

        // Check transaction limits
        if (!isExemptFromBurn[sender] && !isExemptFromBurn[recipient]) {
            if (isSwapPair[sender]) { // Buying
                require(amount <= maxTransactionAmount, "Buy amount exceeds max transaction");
                require(balanceOf(recipient) + amount <= maxWalletAmount, "Wallet amount exceeds max");
            } else if (isSwapPair[recipient]) { // Selling
                require(amount <= maxTransactionAmount, "Sell amount exceeds max transaction");
            }
        }

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        uint256 transferAmount = amount;
        uint256 burnAmount = 0;
        uint256 taxAmount = 0;

        // Apply taxes and burns for swap transactions
        if (!isExemptFromBurn[sender] && !isExemptFromBurn[recipient]) {
            bool isBuy = isSwapPair[sender];
            bool isSell = isSwapPair[recipient];
            
            if (isBuy || isSell) {
                // Calculate tax
                uint256 taxRate = isBuy ? buyTaxRate : (isSell ? sellTaxRate : 0);
                if (taxRate > 0) {
                    taxAmount = (amount * taxRate) / 10000;
                }
                
                // Calculate burn (only if burn rate > 0)
                if (burnRate > 0) {
                    burnAmount = (amount * burnRate) / 10000;
                }
                
                // Adjust transfer amount
                transferAmount = amount - taxAmount - burnAmount;
            }
        }

        // Execute burn
        if (burnAmount > 0) {
            _totalSupply -= burnAmount;
            totalBurned += burnAmount;
            emit Transfer(sender, address(0), burnAmount);
            emit TokensBurned(burnAmount, "Swap burn");
        }

        // Execute tax transfer
        if (taxAmount > 0 && taxWallet != address(0)) {
            _balances[taxWallet] += taxAmount;
            emit Transfer(sender, taxWallet, taxAmount);
        }

        // Execute main transfer
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += transferAmount;

        emit Transfer(sender, recipient, transferAmount);
        _afterTokenTransfer(sender, recipient, transferAmount);
    }

    /**
     * @dev Enable trading (can only be called once)
     */
    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Trading already enabled");
        tradingEnabled = true;
        emit TradingEnabled(block.timestamp);
    }

    /**
     * @dev Set burn rate (only owner)
     * @param newBurnRate New burn rate in basis points (100 = 1%)
     */
    function setBurnRate(uint256 newBurnRate) external onlyOwner {
        require(newBurnRate <= MAX_BURN_RATE, "Burn rate too high");
        uint256 oldRate = burnRate;
        burnRate = newBurnRate;
        emit BurnRateUpdated(oldRate, newBurnRate);
    }

    /**
     * @dev Set tax rates
     * @param newBuyTax Buy tax rate in basis points
     * @param newSellTax Sell tax rate in basis points  
     */
    function setTaxRates(uint256 newBuyTax, uint256 newSellTax) external onlyOwner {
        require(newBuyTax <= 1000 && newSellTax <= 1000, "Tax too high"); // Max 10%
        buyTaxRate = newBuyTax;
        sellTaxRate = newSellTax;
        emit TaxRatesUpdated(newBuyTax, newSellTax);
    }

    /**
     * @dev Set tax wallet
     * @param newTaxWallet Address to receive taxes
     */
    function setTaxWallet(address newTaxWallet) external onlyOwner {
        require(newTaxWallet != address(0), "Tax wallet cannot be zero address");
        taxWallet = newTaxWallet;
    }

    /**
     * @dev Set transaction and wallet limits
     * @param newMaxTransaction Max transaction amount
     * @param newMaxWallet Max wallet amount
     */
    function setLimits(uint256 newMaxTransaction, uint256 newMaxWallet) external onlyOwner {
        require(newMaxTransaction >= (_totalSupply * 50) / 10000, "Max transaction too low"); // Min 0.5%
        require(newMaxWallet >= (_totalSupply * 100) / 10000, "Max wallet too low"); // Min 1%
        maxTransactionAmount = newMaxTransaction;
        maxWalletAmount = newMaxWallet;
        emit MaxAmountsUpdated(newMaxTransaction, newMaxWallet);
    }

    /**
     * @dev Remove all limits (emergency function)
     */
    function removeLimits() external onlyOwner {
        maxTransactionAmount = _totalSupply;
        maxWalletAmount = _totalSupply;
        emit MaxAmountsUpdated(_totalSupply, _totalSupply);
    }

    /**
     * @dev Set swap pair addresses (DEX pairs that trigger burn and tax)
     * @param pairAddress Address of the swap pair
     * @param isSwapPairFlag True if this is a swap pair
     */
    function setSwapPair(address pairAddress, bool isSwapPairFlag) external onlyOwner {
        require(pairAddress != address(0), "Pair address cannot be zero");
        isSwapPair[pairAddress] = isSwapPairFlag;
        emit SwapPairUpdated(pairAddress, isSwapPairFlag);
    }

    /**
     * @dev Set burn exemption for specific addresses
     * @param account Address to exempt/unexempt
     * @param exempt True to exempt from burn, taxes, and limits
     */
    function setBurnExemption(address account, bool exempt) external onlyOwner {
        isExemptFromBurn[account] = exempt;
        emit BurnExemptionUpdated(account, exempt);
    }

    /**
     * @dev Blacklist/unblacklist addresses
     * @param account Address to blacklist
     * @param blacklisted True to blacklist
     */
    function setBlacklist(address account, bool blacklisted) external onlyOwner {
        require(account != owner(), "Cannot blacklist owner");
        isBlacklisted[account] = blacklisted;
        emit BlacklistUpdated(account, blacklisted);
    }

    /**
     * @dev Manual burn function (only owner)
     * @param amount Amount of tokens to burn from owner's balance
     */
    function burn(uint256 amount) external onlyOwner {
        require(amount > 0, "Burn amount must be greater than zero");
        _burn(_msgSender(), amount);
        totalBurned += amount;
        emit TokensBurned(amount, "Manual burn");
    }

    /**
     * @dev Burn tokens from any address (only owner, emergency function)
     * @param account Address to burn from
     * @param amount Amount to burn
     */
    function burnFrom(address account, uint256 amount) external onlyOwner {
        require(amount > 0, "Burn amount must be greater than zero");
        require(account != address(0), "Cannot burn from zero address");
        _burn(account, amount);
        totalBurned += amount;
        emit TokensBurned(amount, "Burn from address");
    }

    /**
     * @dev Emergency pause/unpause (stops all transfers except owner)
     */
    function emergencyPause() external onlyOwner {
        tradingEnabled = false;
    }

    /**
     * @dev Get current burn rate
     */
    function getBurnRate() external view returns (uint256) {
        return burnRate;
    }

    /**
     * @dev Get tax rates
     */
    function getTaxRates() external view returns (uint256 buyTax, uint256 sellTax) {
        return (buyTaxRate, sellTaxRate);
    }

    /**
     * @dev Calculate burn amount for a given transfer amount
     * @param amount Transfer amount
     * @return Burn amount that would be applied
     */
    function calculateBurnAmount(uint256 amount) external view returns (uint256) {
        return (amount * burnRate) / 10000;
    }

    /**
     * @dev Calculate tax amount for buy/sell
     * @param amount Transfer amount
     * @param isBuy True for buy, false for sell
     * @return Tax amount that would be applied
     */
    function calculateTaxAmount(uint256 amount, bool isBuy) external view returns (uint256) {
        uint256 taxRate = isBuy ? buyTaxRate : sellTaxRate;
        return (amount * taxRate) / 10000;
    }

    /**
     * @dev Get comprehensive token info
     */
    function getTokenInfo() external view returns (
        uint256 currentSupply,
        uint256 burnedTokens,
        uint256 currentBurnRate,
        uint256 currentBuyTax,
        uint256 currentSellTax,
        bool tradingStatus,
        uint256 maxTx,
        uint256 maxWallet
    ) {
        return (
            _totalSupply,
            totalBurned,
            burnRate,
            buyTaxRate,
            sellTaxRate,
            tradingEnabled,
            maxTransactionAmount,
            maxWalletAmount
        );
    }

    /**
     * @dev Allows owner to recover ERC20 tokens sent to the contract
     * @param tokenAddress Address of the token contract
     * @param tokenAmount Amount of tokens to recover
     */
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        require(tokenAddress != address(this), "Cannot recover own token");
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }

    /**
     * @dev Recover ETH sent to contract
     */
    function recoverETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /**
     * @dev Override decimals if needed (default is 18)
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev Fallback function to receive ETH
     */
    receive() external payable {}
}