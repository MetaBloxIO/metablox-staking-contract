import { expect } from "chai";
import { ethers } from "hardhat";

describe("MetaBlox", function () {
  it("1. testing contract calling...", async function () {
    const Token = await ethers.getContractFactory("MetaBlox");
    const token = await Token.deploy();
    await token.deployed();

    console.warn(token.symbol());
    expect(await token.symbol()).to.equal("MBLX");
   
    console.log("token name =",await token.name());

    const approve = await token.approve("0x70997970C51812dc3A010C7d01b50e0d17dc79C8",100);
    // wait until the transaction is mined
    await approve.wait();

  });
});
