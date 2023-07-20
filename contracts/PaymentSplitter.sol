// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PaymentSplitter {

    event PaymentReceived(address indexed from, uint256 indexed amount);

    constructor() payable  {}

    // Function to receive ETH and keep it in the contract
    receive() external payable {
        emit PaymentReceived(msg.sender, msg.value);
    }

    function returnEth(address owner) internal {
        payable(owner).transfer(address(this).balance);
    }

    // Function to distribute ETH based on the array of weights
    function distributeEth(address[] memory recipients, uint256[] memory weights, uint256 totalWeights) internal {
        require(recipients.length > 0 && weights.length > 0, "No recipients OR weights registered");
        require(recipients.length == weights.length, "Recipient and weights length mismatch");
        require(totalWeights > 0, "Total weight must be greater than 0");

        uint256 balance = address(this).balance;
        uint256 remainingBalance = balance;

        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 amount = (balance * weights[i]) / totalWeights;
            remainingBalance -= amount;
            payable(recipients[i]).transfer(amount);
        }
    }
}
