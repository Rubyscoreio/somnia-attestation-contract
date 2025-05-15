// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {ECDSA} from "@openzeppelin/5.3.0/utils/cryptography/ECDSA.sol";
import {Strings} from "@openzeppelin/5.3.0/utils/Strings.sol";
import {UUPSUpgradeable} from "@openzeppelin/5.3.0/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/upgradeable/5.3.0/access/AccessControlUpgradeable.sol";
import {ERC721Extended} from "./extensions/ERC721Extended.sol";
import {EIP712Upgradeable} from "@openzeppelin/upgradeable/5.3.0/utils/cryptography/EIP712Upgradeable.sol";
import "./WithdrawingModule.sol";

contract SomniaAttestation is AccessControlUpgradeable, UUPSUpgradeable, ERC721Extended, EIP712Upgradeable, WithdrawingModule {
    using Strings for uint256;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    string private constant NAME = "Attestation";
    string private constant VERSION = "0.1.0";
    bytes32 private constant ATTESTATION_SIGNATURE_STRUCT_HASH = keccak256("AttestationAllowance(address user, uint256 nonce)");

    uint256 public tokenCounter;
    uint256 public attestationFee;
    string public baseUri;
    string public tokenUri;

    mapping(address user => uint256 nonce) public attestationNonces;

    event Attested(address indexed user, uint256 attestationId);
    event AttestationNonceUpdated(address indexed user, uint256 updatedNonce);
    event BaseUriChanged(string _newBaseUri);
    event AttestationFeeChanged(uint256 _newFee);
    event TokenUriChanged(string _newTokenUri);

    error InvalidSignature();
    error NotEnoughPayment(uint256 received, uint256 expected);
    error AlreadyAttested(address _user);

    function initialize(string calldata _name, string calldata _symbol, address _admin, address _operator, uint256 _attestationFee) public initializer {
        __AccessControl_init();
        __EIP712_init(NAME, VERSION);
        __ERC721Extended_init(_name, _symbol);

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(OPERATOR_ROLE, _operator);

        _setAttestationFee(_attestationFee);
    }

    function claimAttestation(address _user, bytes calldata _signature) public payable {
        if (balanceOf(_user) != 0) revert AlreadyAttested(_user);
        if (msg.value < attestationFee) revert NotEnoughPayment(msg.value, attestationFee);

        bytes32 digest = composeNextAttestationAllowanceDigest(_user);
        if (!hasRole(OPERATOR_ROLE, ECDSA.recover(digest, _signature))) revert InvalidSignature();

        uint256 newNonce = _getNextAttestationNonce(_user);
        attestationNonces[_user] = newNonce;

        tokenCounter += 1;

        emit AttestationNonceUpdated(_user, newNonce);
        emit Attested(_user, tokenCounter);

        _mint(_user, tokenCounter);
    }

    function composeNextAttestationAllowanceDigest(address _user) public view returns(bytes32 digest) {
        return _composeAttestationAllowanceDigest(_user, _getNextAttestationNonce(_user));
    }

    function setBaseUri(string calldata _newBaseUri) public onlyRole(OPERATOR_ROLE) {
        baseUri = _newBaseUri;

        emit BaseUriChanged(_newBaseUri);
    }

    function setTokenUri(string calldata _newTokenUri) public onlyRole(OPERATOR_ROLE) {
        tokenUri = _newTokenUri;

        emit TokenUriChanged(_newTokenUri);
    }

    function setAttestationFee(uint256 _newAttestationFee) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setAttestationFee(_newAttestationFee);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        string memory _tokenURI = tokenUri;
        string memory base = _baseURI();

        return string.concat(base, _tokenURI);
    }

    function burn(uint256 tokenId) public override onlyRole(OPERATOR_ROLE) {
        _burn(tokenId);
    }

    function withdraw(address _receiver, Asset calldata _asset) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _withdraw(payable(_receiver), _asset);
    }

    function supportsInterface(bytes4 interfaceId) public view override(AccessControlUpgradeable, ERC721Extended) returns(bool) {
        return AccessControlUpgradeable.supportsInterface(interfaceId)
            || ERC721Extended.supportsInterface(interfaceId);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(OPERATOR_ROLE) {}

    function _composeAttestationAllowanceDigest(address _receiver, uint256 _nonce) internal view returns(bytes32 digest) {
        digest = _hashTypedDataV4(keccak256( abi.encode(
            ATTESTATION_SIGNATURE_STRUCT_HASH,
            _receiver,
            _nonce
        )));
    }

    function _getNextAttestationNonce(address _user) internal view returns(uint256) {
        return attestationNonces[_user] + 1;
    }

    function _setAttestationFee(uint256 _newAttestationFee) internal {
        attestationFee = _newAttestationFee;

        emit AttestationFeeChanged(_newAttestationFee);
    }
}
