// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BloodDonation is Ownable {

    constructor() Ownable(msg.sender){}

    using Counters for Counters.Counter;

    // Structs
    struct DonationRecord {
        address donor;
        string bloodType;
        uint256 units;
        uint256 timestamp;
        string donationCenter;
        bool verified;
    }

    struct BloodRequest {
        address requester;
        string bloodType;
        uint256 unitsNeeded;
        uint256 unitsFulfilled;
        string hospitalName;
        uint256 timestamp;
        bool active;
    }

    struct Donor {
        string name;
        string bloodType;
        uint256 totalDonations;
        uint256 lastDonationDate;
        bool isVerified;
    }

    // State variables
    Counters.Counter private _donationIdCounter;
    Counters.Counter private _requestIdCounter;

    mapping(address => Donor) public donors;
    mapping(uint256 => DonationRecord) public donations;
    mapping(uint256 => BloodRequest) public bloodRequests;
    mapping(address => uint256[]) public donorDonations;
    mapping(address => uint256[]) public requesterRequests;

    // Events
    event DonorRegistered(address indexed donor, string bloodType);
    event DonationRecorded(uint256 indexed donationId, address indexed donor, string bloodType, uint256 units);
    event DonationVerified(uint256 indexed donationId, address indexed verifier);
    event BloodRequestCreated(uint256 indexed requestId, address indexed requester, string bloodType, uint256 units);
    event RequestFulfilled(uint256 indexed requestId, uint256 indexed donationId);

    // Modifiers
    modifier onlyVerifiedDonor() {
        require(donors[msg.sender].isVerified, "Donor not verified");
        _;
    }

    // Register as donor
    function registerDonor(string memory _name, string memory _bloodType) external {
        require(bytes(donors[msg.sender].name).length == 0, "Donor already registered");

        donors[msg.sender] = Donor({
            name: _name,
            bloodType: _bloodType,
            totalDonations: 0,
            lastDonationDate: 0,
            isVerified: false
        });

        emit DonorRegistered(msg.sender, _bloodType);
    }

    // Verify donor (only owner/admin can verify)
    function verifyDonor(address _donor) external onlyOwner {
        require(bytes(donors[_donor].name).length > 0, "Donor not registered");
        donors[_donor].isVerified = true;
    }

    // Record a donation
    function recordDonation(
        string memory _bloodType,
        uint256 _units,
        string memory _donationCenter
    ) external onlyVerifiedDonor returns (uint256) {
        uint256 donationId = _donationIdCounter.current();
        _donationIdCounter.increment();

        donations[donationId] = DonationRecord({
            donor: msg.sender,
            bloodType: _bloodType,
            units: _units,
            timestamp: block.timestamp,
            donationCenter: _donationCenter,
            verified: false
        });

        donorDonations[msg.sender].push(donationId);
        donors[msg.sender].totalDonations += _units;
        donors[msg.sender].lastDonationDate = block.timestamp;

        emit DonationRecorded(donationId, msg.sender, _bloodType, _units);

        return donationId;
    }

    // Verify donation (only owner/medical authority)
    function verifyDonation(uint256 _donationId) external onlyOwner {
        require(_donationId < _donationIdCounter.current(), "Invalid donation ID");
        require(!donations[_donationId].verified, "Already verified");

        donations[_donationId].verified = true;
        emit DonationVerified(_donationId, msg.sender);
    }

    // Create blood request
    function createBloodRequest(
        string memory _bloodType,
        uint256 _unitsNeeded,
        string memory _hospitalName
    ) external returns (uint256) {
        uint256 requestId = _requestIdCounter.current();
        _requestIdCounter.increment();

        bloodRequests[requestId] = BloodRequest({
            requester: msg.sender,
            bloodType: _bloodType,
            unitsNeeded: _unitsNeeded,
            unitsFulfilled: 0,
            hospitalName: _hospitalName,
            timestamp: block.timestamp,
            active: true
        });

        requesterRequests[msg.sender].push(requestId);

        emit BloodRequestCreated(requestId, msg.sender, _bloodType, _unitsNeeded);

        return requestId;
    }

    // Fulfill request with donation
    function fulfillRequest(uint256 _requestId, uint256 _donationId) external {
        require(_requestId < _requestIdCounter.current(), "Invalid request ID");
        require(_donationId < _donationIdCounter.current(), "Invalid donation ID");

        BloodRequest storage request = bloodRequests[_requestId];
        DonationRecord storage donation = donations[_donationId];

        require(request.active, "Request not active");
        require(donation.verified, "Donation not verified");
        require(
            keccak256(bytes(request.bloodType)) == keccak256(bytes(donation.bloodType)),
            "Blood type mismatch"
        );

        uint256 unitsToFulfill = request.unitsNeeded - request.unitsFulfilled;
        if (donation.units >= unitsToFulfill) {
            request.unitsFulfilled = request.unitsNeeded;
            request.active = false;
        } else {
            request.unitsFulfilled += donation.units;
        }

        emit RequestFulfilled(_requestId, _donationId);
    }

    // View functions
    function getDonorInfo(address _donor) external view returns (Donor memory) {
        return donors[_donor];
    }

    function getDonorDonations(address _donor) external view returns (uint256[] memory) {
        return donorDonations[_donor];
    }

    function getBloodRequest(uint256 _requestId) external view returns (BloodRequest memory) {
        return bloodRequests[_requestId];
    }

    function getActiveRequests() external view returns (uint256[] memory) {
        uint256 activeCount = 0;
        uint256 totalRequests = _requestIdCounter.current();

        // Count active requests
        for (uint256 i = 0; i < totalRequests; i++) {
            if (bloodRequests[i].active) {
                activeCount++;
            }
        }

        // Create array of active request IDs
        uint256[] memory activeRequestIds = new uint256[](activeCount);
        uint256 index = 0;

        for (uint256 i = 0; i < totalRequests; i++) {
            if (bloodRequests[i].active) {
                activeRequestIds[index] = i;
                index++;
            }
        }

        return activeRequestIds;
    }
}

// Badge NFT Contract
contract DonorBadge is ERC721, Ownable {

    constructor() ERC721("BloodDonorBadge", "BDB") Ownable(msg.sender){}

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => string) public badgeTypes; // tokenId => badge type
    mapping(address => uint256[]) public userBadges;

    event BadgeMinted(address indexed recipient, uint256 indexed tokenId, string badgeType);


    function mintBadge(address _recipient, string memory _badgeType) external onlyOwner returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _safeMint(_recipient, tokenId);
        badgeTypes[tokenId] = _badgeType;
        userBadges[_recipient].push(tokenId);

        emit BadgeMinted(_recipient, tokenId, _badgeType);

        return tokenId;
    }

    function getUserBadges(address _user) external view returns (uint256[] memory) {
        return userBadges[_user];
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://"; // You'll upload badge metadata to IPFS
    }
}
