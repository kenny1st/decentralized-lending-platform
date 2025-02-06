
---

### **Example Solidity Contract (`contracts/Lending.sol`)**  
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LendingPlatform is Ownable {
    struct Loan {
        address borrower;
        uint256 collateralAmount;
        uint256 borrowedAmount;
        uint256 interestRate;
        uint256 dueDate;
        bool isRepaid;
    }

    IERC20 public stablecoin;
    mapping(address => Loan) public loans;

    event LoanRequested(address indexed borrower, uint256 amount, uint256 collateral);
    event LoanRepaid(address indexed borrower, uint256 amount);

    constructor(address _stablecoin) {
        stablecoin = IERC20(_stablecoin);
    }

    function requestLoan(uint256 _borrowAmount, uint256 _collateralAmount, uint256 _interestRate) public {
        require(loans[msg.sender].borrowedAmount == 0, "Existing loan must be repaid first");

        stablecoin.transferFrom(msg.sender, address(this), _collateralAmount);
        loans[msg.sender] = Loan(msg.sender, _collateralAmount, _borrowAmount, _interestRate, block.timestamp + 30 days, false);

        emit LoanRequested(msg.sender, _borrowAmount, _collateralAmount);
    }

    function repayLoan() public {
        Loan storage loan = loans[msg.sender];
        require(loan.borrowedAmount > 0, "No active loan");
        require(!loan.isRepaid, "Loan already repaid");

        uint256 repaymentAmount = loan.borrowedAmount + (loan.borrowedAmount * loan.interestRate) / 100;
        stablecoin.transferFrom(msg.sender, address(this), repaymentAmount);

        loan.isRepaid = true;
        stablecoin.transfer(msg.sender, loan.collateralAmount);
        
        emit LoanRepaid(msg.sender, repaymentAmount);
    }
}
