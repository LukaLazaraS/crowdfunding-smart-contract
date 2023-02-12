// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address private immutable owner;
    uint public immutable goal;
    uint public immutable endTime;
    mapping(address => uint) public contributors;

    modifier isOwner() {
        require(msg.sender == owner, "You must be the Owner");
        _;
    }

    modifier isNotEnd() {
        require(block.timestamp < endTime, "The crowdfunding has ended");
        _;
    }

    modifier isEnd() {
        require(
            block.timestamp >= endTime,
            "The crowdfunding has not ended yet"
        );
        _;
    }

    modifier isGoalReached() {
        require(
            address(this).balance >= goal,
            "The crowdfunding goal has not been reached"
        );
        _;
    }

    modifier isFundAmountValid() {
        require(msg.value > 0, "The amount must be greater than 0");
        _;
    }

    constructor(uint _goal, uint _durationInDays) {
        owner = msg.sender;
        goal = _goal;
        endTime = block.timestamp + (_durationInDays * 1 days);
    }

    function contribute() public payable isNotEnd isFundAmountValid {
        contributors[msg.sender] += msg.value;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function withdraw() public isOwner isEnd isGoalReached {
        payable(owner).transfer(address(this).balance);
    }
}
