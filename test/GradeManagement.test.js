const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("GradeManagement", function () {
  let gradeManagement, owner, teacher, student;

  beforeEach(async function () {
    [owner, teacher, student] = await ethers.getSigners();

    const GradeManagement = await ethers.getContractFactory("GradeManagement");
    gradeManagement = await GradeManagement.deploy();
    await gradeManagement.deployed();

    await gradeManagement.assignRole(teacher.address, 1);
    await gradeManagement.assignRole(student.address, 0);
  });

  it("Should record and retrieve grades", async function () {
    await gradeManagement.connect(teacher).recordGrade(1, student.address, 85);
    const grades = await gradeManagement.getGrades(1);
    expect(grades[0].grade).to.equal(85);
  });

  it("Should restrict grade recording to teachers", async function () {
    await expect(gradeManagement.connect(student).recordGrade(1, student.address, 85)).to.be.revertedWith("AccessControl: Access denied");
  });
});
