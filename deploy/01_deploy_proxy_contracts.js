const { ethers, upgrades } = require("hardhat");

/**
 * Deploys the proxy contracts for the university management system.
 * 
 * This script assumes that the contracts have already been compiled and are available in the artifacts directory.
 * 
 * @returns {Promise<void>} A promise that resolves when the deployment is complete.
 */
async function main() {
  try {
    // Deploy UniversityAccessControl logic contract
    const UniversityAccessControl = await ethers.getContractFactory("UniversityAccessControl");
    const universityAccessControl = await upgrades.deployProxy(UniversityAccessControl, { initializer: "initialize" });
    console.log("UniversityAccessControl deployed to:", universityAccessControl.address);

    // Deploy CourseManagement logic contract
    const CourseManagement = await ethers.getContractFactory("CourseManagement");
    const courseManagement = await upgrades.deployProxy(CourseManagement, { initializer: "initialize" });
    console.log("CourseManagement deployed to:", courseManagement.address);

    // Deploy GradeManagement logic contract
    const GradeManagement = await ethers.getContractFactory("GradeManagement");
    const gradeManagement = await upgrades.deployProxy(GradeManagement, { initializer: "initialize" });
    console.log("GradeManagement deployed to:", gradeManagement.address);

    // Deploy ScheduleManagement logic contract
    const ScheduleManagement = await ethers.getContractFactory("ScheduleManagement");
    const scheduleManagement = await upgrades.deployProxy(ScheduleManagement, { initializer: "initialize" });
    console.log("ScheduleManagement deployed to:", scheduleManagement.address);

    // Deploy StatisticsTracker logic contract
    const StatisticsTracker = await ethers.getContractFactory("StatisticsTracker");
    const statisticsTracker = await upgrades.deployProxy(StatisticsTracker, { initializer: "initialize" });
    console.log("StatisticsTracker deployed to:", statisticsTracker.address);

    // Additional deployment steps or configurations can be added here
  } catch (error) {
    console.error("Deployment failed:", error);
    process.exit(1);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Deployment failed:", error);
    process.exit(1);
  });
