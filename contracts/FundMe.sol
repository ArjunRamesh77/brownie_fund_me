//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function getEntranceFee() public view returns (uint256) {
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getLatestPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function fund() public payable {
        uint256 minimumUSD = 50 * 10**18;

        require(
            getConversionRate(msg.value) >= minimumUSD,
            "You need to spend more ETH!"
        );

        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);

        //what the ETH -> USD conversion rate
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price * 10000000000);
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getLatestPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 10**18;
        return ethAmountInUsd;
    }

    function withdraw() public payable onlyOwner {
        msg.sender.transfer(address(this).balance);

        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);
    }
}
