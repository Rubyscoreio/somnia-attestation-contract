// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Script} from "lib/forge-std/src/Script.sol";
import {ERC1967Proxy} from "@openzeppelin/5.3.0/proxy/ERC1967/ERC1967Proxy.sol";
import {RubyScoreID} from "../src/RubyScoreID.sol";

contract DeployRubyScoreIDScript is Script {
    address public constant operator = 0x381c031bAA5995D0Cc52386508050Ac947780815;
    address public constant admin = 0x0d0D5Ff3cFeF8B7B2b1cAC6B6C27Fd0846c09361;
    RubyScoreID public constant proxy = RubyScoreID(0xEbAF3b0Cb5ccCCA072F2B01C797F4e9d1aE948e4);
    string public constant name = "RubyScoreID";
    string public constant symbol = "RubyScoreID";
    string public constant baseUri = "ipfs://";
    uint256 public constant attestationFee = 2_000_000_000_000_000;

    function runTestnet() public {
        vm.createSelectFork("baseSepolia");
        uint256 deployerPK = vm.envUint("DEPLOYER_KEY");

        vm.broadcast(deployerPK);
        RubyScoreID implementation = new RubyScoreID();

        vm.broadcast(deployerPK);
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), "");

        vm.broadcast(deployerPK);
        RubyScoreID(address(proxy)).initialize(name, symbol, operator, operator, attestationFee);
    }

    function runMainnet() public {
        require(address(proxy) == address(0), "Already deployed");
        vm.createSelectFork("base");
        uint256 deployerPK = vm.envUint("DEPLOYER_KEY");

        vm.broadcast(deployerPK);
        RubyScoreID implementation = new RubyScoreID();

        vm.broadcast(deployerPK);
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), "");

        vm.broadcast(deployerPK);
        RubyScoreID(address(proxy)).initialize(name, symbol, admin, operator, attestationFee);
    }

    function updateMainnet() public {
        vm.createSelectFork("base");
        uint256 deployerPK = vm.envUint("DEPLOYER_KEY");
        uint256 operatorPK = vm.envUint("OPERATOR_KEY");

        vm.broadcast(deployerPK);
        RubyScoreID implementation = new RubyScoreID();

        vm.broadcast(operatorPK);
        proxy.upgradeToAndCall(address(implementation), "");
    }
}
