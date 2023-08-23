// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

contract DeFi {
    address payable platformAddress = payable(address(this));
    uint256 public timestamp;

    //
    uint256 numberOfMonths;
    uint256 rateOfInterest = 5;

    //a mapping to make a note of how much crypto is there in a specific account
    mapping(address => uint256) public addressToAmount;
    mapping(address => uint256) public borrowedAmount;

    modifier check1(uint256 amountToLend) {
        require(
            amountToLend < msg.sender.balance,
            "Insufficient funds to lend"
        );
        _;
    }

    function lending(uint256 amountToLend) public payable check1(amountToLend) {
        //platformAddress.transfer(msg.value);
        addressToAmount[msg.sender] += msg.value;
    }

    modifier check2(uint256 amountToBorrow) {
        require(amountToBorrow <= address(this).balance);
        _;
    }

    function borrowing(
        uint256 amountToBorrow,
        address payable receiverAddress,
        uint256 _numberOfMonths
    ) public payable check2(amountToBorrow) {
        numberOfMonths = _numberOfMonths;
        //the collateral factor for this platform is 70%
        require(
            (amountToBorrow * 1000000000000000000) <=
                (70 * msg.value * 1000000000000000000),
            "You can borrow a maximum of upto 70% of your collateral"
        );
        receiverAddress.transfer(amountToBorrow * 1000000000000000000);
        addressToAmount[msg.sender] += msg.value;
        borrowedAmount[msg.sender] += (amountToBorrow * 1000000000000000000);
    }

    modifier check3() {
        require(borrowedAmount[msg.sender] > 0);
        _;
    }

    function payEMI() public payable check3 {
        //within one year the borrower neads to return the amount with interest
        //convert the borrowed amount in ether
        //uint256 borrowedAmountInEther = borrowedAmount[msg.sender]*1000000000000000000;
        //formula for emi calculation is (P.r.(1+r)^n) / ((1+r)^n – 1)
        //uint256 emi = ((((borrowedAmountInEther*rateOfInterest/12)*(1200+rateOfInterest)**numberOfMonths)/(100*1200**numberOfMonths))*1200**numberOfMonths)  /  (((1200+rateOfInterest)**numberOfMonths)-1*1200**numberOfMonths);
        //5,25,00,00,00,00,00,00,00,00,000
        uint256 interest = viewInterest();

        if (msg.value == (borrowedAmount[msg.sender] + interest)) {
            borrowedAmount[msg.sender] -= msg.value;
        } else if (msg.value == (borrowedAmount[msg.sender] + interest)) {
            borrowedAmount[msg.sender] = 0;
            payable(msg.sender).transfer(addressToAmount[msg.sender]);
            addressToAmount[msg.sender] = 0;
        }
    }

    function viewInterest() public view check3 returns (uint256) {
        //uint256 borrowedAmountInEther = borrowedAmount[msg.sender]*1000000000000000000;
        uint256 emi = (((((borrowedAmount[msg.sender] * rateOfInterest) / 12) *
            (1200 + rateOfInterest)**numberOfMonths) /
            (100 * 1200**numberOfMonths)) * 1200**numberOfMonths) /
            (((1200 + rateOfInterest)**numberOfMonths) -
                1 *
                1200**numberOfMonths);
        //uint256  interest =  (emi*12) - borrowedAmount[msg.sender];
        uint256 interest = (emi * 12) - borrowedAmount[msg.sender];
        return interest;   
  //adding commands here
  }
}
