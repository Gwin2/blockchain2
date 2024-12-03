// scripts/deploy.js

async function main() {
    const { ethers, upgrades } = require("hardhat");

    // Deploy CourseManagement logic contract
    const CourseManagement = await ethers.getContractFactory("CourseManagement");
    const courseManagement = await upgrades.deployProxy(CourseManagement, { initializer: 'initialize' });
    console.log("CourseManagement deployed to:", courseManagement.address);

    // Deploy GradeManagement logic contract
    const GradeManagement = await ethers.getContractFactory("GradeManagement");
    const gradeManagement = await upgrades.deployProxy(GradeManagement, { initializer: 'initialize' });
    console.log("GradeManagement deployed to:", gradeManagement.address);

    // Deploy ScheduleManagement logic contract
    const ScheduleManagement = await ethers.getContractFactory("ScheduleManagement");
    const scheduleManagement = await upgrades.deployProxy(ScheduleManagement, { initializer: 'initialize' });
    console.log("ScheduleManagement deployed to:", scheduleManagement.address);

    // Deploy StatisticsTracker logic contract
    const StatisticsTracker = await ethers.getContractFactory("StatisticsTracker");
    const statisticsTracker = await upgrades.deployProxy(StatisticsTracker, { initializer: 'initialize' });
    console.log("StatisticsTracker deployed to:", statisticsTracker.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
