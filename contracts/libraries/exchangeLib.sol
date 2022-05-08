//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../interfaces/IWeapon.sol";
import "../interfaces/INewMinter.sol";

library ExchangeLib {

    function ownsOne(address addr, uint16 tokenId) internal view returns (bool ans){
        IWeapon(addr).ownerOf(uint256(tokenId)) == msg.sender ? ans = true : ans = false;
    }

    function ownsMul(address addr, uint16[] memory tokenIds) internal view returns (bool){
        for(uint8 i = 0; i < tokenIds.length; i++){
            address owner = IWeapon(addr).ownerOf(uint256(tokenIds[i]));
            if(owner != msg.sender){
                return false;
            }
        }
        return true;
    }

    function burnOne(address addr, uint16 tokenId, address dead) internal {
        IWeapon(addr).safeTransferFrom(msg.sender, dead, uint256(tokenId));
    }

    function burnMul(address addr, uint16[] memory tokenIds, address dead) internal {
        for(uint8 i = 0; i < tokenIds.length; i++){
            IWeapon(addr).safeTransferFrom(msg.sender, dead, uint256(tokenIds[i]));
        }
    }

    function mintOne(address addr, uint16 tokenId) internal {
        IMinter(addr).mintOneFor(msg.sender, tokenId);
    }

    function mintMul(address addr, uint16[] memory tokenIds) internal {
        IMinter(addr).mintMulFor(msg.sender,tokenIds);
    }

}