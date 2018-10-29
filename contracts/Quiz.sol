pragma solidity ^0.4.24;
contract Quiz
{
    address public moderator;
    uint public N; // No. of participants
    uint public pFee; // Participation fee for each player
    uint public tFee = 0;
    uint256 public quizEnded;
    uint256 public quizStart;
    bool public prizeDet=false;
    // bool quizEnded = false;
    mapping(address => uint256) public pendingReturns;
    mapping(address =>  uint256[]) retrieveTime;
    mapping(address => uint) retrievedQNo;
    mapping(address => uint) playerQNo;
    mapping(address => uint) playerAnsNo;
    mapping(uint => address[]) public QWinPlayers;

    struct Player
    {
        address addr;
    }

    struct Question
    {
        string statement;
        // string[] options;
        // uint ansInd;
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
        quizStart=now;
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
        for(uint i=0; i< players.length; i++)
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
        for(uint i=0; i< players.length; i++)
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
    function register()
    isNotPlayer()
    payable
    public
    {
        require(players.length < N, "Player space is full");
        require(msg.value > pFee, "Insufficient funds sent");

        // Units of fee?
        pendingReturns[msg.sender] = msg.value - pFee;
        // Subtract the  pFee here
        players.push(Player({
            addr: msg.sender
        }));
        tFee += pFee;
        emit playerRegistered(msg.sender);
    }





    function addQuestion(string _statement,/*  string[] _opts,  uint _ansInd*/ string _ans) // bytes32 uses less gas than string
    onlyBy(moderator)
    public
    {
        questions.push(Question({
            statement: _statement,
            // options: _opts,
            // ansInd: _ansInd
            ans: _ans

        }));
        // add question to questions array
        //TODO: prevent invalid question/options
    }

    // Player should not be able to know a question in advance
    // Player should get a question, and an identifier,
    // TODO: some time constraint to answer the question, once it has been retrieved by player?

    function getQuestion(uint _qInd) // should return statement and/or options somehow
    isPlayer()
    onlyBefore(quizEnded)
    public
    returns(string)
    {
        // require(playerQNo[msg.sender] ==  _qInd-1, "You are accessing an invalid question");
        // if (playerQNo[msg.sender] == _qInd-1){
        // playerQNo[msg.sender] = _qInd;
        require(_qInd < 4, "Invalid index for question");
        // string[] memory res;
        string question = questions[_qInd].statement;
        // string[] memory options = questions[_qInd].options;
        // res[0]=question;
        // for(uint i=1;i<=options.length;i++)
        // {
            // res[i] = options[i-1];
        // }
        return question;
    }

    function compareStrings (string a, string b)
    view
    returns (bool)
    {
       return keccak256(a) == keccak256(b);
    }

    // Player should be able to answer a question,
    function answerQuestion(uint _qInd/* , uint optNo */, string ans) // Args? quesIdentifier, ansIndex
    isPlayer()
    onlyBefore(quizEnded)
    public
    {
        // require(playerQNo[msg.sender] == _qInd, "Answering wrong question.");
        // require(playerAnsNo[msg.sender] != _qInd, "You already answered this question.");
        // if(questions[_qInd].ansInd == optNo)
       /*  if(compareStrings(questions[_qInd].ans, ans))
        {
            QWinPlayers[_qInd].push(msg.sender);
        } */
        QWinPlayers[_qInd].push(msg.sender);

        // playerAnsNo[msg.sender]=_qInd;
    }
    // Check whether answers given by players are correct or incorrect
    // function checkAnswers()
    // onlyBy(moderator)
    // {

    // }

    function prizeDetermine()
    // onlyAfter(quizEnded)
    onlyBy(moderator)
    public
    {
        for(uint i=0;i<4;i++)
        {
            if(QWinPlayers[i].length > 0)
            {
                uint256 reward = (3*tFee)/(16*QWinPlayers[i].length);
                prizeDetHelper(i, reward);
            }
        }
        prizeDet = true;
    }

    function prizeDetHelper(uint _qInd, uint256 reward)
    onlyBy(moderator)
    // onlyAfter(quizEnded)
    private
    {
        for(uint i=0; i<QWinPlayers[_qInd].length;i++)
        {
            pendingReturns[QWinPlayers[_qInd][i]] += reward;
        }
    }

    function withdraw()
    onlyAfter(quizEnded)
    onlyIfTrue(prizeDet)
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