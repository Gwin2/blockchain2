// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./UniversityAccessControlUpgradeable.sol";

contract CourseManagementUpgradeable is Initializable, UniversityAccessControlUpgradeable {
    struct Course {
        uint256 id;
        string name;
        string description;
        address instructor;
        uint256 capacity;
        uint256 enrolledStudents;
    }

    mapping(uint256 => Course) public courses;
    uint256 public courseCount;

    event CourseCreated(uint256 courseId, string name, address instructor);
    event StudentEnrolled(uint256 courseId, address student);
    event CourseUpdated(uint256 courseId, string name, string description);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __AccessControl_init();
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function createCourse(
        string memory _name, 
        string memory _description, 
        uint256 _capacity
    ) external onlyRole(TEACHER_ROLE) {
        courseCount++;
        courses[courseCount] = Course({
            id: courseCount,
            name: _name,
            description: _description,
            instructor: msg.sender,
            capacity: _capacity,
            enrolledStudents: 0
        });

        emit CourseCreated(courseCount, _name, msg.sender);
    }

    function enrollInCourse(uint256 _courseId) external onlyRole(STUDENT_ROLE) {
        Course storage course = courses[_courseId];
        require(course.enrolledStudents < course.capacity, "Course is full");
        course.enrolledStudents++;
        emit StudentEnrolled(_courseId, msg.sender);
    }

    function getCourseDetails(uint256 _courseId) external view returns (Course memory) {
        return courses[_courseId];
    }

    uint256[50] private __gap;
}
