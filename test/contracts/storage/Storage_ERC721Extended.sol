// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/Test.sol";

import {Harness_ERC721Extended} from "test/contracts/harness/Harness_ERC721Extended.sol";

abstract contract Storage_ERC721Extended is Test {
    Harness_ERC721Extended public erc721Extended;

    function toComparable(string memory _str) public pure returns (bytes32) {
        return keccak256(abi.encode(_str));
    }

    function _prepareEnv() internal virtual;

    function setUp() public virtual {
        _prepareEnv();
    }
}
