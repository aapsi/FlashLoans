// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title Arbitrage
 * @notice This contract simply mimics the arbitrage of swaps between two different exchanges.
 */
contract Arbitrage {
    using SafeERC20 for IERC20;

    address public token;

    error InvalidToken();

    event Arbitrage(address indexed user, uint256 amount, uint256 profit);
    constructor(address _token) {
        if (_token == address(0)) revert InvalidToken();
        token = _token;
    }

    function arbitrage(address _token, uint256 _amount) external returns (bool) {
        // TODO: Implement arbitrage logic
        // accept tokens from a user
        // increase the tokens by 10%
        // return the tokens to the user with that 10% increase

        if(_token != token) revert InvalidToken();

        IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);
        IERC20(token).safeTransfer(msg.sender, _amount * 110 / 100);
        emit Arbitrage(msg.sender, _amount, _amount * 110 / 100 - _amount);
        return true;
    }
}