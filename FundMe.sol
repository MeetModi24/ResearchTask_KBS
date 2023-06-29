// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// import "./PriceConvertor.sol";

error NotOwner();

contract FundMe{
    // using PriceConvertor for uint256;


    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    address private owner;
    // uint256 public constant MINIMUM_USD = 50 * 10 ** 18;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    constructor() {
        owner = msg.sender;
        emit OwnerSet(address(0), owner);
    }

    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function fund() public payable {
        // require(msg.value.getConversionRate() >= MINIMUM_USD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        uint256 flag = 1;
        for(uint256 i = 0; i<funders.length;i++){
              if(msg.sender == funders[i]){
                  flag=0;
                  break;
              }
        }
        if(flag==1) funders.push(msg.sender);
    }
    
    // function getVersion() public view returns (uint256){
    //     // ETH/USD price feed address of Sepolia Network.
    //     AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    //     return priceFeed.version();
    // }
    
    modifier onlyOwner {
        // require(msg.sender == owner);
        if (msg.sender != owner) revert NotOwner();
        _;
    }
    
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }


    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

}