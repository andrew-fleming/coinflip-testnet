import "./provableAPI_0.5.sol";

pragma solidity =0.5.16;

contract Coinflip is usingProvable{
    
    struct Bet {
        address payable playerAddress;
        uint betValue;
        uint headsTails;
        uint playerWinnings;
    }
    
    mapping(address => Bet) public waiting;
    mapping(address => Bet) public afterWaiting;
    mapping(address => uint) public winningsBalance;
    
    constructor() public payable{
        owner = msg.sender;
        contractBalance += msg.value;
    }
    
    address payable public owner = msg.sender;
    uint public contractBalance;
    uint public latestNumber;
    
    function random() private view returns(uint){
        return (now % 2);
    }
    
    function flip(uint oneZero) public payable {
        Bet memory newBetter;
        waiting[msg.sender] = newBetter;
        waiting[msg.sender].playerAddress = msg.sender;
        waiting[msg.sender].betValue = msg.value;
        waiting[msg.sender].headsTails = oneZero;
        
        contractBalance += msg.value;
        
        __callback(msg.sender);
    }
    
    function __callback(address _address) public payable {
        Bet memory postBetter;
        afterWaiting[_address] = postBetter;
        afterWaiting[_address].playerAddress = waiting[_address].playerAddress;
        afterWaiting[_address].betValue = waiting[_address].betValue;
        afterWaiting[_address].headsTails = waiting[_address].headsTails;
        
        delete(waiting[_address].playerAddress);
        waiting[_address].betValue = 0;
        waiting[_address].headsTails = 2;
        
        latestNumber = random();
        if(latestNumber == afterWaiting[_address].headsTails){
            uint winAmount = (afterWaiting[_address].betValue * 2);
            contractBalance -= winAmount;
            afterWaiting[_address].betValue = 0;
            afterWaiting[_address].playerWinnings = winAmount;
            afterWaiting[_address].headsTails = 2;
            winningsBalance[_address] += afterWaiting[_address].playerWinnings;
            afterWaiting[_address].playerWinnings = 0;
        } else {
            afterWaiting[_address].betValue = 0;
            afterWaiting[_address].headsTails = 2;
        }
    }
    
    function withdrawAll() public {
        require(msg.sender == owner, "You are not the owner");
        uint toTransfer = contractBalance;
        contractBalance = 0;
        owner.transfer(toTransfer);
    }
    
    function withdrawUserWinnings() public {
        uint toTransfer = winningsBalance[msg.sender];
        winningsBalance[msg.sender] = 0;
        msg.sender.transfer(toTransfer);
        
    }
    
    

}