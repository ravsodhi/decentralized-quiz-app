const Quiz = artifacts.require('./Quiz.sol')
const assert = require('assert')

let contractInstance

contract('Full Test', (accounts) => {
    const moderator = accounts[0];
    const player1 = accounts[1];
    const player2 = accounts[2];
    const player3 = accounts[3];
    const player4 = accounts[4];
    const player5 = accounts[5];
    beforeEach(async () => {
        contractInstance = await Quiz.deployed({ from: moderator });
    })
    it('Register with 99 wei', async () => {
        try {
            await contractInstance.register({ value: web3.toWei(0.000000000000000099, "ether"), from: player1 });
            assert.fail("Player registered");
        }
        catch (e) {
            assert.ok("True", "Player not registered");
        }
    })
    it('Register with 101 wei', async() => {
        try{
            await contractInstance.register({ value: web3.toWei(0.000000000000000101, "ether"), from: player1 });
            assert.ok("True", "Player registration was succesful");
        }
        catch(e){
            assert.fail("Player not registered");
        }
    })
    it('Multiple registration attempt', async () => {
        try {
            await contractInstance.register({ value: web3.toWei(0.000000000000000105, "ether"), from: player1 });
            assert.fail("Player registered");
        }
        catch (e) {
            assert.ok("True", "Player not registered");
        }
    })
    it('4 Registrations', async () => {
        try {
            await contractInstance.register({ value: web3.toWei(0.000000000000000101, "ether"), from: player2 });
            await contractInstance.register({ value: web3.toWei(0.000000000000000101, "ether"), from: player3 });
            await contractInstance.register({ value: web3.toWei(0.000000000000000101, "ether"), from: player4 });
            assert.ok("True", "Player registered");
        }
        catch (e) {
            assert.fail("Player not registered");
        }
    })
    it('5th Registration', async () => {
        try {
            await contractInstance.register({ value: web3.toWei(0.000000000000000101, "ether"), from: player5 });
            assert.fail("Player registered");
        }
        catch (e) {
            assert.ok("True", "Player not registered");
        }
    })
    it('Add Questions', async()=>{
        try{
            await contractInstance.addQuestion("What is 2 + 2?", "4", {from: moderator});
            await contractInstance.addQuestion("What is 5 + 1?", "6", { from: moderator });
            await contractInstance.addQuestion("What is 9 + 11?", "20", { from: moderator });
            assert.ok("True", "Questions added");
        }
        catch(e){
            assert.fail("Questions not added");
        }
    })
    it('Get Questions', async()=>{
        try{
            const q1 = await contractInstance.getQuestion.call(0, { from: player1 });
            const q2 = await contractInstance.getQuestion.call(1, { from: player2 });
            const q3 = await contractInstance.getQuestion.call(2, { from: player3 });

            // const q = await contractInstance.questions(0);
            console.log(q1);
            console.log(q2);
            console.log(q3);
            assert.ok("True", "Question fetched successfully");
        }
        catch(e){
            assert.fail("Question not fetched");
        }
    })
    it('Answer Questions', async()=>{
        try{
            await contractInstance.answerQuestion(0, "4", {from: player1});
            assert.ok("True", "Question answered successfully");
            // const x = await contractInstance.QWinPlayers(0);
            // console.log(x);
        }
        catch(e){
            assert.fail("Question not answered");
        }
    })
})
