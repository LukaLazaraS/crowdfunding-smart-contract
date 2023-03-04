// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    uint public immutable goal;
    uint public immutable endTime;
    address private immutable owner;
    address[] public contributorsArray;
    mapping(address => uint) public contributors;

    event goalReached();
    event newFund();

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

    modifier isNotGoalReached() {
        require(
            address(this).balance < goal,
            "You can't refund funds, the crowdfunding has reached the goal"
        );
        _;
    }

    modifier hasFounds() {
        require(contributors[msg.sender] > 0, "You don't have funds to refund");
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
        if (contributors[msg.sender] == 0) contributorsArray.push(msg.sender);
        contributors[msg.sender] += msg.value;
        emit newFund();
        if (address(this).balance >= goal) emit goalReached();
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function refund() public isEnd isNotGoalReached hasFounds {
        payable(msg.sender).transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
    }

    function withdraw() public isOwner isEnd isGoalReached {
        payable(owner).transfer(address(this).balance);
    }
}
