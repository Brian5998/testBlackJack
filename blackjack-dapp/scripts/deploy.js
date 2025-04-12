const hre = require("hardhat");

async function main() {
  const Blackjack = await hre.ethers.getContractFactory("Blackjack");
  const blackjack = await Blackjack.deploy();
  await blackjack.deployed();
  console.log("Blackjack deployed to:", blackjack.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
