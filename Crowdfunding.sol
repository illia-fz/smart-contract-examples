pragma solidity ^0.8.0;

// A simple crowdfunding contract example
contract Crowdfunding {
    address public owner;
    uint256 public goal;
    uint256 public deadline;
    mapping(address => uint256) public contributions;
    uint256 public totalContributed;

    event ContributionReceived(address indexed contributor, uint256 amount);
    event FundsWithdrawn(address indexed recipient, uint256 amount);
    event RefundIssued(address indexed contributor, uint256 amount);

    constructor(uint256 _goal, uint256 _duration) {
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + _duration;
    }

    function contribute() external payable {
        require(block.timestamp < deadline, "Campaign ended");
        contributions[msg.sender] += msg.value;
        totalContributed += msg.value;
        emit ContributionReceived(msg.sender, msg.value);
    }

    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        require(totalContributed >= goal, "Goal not reached");
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
        emit FundsWithdrawn(owner, balance);
    }

    function refund() external {
        require(block.timestamp >= deadline, "Campaign not ended");
        require(totalContributed < goal, "Goal reached, no refunds");
        uint256 amount = contributions[msg.sender];
        require(amount > 0, "No contribution found");
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit RefundIssued(msg.sender, amount);
    }
}
