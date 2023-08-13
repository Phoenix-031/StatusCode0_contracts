// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FixedDeposit {
    address public owner;
    
    struct Deposit {
        uint256 amount;
        uint256 timestamp;
        uint256 lockDuration;
        bool withdrawn;
    }
    
    mapping(address => Deposit[]) public deposits;
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    
    function fixFunds(uint256 lockDuration) external payable {
        require(lockDuration == 2 || lockDuration == 12 || lockDuration == 18 || lockDuration == 24, "Invalid lock duration");
        
        uint256 amount = msg.value;
        
        if (lockDuration == 2) {
            amount += 0.5 ether;
        }
        
        deposits[msg.sender].push(Deposit(amount, block.timestamp, lockDuration, false));
    }
    
    function calculateInterest(uint256 amount, uint256 lockDuration) internal pure returns (uint256) {
        if (lockDuration == 12) {
            return (amount * 7) / 100;
        } else if (lockDuration == 18) {
            return (amount * 8) / 100;
        } else if (lockDuration == 24) {
            return (amount * 9) / 100;
        }
        return 0;
    }
    
    function withdraw(uint256 depositIndex) external {
        require(depositIndex < deposits[msg.sender].length, "Invalid deposit index");
        Deposit storage deposit = deposits[msg.sender][depositIndex];
        
        require(!deposit.withdrawn, "Already withdrawn");
        
        uint256 interest = calculateInterest(deposit.amount, deposit.lockDuration);
        uint256 totalAmount = deposit.amount + interest;
        
        // Mark the deposit as withdrawn
        deposit.withdrawn = true;
        
        payable(msg.sender).transfer(totalAmount);
    }
    
    function getActiveDepositsCount() external view returns (uint256) {
        uint256 activeCount = 0;
        for (uint256 i = 0; i < deposits[msg.sender].length; i++) {
            if (!deposits[msg.sender][i].withdrawn) {
                activeCount++;
            }
        }
        return activeCount;
    }
    
    function getDepositDetails(uint256 depositIndex) external view returns (uint256, uint256, uint256, bool) {
        require(depositIndex < deposits[msg.sender].length, "Invalid deposit index");
        Deposit memory deposit = deposits[msg.sender][depositIndex];
        return (deposit.amount, deposit.timestamp, deposit.lockDuration, deposit.withdrawn);
    }
    
    function getUserDepositIndexes() external view returns (uint256[] memory) {
        uint256[] memory indexes = new uint256[](deposits[msg.sender].length);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < deposits[msg.sender].length; i++) {
            if (!deposits[msg.sender][i].withdrawn) {
                indexes[currentIndex] = i;
                currentIndex++;
            }
        }
        return indexes;
    }
    
    function getTimeLeftForDeposit(uint256 depositIndex) external view returns (uint256) {
        require(depositIndex < deposits[msg.sender].length, "Invalid deposit index");
        Deposit memory deposit = deposits[msg.sender][depositIndex];
        
        if (block.timestamp >= deposit.timestamp + deposit.lockDuration * 1 minutes) {
            return 0;
        } else {
            return (deposit.timestamp + deposit.lockDuration * 1 minutes) - block.timestamp;
        }
    }
    
    function contractBalance() external view onlyOwner returns (uint256) {
        return address(this).balance;
    }
}
