const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("UniversityAccessControl", function () {
  let accessControl, owner, admin, teacher, student;

  beforeEach(async function () {
    [owner, admin, teacher, student] = await ethers.getSigners();
    const AccessControl = await ethers.getContractFactory('UniversityAccessControl');
    accessControl = await AccessControl.deploy();

    await accessControl.waitForDeployment();
    await accessControl.initialize();
    await accessControl.assignRole(admin.address, 2);
    await accessControl.assignRole(teacher.address, 1);
    await accessControl.assignRole(student.address, 0);
  });

  // it("Should initialize correctly", async function () {
  //   expect(await accessControl.hasRole(ethers.utils.id("DEFAULT_ADMIN_ROLE"), owner.address)).to.be.true;
  // });

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
