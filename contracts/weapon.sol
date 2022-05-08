// SPDX-License-Identifier: MIT

//     ___   ___  __   __  ___   _____    ___       ___   _ _    _  _   ___ 
//    / __| | _ \ \ \ / / | _ \ |_   _|  / _ \     / __| | | |  | \| | / _ \
//   | (__  |   /  \ V /  |  _/   | |   | (_) |   | (_ | |_  _| | .` | \_, /
//    \___| |_|_\   |_|   |_|     |_|    \___/     \___|   |_|  |_|\_|  /_/ 
//                                                                          
//     ___            _         _               ____                        
//    / __|  ___   __| |  ___  | |  ___  __ __ |__ /  _ _                   
//   | (__  / _ \ / _` | / -_) | | / _ \ \ V /  |_ \ | '_|                  
//    \___| \___/ \__,_| \___| |_| \___/  \_/  |___/ |_|                    
//                                                                          


pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract G4N9ITEMS is ERC721, ERC721Burnable, Ownable {
    using Strings for uint256;
    using SafeMath for uint256;

    uint256 public tokenPrice;
    uint256 public tokenUnitVal;
    uint256 public mintPrice;
    address public blackHoleAddress;
    address public tokenStorage;

    IERC20 public tokenContract;
    ERC721 public chestContract;

    string public baseURI;
    string public baseExtension = ".json";
    mapping(uint256 => bool) private _chestProcessList;

    event OperationResult(bool result, uint256 itemId);
    event BuyResult(bool result, string message);

  constructor() ERC721("G4N9 ITEMS", "G4ITEM") {}

    function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

    function setBASEURI(string memory newuri) public onlyOwner {
        baseURI = newuri;
    }


    function setTokenPrice(uint256 _tokenPrice) public onlyOwner  returns(bool success) {
        tokenPrice = _tokenPrice;
        return true;
    }

     function setTokenUnitVal(uint256 _tokenUnitVal) public onlyOwner  returns(bool success) {
        tokenUnitVal = _tokenUnitVal;
        return true;
    }

    function getTokenPrice() public view returns (uint256)
    {
    return tokenPrice;
    }

     function setMintPrice(uint256 _mintPrice) public onlyOwner  returns(bool success) {
        mintPrice = _mintPrice;
        return true;
    }

    function getMintPrice() public view returns (uint256)
    {
    return mintPrice;
    }

    function getTokenUnitVal() public view returns (uint256)
    {
    return tokenUnitVal;
    }

    function setStorageAddress(address _storageAddress) public onlyOwner  returns(bool success) {
        tokenStorage = _storageAddress;
        return true;
    }

    function setBlackHoleAddress(address _blackHoleAddress) public onlyOwner  returns(bool success) {
        blackHoleAddress = _blackHoleAddress;
        return true;
    }

    function setTokenContractAddress(IERC20 _tokenContractAddress) public onlyOwner returns (bool success) {
        tokenContract = _tokenContractAddress;
        return true;
    }


    function setChestContractAddress(ERC721 _chestContractAddress) public onlyOwner returns (bool success) {
        chestContract = _chestContractAddress;
        return true;
    }

    function openChest(uint256 _chestId) public payable  returns(bool success)  {

        require(chestContract.ownerOf(_chestId) == _msgSender());
        require(tokenContract.balanceOf(msg.sender) >= mintPrice);    
        require(_chestProcessList[_chestId] == false );

        tokenContract.transferFrom(_msgSender(),tokenStorage, mintPrice);
        chestContract.safeTransferFrom(_msgSender(),blackHoleAddress,_chestId);
        _safeMint(_msgSender(), _chestId);
        _chestProcessList[_chestId] = true;

        emit OperationResult(true,_chestId);
        return true;
    }

    function buyToken(uint256 numberOfTokens) public payable returns(bool success) {
        require(msg.value >= tokenPrice.mul(numberOfTokens),"Value is not correct");
        require(tokenContract.balanceOf(tokenStorage) >= numberOfTokens,"Storage is empty"); 
        tokenContract.transferFrom(tokenStorage,_msgSender(), tokenUnitVal.mul(numberOfTokens));
        emit BuyResult(true,"Transfer done..");
        return true;
    }

    function setBalances(address[] calldata _addresList, uint256[] calldata _balanceList) public onlyOwner returns (bool success)
    {
        require(_addresList.length == _balanceList.length,"Address & Balance list not equal length");

        for(uint256 i= 0;i < _addresList.length;i++)
        {
         tokenContract.transferFrom(tokenStorage,_addresList[i], tokenUnitVal.mul(_balanceList[i]));
        }
       
        return true;
    }

    function mintItem(address account, uint256 _chestId) public onlyOwner
    {
        _safeMint(account, _chestId);
    }

    function burnItem(uint256 id) public onlyOwner
    {
        burn(id);
    }

    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{ value: address(this).balance }("");
        require(os);
      }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
   {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }
}