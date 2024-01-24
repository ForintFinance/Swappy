// SPDX-License-Identifier: MIT

/*

 .d8888b.  888       888        d8888 8888888b.  8888888b. Y88b   d88P          d8888       .d8888b.       .d8888b.  
d88P  Y88b 888   o   888       d88888 888   Y88b 888   Y88b Y88b d88P          d8P888      d88P  Y88b     d88P  Y88b 
Y88b.      888  d8b  888      d88P888 888    888 888    888  Y88o88P          d8P 888      888    888     888    888 
 "Y888b.   888 d888b 888     d88P 888 888   d88P 888   d88P   Y888P          d8P  888      888    888     888    888 
    "Y88b. 888d88888b888    d88P  888 8888888P"  8888888P"     888          d88   888      888    888     888    888 
      "888 88888P Y88888   d88P   888 888        888           888          8888888888     888    888     888    888 
Y88b  d88P 8888P   Y8888  d8888888888 888        888           888                888  d8b Y88b  d88P d8b Y88b  d88P 
 "Y8888P"  888P     Y888 d88P     888 888        888           888                888  Y8P  "Y8888P"  Y8P  "Y8888P"  
                                                                                                                     
*/

pragma solidity ^0.8.23;

import "./interface.sol";

contract BlockchainAddressRegistry is Ownable, ReentrancyGuard, Pausable {
    
    //SECURITY

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    address public contractManager;
    event ContractManagerChanged(address indexed previousManager, address indexed newManager);

    modifier onlyOwnerOrContractManager() {
        require(msg.sender == owner() || msg.sender == contractManager, "Caller is not authorized");
        _;
    }

    function setContractManager(address _newManager) public onlyOwnerOrContractManager {
        require(_newManager != address(0), "New manager is the zero address");
        emit ContractManagerChanged(contractManager, _newManager);
        contractManager = _newManager;
    }

    function getContractManager() public view returns (address) {
        return contractManager;
    }

    // 4INT SETTINGS

    IERC20 public forintToken;
    IERC20 public usdtToken;
    uint256 public forintDecimals;
    uint256 public usdtDecimals;
    uint256 public minimumClaimAmount; 

    function setForintAddress(address _forintToken, uint256 _forintDecimals) public onlyOwnerOrContractManager {
        forintToken = IERC20(_forintToken);
        forintDecimals = _forintDecimals;
    }

    function setUsdtAddress(address _usdtToken, uint256 _usdtDecimals, uint256 _minimumClaimAmount) public onlyOwnerOrContractManager {
        usdtToken = IERC20(_usdtToken);
        usdtDecimals = _usdtDecimals;
        minimumClaimAmount = _minimumClaimAmount * (10 ** _usdtDecimals);
    }

    function getForintBalance(address _userAddress) public view returns (uint256) {
        return forintToken.balanceOf(_userAddress);
    }
    
    uint256 public silverThreshold = 10000;
    uint256 public goldThreshold = 50000;   
    uint256 public platinumThreshold = 250000; 

    function setThreshold(uint256 _silver, uint256 _gold, uint256 _platinum) public onlyOwnerOrContractManager {
        silverThreshold = _silver;
        goldThreshold = _gold;
        platinumThreshold = _platinum;
    }
    
    uint256 public silverCashback = 25;
    uint256 public goldCashback = 50;   
    uint256 public platinumCashback = 100; 
    uint256 public decimalsCashback = 2;

    function setCashback(uint256 _silver, uint256 _gold, uint256 _platinum, uint256 _decimals) public onlyOwnerOrContractManager {
        silverCashback = _silver;
        goldCashback = _gold;
        platinumCashback = _platinum;
        decimalsCashback = _decimals;
    }

    function getCashback(address _userAddress) public view returns (uint256) {
        uint256 _balance = getForintBalance(_userAddress);

        if (_balance >= (platinumThreshold * (10**forintDecimals))) {
            return platinumCashback;
        } else if (_balance >= (goldThreshold * (10**forintDecimals))) {
            return goldCashback;
        } else if (_balance >= (silverThreshold * (10**forintDecimals))) {
            return silverCashback;
        }

        return 0; 
    }

    // SETTINGS BLOCKCHAIN

    mapping(string => bool) private blockchainSupported;

    function addBlockchain(string memory _blockchain) public onlyOwnerOrContractManager {
        require(!blockchainSupported[_blockchain], "Blockchain already supported");
        blockchainSupported[_blockchain] = true;
    }

    function isBlockchainSupported(string memory _blockchain) public view returns (bool) {
        return blockchainSupported[_blockchain];
    }

    function removeBlockchain(string memory _blockchain) public onlyOwnerOrContractManager {
        require(blockchainSupported[_blockchain], "Blockchain not found");
        blockchainSupported[_blockchain] = false;
    }

    // 4INT ASSOCIATED ADDRESS
    
    uint256 public maxAddressLength = 100;

    function setMaxAddressLength(uint256 _maxAddressLength) public onlyOwnerOrContractManager {
        maxAddressLength = _maxAddressLength;
    }
    
    mapping(address => bool) private isRegistered;
    address[] public registeredUsers;
    
    mapping(address => mapping(string => string)) public userBlockchainAddresses;
    mapping(string => mapping(string => address)) public blockchainAddressToUser;
    
    function setAddress(string memory _blockchain, string memory _newAddress) public whenNotPaused nonReentrant {
        require(isBlockchainSupported(_blockchain), "Blockchain not supported");
        require(bytes(_newAddress).length <= maxAddressLength, "Address too long");
        
        address existingUser = blockchainAddressToUser[_blockchain][_newAddress];
        require(existingUser == address(0) || existingUser == msg.sender, "Address already used");

        userBlockchainAddresses[msg.sender][_blockchain] = _newAddress;
        blockchainAddressToUser[_blockchain][_newAddress] = msg.sender;
    }
    
    function getAddress(string memory blockchain) public view returns (string memory) {
        return userBlockchainAddresses[msg.sender][blockchain];
    }
    
    function removeAddress(string memory _blockchain) public nonReentrant {
        string memory existingAddress = userBlockchainAddresses[msg.sender][_blockchain];
        require(bytes(existingAddress).length != 0, "No address to remove");
        
        delete blockchainAddressToUser[_blockchain][existingAddress];
        delete userBlockchainAddresses[msg.sender][_blockchain];
    }

    // FIAT TRANSACTION

    struct FiatTransaction {
        string transactionId;
        uint256 usdtAmountWei; 
        uint256 cashbackAmountWei; 
        uint256 extraCashbackAmountWei;
        string description;
        uint256 timestamp;
    }

    mapping(address => FiatTransaction[]) public userFiatTransactions;
    mapping(string => bool) public registeredTransactionIds;
    
    function addFiatTransaction(address _userAddress, string memory _transactionId, uint256 _usdtAmountWei, uint256 _extraCashbackAmountWei, string memory _description, uint _timestamp) public onlyOwnerOrContractManager nonReentrant {
        require(!registeredTransactionIds[_transactionId], "Transaction already registered");
        uint256 _cashback = getCashback(_userAddress);
        uint256 _cashbackAmountWei = _usdtAmountWei * _cashback / (10**decimalsCashback);

        FiatTransaction memory newTransaction = FiatTransaction(_transactionId, _usdtAmountWei, _cashbackAmountWei, _extraCashbackAmountWei, _description, _timestamp);
        userFiatTransactions[_userAddress].push(newTransaction);
        addRedeemableBalance(_userAddress, _cashbackAmountWei, _extraCashbackAmountWei);
        registeredTransactionIds[_transactionId] = true;
    }
    
    function getFiatTransactions(address user) public view returns (FiatTransaction[] memory) {
        return userFiatTransactions[user];
    }

    // CLAIM

    using SafeERC20 for IERC20;
    mapping(address => uint256) public redeemableBalance;
    mapping(address => uint256) public redeemableForintBalance;

    function addRedeemableBalance(address _userAddress, uint256 _amount, uint256 _forintAmount) public onlyOwnerOrContractManager nonReentrant {
        redeemableBalance[_userAddress] += _amount;
        redeemableForintBalance[_userAddress] += _forintAmount;
    }

    function editRedeemableBalance(address _userAddress, uint256 _amount, uint256 _forintAmount) public onlyOwnerOrContractManager nonReentrant {
        redeemableBalance[_userAddress] = _amount;
        redeemableForintBalance[_userAddress] = _forintAmount;
    }

    function claimBalance() public whenNotPaused nonReentrant {
        uint256 balance = redeemableBalance[msg.sender];
        uint256 forintBalance = redeemableForintBalance[msg.sender];
        require(balance > 0, "No balance to claim");
        require(balance >= minimumClaimAmount, "Minimum withdrawal balance not reached");
        require(usdtToken.balanceOf(address(this)) >= balance, "Insufficient USDT balance in the contract");

        if (forintBalance > 0) {        
            require(forintToken.balanceOf(address(this)) >= forintBalance, "Insufficient Forint balance in the contract");
            forintToken.safeTransfer(msg.sender, forintBalance);
            redeemableForintBalance[msg.sender] = 0;
        }

        usdtToken.safeTransfer(msg.sender, balance);
        redeemableBalance[msg.sender] = 0;
    }
}
