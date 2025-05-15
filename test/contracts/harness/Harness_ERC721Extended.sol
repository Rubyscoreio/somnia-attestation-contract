// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {ERC721Extended} from "src/extensions/ERC721Extended.sol";

contract Harness_ERC721Extended is ERC721Extended {
    function initialize(string calldata _name, string calldata _symbol) public initializer {
        __ERC721Extended_init(_name, _symbol);
    }

    function exposed_safeTransfer(address _from, address _to, uint256 _tokenId, bytes memory _data) public {
        _safeTransfer(_from, _to, _tokenId, _data);
    }

    function helper_mint(address _user, uint256 _tokenId) public {
        _mint(_user, _tokenId);
    }
}
