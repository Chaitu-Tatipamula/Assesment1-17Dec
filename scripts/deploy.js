
const hre = require("hardhat");

async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  const blsContract = await hre.ethers.deployContract("BLSToken");
  await blsContract.waitForDeployment();
  console.log("BLS Token Contract Deployed at : ", blsContract.target);

  const stblsContract = await hre.ethers.deployContract("StakedBLSToken");
  await stblsContract.waitForDeployment();
  console.log("staked BLS Token Contract Deployed at : ", stblsContract.target);

  const actualContract = await hre.ethers.deployContract("BlumeLiquidStaking",[blsContract.target, stblsContract.target]);
  await actualContract.waitForDeployment();
  console.log("Actual Contract Deployed at : ", actualContract.target);

  await sleep(30*1000);

  await hre.run("verify:verify",{
    address : blsContract.target,
    constructorArguments : []
  })
  
  await hre.run("verify:verify",{
    address : stblsContract.target,
    constructorArguments : []
  })

  await hre.run("verify:verify",{
    address : actualContract.target,
    constructorArguments : [blsContract.target, stblsContract.target]
  })
}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
