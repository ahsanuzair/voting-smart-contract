// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Voting {
    address public immutable i_owner;
    uint256 public votingStartTime;
    uint256 public votingEndTime;

    error NotOwner();

    modifier onlyOwner(){
        if(msg.sender != i_owner){
            revert NotOwner();
        }
        _;
    }

    modifier onlyDuringVotingTIme(){
        require(block.timestamp >= votingStartTime && block.timestamp <= votingEndTime);
        _;
    }

    constructor(uint256 _durationInMinutes){
        i_owner = msg.sender;
        votingStartTime = block.timestamp;
        votingEndTime = block.timestamp + (_durationInMinutes * 60);
    }

    struct Candidate {
        string name;
        uint256 voteCount;
    }

     // Array to store all candidates
    Candidate[] public candidates;

    // Mapping to track whether an address has voted
    mapping (address => bool) public hasVoted;

    // Function to add a new candidate to the election, initilize voteCount to 0
    function addCandidate(string memory _name) public onlyOwner {
        require(block.timestamp <= votingStartTime, "can't add candidate after coting starts");
        candidates.push(Candidate(_name,0));
    }

    function vote(uint256 _candidateIndex) public onlyDuringVotingTIme {
        require((!hasVoted[msg.sender]),"Already voted");
        require(msg.sender != i_owner, "Owner can't vote");
        require(_candidateIndex < candidates.length,"Invalid index");
        candidates[_candidateIndex].voteCount++;
        hasVoted[msg.sender] = true;
    }

    function getWinner() public view returns (string memory _name, uint256 _votes){
        require(block.timestamp >= votingEndTime);

        uint256 highestVotes = 0;
        uint256 winnerIndex = 0;

        // calculate highest number of votes
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > highestVotes) {
                highestVotes = candidates[i].voteCount;
                winnerIndex = i;
            }
        }

        return (candidates[winnerIndex].name, highestVotes);
    }
}