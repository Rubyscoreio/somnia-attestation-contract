// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {IERC20} from "@openzeppelin/5.3.0/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/5.3.0/token/ERC20/utils/SafeERC20.sol";

struct Asset {
    address assetAddress;
    uint256 amount;
}

abstract contract WithdrawingModule {
    using SafeERC20 for IERC20;

    event Withdrawn(address indexed receiver, address indexed asset, uint256 amount);

    function _withdraw(address payable _receiver, Asset memory _asset) internal {
        if (_asset.assetAddress == address(0)) {
            _sendNativeToken(_receiver, _asset.amount);
        } else {
            _sendERC20Token(_asset.assetAddress, _receiver, _asset.amount);
        }

        emit Withdrawn(_receiver, _asset.assetAddress, _asset.amount);
    }

    function _sendNativeToken(address payable _receiver, uint256 _amount) internal {
        (bool sent,) = _receiver.call{value: _amount}("");
        require(sent, "Failed to send native token");
    }

    function _sendERC20Token(address _token, address _receiver, uint256 _amount) internal {
        IERC20(_token).safeTransfer(_receiver, _amount);
    }
}
