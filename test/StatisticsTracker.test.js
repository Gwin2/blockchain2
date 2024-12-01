const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("StatisticsTracker", function () {
  let statisticsTracker, owner, teacher, student;

  beforeEach(async function () {
    [owner, teacher, student] = await ethers.getSigners();

    const StatisticsTracker = await ethers.getContractFactory("StatisticsTracker");
    statisticsTracker = await StatisticsTracker.deploy();
    await statisticsTracker.deployed();

    await statisticsTracker.assignRole(teacher.address, 1); // Assign Teacher role
    await statisticsTracker.assignRole(student.address, 0); // Assign Student role
  });

  it("Should calculate average grades", async function () {
    await statisticsTracker.connect(teacher).recordGrade(1, student.address, 85);
    await statisticsTracker.connect(teacher).recordGrade(1, student.address, 90);
    const avgGrade = await statisticsTracker.getAverageGrade(1);
    expect(avgGrade).to.equal(87);
  });

  it("Should calculate attendance rate", async function () {
    await statisticsTracker.connect(teacher).markAttendance(1, student.address, true);
    await statisticsTracker.connect(teacher).markAttendance(1, student.address, false);
    const attendanceRate = await statisticsTracker.getAttendanceRate(1);
    expect(attendanceRate).to.equal(50);
  });
});
