//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//import ERC721AQueryable.sol A gas optomised version of 
import "./ERC721A/ERC721AQueryable.sol";

//import Address library
import "@openzeppelin/contracts/utils/Address.sol";

contract G4N9ItemsMinter is ERC721AQueryable{

    address private admin;
    address private exchangeContract;

    uint16 private totalLimit;

    constructor(
        address _exchangeContract,
        address _admin,
        string memory name,
        string memory symbol
    ) ERC721A(name,symbol){
        admin = _admin;
        exchangeContract =_exchangeContract;
    }

    modifier onlyExchange {
        require(msg.sender == exchangeContract,"ERR:NE");
        _;
    }

    modifier notContract(address to){
        require(!Address.isContract(to), "ERR:SC");
        _;
    }

    function mintOneFor(address to, uint16 tokenId) external onlyExchange notContract(to){
        //check that token is not already minted
        require(!_exists(tokenId),"ERR:EX");

        //check that token in above 0 & less than or equal to 10k
        require(tokenId > 0 && tokenId <= 10000, "ERR:ID");

        _safeMint(to,tokenId); 
    }

    function mintMulFor(address to, uint16[] memory tokenIds) external onlyExchange notContract(to){
        for(uint8 i = 0; i < tokenIds.length; i++){
            //check that token is not already minted
            require(!_exists(tokenIds[i]),"ERR:EX");

            //check that token in above 0 & less than or equal to 10k
            require(tokenIds[i] > 0 && tokenIds[i] <= 10000, "ERR:ID");

            _safeMint(to, tokenIds[i]);
        }
    }

}