// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Profile.sol";
import "./NFTManager.sol";

contract MasterContract {
    mapping(address => address) public profileContracts;
    address public owner;
    NFTManager public nftManager; 

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    constructor(address _nftManagerAddress, address _fixedDepositContract) {
        owner = msg.sender;
        nftManager = NFTManager(_nftManagerAddress);
        fixedDepositContract = FixedDeposit(_fixedDepositContract); 
    }

    function createProfile(
        string memory _name,
        string memory _creditFile
    ) external {
        require(profileContracts[msg.sender] == address(0), "Profile already exists for this wallet address.");

        ProfileContract newProfile = new ProfileContract(_name, msg.sender, _creditFile);
        profileContracts[msg.sender] = address(newProfile);
    }

    function setProfilePicture(string memory _profilePicture) external {
        ProfileContract(profileContracts[msg.sender]).updateProfilePicture(_profilePicture);
    }

    function setFixedDepositData(uint256 _noOfDeposits, uint256 _totalAmount) external {
        ProfileContract(profileContracts[msg.sender]).setFixedDepositDetails(_noOfDeposits, _totalAmount);
    }

    function setLoanData(
        uint256 _noOfLoanTaken,
        uint256 _noOfLoanSettled,
        uint256 _noOfLoanFailedToSettle,
        uint256 _creditScore
    ) external {
        ProfileContract(profileContracts[msg.sender]).setLoanDetails(
            _noOfLoanTaken,
            _noOfLoanSettled,
            _noOfLoanFailedToSettle,
            _creditScore
        );
    }

    function setActiveLoanData(
        bool _activeLoan,
        string memory _activeLoanType,
        uint256 _activeLoanAmount,
        uint256 _activeLoanTimePeriod
    ) external {
        ProfileContract(profileContracts[msg.sender]).setActiveLoanDetails(
            _activeLoan,
            _activeLoanType,
            _activeLoanAmount,
            _activeLoanTimePeriod
        );
    }

    function setLoanRequestStatus(string memory _loanRequestStatus) external onlyOwner {
        // Call the setLoanRequestStatus function in the Profile contract
        ProfileContract(profileContracts[msg.sender]).setLoanRequestStatus(_loanRequestStatus);
    }

    function setLoanDocuments(string memory _loanDocuments) external onlyOwner {
        ProfileContract(profileContracts[msg.sender]).setLoanDocuments(_loanDocuments);
    }

    function setPersonalDocuments(string memory _personalDocuments) external onlyOwner {
        ProfileContract(profileContracts[msg.sender]).setPersonalDocuments(_personalDocuments);
    }

    function getProfileData() external view returns (string memory, address, string memory, string memory) {
        return ProfileContract(profileContracts[msg.sender]).getNameWalletCreditFileProfilePicture();
    }

    function getFixedDepositData() external view returns (uint256, uint256) {
        return ProfileContract(profileContracts[msg.sender]).getFixedDepositDetails();
    }

    function getLoanData()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return ProfileContract(profileContracts[msg.sender]).getLoanDetails();
    }

    function getCreditScore() external view returns (uint256) {
        return ProfileContract(profileContracts[msg.sender]).getCreditScore();
    }

    function getActiveLoanData()
        external
        view
        returns (
            bool,
            string memory,
            uint256,
            uint256
        )
    {
        return ProfileContract(profileContracts[msg.sender]).getActiveLoanDetails();
    }

    function getLoanRequestStatus() external view returns (string memory) {
        // Call the getLoanRequestStatus function in the Profile contract
        return ProfileContract(profileContracts[msg.sender]).getLoanRequestStatus();
    }

    function getLoanDocuments() external view returns (string memory) {
        return ProfileContract(profileContracts[msg.sender]).getLoanDocuments();
    }

    function getPersonalDocuments() external view returns (string memory) {
        return ProfileContract(profileContracts[msg.sender]).getPersonalDocuments();
    }

    function requestLoanWithNFT(uint256 _loanAmount, address _nftAddress) external {
     require(_loanAmount > 0, "Loan amount must be greater than 0");
     require(profileContracts[msg.sender] != address(0), "Profile does not exist for this wallet address");

     // Check if the NFT exists and is owned by the user
     (bool nftOwned, uint256 nftValue) = nftManager.checkNft(msg.sender, _nftAddress, 0);
     require(nftOwned, "User does not own the specified NFT");

     // Check if the loan amount is less than or equal to the NFT value
     require(_loanAmount <= nftValue, "Loan amount is greater than the NFT value");

     ProfileContract userProfile = ProfileContract(profileContracts[msg.sender]);

     // Check if the user has an active loan
     (bool activeLoan,,,) = userProfile.getActiveLoanDetails();
     require(!activeLoan, "User already has an active loan");

     // Update loan request status based on NFT value
     string memory loanRequestStatus = (nftValue >= _loanAmount) ? "approved" : "rejected";
     userProfile.setLoanRequestStatus(loanRequestStatus);
    }


    function getAllNFTsForUser(address _userWalletAddress) external view returns (NFTManager.NFT[] memory) {
        return nftManager.getAll(_userWalletAddress);
    }
}

