const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('CourseManagement', function () {
  let CourseManagement, courseManagement, owner, teacher, student;

  beforeEach(async function () {
    [owner, teacher, student] = await ethers.getSigners();
    const UniversityAccessControl = await ethers.getContractFactory('UniversityAccessControl');
    const universityAccessControl = await UniversityAccessControl.deploy();
    await universityAccessControl.deployed();

    CourseManagement = await ethers.getContractFactory('CourseManagement');
    courseManagement = await CourseManagement.deploy(universityAccessControl.address);
    await courseManagement.deployed();

    await universityAccessControl.assignRole(teacher.address, 2);
    await universityAccessControl.assignRole(student.address, 1);
  });

  it('should create a course', async function () {
    await courseManagement.connect(owner).createCourse('Blockchain 101', teacher.address);
    const course = await courseManagement.getCourse(0);
    expect(course.name).to.equal('Blockchain 101');
    expect(course.teacher).to.equal(teacher.address);
  });

  it('should enroll a student', async function () {
    await courseManagement.connect(owner).createCourse('Blockchain 101', teacher.address);
    await courseManagement.connect(student).enrollStudent(0);
    const course = await courseManagement.getCourse(0);
    expect(course.students).to.include(student.address);
  });

  it('should confirm enrollment', async function () {
    await courseManagement.connect(owner).createCourse('Blockchain 101', teacher.address);
    await courseManagement.connect(student).enrollStudent(0);
    await courseManagement.connect(teacher).confirmEnrollment(0, student.address);
  });
});
