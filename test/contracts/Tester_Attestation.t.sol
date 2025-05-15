// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Suite_Attestation} from "./suite/Suite_Attestation.sol";
import {Environment_Attestation} from "./environment/Environment_Attestation.sol";

contract Tester_Attestation is
Environment_Attestation,
Suite_Attestation
    {}
