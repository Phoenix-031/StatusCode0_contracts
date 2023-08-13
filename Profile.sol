// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProfileContract {
    address public owner;
    bool public activeLoan;
    string public activeLoanType;
    uint256 public activeLoanAmount;
    uint256 public activeLoanTimePeriod;
    string public loanRequestStatus;
    string public personalDocuments;
    string public loanDocuments;

    struct Profile {
        string name;
        address walletAddress;
        string creditFile;
        string profilePicture;
    }

    struct FixedDeposits {
        uint256 noOfFixedDeposits;
        uint256 totalAmountInFixedDeposit;
    }

    struct LoanPool {
        uint256 totalAmountInvestedInLoanPool;
        uint256 noOfPeerToPeerLoanGiven;
        uint256 totalAmountInPeerToPeerLoanGiven;
    }

    struct Loans {
        uint256 noOfLoanTaken;
        uint256 noOfLoanSettled;
        uint256 noOfLoanFailedToSettled;
        uint256 creditScore;
    }

    mapping(address => Profile) private profiles;
    mapping(address => FixedDeposits) private fixedDeposits;
    mapping(address => LoanPool) private loanPool;
    mapping(address => Loans) private loans;

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner.");
        _;
    }

    constructor(
        string memory _name,
        address _walletAddress,
        string memory _creditFile
    ) {
        owner = msg.sender;
        profiles[msg.sender].name = _name;
        profiles[msg.sender].walletAddress = _walletAddress;
        profiles[msg.sender].creditFile = _creditFile;
    }

    function updateProfilePicture(string memory _profilePicture) external onlyOwner {
        profiles[msg.sender].profilePicture = _profilePicture;
    }

    function setFixedDepositDetails(uint256 _noOfFixedDeposits, uint256 _totalAmountInFixedDeposit) external onlyOwner {
        fixedDeposits[msg.sender].noOfFixedDeposits = _noOfFixedDeposits;
        fixedDeposits[msg.sender].totalAmountInFixedDeposit = _totalAmountInFixedDeposit;
    }

    function setLoanPoolDetails(uint256 _totalAmountInvestedInLoanPool, uint256 _noOfPeerToPeerLoanGiven, uint256 _totalAmountInPeerToPeerLoanGiven) external onlyOwner {
        loanPool[msg.sender].totalAmountInvestedInLoanPool = _totalAmountInvestedInLoanPool;
        loanPool[msg.sender].noOfPeerToPeerLoanGiven = _noOfPeerToPeerLoanGiven;
        loanPool[msg.sender].totalAmountInPeerToPeerLoanGiven = _totalAmountInPeerToPeerLoanGiven;
    }

    function setLoanDetails(uint256 _noOfLoanTaken, uint256 _noOfLoanSettled, uint256 _noOfLoanFailedToSettled, uint256 _creditScore) external onlyOwner {
        loans[msg.sender].noOfLoanTaken = _noOfLoanTaken;
        loans[msg.sender].noOfLoanSettled = _noOfLoanSettled;
        loans[msg.sender].noOfLoanFailedToSettled = _noOfLoanFailedToSettled;
        loans[msg.sender].creditScore = _creditScore;
    }

    function setActiveLoanDetails(bool _activeLoan, string memory _activeLoanType, uint256 _activeLoanAmount, uint256 _activeLoanTimePeriod) external onlyOwner {
        activeLoan = _activeLoan;
        activeLoanType = _activeLoanType;
        activeLoanAmount = _activeLoanAmount;
        activeLoanTimePeriod = _activeLoanTimePeriod;
    }

    function setLoanRequestStatus(string memory _loanRequestStatus) external onlyOwner {
        loanRequestStatus = _loanRequestStatus;
    }

    function setLoanDocuments(string memory _loanDocuments) external onlyOwner {
        loanDocuments = _loanDocuments;
    }

    function setPersonalDocuments(string memory _personalDocuments) external onlyOwner {
        personalDocuments = _personalDocuments;
    }

    function getNameWalletCreditFileProfilePicture()
        external
        view
        returns (
            string memory,
            address,
            string memory,
            string memory
        )
    {
        Profile memory profile = profiles[msg.sender];
        return (profile.name, profile.walletAddress, profile.creditFile, profile.profilePicture);
    }

    function getFixedDepositDetails() external view returns (uint256, uint256) {
        FixedDeposits memory fd = fixedDeposits[msg.sender];
        return (fd.noOfFixedDeposits, fd.totalAmountInFixedDeposit);
    }

    function getLoanPoolDetails()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        LoanPool memory lp = loanPool[msg.sender];
        return (lp.totalAmountInvestedInLoanPool, lp.noOfPeerToPeerLoanGiven, lp.totalAmountInPeerToPeerLoanGiven);
    }

    function getLoanDetails()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        Loans memory l = loans[msg.sender];
        return (l.noOfLoanTaken, l.noOfLoanSettled, l.noOfLoanFailedToSettled, l.creditScore);
    }

    function getActiveLoanDetails()
        external
        view
        returns (
            bool,
            string memory,
            uint256,
            uint256
        )
    {
        return (activeLoan, activeLoanType, activeLoanAmount, activeLoanTimePeriod);
    }

    function getLoanRequestStatus() external view returns (string memory) {
        return loanRequestStatus;
    }

    function getCreditScore() external view returns (uint256)
    {
        Loans memory l = loans[msg.sender];
        return (l.creditScore);
    }

    function getLoanDocuments() external view returns (string memory) {
        return(loanDocuments);
    }

    function getPersonalDocuments() external view returns (string memory) {
        return(personalDocuments);
    }
        
}
