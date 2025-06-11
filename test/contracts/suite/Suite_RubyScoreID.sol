// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Strings} from "@openzeppelin/5.3.0/utils/Strings.sol";
import {IERC721Errors} from "@openzeppelin/5.3.0/interfaces/draft-IERC6093.sol";
import {IAccessControl} from "@openzeppelin/5.3.0/access/IAccessControl.sol";
import {IERC721} from "@openzeppelin/5.3.0/token/ERC721/IERC721.sol";

import {RubyScoreID} from "src/RubyScoreID.sol";
import {ERC721Extended} from "src/extensions/ERC721Extended.sol";
import {Storage_RubyScoreID} from "test/contracts/storage/Storage_RubyScoreID.sol";
import "src/WithdrawingModule.sol";

abstract contract Suite_RubyScoreID is Storage_RubyScoreID {
    using Strings for uint256;

    function test_Deployment_ERC721Extended(uint256 _tokenId) public {
        vm.assertTrue(attestationContract.hasRole(DEFAULT_ADMIN_ROLE, admin));
        vm.assertTrue(attestationContract.hasRole(OPERATOR_ROLE, operator));
        vm.assertEq(attestationContract.attestationFee(), attestationFee);
        vm.assertEq(toComparable(attestationContract.name()), toComparable("RubyScore ID Somnia"));
        vm.assertEq(toComparable(attestationContract.symbol()), toComparable("TST"));
    }

    function test_TokenURI_Ok(address _user, uint256 _tokenId, string calldata _baseUri, string calldata _tokenUri)
        public
    {
        vm.assume(_user != address(0));
        attestationContract.helper_mint(_user, _tokenId);
        attestationContract.helper_setBaseUri(_baseUri);
        attestationContract.helper_setTokenUri(_tokenUri);

        vm.assertEq(
            toComparable(attestationContract.tokenURI(_tokenId)), toComparable(string.concat(_baseUri, _tokenUri))
        );
    }

    function test_TokenURI_Revert_IfTokenIsNotMinted(uint256 _tokenId) public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, _tokenId));
        attestationContract.tokenURI(_tokenId);
    }

    function test_TransferFrom_Revert_Always(address _sender, address _receiver, uint256 _tokenId) public {
        vm.assume(_sender != address(0));
        vm.assume(_receiver != address(0));
        attestationContract.helper_mint(_sender, _tokenId);

        vm.expectRevert(ERC721Extended.SoulBoundToken.selector);
        attestationContract.transferFrom(_sender, _receiver, _tokenId);
    }

    function test_SafeTransferFrom_Revert_Always(address _sender, address _receiver, uint256 _tokenId) public {
        vm.assume(_sender != address(0));
        vm.assume(_receiver != address(0));
        attestationContract.helper_mint(_sender, _tokenId);

        vm.expectRevert(ERC721Extended.SoulBoundToken.selector);
        attestationContract.safeTransferFrom(_sender, _receiver, _tokenId);
    }

    function test_ExposedSafeTransfer_Revert_Always(
        address _sender,
        address _receiver,
        uint256 _tokenId,
        bytes calldata _data
    ) public {
        vm.assume(_sender != address(0));
        vm.assume(_receiver != address(0));
        attestationContract.helper_mint(_sender, _tokenId);

        vm.expectRevert(ERC721Extended.SoulBoundToken.selector);
        attestationContract.exposed_safeTransfer(_sender, _receiver, _tokenId, _data);
    }

    function test_ComposeNextAttestationAllowanceDigest_Ok(address _user) public {
        assertEq(
            attestationContract.composeNextAttestationAllowanceDigest(_user),
            attestationContract.exposed_composeAttestationAllowanceDigest(
                _user, attestationContract.attestationNonces(_user) + 1
            )
        );
    }

    function test_SetBaseUri_Ok(
        string calldata _newBaseUri,
        address _operator,
        string calldata _tokenUri,
        uint256 _tokenId
    ) public {
        attestationContract.helper_grantRole(OPERATOR_ROLE, _operator);
        attestationContract.helper_setTokenUri(_tokenUri);
        attestationContract.helper_mint(address(1), _tokenId);

        vm.expectEmit();
        emit RubyScoreID.BaseUriChanged(_newBaseUri);

        vm.prank(_operator);
        attestationContract.setBaseUri(_newBaseUri);

        vm.assertEq(
            toComparable(attestationContract.tokenURI(_tokenId)), toComparable(string.concat(_newBaseUri, _tokenUri))
        );
    }

    function test_SetBaseUri_Revert_IfSenderIsNotAnOwner(
        string calldata _newBaseUri,
        address _anonym,
        string calldata _tokenUri,
        uint256 _tokenId
    ) public {
        attestationContract.helper_setTokenUri(_tokenUri);
        attestationContract.helper_mint(address(1), _tokenId);

        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, _anonym, OPERATOR_ROLE)
        );

        vm.prank(_anonym);
        attestationContract.setBaseUri(_newBaseUri);
    }

    function test_SetTokenUri_Ok(
        string calldata _newTokenUri,
        address _operator,
        string calldata _baseUri,
        uint256 _tokenId
    ) public {
        attestationContract.helper_grantRole(OPERATOR_ROLE, _operator);
        attestationContract.helper_setBaseUri(_baseUri);
        attestationContract.helper_mint(address(1), _tokenId);

        vm.expectEmit();
        emit RubyScoreID.TokenUriChanged(_newTokenUri);

        vm.prank(_operator);
        attestationContract.setTokenUri(_newTokenUri);

        vm.assertEq(
            toComparable(attestationContract.tokenURI(_tokenId)), toComparable(string.concat(_baseUri, _newTokenUri))
        );
    }

    function test_SetTokenUri_Revert_IfSenderIsNotAnOwner(
        string calldata _newTokenUri,
        address _anonym,
        string calldata _baseUri,
        uint256 _tokenId
    ) public {
        attestationContract.helper_setBaseUri(_baseUri);
        attestationContract.helper_mint(address(1), _tokenId);

        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, _anonym, OPERATOR_ROLE)
        );

        vm.prank(_anonym);
        attestationContract.setTokenUri(_newTokenUri);
    }

    function test_Burn_Ok(address _operator, uint256 _tokenId) public {
        attestationContract.helper_grantRole(OPERATOR_ROLE, _operator);
        attestationContract.helper_mint(address(1), _tokenId);

        vm.expectEmit();
        emit IERC721.Transfer(address(1), address(0), _tokenId);

        vm.prank(_operator);
        attestationContract.burn(_tokenId);

        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, _tokenId));

        attestationContract.ownerOf(_tokenId);
    }

    function test_Burn_Revert_IfSenderIsNotAnOwner(address _anonym, uint256 _tokenId) public {
        attestationContract.helper_mint(address(1), _tokenId);

        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, _anonym, OPERATOR_ROLE)
        );

        vm.prank(_anonym);
        attestationContract.burn(_tokenId);
    }

    function test_ClaimAttestation_Ok(address _user, uint32 _operatorIndex) public {
        assumeUnusedAddress(_user);

        (uint256 operatorPK, address operator) = generateWallet(_operatorIndex, "Operator");

        attestationContract.helper_grantRole(OPERATOR_ROLE, operator);

        bytes32 digest = attestationContract.composeNextAttestationAllowanceDigest(_user);

        bytes memory signature = helper_sign(operatorPK, digest);

        uint256 expectedTokenId = attestationContract.tokenCounter() + 1;

        uint256 balanceCallerBefore = address(this).balance;
        uint256 balanceContractBefore = address(attestationContract).balance;

        vm.expectEmit();
        emit RubyScoreID.Attested(_user, expectedTokenId);

        vm.expectEmit();
        emit IERC721.Transfer(address(0), _user, expectedTokenId);

        attestationContract.claimAttestation{value: attestationFee}(_user, signature);

        uint256 balanceCallerAfter = address(this).balance;
        uint256 balanceContractAfter = address(attestationContract).balance;

        vm.assertEq(attestationContract.balanceOf(_user), 1);
        vm.assertEq(attestationContract.attestationNonces(_user), 1);
        vm.assertEq(balanceCallerAfter, balanceCallerBefore - attestationFee);
        vm.assertEq(balanceContractAfter, balanceContractBefore + attestationFee);
    }

    function test_ClaimAttestation_RevertIfSignerIsNotAnOwner(address _user, uint32 _anonymIndex) public {
        assumeUnusedAddress(_user);

        (uint256 anonymPK, address anonym) = generateWallet(_anonymIndex, "Anonym");

        bytes32 digest = attestationContract.composeNextAttestationAllowanceDigest(_user);

        bytes memory signature = helper_sign(anonymPK, digest);

        uint256 balanceCallerBefore = address(this).balance;
        uint256 balanceContractBefore = address(attestationContract).balance;

        uint256 expectedTokenId = attestationContract.tokenCounter() + 1;

        vm.expectRevert(abi.encodeWithSelector(RubyScoreID.InvalidSignature.selector));
        attestationContract.claimAttestation{value: attestationFee}(_user, signature);

        uint256 balanceCallerAfter = address(this).balance;
        uint256 balanceContractAfter = address(attestationContract).balance;

        vm.assertEq(attestationContract.balanceOf(_user), 0);
        vm.assertEq(attestationContract.attestationNonces(_user), 0);
        vm.assertEq(balanceCallerAfter, balanceCallerBefore);
        vm.assertEq(balanceContractAfter, balanceContractBefore);
    }

    function test_ClaimAttestation_Revert_IfSignerIsInvalid(address _user, address _invalidUser, uint32 _operatorIndex)
        public
    {
        assumeUnusedAddress(_user);
        assumeUnusedAddress(_invalidUser);

        (uint256 operatorPK, address operator) = generateWallet(_operatorIndex, "Operator");

        attestationContract.helper_grantRole(OPERATOR_ROLE, operator);

        bytes32 digest = attestationContract.composeNextAttestationAllowanceDigest(_user);

        bytes memory signature = helper_sign(operatorPK, digest);

        uint256 balanceCallerBefore = address(this).balance;
        uint256 balanceContractBefore = address(attestationContract).balance;

        uint256 expectedTokenId = attestationContract.tokenCounter() + 1;

        vm.expectRevert(abi.encodeWithSelector(RubyScoreID.InvalidSignature.selector));
        attestationContract.claimAttestation{value: attestationFee}(_invalidUser, signature);

        uint256 balanceCallerAfter = address(this).balance;
        uint256 balanceContractAfter = address(attestationContract).balance;

        vm.assertEq(attestationContract.balanceOf(_user), 0);
        vm.assertEq(attestationContract.attestationNonces(_user), 0);
        vm.assertEq(balanceCallerAfter, balanceCallerBefore);
        vm.assertEq(balanceContractAfter, balanceContractBefore);
    }

    function test_ClaimAttestation_Revert_IfNotEnoughValue(address _user, uint32 _operatorIndex) public {
        assumeUnusedAddress(_user);

        (uint256 operatorPK, address operator) = generateWallet(_operatorIndex, "Operator");

        attestationContract.helper_grantRole(OPERATOR_ROLE, operator);

        bytes32 digest = attestationContract.composeNextAttestationAllowanceDigest(_user);

        bytes memory signature = helper_sign(operatorPK, digest);

        uint256 expectedTokenId = attestationContract.tokenCounter() + 1;

        uint256 balanceCallerBefore = address(this).balance;
        uint256 balanceContractBefore = address(attestationContract).balance;

        vm.expectRevert(abi.encodeWithSelector(RubyScoreID.NotEnoughPayment.selector, 0, attestationFee));

        attestationContract.claimAttestation(_user, signature);

        uint256 balanceCallerAfter = address(this).balance;
        uint256 balanceContractAfter = address(attestationContract).balance;

        vm.assertEq(attestationContract.balanceOf(_user), 0);
        vm.assertEq(attestationContract.attestationNonces(_user), 0);
        vm.assertEq(balanceCallerAfter, balanceCallerBefore);
        vm.assertEq(balanceContractAfter, balanceContractBefore);
    }

    function test_SetAttestationFee_Ok(address _admin, uint256 _newAttestationPrice) public {
        vm.assume(_admin != address(0));

        attestationContract.helper_grantRole(DEFAULT_ADMIN_ROLE, _admin);

        vm.expectEmit();
        emit RubyScoreID.AttestationFeeChanged(_newAttestationPrice);

        vm.prank(admin);
        attestationContract.setAttestationFee(_newAttestationPrice);

        vm.assertEq(attestationContract.attestationFee(), _newAttestationPrice);
    }

    function test_SetMintPrice_Revert_IfCallerIsNotAnAdmin(address _anonym, uint256 _newMintPrice) public {
        vm.assume(_anonym != address(0));
        vm.assume(!attestationContract.hasRole(DEFAULT_ADMIN_ROLE, _anonym));

        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, _anonym, DEFAULT_ADMIN_ROLE
            )
        );

        vm.prank(_anonym);
        attestationContract.setAttestationFee(_newMintPrice);
    }

    function test_withdraw_Ok_ERC20asset(address _receiver, Asset memory _asset, uint32 _adminIndex) public {
        assumeUnusedAddress(_receiver);
        assumeUnusedAddress(_asset.assetAddress);

        deployMockERC20(_asset.assetAddress);

        deal(_asset.assetAddress, address(attestationContract), _asset.amount);
        (, address admin) = generateWallet(_adminIndex, "Admin");
        attestationContract.helper_grantRole(DEFAULT_ADMIN_ROLE, admin);

        uint256 contractBalanceBefore = IERC20(_asset.assetAddress).balanceOf(address(attestationContract));
        uint256 receiverBalanceBefore = IERC20(_asset.assetAddress).balanceOf(_receiver);

        vm.expectEmit();
        emit WithdrawingModule.Withdrawn(_receiver, _asset.assetAddress, _asset.amount);

        vm.prank(admin);
        attestationContract.withdraw(_receiver, _asset);

        uint256 contractBalanceAfter = IERC20(_asset.assetAddress).balanceOf(address(attestationContract));
        uint256 receiverBalanceAfter = IERC20(_asset.assetAddress).balanceOf(_receiver);

        assertEq(contractBalanceAfter, contractBalanceBefore - _asset.amount);
        assertEq(receiverBalanceAfter, receiverBalanceBefore + _asset.amount);
    }

    function test_withdraw_Ok_NativeAsset(address _receiver, Asset memory _asset, uint32 _adminIndex) public {
        vm.assume(_receiver != address(attestationContract));
        assumePayable(_receiver);

        deal(address(attestationContract), _asset.amount);
        (, address admin) = generateWallet(_adminIndex, "Admin");
        attestationContract.helper_grantRole(DEFAULT_ADMIN_ROLE, admin);
        _asset.assetAddress = address(0);

        uint256 contractBalanceBefore = address(attestationContract).balance;
        uint256 receiverBalanceBefore = address(_receiver).balance;

        vm.expectEmit();
        emit WithdrawingModule.Withdrawn(_receiver, _asset.assetAddress, _asset.amount);

        vm.prank(admin);
        attestationContract.withdraw(_receiver, _asset);

        uint256 contractBalanceAfter = address(attestationContract).balance;
        uint256 receiverBalanceAfter = address(_receiver).balance;

        assertEq(contractBalanceAfter, contractBalanceBefore - _asset.amount);
        assertEq(receiverBalanceAfter, receiverBalanceBefore + _asset.amount);
    }

    function test_withdraw_RevertIf_NotAnAdmin(address _receiver, Asset memory _asset, uint32 _anonymIndex) public {
        vm.assume(_receiver != address(attestationContract));
        assumePayable(_receiver);

        deal(address(attestationContract), _asset.amount);
        (, address anonym) = generateWallet(_anonymIndex, "Anonym");
        _asset.assetAddress = address(0);

        uint256 contractBalanceBefore = address(attestationContract).balance;
        uint256 receiverBalanceBefore = address(_receiver).balance;

        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, anonym, DEFAULT_ADMIN_ROLE)
        );

        vm.prank(anonym);
        attestationContract.withdraw(_receiver, _asset);

        uint256 contractBalanceAfter = address(attestationContract).balance;
        uint256 receiverBalanceAfter = address(_receiver).balance;

        assertEq(contractBalanceAfter, contractBalanceBefore);
        assertEq(receiverBalanceAfter, receiverBalanceBefore);
    }
}
