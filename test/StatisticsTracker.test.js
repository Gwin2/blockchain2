const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("StatisticsTracker", function () {
  let statisticsTracker, owner, teacher, student;
  let StatisticsTracker;

  beforeEach(async function () {
    [owner, teacher, student] = await ethers.getSigners();
    StatisticsTracker = await ethers.getContractFactory('StatisticsTracker');
    statisticsTracker = await upgrades.deployProxy(StatisticsTracker, { initializer: 'initialize' });
    await statisticsTracker.deployed();

    await statisticsTracker.assignRole(teacher.address, 1);
    await statisticsTracker.assignRole(student.address, 0);
    await statisticsTracker.initialize();
  });

  it("should deploy the proxy and logic contracts correctly", async function () {
    expect(await statisticsTracker.address).to.properAddress;
  });

  it("should initialize the contract correctly", async function () {
  });

  it("Should initialize correctly", async function () {
    await statisticsTracker.initialize();
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

  it("Should retrieve grades for a course", async function () {
    await statisticsTracker.connect(teacher).recordGrade(1, student.address, 85);
    const grades = await statisticsTracker.getGrades(1);
    expect(grades.length).to.equal(1);
    expect(grades[0].grade).to.equal(85);
  });

  it("Should retrieve attendance records for a course", async function () {
    await statisticsTracker.connect(teacher).markAttendance(1, student.address, true);
    const attendance = await statisticsTracker.getAttendance(1);
    expect(attendance.length).to.equal(1);
    expect(attendance[0].attended).to.be.true;
  });

  it("Should handle no grades scenario", async function () {
    const avgGrade = await statisticsTracker.getAverageGrade(2);
    expect(avgGrade).to.equal(0);
  });

  it("Should handle no attendance records scenario", async function () {
    const attendanceRate = await statisticsTracker.getAttendanceRate(2);
    expect(attendanceRate).to.equal(0);
  });

  it("Should calculate average grade by student", async function () {
    await statisticsTracker.connect(teacher).recordGrade(1, student.address, 85);
    await statisticsTracker.connect(teacher).recordGrade(1, student.address, 90);
    const avgGrade = await statisticsTracker.getAverageGradeByStudent(1, student.address);
    expect(avgGrade).to.equal(87);
  });

  it("Should calculate attendance rate by student", async function () {
    await statisticsTracker.connect(teacher).markAttendance(1, student.address, true);
    await statisticsTracker.connect(teacher).markAttendance(1, student.address, false);
    const attendanceRate = await statisticsTracker.getAttendanceRateByStudent(1, student.address);
    expect(attendanceRate).to.equal(50);
  });
});
