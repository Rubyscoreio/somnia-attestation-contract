// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Suite_RubyScoreID} from "./suite/Suite_RubyScoreID.sol";
import {Environment_RubyScoreID} from "./environment/Environment_RubyScoreID.sol";

contract Tester_Attestation is
Environment_RubyScoreID,
Suite_RubyScoreID
    {}
