const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("Proxy Contracts", function () {
  let proxyAdmin;
  let accessControlProxy;
  let courseManagementProxy;
  let gradeManagementProxy;
  let scheduleManagementProxy;
  let statisticsTrackerProxy;
  let owner;
  let teacher;
  let student;

  beforeEach(async function () {
    [owner, teacher, student] = await ethers.getSigners();

    // Deploy ProxyAdmin
    const UniversityProxyAdmin = await ethers.getContractFactory("UniversityProxyAdmin");
    proxyAdmin = await UniversityProxyAdmin.deploy();
    await proxyAdmin.deployed();

    // Deploy UniversityAccessControl
    const UniversityAccessControl = await ethers.getContractFactory("UniversityAccessControlUpgradeable");
    accessControlProxy = await upgrades.deployProxy(UniversityAccessControl, [], {
      initializer: "initialize",
      admin: proxyAdmin.address,
    });
    await accessControlProxy.deployed();

    // Deploy CourseManagement
    const CourseManagement = await ethers.getContractFactory("CourseManagementUpgradeable");
    courseManagementProxy = await upgrades.deployProxy(CourseManagement, [], {
      initializer: "initialize",
      admin: proxyAdmin.address,
    });
    await courseManagementProxy.deployed();

    // Deploy GradeManagement
    const GradeManagement = await ethers.getContractFactory("GradeManagementUpgradeable");
    gradeManagementProxy = await upgrades.deployProxy(GradeManagement, [], {
      initializer: "initialize",
      admin: proxyAdmin.address,
    });
    await gradeManagementProxy.deployed();

    // Deploy ScheduleManagement
    const ScheduleManagement = await ethers.getContractFactory("ScheduleManagementUpgradeable");
    scheduleManagementProxy = await upgrades.deployProxy(ScheduleManagement, [], {
      initializer: "initialize",
      admin: proxyAdmin.address,
    });
    await scheduleManagementProxy.deployed();

    // Deploy StatisticsTracker
    const StatisticsTracker = await ethers.getContractFactory("StatisticsTrackerUpgradeable");
    statisticsTrackerProxy = await upgrades.deployProxy(StatisticsTracker, [], {
      initializer: "initialize",
      admin: proxyAdmin.address,
    });
    await statisticsTrackerProxy.deployed();

    // Setup roles
    await accessControlProxy.assignRole(teacher.address, 2); // Teacher role
    await accessControlProxy.assignRole(student.address, 1); // Student role
  });

  describe("UniversityAccessControl", function () {
    it("Should assign roles correctly", async function () {
      expect(await accessControlProxy.hasRole(await accessControlProxy.TEACHER_ROLE(), teacher.address)).to.be.true;
      expect(await accessControlProxy.hasRole(await accessControlProxy.STUDENT_ROLE(), student.address)).to.be.true;
    });

    it("Should upgrade successfully", async function () {
      const UniversityAccessControlV2 = await ethers.getContractFactory("UniversityAccessControlUpgradeable");
      const upgraded = await upgrades.upgradeProxy(accessControlProxy.address, UniversityAccessControlV2);
      expect(await upgraded.hasRole(await upgraded.TEACHER_ROLE(), teacher.address)).to.be.true;
    });
  });

  describe("CourseManagement", function () {
    it("Should create course correctly", async function () {
      await courseManagementProxy.connect(teacher).createCourse("Math 101", "Introduction to Mathematics", 30);
      const course = await courseManagementProxy.getCourseDetails(1);
      expect(course.name).to.equal("Math 101");
      expect(course.instructor).to.equal(teacher.address);
    });

    it("Should allow student enrollment", async function () {
      await courseManagementProxy.connect(teacher).createCourse("Math 101", "Introduction to Mathematics", 30);
      await courseManagementProxy.connect(student).enrollInCourse(1);
      const course = await courseManagementProxy.getCourseDetails(1);
      expect(course.enrolledStudents).to.equal(1);
    });
  });

  describe("GradeManagement", function () {
    it("Should record grades correctly", async function () {
      await gradeManagementProxy.connect(teacher).recordGrade(1, student.address, 85);
      const grades = await gradeManagementProxy.getGrades(1);
      expect(grades[0].grade).to.equal(85);
      expect(grades[0].student).to.equal(student.address);
    });
  });

  describe("ScheduleManagement", function () {
    it("Should create and edit schedule correctly", async function () {
      await scheduleManagementProxy.connect(teacher).createSchedule(1, "2024-01-01", "10:00");
      let schedules = await scheduleManagementProxy.getSchedule(1);
      expect(schedules[0].date).to.equal("2024-01-01");
      
      await scheduleManagementProxy.connect(teacher).editSchedule(1, 0, "2024-01-02", "11:00");
      schedules = await scheduleManagementProxy.getSchedule(1);
      expect(schedules[0].date).to.equal("2024-01-02");
    });
  });

  describe("StatisticsTracker", function () {
    beforeEach(async function () {
      await gradeManagementProxy.connect(teacher).recordGrade(1, student.address, 85);
      await gradeManagementProxy.connect(teacher).recordGrade(1, student.address, 95);
    });

    it("Should calculate average grade correctly", async function () {
      const avgGrade = await statisticsTrackerProxy.getAverageGrade(1);
      expect(avgGrade).to.equal(90);
    });

    it("Should calculate student's average grade correctly", async function () {
      const studentAvgGrade = await statisticsTrackerProxy.getAverageGradeByStudent(1, student.address);
      expect(studentAvgGrade).to.equal(90);
    });
  });
});
