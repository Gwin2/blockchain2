const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("UniversityAccessControl", function () {
  let accessControl, owner, admin, teacher, student;

  beforeEach(async function () {
    [owner, admin, teacher, student] = await ethers.getSigners();

    const AccessControl = await ethers.getContractFactory("UniversityAccessControl");
    accessControl = await AccessControl.deploy();
    await accessControl.deployed();

    await accessControl.assignRole(admin.address, 2); // Assign Admin role
    await accessControl.assignRole(teacher.address, 1); // Assign Teacher role
    await accessControl.assignRole(student.address, 0); // Assign Student role
  });

  it("Should have correct roles for test accounts", async function () {
    expect(await accessControl.getRole(admin.address)).to.equal(2);
    expect(await accessControl.getRole(teacher.address)).to.equal(1);
    expect(await accessControl.getRole(student.address)).to.equal(0);
  });

  it("Admin should be able to assign roles", async function () {
    const newStudent = ethers.Wallet.createRandom();
    await accessControl.connect(admin).assignRole(newStudent.address, 0);
    expect(await accessControl.getRole(newStudent.address)).to.equal(0);
  });

  it("Teacher should not be able to assign roles", async function () {
    const newStudent = ethers.Wallet.createRandom();
    await expect(accessControl.connect(teacher).assignRole(newStudent.address, 0)).to.be.revertedWith("AccessControl: Access denied");
  });
});
