const { expect } = require('chai');
const { ethers, upgrades } = require('hardhat');

describe('CourseManagement', function () {
  let CourseManagement, courseManagement, universityAccessControl, owner, teacher, student;

  beforeEach(async function () {
    [owner, teacher, student] = await ethers.getSigners();
    const UniversityAccessControl = await ethers.getContractFactory('UniversityAccessControl');
    universityAccessControl = await UniversityAccessControl.deploy();

    CourseManagement = await ethers.getContractFactory('CourseManagement');
    courseManagement = await upgrades.deployProxy(CourseManagement, { initializer: 'initialize' });

    await universityAccessControl.initialize();
    await universityAccessControl.assignRole(teacher.address, 2);
    await universityAccessControl.assignRole(student.address, 1);
  });

  it("Should initialize correctly", async function () {
  });

  it('should deploy the proxy and logic contracts correctly', async function () {
    expect(await courseManagement.address).to.properAddress;
  });

  it('should initialize the contract correctly', async function () {
    await courseManagement.initialize(universityAccessControl.address);
    const courseCount = await courseManagement.courseCount();
    expect(courseCount).to.equal(0);
  });

  it('should create a course', async function () {
    await universityAccessControl.assignRole(owner.address, ethers.utils.id("TEACHER_ROLE"));
    await courseManagement.connect(owner).createCourse('Blockchain1', 'Introduction to Blockchain', 30);
    const course = await courseManagement.getCourseDetails(1);
    expect(course.name).to.equal('Blockchain1');
    expect(course.description).to.equal('Introduction to Blockchain');
    expect(course.capacity).to.equal(30);
    expect(course.instructor).to.equal(owner.address);
  });

  it('should enroll a student', async function () {
    await courseManagement.connect(owner).createCourse('Blockchain1', teacher.address);
    await courseManagement.connect(student).enrollStudent(0);
    const course = await courseManagement.getCourse(0);
    expect(course.students).to.include(student.address);
  });

  it('should confirm enrollment', async function () {
    await courseManagement.connect(owner).createCourse('Blockchain1', teacher.address);
    await courseManagement.connect(student).enrollStudent(0);
    await courseManagement.connect(teacher).confirmEnrollment(0, student.address);
  });

  it('should remove a student from a course', async function () {
    await courseManagement.connect(owner).createCourse('Blockchain1', teacher.address);
    await courseManagement.connect(student).enrollStudent(0);
    await courseManagement.connect(owner).removeStudent(0, student.address);
    const course = await courseManagement.getCourse(0);
    expect(course.students).to.not.include(student.address);
  });

  it('should update course details', async function () {
    await courseManagement.connect(owner).createCourse('Blockchain1', teacher.address);
    await courseManagement.connect(owner).updateCourse(0, 'Blockchain2', teacher.address);
    const course = await courseManagement.getCourse(0);
    expect(course.name).to.equal('Blockchain2');
  });
});
