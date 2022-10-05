// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

//  _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _                         
// |   ____  _          ____                 |
// |  / ___|(_) _   _  |  _ \   ___ __   __  |
// | | |  _ | || | | | | | | | / _ \\ \ / /  |
// | | |_| || || |_| | | |_| ||  __/ \ V /   |
// |  \____||_| \__,_| |____/  \___|  \_/    |
// | _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ | 

//Giuliano Neroni DEV
//https://www.giulianoneroni.com/

import "./abstract.sol";
import "./library.sol";

contract SwappyRegister is Ownable{
    using Strings for uint256;

    struct dbTx {
        string hashFrom;
        uint256 blockchainFrom;
        string tokenFrom;
        string amountFrom;
        string walletOffchain;
        uint256 blockchainTo;
        string tokenTo;
        string amountTo;
        string hashTo;
        uint256 state;
        uint256 buyOrSell;
        uint256 expiration;
        string refCode;
        uint256 lastUpdate;}

    struct stateTx {
        string state;}

    mapping(string => mapping(uint => string)) public refTx;
    mapping(string => uint) public totalRefTx;
    mapping(string => mapping(string => dbTx)) private storedTx;
    mapping(uint => stateTx) private storedState;

    uint256 public totalTxStored;
    

    string public dailyUSDTSwapped = "0";
    string public totalUSDTSwapped = "0";

    function updateDailySwapped(string memory amount) public onlyOwner {
        dailyUSDTSwapped = amount;}

    function updateTotalSwapped(string memory amount) public onlyOwner {
        totalUSDTSwapped = amount;}

    function setState(uint256 idState, string memory txState) public onlyOwner {
        storedState[idState].state = txState;}

    function getState(uint256 idState) public view returns (string memory txState) {
        require(bytes(storedState[idState].state).length > 0, "Tx State not inserted");
        return(storedState[idState].state);}

    function storeTxRef(string memory refCode, string memory hashFrom) private onlyOwner {
        refTx[refCode][totalRefTx[refCode]] = hashFrom;
        totalRefTx[refCode] += 1;}

    function orderTx(string memory walletAddress, string memory hashFrom, uint256 blockchainFrom, string memory tokenFrom, string memory amountFrom, string memory walletOffchain, uint256 blockchainTo, string memory tokenTo, uint256 buyOrSell, uint256 expiration, string memory refCode) public onlyOwner {  

        storedTx[walletAddress][hashFrom].hashFrom = hashFrom;
        storedTx[walletAddress][hashFrom].blockchainFrom = blockchainFrom;
        storedTx[walletAddress][hashFrom].tokenFrom = tokenFrom;
        storedTx[walletAddress][hashFrom].amountFrom = amountFrom;
        storedTx[walletAddress][hashFrom].walletOffchain = walletOffchain;
        storedTx[walletAddress][hashFrom].blockchainTo = blockchainTo;
        storedTx[walletAddress][hashFrom].tokenTo = tokenTo;

        storedTx[walletAddress][hashFrom].state = 0;
        storedTx[walletAddress][hashFrom].buyOrSell = buyOrSell;
        storedTx[walletAddress][hashFrom].expiration = expiration;
        storedTx[walletAddress][hashFrom].refCode = refCode;
        storedTx[walletAddress][hashFrom].lastUpdate = block.timestamp;}

    function storeTx(string memory walletAddress, string memory hashFrom, uint256 blockchainFrom, string memory tokenFrom, string memory amountFrom, string memory walletOffchain, uint256 blockchainTo, string memory tokenTo, string memory refCode) public onlyOwner {  

        storedTx[walletAddress][hashFrom].hashFrom = hashFrom;
        storedTx[walletAddress][hashFrom].blockchainFrom = blockchainFrom;
        storedTx[walletAddress][hashFrom].tokenFrom = tokenFrom;
        storedTx[walletAddress][hashFrom].amountFrom = amountFrom;
        storedTx[walletAddress][hashFrom].walletOffchain = walletOffchain;
        storedTx[walletAddress][hashFrom].blockchainTo = blockchainTo;
        storedTx[walletAddress][hashFrom].tokenTo = tokenTo;

        storedTx[walletAddress][hashFrom].state = 0;
        storedTx[walletAddress][hashFrom].refCode = refCode;
        storedTx[walletAddress][hashFrom].lastUpdate = block.timestamp;
        
        if(keccak256(abi.encodePacked((refCode))) != keccak256(abi.encodePacked(("none")))){
            storeTxRef(refCode, hashFrom);}

        totalTxStored += 1;}
        
    function updateTx(string memory walletAddress, string memory hashFrom, string memory hashTo, string memory amountTo) public onlyOwner {  

        storedTx[walletAddress][hashFrom].hashTo = hashTo;
        storedTx[walletAddress][hashFrom].amountTo = amountTo;

        storedTx[walletAddress][hashFrom].state = 1;
        storedTx[walletAddress][hashFrom].lastUpdate = block.timestamp;}

    function getTx(string memory walletAddress, string memory hashFrom) public view returns (uint256 blockchainFrom, string memory tokenFrom, string memory amountFrom, string memory walletOffchain, uint256 blockchainTo, string memory tokenTo, string memory amountTo, uint256 state, uint256 buyOrSell, uint256 expiration, uint256 lastUpdate) {
        
        require(bytes(storedTx[walletAddress][hashFrom].hashFrom).length > 0, "TX not registered");
        hashFrom = storedTx[walletAddress][hashFrom].hashFrom;
        blockchainFrom = storedTx[walletAddress][hashFrom].blockchainFrom;
        tokenFrom = storedTx[walletAddress][hashFrom].tokenFrom;
        amountFrom = storedTx[walletAddress][hashFrom].amountFrom;
        walletOffchain = storedTx[walletAddress][hashFrom].walletOffchain;
        blockchainTo = storedTx[walletAddress][hashFrom].blockchainTo;
        tokenTo = storedTx[walletAddress][hashFrom].tokenTo;
        amountTo = storedTx[walletAddress][hashFrom].amountTo;
        state = storedTx[walletAddress][hashFrom].state;
        buyOrSell = storedTx[walletAddress][hashFrom].buyOrSell;
        expiration = storedTx[walletAddress][hashFrom].expiration;
        lastUpdate = storedTx[walletAddress][hashFrom].lastUpdate;
        
        return(blockchainFrom, tokenFrom, amountFrom, walletOffchain, blockchainTo, tokenTo, amountTo, state, buyOrSell, expiration, lastUpdate);}}
