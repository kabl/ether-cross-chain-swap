var Contract = artifacts.require('./EtherSwap.sol')

var sha256 = require('js-sha256');
var Web3 = require('web3')
var web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))

contract('EtherSwap', (accounts) => {
  var address = accounts[0]

  it('secretLock', async function() {
    var instance = await Contract.deployed();

    var msg = "Hello World";
    var sha256Calc = sha256.create();
    sha256Calc.update(msg);
    var hash = "0x" + sha256Calc.hex();
    
    var alice = accounts[0];
    var bob = accounts[1];
    
    var result1 = await instance.secretLock(3600, hash, bob, {value: 1000000, from: alice});
    assert.equal(result1.logs[0].event, "SwapInitiatedEvent");
    assert.equal(result1.logs[0].args.hash, hash);


    var balanceBob = await web3.eth.getBalance(bob);

    var result2 = await instance.secretProof(hash, msg);
    assert.equal(result2.logs[0].event, "SwapSuccessEvent");
    assert.equal(result2.logs[0].args.hash, hash);

    var balanceBob2 = await web3.eth.getBalance(bob);
    assert.equal(balanceBob, (balanceBob2 - 1000000));
  });

  it('calcHash', async function() {
    var instance = await Contract.deployed();

    var sha256Calc = sha256.create();
    sha256Calc.update("Hello World");
    var hash = "0x" + sha256Calc.hex();
    console.log(hash);

    var result1 = await instance.calcHash("Hello World");
    console.log(result1);

    assert.equal(hash, result1);
  });

})