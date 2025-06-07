// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC3156FlashLender} from "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract FlashLoan is Ownable, ReentrancyGuard, IERC3156FlashLender {
    using SafeERC20 for IERC20;

    uint256 public constant MAX_LOAN_AMOUNT = 1000000000000000000000000;
    uint256 public constant FLASH_LOAN_FEE = 1000000000000000000;

    IERC20 public token;

    constructor(address _token) Ownable(msg.sender) {
        token = IERC20(_token);
        
    }

    function maxFlashLoan(address _token) external pure returns (uint256) {
        return MAX_LOAN_AMOUNT;
    }

    function flashFee(address _token, uint256 _amount) external pure returns (uint256) {
        return FLASH_LOAN_FEE;
    }


    function flashLoan(        
        IERC3156FlashBorrower receiver,
        address _token,
        uint256 _amount,
        bytes calldata data) external override returns (bool) {
        // TODO: Implement flash loan logic
    }

    function withdraw() public {
        // TODO: Implement safe withdraw logic

    }
}