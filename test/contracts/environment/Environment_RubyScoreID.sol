// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Harness_RubyScoreID} from "test/contracts/harness/Harness_RubyScoreID.sol";
import {Storage_RubyScoreID} from "test/contracts/storage/Storage_RubyScoreID.sol";

abstract contract Environment_RubyScoreID is Storage_RubyScoreID {
    function _prepareEnv() internal override {
        attestationContract = new Harness_RubyScoreID();

        attestationContract.initialize("Test", "TST", admin, operator, attestationFee);
    }
}
