pragma solidity ^0.4.24;
contract Quiz
{
    address public moderator;

    constructor()
    public
    {
        moderator = msg.sender;

    }
}
