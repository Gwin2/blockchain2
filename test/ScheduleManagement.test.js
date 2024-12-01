const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ScheduleManagement", function () {
  let scheduleManagement, owner, teacher;

  beforeEach(async function () {
    [owner, teacher] = await ethers.getSigners();

    const ScheduleManagement = await ethers.getContractFactory("ScheduleManagement");
    scheduleManagement = await ScheduleManagement.deploy();
    await scheduleManagement.deployed();

    await scheduleManagement.assignRole(teacher.address, 1); // Assign Teacher role
  });

  it("Should create and edit schedules", async function () {
    await scheduleManagement.connect(teacher).createSchedule(1, "2023-10-10", "10:00");
    let schedule = await scheduleManagement.getSchedule(1);
    expect(schedule[0].date).to.equal("2023-10-10");

    await scheduleManagement.connect(teacher).editSchedule(1, 0, "2023-10-11", "11:00");
    schedule = await scheduleManagement.getSchedule(1);
    expect(schedule[0].date).to.equal("2023-10-11");
  });

  it("Should restrict schedule editing to teachers", async function () {
    await expect(scheduleManagement.connect(owner).editSchedule(1, 0, "2023-10-11", "11:00")).to.be.revertedWith("AccessControl: Access denied");
  });
});
