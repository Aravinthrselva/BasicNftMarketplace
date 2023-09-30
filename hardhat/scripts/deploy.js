const { ethers } = require("hardhat");
const hre = require("hardhat");

require("dotenv").config({path:'.env'});


async function main() {
  
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contract with address:", deployer.address);

  // Deploying the NFTMarketPlace contract 
  const NFTMarketplace = await hre.ethers.getContractFactory("NotOpenSea");
  const deployedNFTMarketplace = await NFTMarketplace.deploy();
  await deployedNFTMarketplace.deployed();


  console.log("NFTMarketPlace Address :", deployedNFTMarketplace.address);

}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});
