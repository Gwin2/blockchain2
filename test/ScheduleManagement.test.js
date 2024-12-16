const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("ScheduleManagement", function () {
  let scheduleManagement, owner, teacher;
  let ScheduleManagement;

  beforeEach(async function () {
    [owner, teacher] = await ethers.getSigners();
    ScheduleManagement = await ethers.getContractFactory('ScheduleManagement');
    scheduleManagement = await upgrades.deployProxy(ScheduleManagement, { initializer: 'initialize' });
    await scheduleManagement.waitForDeployment();

    await scheduleManagement.assignRole(teacher.address, 1);
  });

  it("should deploy the proxy and logic contracts correctly", async function () {
    expect(await scheduleManagement.address);
  });

  it("should initialize the contract correctly", async function () {
    // Add specific initialization checks for ScheduleManagement
  });

  it("Should initialize correctly", async function () {
    await scheduleManagement.initialize();
  });

  it("Should create and edit schedules", async function () {
    await scheduleManagement.connect(teacher).createSchedule(1, "2024-03-12", "10:00");
    let schedule = await scheduleManagement.getSchedule(1);
    expect(schedule[0].date).to.equal("2023-10-10");

    await scheduleManagement.connect(teacher).editSchedule(1, 0, "2024-03-12", "11:00");
    schedule = await scheduleManagement.getSchedule(1);
    expect(schedule[0].date).to.equal("2024-03-12");
  });

  it("Should restrict schedule editing to teachers", async function () {
    await expect(scheduleManagement.connect(owner).editSchedule(1, 0, "2024-03-12", "11:00")).to.be.revertedWith("AccessControl: Access denied");
  });

  it("Should delete a schedule", async function () {
    await scheduleManagement.connect(teacher).createSchedule(1, "2024-03-12", "10:00");
    await scheduleManagement.connect(teacher).deleteSchedule(1, 0);
    const schedule = await scheduleManagement.getSchedule(1);
    expect(schedule.length).to.equal(0);
  });

  it("Should view all schedules for a teacher", async function () {
    await scheduleManagement.connect(teacher).createSchedule(1, "2024-03-12", "10:00");
    await scheduleManagement.connect(teacher).createSchedule(1, "2024-03-12", "11:00");
    const schedules = await scheduleManagement.getAllSchedulesForTeacher(teacher.address);
    expect(schedules.length).to.equal(2);
  });
});
