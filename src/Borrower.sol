// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {IERC3156FlashLender} from "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IArbitrage {
    function arbitrage(address _token, uint256 _amount) external returns (bool);
}

contract LoanBorrower is IERC3156FlashBorrower, ReentrancyGuard{
    using SafeERC20 for IERC20;

    IERC20 public token;
    address public initiator;
    IERC3156FlashLender public flashLoan;
    address public arbitrage;


    mapping(address => uint256) public loanAmount;


    error InvalidAddress();
    error FlashLoanFailed();
    error InvalidLender();
    error InvalidInitiator();
    error ArbitrageFailed();
    
    event FlashLoanBorrowed(address indexed initiator, uint256 amount);

    constructor(address _token, address _initiator, IERC3156FlashLender _flashLoan, address _arbitrage) {
        if(_token ==address(0) || _initiator == address(0) || address(_flashLoan) == address(0)) revert InvalidAddress();
        token = IERC20(_token);
        initiator = _initiator;
        flashLoan = _flashLoan;
        arbitrage = _arbitrage;
    }

    function borrow(uint256 amount) external nonReentrant returns (bool) {
        loanAmount[msg.sender] = amount;
        bool success = flashLoan.flashLoan(this, address(token), amount, "");
        if(!success) revert FlashLoanFailed();

        emit FlashLoanBorrowed(msg.sender, amount);
        return success;
    }

    function onFlashLoan(
        address _initiator,
        address _token,
        uint256 _amount,
        uint256 _fee,
        bytes calldata
    ) external override nonReentrant returns (bytes32) {
        if(msg.sender != address(flashLoan)) revert InvalidLender();
        if(_initiator != address(this)) revert InvalidInitiator();

       // TODO: flashloan logic : swap, arbitrage, etc
       bool success = IArbitrage(arbitrage).arbitrage(_token, _amount);
       if(!success) revert ArbitrageFailed();

       // aderyn-ignore-next-line(unchecked-return)
       IERC20(_token).safeIncreaseAllowance(address(flashLoan), _amount + _fee);
       return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}