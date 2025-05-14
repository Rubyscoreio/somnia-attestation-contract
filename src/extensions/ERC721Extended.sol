// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {IERC721} from "@openzeppelin/5.3.0/token/ERC721/IERC721.sol";
import {ERC721BurnableUpgradeable} from "@openzeppelin/upgradeable/5.3.0/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import {ERC721Upgradeable} from "@openzeppelin/upgradeable/5.3.0/token/ERC721/ERC721Upgradeable.sol";
import {ERC721URIStorageUpgradeable} from "@openzeppelin/upgradeable/5.3.0/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";

abstract contract ERC721Extended is  ERC721Upgradeable, ERC721BurnableUpgradeable, ERC721URIStorageUpgradeable {
    error SoulBoundToken();

    function __ERC721Extended_init(string calldata _name, string calldata _symbol) internal {
        __ERC721_init(_name, _symbol);
        __ERC721URIStorage_init();
        __ERC721Burnable_init();
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory) {
        return ERC721URIStorageUpgradeable.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns(bool) {
        return ERC721Upgradeable.supportsInterface(interfaceId)
            || ERC721URIStorageUpgradeable.supportsInterface(interfaceId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override(IERC721, ERC721Upgradeable) {
        revert SoulBoundToken();
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal override {
        revert SoulBoundToken();
    }
}
