
module.exports = {
  networks: {
    development: {
      host: 'localhost',
      port: 8545,
      network_id: '*', // Match any network id
      gasPrice: 20000000000 // Same value as `truffle develop`
    }
  }
}