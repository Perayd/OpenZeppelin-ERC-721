async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with", deployer.address);

  const A333 = await ethers.getContractFactory("A333");
  const baseURI = "ipfs://REPLACE_WITH_CID/";   // update after uploading metadata
  const treasury = deployer.address;

  const a333 = await A333.deploy(baseURI, treasury);
  await a333.deployed();

  console.log("A333 deployed to:", a333.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
