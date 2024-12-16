const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("GradeManagement", function () {
  let gradeManagement, owner, teacher, student;
  let GradeManagement;

  beforeEach(async function () {
    [owner, teacher, student] = await ethers.getSigners();
    GradeManagement = await ethers.getContractFactory('GradeManagement');
    gradeManagement = await upgrades.deployProxy(GradeManagement, { initializer: 'initialize' });
    await gradeManagement.waitForDeployment();

    await gradeManagement.assignRole(teacher.address, 1);
    await gradeManagement.assignRole(student.address, 0);
  });

  it("should deploy the proxy and logic contracts correctly", async function () {
    expect(gradeManagement.address).to.be.properAddress;
  });

  it("should initialize the contract correctly", async function () {
    await gradeManagement.initialize();
    // Add assertions to verify initialization state if applicable
  });

  it("Should record and retrieve grades", async function () {
    await gradeManagement.connect(teacher).recordGrade(1, student.address, 85);
    const grades = await gradeManagement.getGrades(1);
    expect(grades[0].grade).to.equal(85);
  });

  it("Should restrict grade recording to teachers", async function () {
    await expect(gradeManagement.connect(student).recordGrade(1, student.address, 85)).to.be.revertedWith("AccessControl: Access denied");
  });

  it("Should record multiple grades for a student", async function () {
    await gradeManagement.connect(teacher).recordGrade(1, student.address, 85);
    await gradeManagement.connect(teacher).recordGrade(1, student.address, 90);
    const grades = await gradeManagement.getGrades(1);
    expect(grades.length).to.equal(2);
    expect(grades[1].grade).to.equal(90);
  });

  it("Should update a grade", async function () {
    await gradeManagement.connect(teacher).recordGrade(1, student.address, 85);
    await gradeManagement.connect(teacher).updateGrade(1, student.address, 95);
    const grades = await gradeManagement.getGrades(1);
    expect(grades[0].grade).to.equal(95);
  });

  it("Should assign roles correctly", async function () {
    const role = await gradeManagement.getRole(teacher.address);
    expect(role).to.equal(1);
  });

  it("Should revert on invalid role assignment", async function () {
    await expect(gradeManagement.assignRole(student.address, 3)).to.be.revertedWith("Invalid role");
  });
});