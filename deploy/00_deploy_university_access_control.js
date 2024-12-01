const { deployments, getNamedAccounts } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("UniversityAccessControl", {
    from: deployer,
    log: true,
  });
};
module.exports.tags = ["UniversityAccessControl"];
