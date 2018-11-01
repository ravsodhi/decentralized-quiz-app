pragma solidity ^0.4.24;
contract Quiz
{
    address public moderator;
    uint public N; // No. of participants
    uint public pFee; // Participation fee for each player
    uint public tFee = 0;
    uint256 public quizEnded;
    uint256 public quizStart;
    bool public prizeDetermined=false;
    mapping(address => uint256) public pendingReturns;
    mapping(uint => address[]) public winners;
    mapping(uint => uint) public que_reward;
    mapping(address => uint[]) private answered;

    struct Player
    {
        address addr;
    }

    struct Question
    {
        string statement;
        string ans;
    }

    Player[] players;
    Question[] questions;

    constructor (uint _N, uint _pFee, uint quizDuration)
    public
    {
        moderator = msg.sender;
        N = _N;
        pFee = _pFee;
        quizStart = now;
        quizEnded = now + quizDuration;

        emit quizCreated(N, pFee);
    }

    // Modifiers
    modifier onlyBy(address account)
    {
        require(msg.sender == account, "Not authorised to call this method");
        _;
    }
    modifier onlyIfTrue(bool x)
    {
        require(x == true, "Value of variable should be true");
        _;
    }
    modifier isNotPlayer()
    {
        bool flag = false;
        for(uint i=0; i < players.length; i++)
        {
            if(msg.sender == players[i].addr)
            {
                flag = true;
            }
        }
        require(flag == false, "Player already registered");
        _;
    }
    modifier isPlayer()
    {
        bool flag = false;
        for(uint i=0; i < players.length; i++)
        {
            if(msg.sender == players[i].addr)
            {
                flag = true;
            }
        }
        require(flag == true, "Player is registered");
        _;
    }
    modifier onlyBefore(uint256 time)
    {
        require(now < time, "Too late");
        _;
    }
    modifier onlyAfter(uint256 time)
    {
        require(now > time, "Too early");
        _;
    }

    // Events
    event quizCreated(uint _N, uint _pFee);
    event playerRegistered(address _addr);

    // Functions

    /* Helper function to compare two strings */
    function compareStrings (string a, string b)
    view
    returns (bool)
    {
       return keccak256(a) == keccak256(b);
    }

    /* Player registers with a minimum fee, set to 100 wei */
    function register()
    isNotPlayer()
    payable
    public
    {
        require(players.length < N, "Player space is full");
        require(msg.value >= pFee, "Insufficient funds sent");

        pendingReturns[msg.sender] = msg.value - pFee;
        players.push(Player({
            addr: msg.sender
        }));
        tFee += pFee;
        emit playerRegistered(msg.sender);
    }

    /* Moderator adds a question consisting of a statement(string) and ans (string) */
    function addQuestion(string _statement, string _ans)
    onlyBy(moderator)
    public
    {
        questions.push(Question({
            statement: _statement,
            ans: _ans

        }));
    }

    /* Player gets a question statement by providing index (0 <= i < 4) */
    function getQuestion(uint _qInd)
    isPlayer()
    onlyBefore(quizEnded)
    public
    returns(string)
    {
        require(_qInd >= 0 && _qInd < 4, "Invalid index for question");

        string question = questions[_qInd].statement;
        return question;
    }

    /* Player answers a question providing index of the question, and the answer */
    function answerQuestion(uint _qInd, string ans)
    isPlayer()
    onlyBefore(quizEnded)
    public
    returns (bool)
    {
        // for(uint i=0;i<winners[_qInd].length;i++)
        // {
        //     if(msg.sender == winners[_qInd][i])
        //     {
        //         return false;
        //     }
        // }
        for (uint i = 0;i<answered[msg.sender].length;i++) {
            if (answered[msg.sender][i] == _qInd) {
                return false;
            }
        }
        answered[msg.sender].push(_qInd);
        if(compareStrings(questions[_qInd].ans, ans))
        {
            winners[_qInd].push(msg.sender);
        }
        return true;
    }

    /* After all the players have answered, the prize for each winner is determined */
    function prizeDetermine()
    onlyAfter(quizEnded)
    onlyBy(moderator)
    public
    {
        for(uint i=0;i<4;i++)
        {
            uint256 reward = 0;
            if(winners[i].length > 0)
            {
                reward = (3*tFee)/(16*winners[i].length);
                prizeDetHelper(i, reward);
            }
            que_reward[i] = reward;
        }
        prizeDetermined = true;
    }

    function prizeDetHelper(uint _qInd, uint256 reward)
    onlyBy(moderator)
    onlyAfter(quizEnded)
    private
    {
        for(uint i=0; i<winners[_qInd].length;i++)
        {
            pendingReturns[winners[_qInd][i]] += reward;
        }
    }

    /* Player withdraws his winnnings, if any */
    function withdraw()
    onlyAfter(quizEnded)
    onlyIfTrue(prizeDetermined)
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

    function getBalance() 
    public view 
    returns (uint256) {
        return address(this).balance;
    }
}