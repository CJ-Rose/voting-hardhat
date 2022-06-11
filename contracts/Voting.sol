// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

contract Voting {
    enum VoteStates {
        Absent,
        Yes,
        No
    }

    struct Proposal {
        address creator;
        string question;
        address payable destination;
        uint value;
        bytes data;
        uint startTime;
        bool passed;
        bool executed;
        uint yesCount;
        uint noCount;
        mapping(address => VoteStates) voteStates;
    }

    Proposal[] public proposals;
    uint numVotesRequired;
    mapping(address => bool) members;

    event ProposalCreated(uint);
    event VoteCast(uint, address indexed);

    constructor(address[] memory _members, uint _numVotesRequired) {
        uint numMembers = _members.length;
        require(
            numMembers > 0 &&
                _numVotesRequired > 0 &&
                numMembers > _numVotesRequired
        );
        for (uint i = 0; i < numMembers; i++) {
            members[_members[i]] = true;
        }
        members[msg.sender] = true;
        numVotesRequired = _numVotesRequired;
    }

    function executeTransaction(uint _proposalId) internal {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed);
        proposal.executed = true;
        (bool success, ) = proposal.destination.call{value: proposal.value}(
            proposal.data
        );
        require(success);
    }

    function proposalCount() external view returns (uint) {
        return proposals.length;
    }

    function newProposal(
        string calldata _question,
        address payable _destination,
        uint _value,
        bytes memory _data
    ) external MembersOnly {
        Proposal storage proposal = proposals.push();
        proposal.creator = msg.sender;
        proposal.question = _question;
        proposal.destination = _destination;
        proposal.value = _value;
        proposal.data = _data;
        proposal.startTime = block.timestamp;
        proposal.voteStates[msg.sender] = VoteStates.Yes;
        proposal.yesCount++;
        emit ProposalCreated(proposals.length);
    }

    function isActive(uint _proposalId) public view returns (bool) {
        return block.timestamp < proposals[_proposalId].startTime + 7 days;
    }

    function castVote(uint _proposalId, bool _supports) external MembersOnly {
        require(isActive(_proposalId));
        Proposal storage proposal = proposals[_proposalId];

        if (proposal.voteStates[msg.sender] == VoteStates.Yes) {
            proposal.yesCount--;
        }
        if (proposal.voteStates[msg.sender] == VoteStates.No) {
            proposal.noCount--;
        }

        if (_supports) {
            proposal.yesCount++;
        } else {
            proposal.noCount++;
        }

        proposal.voteStates[msg.sender] = _supports
            ? VoteStates.Yes
            : VoteStates.No;

        if (proposal.yesCount > numVotesRequired) {
            proposal.passed = true;
            executeTransaction(_proposalId);
        }

        emit VoteCast(_proposalId, msg.sender);
    }

    function removeVote(uint _proposalId) external MembersOnly {
        require(isActive(_proposalId));
        Proposal storage proposal = proposals[_proposalId];

        if (proposal.voteStates[msg.sender] == VoteStates.Yes) {
            proposal.yesCount--;
        }
        if (proposal.voteStates[msg.sender] == VoteStates.No) {
            proposal.noCount--;
        }

        proposal.voteStates[msg.sender] = VoteStates.Absent;
    }

    receive() external payable {}

    modifier MembersOnly() {
        require(
            members[msg.sender],
            "You are not authorized to perform this action"
        );
        _;
    }
}
