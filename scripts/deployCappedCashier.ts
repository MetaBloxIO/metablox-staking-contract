// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers, run } from "hardhat";
import { Contract, ContractFactory } from "ethers";

async function main(): Promise<void> {
  // Hardhat always runs the compile task when running scripts through it.
  // If this runs in a standalone fashion you may want to call compile manually
  // to make sure everything is compiled
  // await run("compile");
  // We get the contract to deploy

  const Token1: ContractFactory = await ethers.getContractFactory("MetaBlox");
  const token1: Contract = await Token1.deploy();
  await token1.deployed();
  console.log("token1 deployed to: ", token1.address);

  const Token: ContractFactory = await ethers.getContractFactory(
    "CappedCashier"
  );

  let _stakingToken = token1.address;
  let _rewardToken = token1.address;
  let _rewardAmount = 5000000;
  let _startTime = Math.round(new Date().getTime()/1000) + 60 * 3;
  console.log("_startTime: ", _startTime);
  let _cap = "5000000000000000000000000";
  let _minPerTime = "200000000000000000000";
  let _maxPerAddress = "500000000000000000000000";
  const token: Contract = await Token.deploy(
    _stakingToken,
    _rewardToken,
    _rewardAmount,
    _startTime,
    _cap,
    _minPerTime,
    _maxPerAddress
  );

  await token.deployed();
  console.log("token deployed to: ", token.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error: Error) => {
    console.error(error);
    process.exit(1);
  });
