// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function batchMint(address[] memory to, uint256[] memory amount) external returns (bool);
}

contract VotingContract {
    // Structure to hold voter information
    struct Voter {
        bool hasVoted;
        bool votedYes;
    }

    // The address of the contract creator who can end the voting
    address public owner;

    // Voting time variables
    uint256 public votingStartTime;
    uint256 public votingEndTime;

    // Mapping to store voter information
    mapping(address => Voter) public voters;

    // Array of voters
    address[] private yesVoters;
    address[] private noVoters;

    // Variables to keep track of the vote count
    uint256 public yesVotes;
    uint256 public noVotes;

    // SBT token contract
    IERC20 private sbtToken;

    // Events to track voting and token distribution
    event Voted(address indexed voter, bool votedYes);
    event TokensDistributed(address indexed voter, uint256 tokensReceived);

    // Modifier to check if the voting period has ended
    modifier votingPeriodEnded() {
        require(block.timestamp >= votingEndTime, "Voting period has not ended yet.");
        _;
    }

    // Modifier to ensure only the contract creator can execute certain functions
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the contract owner.");
        _;
    }

    constructor(uint256 _votingDurationSeconds, address sbtAddress) {
        sbtToken = IERC20(sbtAddress);

        owner = msg.sender;

        votingStartTime = block.timestamp;
        votingEndTime = votingStartTime + _votingDurationSeconds;
    }

    // Function to calcule the vote weight of an address
    function calculateVoteWeight(uint256 balance) internal pure returns (uint256) {
        return balance >= 0 ? 3 : 1;
    }

    // Function to vote "yes"
    function voteYes() external {
        require(block.timestamp >= votingStartTime && block.timestamp < votingEndTime, "Voting is not allowed at this time.");
        require(!voters[msg.sender].hasVoted, "You have already voted.");
        
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedYes = true;

        uint256 voterBalance = sbtToken.balanceOf(msg.sender);
        uint256 voteWeight = calculateVoteWeight(voterBalance);
        yesVoters.push(msg.sender);

        yesVotes += voteWeight;
        
        emit Voted(msg.sender, true);
    }

    // Function to vote "no"
    function voteNo() external {
        require(block.timestamp >= votingStartTime && block.timestamp < votingEndTime, "Voting is not allowed at this time.");
        require(!voters[msg.sender].hasVoted, "You have already voted.");

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedYes = false;
        noVoters.push(msg.sender);

        uint256 voterBalance = sbtToken.balanceOf(msg.sender);
        uint256 voteWeight = calculateVoteWeight(voterBalance);

        yesVotes += voteWeight;

        emit Voted(msg.sender, false);
    }

    function distributeTokens() external votingPeriodEnded {
        
        if(yesVotes >= noVotes) {

        } else {

        }
    }
}