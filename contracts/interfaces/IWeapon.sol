// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IWeapon  {
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function tokenURI(uint256 tokenId) external view returns (string memory);
}