// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Strings} from "@openzeppelin/5.3.0/utils/Strings.sol";
import {IERC721Errors} from "@openzeppelin/5.3.0/interfaces/draft-IERC6093.sol";
import {Storage_ERC721Extended} from "test/contracts/storage/Storage_ERC721Extended.sol";

import {ERC721Extended} from "src/extensions/ERC721Extended.sol";

abstract contract Suite_ERC721Extended is Storage_ERC721Extended {
    using Strings for uint256;

    function test_Deployment_ERC721Extended(uint256 _tokenId) public {
        vm.assertEq(toComparable(erc721Extended.name()), toComparable("Test"));
        vm.assertEq(toComparable(erc721Extended.symbol()), toComparable("TST"));
    }

    function test_TokenURI_Ok(address _user, uint256 _tokenId) public {
        vm.assume(_user != address(0));
        erc721Extended.helper_mint(_user, _tokenId);

        vm.assertEq(toComparable(erc721Extended.tokenURI(_tokenId)), toComparable(""));
    }

    function test_TokenURI_Revert_IfTokenIsNotMinted(uint256 _tokenId) public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, _tokenId));
        erc721Extended.tokenURI(_tokenId);
    }

    function test_TransferFrom_Revert_Always(address _sender, address _receiver, uint256 _tokenId) public {
        vm.assume(_sender != address(0));
        vm.assume(_receiver != address(0));
        erc721Extended.helper_mint(_sender, _tokenId);

        vm.expectRevert(ERC721Extended.SoulBoundToken.selector);
        erc721Extended.transferFrom(_sender, _receiver, _tokenId);
    }

    function test_SafeTransferFrom_Revert_Always(address _sender, address _receiver, uint256 _tokenId) public {
        vm.assume(_sender != address(0));
        vm.assume(_receiver != address(0));
        erc721Extended.helper_mint(_sender, _tokenId);

        vm.expectRevert(ERC721Extended.SoulBoundToken.selector);
        erc721Extended.safeTransferFrom(_sender, _receiver, _tokenId);
    }

    function test_ExposedSafeTransfer_Revert_Always(address _sender, address _receiver, uint256 _tokenId, bytes calldata _data) public {
        vm.assume(_sender != address(0));
        vm.assume(_receiver != address(0));
        erc721Extended.helper_mint(_sender, _tokenId);

        vm.expectRevert(ERC721Extended.SoulBoundToken.selector);
        erc721Extended.exposed_safeTransfer(_sender, _receiver, _tokenId, _data);
    }
}
