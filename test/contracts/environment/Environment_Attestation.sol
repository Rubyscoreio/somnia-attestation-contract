// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Harness_Attestation} from "test/contracts/harness/Harness_Attestation.sol";
import {Storage_Attestation} from "test/contracts/storage/Storage_Attestation.sol";

abstract contract Environment_Attestation is Storage_Attestation {
    function _prepareEnv() internal override {
        attestationContract = new Harness_Attestation();

        attestationContract.initialize("Test", "TST", admin, operator, attestationFee);
    }
}
