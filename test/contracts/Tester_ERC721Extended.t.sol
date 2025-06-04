// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Suite_ERC721Extended} from "./suite/Suite_ERC721Extended.sol";
import {Environment_ERC721Extended} from "./environment/Environment_ERC721Extended.sol";

contract Tester_ERC721Extended is Environment_ERC721Extended, Suite_ERC721Extended {}
