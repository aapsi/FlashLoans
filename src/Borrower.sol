// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
contract LoanBorrower is IERC3156FlashBorrower, ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public token;
    address public initiator;

    constructor(address _token, address _initiator) Ownable(msg.sender) {
        token = IERC20(_token);
        initiator = _initiator;
    }

    function onFlashLoan(
        address _initiator,
        address _token,
        uint256 _amount,
        uint256 _fee,
        bytes calldata data
    ) external override returns (bytes32) {
        // TODO: Implement flash loan logic
    }
}