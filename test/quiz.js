const Quiz = artifacts.require('./Quiz.sol')
const assert = require('assert')

let contractInstance
contract('Initial Test', (accounts) => {
    const moderator = accounts[0];

    beforeEach(async() => {
        contractInstance = await Quiz.deployed({from: moderator});
    })
    it('Moderator deploys Quiz', async() =>{
        try{
            assert.ok(true);
        }
        catch(e){
       
        }
    })
})
