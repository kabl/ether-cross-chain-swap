var EtherSwap = artifacts.require("EtherSwap.sol");

module.exports = function(deployer) {
    deployer.deploy(EtherSwap);
}; 