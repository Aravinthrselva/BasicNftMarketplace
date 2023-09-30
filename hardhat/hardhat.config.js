require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config({path: ".env"});


const ALCHEMY_HTTP_URL = process.env.ALCHEMY_HTTP_URL;

const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

const PRV_KEY = process.env.PRV_KEY;


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks: {
    sepolia: {
      url: ALCHEMY_HTTP_URL,
      accounts: [PRV_KEY],
    },
  },
  etherscan:{    
    apiKey: ETHERSCAN_API_KEY,
  },
};