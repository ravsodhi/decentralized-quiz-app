pragma solidity ^0.4.24;
contract Quiz
{
    address public moderator;
    uint public N; // No. of participants
    uint public pFee; // Participation fee for each player
    uint public tFee = 0;
    bool quizEnded = false;
    mapping(address => uint256) pendingReturns;

    struct Player
    {
        address addr;
    }

    Player[] players;

    constructor (uint _N, uint _pFee)
    public
    {
        moderator = msg.sender;
        N = _N;
        pFee = _pFee;

        emit quizCreated(N, pFee);
    }

    // Modifiers
    modifier onlyModerator()
    {
        require(msg.sender == moderator, "Only moderator is allowed to call this method");
        _;
    }
    modifier onlyIfTrue(bool x)
    {
        require(x == true, "Value of variable should be true");
        _;
    }
    // Events
    event quizCreated(uint _N, uint _pFee);
    event playerRegistered(address _addr);

    // Functions
    function register()
    payable
    public
    {
        require(players.length < N, "Player space is full");
        require(msg.value > pFee, "Insufficient funds sent");

        // Units of fee?
        pendingReturns[msg.sender] = msg.value;
        // Subtract the  pFee here
        players.push(Player({
            addr: msg.sender
        }));

        emit playerRegistered(msg.sender);
    }


    function withdraw()
    onlyIfTrue(quizEnded)
    public
    returns (bool)
    {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0)
        {
            pendingReturns[msg.sender] = 0;
            msg.sender.transfer(amount);
        }
        return true;
    }
}
