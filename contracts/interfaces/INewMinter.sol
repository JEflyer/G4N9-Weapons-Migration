//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IMinter {
    function mintOneFor(address to, uint16 token) external;

    function mintMulFor(address to, uint16[] memory tokens) external;
}