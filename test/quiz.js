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
    it('Get invalid question', async() =>{
        try{
            const q1 = await contractInstance.getQuestion.call(-1, { from: player1 });
            assert.fail("Invalid index recognized");
        }
        catch(e){
            assert.ok("True", "Invalid index not recognized");
        }
        try{
            const q1 = await contractInstance.getQuestion.call(4, { from: player1 });
            assert.fail("Invalid index recognized");
        }
        catch (e) {
            assert.ok("True", "Invalid index not recognized");
        }
    })
    it('Get Questions', async()=>{
        try{
            const q1 = await contractInstance.getQuestion.call(0, { from: player1 });
            const q2 = await contractInstance.getQuestion.call(1, { from: player2 });
            const q3 = await contractInstance.getQuestion.call(2, { from: player3 });

            // const q = await contractInstance.questions(0);
            assert.equal(q1, "What is 2 + 2?", "Question are not same");
            assert.equal(q2, "What is 5 + 1?", "Question are not same");
            assert.equal(q3, "What is 9 + 11?", "Question are not same");
            assert.ok("True", "Question fetched successfully");
        }
        catch(e){
            assert.fail("Question not fetched");
        }
    })
    it('Answer Questions', async()=>{
        try{
            await contractInstance.answerQuestion(0, "4", { from: player1 });
            await contractInstance.answerQuestion(0, "4", { from: player2 });
            await contractInstance.answerQuestion(0, "5", { from: player3 });

            assert.ok("True", "Question answered successfully");
            const w1 = await contractInstance.winners(0, 0);
            const w2 = await contractInstance.winners(0, 1);
            try{
                const w3 = await contractInstance.winners(0, 2);
                assert.fail("Invalid index call was successful");
            }
            catch(ee){
                assert.ok("True", "Invalid index for winner");
            }

            assert.equal(w1, player1, "The address of the winner doesn't match");
            assert.equal(w2, player2, "The address of the winner doesn't match");
        }
        catch(e){
            assert.fail("Question not answered");
        }
    })
    it('Prize determination', async()=>{
        try{
            await contractInstance.prizeDetermine({from: moderator});
            assert.ok("True", "Prize determined successfully");
            const x = await contractInstance.pendingReturns(player1);
            console.log(x.c[0]);
        }
        catch(e){
            assert.fail("Prize determination unsuccessful");
        }
    })
    it('Withdraw', async() =>{
        try{
            await contractInstance.withdraw({ from: player1 });
            await contractInstance.withdraw({ from: player2 });
            await contractInstance.withdraw({ from: player3 });
            await contractInstance.withdraw({ from: player4 });

            const p1 = await contractInstance.pendingReturns(player1);
            const p2 = await contractInstance.pendingReturns(player2);
            const p3 = await contractInstance.pendingReturns(player3);
            const p4 = await contractInstance.pendingReturns(player4);

            assert.equal(p1.c[0], 0, "Error in withdrawal");
            assert.equal(p2.c[0], 0, "Error in withdrawal");
            assert.equal(p3.c[0], 0, "Error in withdrawal");
            assert.equal(p4.c[0], 0, "Error in withdrawal");

            assert.ok("True", "Player was able to withdraw successfully");
        }
        catch(e){
            assert.fail("Player unable to withdraw")
        }
    })
})
