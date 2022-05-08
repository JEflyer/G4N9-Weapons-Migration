//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//import interface for interacting with old & new minter contracts
import "./interfaces/IWeapon.sol";
import "./interfaces/INewMinter.sol";

//import library of internal functions
import "./libraries/exchangeLib.sol";

//import library for verification that a given address is not a contract
import "@openzeppelin/contracts/utils/Address.sol";

//import library to guard against reentranct attacks
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Exchange is ReentrancyGuard{

    //old minter contract address
    address private weaponContract;

    //new minter contract address
    address private newMinterContract;
    
    //admin wallet address
    address private admin;

    //address(0xdead) a address no one can use
    address private deadAddress;

    //used for storing whether a token has been exchanged or not
    mapping(uint16 => bool) private alreadyExchanged;

    constructor(
        address _weaponContract,
        address _newMinterContract
    ){
        admin = msg.sender;
        weaponContract = _weaponContract;
        newMinterContract = _newMinterContract;
        deadAddress = address(0xdead);
    }

    modifier onlyAdmin {
        require(msg.sender == admin , "ERR:NA");
        _;
    }

    function changeWeapon(address _new) external onlyAdmin {
        weaponContract = _new;
    }
    
    function changeMinter(address _new) external onlyAdmin {
        newMinterContract = _new;
    }

    function exchangeOne(uint16 tokenId) external nonReentrant{
        //check that token has not already been exchanged
        require(!alreadyExchanged[tokenId],"ERR:AE");

        //check that token is owned by msg.sender
        require(ExchangeLib.ownsOne(weaponContract,tokenId),"ERR:DO");
        
        //check that msg.sender is not a contract
        require(!Address.isContract(msg.sender),"ERR:SC");

        //record token as exchanged
        alreadyExchanged[tokenId] = true;

        //burn token on weapon contract
        ExchangeLib.burnOne(weaponContract,tokenId, deadAddress);

        //mint on new contract
        ExchangeLib.mintOne(newMinterContract, tokenId);
    }

    function exchangeMul(uint16[] memory tokenIds) public nonReentrant {
        //check that tokens have not already been exchanged
        for(uint8 i = 0; i< tokenIds.length; i++){
            require(!alreadyExchanged[tokenIds[i]], "ERR:AE");
        }

        //check that tokens are owned by msg.sender
        require(ExchangeLib.ownsMul(weaponContract, tokenIds), "ERR:DO");

        //check that msg.sender is not a contract
        require(!Address.isContract(msg.sender),"ERR:SC");

        for(uint8 i = 0; i< tokenIds.length; i++){
            //record token as exchanged
            alreadyExchanged[tokenIds[i]] = true;
        }

        //burn tokens on weapon contract
        ExchangeLib.burnMul(weaponContract, tokenIds, deadAddress);

        //mint on new contract
        ExchangeLib.mintMul(newMinterContract, tokenIds);

    }

}