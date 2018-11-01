var Quiz = artifacts.require("Quiz");

module.exports = function (deployer) {
    deployer.deploy(Quiz, 4, 100, 100);
    // To pass arguments, separate by comma
};