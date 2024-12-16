const { ethers, upgrades } = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  // Deploy ProxyAdmin
  const UniversityProxyAdmin = await ethers.getContractFactory("UniversityProxyAdmin");
  const proxyAdmin = await UniversityProxyAdmin.deploy();
  await proxyAdmin.deployed();
  console.log("ProxyAdmin deployed to:", proxyAdmin.address);

  // Deploy UniversityAccessControl
  const UniversityAccessControl = await ethers.getContractFactory("UniversityAccessControlUpgradeable");
  const accessControlImpl = await UniversityAccessControl.deploy();
  await accessControlImpl.deployed();
  
  const accessControlProxy = await upgrades.deployProxy(UniversityAccessControl, [], {
    initializer: "initialize",
    admin: proxyAdmin.address,
  });
  await accessControlProxy.deployed();
  console.log("UniversityAccessControl Proxy deployed to:", accessControlProxy.address);

  // Deploy CourseManagement
  const CourseManagement = await ethers.getContractFactory("CourseManagementUpgradeable");
  const courseManagementImpl = await CourseManagement.deploy();
  await courseManagementImpl.deployed();
  
  const courseManagementProxy = await upgrades.deployProxy(CourseManagement, [], {
    initializer: "initialize",
    admin: proxyAdmin.address,
  });
  await courseManagementProxy.deployed();
  console.log("CourseManagement Proxy deployed to:", courseManagementProxy.address);

  // Deploy GradeManagement
  const GradeManagement = await ethers.getContractFactory("GradeManagementUpgradeable");
  const gradeManagementImpl = await GradeManagement.deploy();
  await gradeManagementImpl.deployed();
  
  const gradeManagementProxy = await upgrades.deployProxy(GradeManagement, [], {
    initializer: "initialize",
    admin: proxyAdmin.address,
  });
  await gradeManagementProxy.deployed();
  console.log("GradeManagement Proxy deployed to:", gradeManagementProxy.address);

  // Deploy ScheduleManagement
  const ScheduleManagement = await ethers.getContractFactory("ScheduleManagementUpgradeable");
  const scheduleManagementImpl = await ScheduleManagement.deploy();
  await scheduleManagementImpl.deployed();
  
  const scheduleManagementProxy = await upgrades.deployProxy(ScheduleManagement, [], {
    initializer: "initialize",
    admin: proxyAdmin.address,
  });
  await scheduleManagementProxy.deployed();
  console.log("ScheduleManagement Proxy deployed to:", scheduleManagementProxy.address);

  // Deploy StatisticsTracker
  const StatisticsTracker = await ethers.getContractFactory("StatisticsTrackerUpgradeable");
  const statisticsTrackerImpl = await StatisticsTracker.deploy();
  await statisticsTrackerImpl.deployed();
  
  const statisticsTrackerProxy = await upgrades.deployProxy(StatisticsTracker, [], {
    initializer: "initialize",
    admin: proxyAdmin.address,
  });
  await statisticsTrackerProxy.deployed();
  console.log("StatisticsTracker Proxy deployed to:", statisticsTrackerProxy.address);

  // Save deployment addresses
  const deploymentDir = path.join(__dirname, "../.deployed");
  if (!fs.existsSync(deploymentDir)) {
    fs.mkdirSync(deploymentDir);
  }

  const addresses = {
    ProxyAdmin: proxyAdmin.address,
    UniversityAccessControlImpl: accessControlImpl.address,
    UniversityAccessControlProxy: accessControlProxy.address,
    CourseManagementImpl: courseManagementImpl.address,
    CourseManagementProxy: courseManagementProxy.address,
    GradeManagementImpl: gradeManagementImpl.address,
    GradeManagementProxy: gradeManagementProxy.address,
    ScheduleManagementImpl: scheduleManagementImpl.address,
    ScheduleManagementProxy: scheduleManagementProxy.address,
    StatisticsTrackerImpl: statisticsTrackerImpl.address,
    StatisticsTrackerProxy: statisticsTrackerProxy.address,
  };

  // Save individual address files for CI/CD
  Object.entries(addresses).forEach(([name, address]) => {
    fs.writeFileSync(
      path.join(deploymentDir, `${name}.address`),
      address
    );
  });

  // Save complete addresses JSON
  fs.writeFileSync(
    path.join(deploymentDir, "addresses.json"),
    JSON.stringify(addresses, null, 2)
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
