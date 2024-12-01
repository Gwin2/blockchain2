// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./UniversityAccessControl.sol";

contract CourseManagement is Initializable, AccessControlUpgradeable, UniversityAccessControl {
    function initialize() public initializer {
        __AccessControl_init();
        UniversityAccessControl.initialize();
    }

    struct Course {
        string name;
        address teacher;
        address[] students;
    }

    mapping(uint256 => Course) private courses;
    uint256 private courseCounter;

    event CourseCreated(uint256 courseId, string name, address indexed teacher);
    event StudentEnrolled(uint256 courseId, address indexed student);

    function createNewCourse(string memory _name, address _teacher) external onlyRole(Role.Admin) {
        require(hasRole(_teacher, Role.Teacher), "Create course only by assigned teacher");
        courses[courseCounter] = Course(_name, _teacher, new address[](0));
        emit CourseCreated(courseCounter, _name, _teacher);
        courseCounter++;
    }

    function enrollStudent(uint256 _courseId) external onlyRole(Role.Student) {
        Course storage course = courses[_courseId];
        require(course.teacher != address(0), "Course does not exist");
        course.students.push(msg.sender);
        emit StudentEnrolled(_courseId, msg.sender);
    }

    function enrollStudentWithConfirmation(uint256 _courseId) external onlyRole(Role.Student) {
        Course storage course = courses[_courseId];
        require(course.teacher != address(0), "Course does not exist");
        course.students.push(msg.sender);
        emit StudentEnrolled(_courseId, msg.sender);
    }

    function confirmEnrollment(uint256 _courseId, address _student) external view onlyRole(Role.Teacher) {
        Course storage course = courses[_courseId];
        require(course.teacher == msg.sender, "Only the assigned teacher can confirm enrollment");
        bool isEnrolled = false;
        for (uint256 i = 0; i < course.students.length; i++) {
            if (course.students[i] == _student) {
                isEnrolled = true;
                break;
            }
        }
        require(isEnrolled, "Student is not enrolled");
    }

    function confirmStudentEnrollment(uint256 _courseId, address _student) external onlyRole(Role.Teacher) {
        Course storage course = courses[_courseId];
        require(course.teacher == msg.sender, "Only the assigned teacher can confirm enrollment");
        bool isEnrolled = false;
        for (uint256 i = 0; i < course.students.length; i++) {
            if (course.students[i] == _student) {
                isEnrolled = true;
                break;
            }
        }
        require(isEnrolled, "Student is not enrolled");
    }

    function assignTeacherToCourse(uint256 _courseId, address _teacher) external onlyRole(Role.Admin) {
        require(hasRole(_teacher, Role.Teacher), "Assigned teacher must have Teacher role");
        Course storage course = courses[_courseId];
        course.teacher = _teacher;
        emit CourseCreated(_courseId, course.name, _teacher);
    }

    function getCourse(uint256 _courseId) external view returns (string memory, address, address[] memory) {
        Course storage course = courses[_courseId];
        return (course.name, course.teacher, course.students);
    }
}
