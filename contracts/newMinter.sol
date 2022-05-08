//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//import ERC721Enumerable.sol  
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

//import Address library
import "@openzeppelin/contracts/utils/Address.sol";

contract G4N9ItemsMinter is ERC721Enumerable{

    struct WeaponData {
        uint8 weaponType;
        uint8 effect;
        uint8 minDMG;
        uint8 maxDMG;
        uint8 levelRequirement;
        uint8 critChance;
        uint8 accuracy;
    }

    //for storing the address of project admin
    address private admin;

    //for storing the address of the exchange contract
    address private exchangeContract;

    //for storing the address that has access to the update stat functions
    address private authorised;

    //total limit of tokens that can be minted
    uint16 private totalLimit;

    //current amount that has been minted
    uint16 private currentlyMinted;

    //mapping for storing tokenURIs
    mapping(uint16 => string) private tokenURIs;

    //for storing token information
    mapping(uint16 => WeaponData) private weaponData;

    //for tracking the new minter tokenId => old minter tokenId
    mapping(uint16 => uint16) private previousTokenId;

    constructor(
        address _exchangeContract,
        address _admin,
        address _authorised,
        string memory name,
        string memory symbol
    ) ERC721A(name,symbol){
        currentlyMinted = 0;
        authorised = _authorised;
        totalLimit = 10000;
        admin = _admin;
        exchangeContract =_exchangeContract;
    }

    modifier onlyAuthorised {
        require(msg.sender == authorised,"ERR:NA");
        _;
    }

    modifier notContract(address to){
        require(!Address.isContract(to), "ERR:SC");
        _;
    }

    function mintOneFor(
        address to,
        uint8 weaponType,
        uint8 effect,
        uint8 minDMG,
        uint8 maxDMG,
        uint8 levelRequirement,
        uint8 critChance,
        uint8 accuracy,
        string memory uri
    ) external onlyAuthorised notContract(to){
        //increment currentlyMinted
        currentlyMinted++;

        //set uri
        tokenURIs[currentlyMinted] = uri;

        //mint to address & use curentlyMinted as the tokenId
        _safeMint(to,uint256(currentlyMinted)); 

        //set stats
        weaponStats[currentlyMinted].weaponType = weaponType;
        weaponStats[currentlyMinted].effect = effect;
        weaponStats[currentlyMinted].minDMG = minDMG;
        weaponStats[currentlyMinted].maxDMG = maxDMG;
        weaponStats[currentlyMinted].levelRequirement = levelRequirement;
        weaponStats[currentlyMinted].critChance = critChance;
        weaponStats[currentlyMinted].accuracy = accuracy;
    }

    function mintMulFor(
        address to, 
        uint8 amount,
        uint8[] memory weaponType,
        uint8[] memory effect,
        uint8[] memory minDMG,
        uint8[] memory maxDMG,
        uint8[] memory levelRequirement,
        uint8[] memory critChance,
        uint8[] memory accuracy,
        string[] memory uri
    ) external onlyAuthorised notContract(to){
        require(amount != 0, "ERR:WL");
        require(amount == weaponType.length, "ERR:WL");
        require(amount == effect.length, "ERR:WL");
        require(amount == minDMG.length, "ERR:WL");
        require(amount == maxDMG.length, "ERR:WL");
        require(amount == levelRequirement.length, "ERR:WL");
        require(amount == critChance.length, "ERR:WL");
        require(amount == accuracy.length, "ERR:WL");
        require(amount == uri.length, "ERR:WL");

        for(uint8 i = 0; i < amount; i++){
            //increment curently minted
            currentlyMinted++;

            //set uri
            tokenURIs[currentlyMinted] = uris[i];

            //mint to address & use curentlyMinted as the tokenId
            _safeMint(to, uint256(currentlyMinted));

            //set stats
            weaponStats[currentlyMinted].weaponType = weaponType[i];
            weaponStats[currentlyMinted].effect = effect[i];
            weaponStats[currentlyMinted].minDMG = minDMG[i];
            weaponStats[currentlyMinted].maxDMG = maxDMG[i];
            weaponStats[currentlyMinted].levelRequirement = levelRequirement[i];
            weaponStats[currentlyMinted].critChance = critChance[i];
            weaponStats[currentlyMinted].accuracy = accuracy[i];
        }
    }

    function updateTokenURI(string memory _uri, uint16 token) external onlyAuthorised {
        tokenURIs[token] = _uri;
    }

    function updateBatchURIs(string[] memory _uris, uint16[] memory tokens) external onlyAuthorised {
        require(_uris.length == tokens.length, "ERR:WL");
        for(uint8 i = 0; i< tokens.length; i++){
            tokenURIs[tokens[i]] = _uris[i];
        }
    }

    function updateStats(
        uint16[] memory tokenIds,
        uint8[] memory weaponType,
        uint8[] memory effect,
        uint8[] memory minDMG,
        uint8[] memory maxDMG,
        uint8[] memory levelRequirement,
        uint8[] memory critChance,
        uint8[] memory accuracy
    ) external onlyAuthorised{
        //check that arrays are all the same size & not length 0
        require(tokenIds.length != 0, "ERR:WL");
        require(tokenIds.length == weaponType.length, "ERR:WL");
        require(tokenIds.length == effect.length, "ERR:WL");
        require(tokenIds.length == minDMG.length, "ERR:WL");
        require(tokenIds.length == maxDMG.length, "ERR:WL");
        require(tokenIds.length == levelRequirement.length, "ERR:WL");
        require(tokenIds.length == critChance.length, "ERR:WL");
        require(tokenIds.length == accuracy.length, "ERR:WL");

        for(uint8 i = 0; i< tokenIds.length; i++){
            weaponData[tokenIds[i]].weaponType = weaponType[i]; 
            weaponData[tokenIds[i]].effect = effect[i];
            weaponData[tokenIds[i]].minDMG = minDMG[i];
            weaponData[tokenIds[i]].maxDMG = maxDMG[i];
            weaponData[tokenIds[i]].levelRequirement = levelRequirement[i];
            weaponData[tokenIds[i]].critChance = critChance[i];
            weaponData[tokenIds[i]].accuracy = accuracy[i];
        }
    }

    function updateSingleStat(uint16 tokenId, uint8 statChoice, uint8 newStat) external onlyAuthorised {
        if(statChoice == 0){
            weaponData[tokenId].weaponType = newStat;
        } else if(statChoice == 1){
            weaponData[tokenId].effect = newStat;
        } else if(statChoice == 2){
            weaponData[tokenId].minDMG = newStat;
        } else if(statChoice == 3){
            weaponData[tokenId].maxDMG = newStat;
        } else if(statChoice == 4){
            weaponData[tokenId].levelRequirement = newStat;
        } else if(statChoice == 5){
            weaponData[tokenId].critChance = newStat;
        } else if(statChoice == 6){
            weaponData[tokenId].accuracy = newStat;
        }
    }

    function queryWeaponData(uint16 tokenId) external view returns (WeaponData memory){
        return weaponData[tokenId];
    }

    function queryBatchWeaponData(uint16[] memory tokenIds) external view returns (WeaponData[] memory data){
        for(uint8 i = 0 ; i < tokenIds.length; i++){
            data[i] = weaponData[tokenIds[i]];
        }
    }

    function querySingleStat(uint16 tokenId, uint8 statChoice) external view returns(uint8){
        if(statChoice == 0){
            return weaponData[tokenId].weaponType;
        } else if(statChoice == 1){
            return weaponData[tokenId].effect;
        } else if(statChoice == 2){
            return weaponData[tokenId].minDMG;
        } else if(statChoice == 3){
            return weaponData[tokenId].maxDMG;
        } else if(statChoice == 4){
            return weaponData[tokenId].levelRequirement;
        } else if(statChoice == 5){
            return weaponData[tokenId].critChance;
        } else if(statChoice == 6){
            return weaponData[tokenId].accuracy;
        }
    }

    function setAuthorised(address _new) external onlyAdmin {
        authorised = _new;
    }

    //returns an array of tokens held by a wallet
    function walletOfOwner(address _wallet) public view  returns(uint16[] memory ids){
        uint16 ownerTokenCount = uint16(balanceOf(_wallet));
        ids = new uint16[](ownerTokenCount);
        for(uint16 i = 0; i< ownerTokenCount; i++){
            ids[i] = uint16(tokenOfOwnerByIndex(_wallet, i));
        }
    }
}