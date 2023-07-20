// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PaymentSplitter.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function batchMint(address[] memory to, uint256 amount) external;
    function batchBurn(address[] memory accounts, uint256 amount) external;
}

contract VotingContract is PaymentSplitter {
    // Structure to hold voter information
    struct Voter {
        bool hasVoted;
        bool votedYes;
    }

    // The address of the contract creator who can end the voting
    address public owner;

    // The proposal that users are voting on
    string public proposal;

    // Voting time variables
    uint256 public votingStartTime;
    uint256 public votingEndTime;

    // Mapping to store voter information
    mapping(address => Voter) private voters;

    // Array of voters
    address[] private yesVoters;
    uint256[] private yesVotersWeight;
    address[] private noVoters;
    uint256[] private noVotersWeight;

    // Variables to keep track of the vote count
    uint256 private yesVotes;
    uint256 private noVotes;

    bool private votesDistributed;

    // SBT token contract
    IERC20 private sbtToken;

    // Events to track voting and token distribution
    event Voted(address indexed voter, bool votedYes);
    event TokensDistributed(uint256 indexed yesVotes, uint256 indexed noVotes, address[] voters);

    // Modifier to check if the voting period has ended
    modifier votingPeriodEnded() {
        require(block.timestamp >= votingEndTime, "Voting period has not ended yet.");
        _;
    }

    modifier distributedVotes() {
        require(!votesDistributed, "Votes are distributes");
        _;
    }

    // Modifier to ensure only the contract creator can execute certain functions
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the contract owner.");
        _;
    }

    constructor(string memory _proposal, uint256 _votingDurationSeconds, address sbtAddress) PaymentSplitter() payable {
        sbtToken = IERC20(sbtAddress);

        proposal = _proposal;
        owner = msg.sender;
        votesDistributed = false;

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
        yesVotersWeight.push(voteWeight);

        yesVotes += voteWeight;
        
        emit Voted(msg.sender, true);
    }

    // Function to vote "no"
    function voteNo() external {
        require(block.timestamp >= votingStartTime && block.timestamp < votingEndTime, "Voting is not allowed at this time.");
        require(!voters[msg.sender].hasVoted, "You have already voted.");

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedYes = false;

        uint256 voterBalance = sbtToken.balanceOf(msg.sender);
        uint256 voteWeight = calculateVoteWeight(voterBalance);

        noVoters.push(msg.sender);
        noVotersWeight.push(voteWeight);

        noVotes += voteWeight;

        emit Voted(msg.sender, false);
    }

    function distributeTokens() external votingPeriodEnded distributedVotes {
        if(yesVotes > noVotes) {
            sbtToken.batchMint(yesVoters, 1 ether);
            sbtToken.batchBurn(noVoters, 1 ether);

            distributeEth(yesVoters, yesVotersWeight, yesVotes);

            emit TokensDistributed(yesVotes, noVotes, yesVoters);
        } else if(noVotes > yesVotes) {
            sbtToken.batchMint(noVoters, 1 ether);
            sbtToken.batchBurn(yesVoters, 1 ether);

            distributeEth(noVoters, noVotersWeight, noVotes);

            emit TokensDistributed(yesVotes, noVotes, noVoters);
        } else {
            returnEth(owner);
        }

        votesDistributed = true;
    }
}