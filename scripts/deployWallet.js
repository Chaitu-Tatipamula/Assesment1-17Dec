
const hre = require("hardhat");

async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  const smartWallet = await hre.ethers.deployContract("SmartWallet");
  await smartWallet.waitForDeployment();
  console.log("smartWallet Contract Deployed at : ", smartWallet.target);

  
  await sleep(30*1000);

  await hre.run("verify:verify",{
    address : smartWallet.target,
    constructorArguments : []
  })

}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
