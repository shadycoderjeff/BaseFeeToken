const BaseFeeToken = artifacts.require("BaseFeeToken");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(BaseFeeToken, {from: accounts[0]});
};
