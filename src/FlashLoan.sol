// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC3156FlashLender} from "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract FlashLoan is ReentrancyGuard, IERC3156FlashLender {
    using SafeERC20 for IERC20;

    IERC20 public token;

    uint256 public constant FLASH_LOAN_FEE = 5; // 0.05%

    mapping(address => uint256) public depositedAmount;

    error InvalidToken();
    error InsufficientBalance();
    error FlashLoanFailed();
    error RepaymentFailed();

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor(address _token) {
        if (_token == address(0)) revert InvalidToken();
        token = IERC20(_token);
    }

    function deposit(uint256 _amount) external {
        token.safeTransferFrom(msg.sender, address(this), _amount);
        depositedAmount[msg.sender] += _amount;
        emit Deposit(msg.sender, _amount);
    }

    function maxFlashLoan(address _token) external view returns (uint256) {
        return IERC20(_token).balanceOf(address(this));
    }
    function flashFee(
        address _token,
        uint256 _amount
    ) external pure override returns (uint256) {
        return (_amount * FLASH_LOAN_FEE) / 10_000;
    }

    function flashLoan(
        IERC3156FlashBorrower receiver,
        address _token,
        uint256 _amount,
        bytes calldata data
    ) external override nonReentrant returns (bool) {
        if (_token != address(token)) revert InvalidToken();
        if (_amount > token.balanceOf(address(this)))
            revert InsufficientBalance();
        address initiator = msg.sender;

        token.safeTransfer(address(receiver), _amount);
        if (
            receiver.onFlashLoan(initiator, _token, _amount, 0, data) !=
            keccak256("ERC3156FlashBorrower.onFlashLoan")
        ) revert FlashLoanFailed();

        if (!token.transferFrom(address(receiver), address(this), _amount))
            revert RepaymentFailed();
        return true;
    }

    function withdraw() external nonReentrant {
        token.safeTransfer(msg.sender, depositedAmount[msg.sender]);
        depositedAmount[msg.sender] = 0;
        emit Withdraw(msg.sender, depositedAmount[msg.sender]);
    }
}
