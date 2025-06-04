// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {RubyScoreID} from "src/RubyScoreID.sol";

contract Harness_RubyScoreID is RubyScoreID {
    function exposed_baseURI() public view returns(string memory) {
        return _baseURI();
    }

    function exposed_composeAttestationAllowanceDigest(address _user, uint256 _nonce) public view returns(bytes32) {
        return _composeAttestationAllowanceDigest(_user, _nonce);
    }

    function exposed_getNextAttestationNonce(address _user) public view returns(uint256) {
        return exposed_getNextAttestationNonce(_user);
    }

    function exposed_safeTransfer(address _from, address _to, uint256 _tokenId, bytes memory _data) public {
        _safeTransfer(_from, _to, _tokenId, _data);
    }

    function helper_setBaseUri(string calldata _newBaseUri) public {
        baseUri = _newBaseUri;
    }

    function helper_setTokenUri(string calldata _newTokenUri) public {
        tokenUri = _newTokenUri;
    }

    function helper_mint(address _user, uint256 _tokenId) public {
        _mint(_user, _tokenId);
    }

    function helper_grantRole(bytes32 _role, address _account) public {
        _grantRole(_role, _account);
    }

    function helper_revokeRole(bytes32 _role, address _account) public {
        _revokeRole(_role, _account);
    }
}
