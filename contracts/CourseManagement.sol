// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./UniversityAccessControl.sol";

contract CourseManagement is Initializable, UniversityAccessControl {
    struct Course {
        uint256 id;
        string name;
        string description;
        address instructor;
        uint256 capacity;
        uint256 enrolledStudents;
        string department;
        uint256 credits;
        bool isActive;
        uint256 startDate;
        uint256 endDate;
        string[] prerequisites;
        mapping(address => bool) enrolledStudentsList;
        mapping(address => bool) waitlist;
        uint256 waitlistCount;
    }

    struct CourseView {
        uint256 id;
        string name;
        string description;
        address instructor;
        uint256 capacity;
        uint256 enrolledStudents;
        string department;
        uint256 credits;
        bool isActive;
        uint256 startDate;
        uint256 endDate;
        string[] prerequisites;
        uint256 waitlistCount;
    }

    mapping(uint256 => Course) public courses;
    mapping(address => uint256[]) public studentCourses;
    mapping(address => uint256[]) public teacherCourses;
    uint256 public courseCount;

    event CourseCreated(uint256 courseId, string name, address instructor);
    event CourseUpdated(uint256 courseId, string name, string description);
    event StudentEnrolled(uint256 courseId, address student);
    event StudentDropped(uint256 courseId, address student);
    event CourseStatusChanged(uint256 courseId, bool isActive);
    event AddedToWaitlist(uint256 courseId, address student);
    event RemovedFromWaitlist(uint256 courseId, address student);

    function initialize() public override initializer {
        UniversityAccessControl.initialize();
    }

    modifier onlyInstructor(uint256 _courseId) {
        require(courses[_courseId].instructor == msg.sender, "Only course instructor can perform this action");
        _;
    }

    modifier courseExists(uint256 _courseId) {
        require(_courseId > 0 && _courseId <= courseCount, "Course does not exist");
        _;
    }

    modifier courseIsActive(uint256 _courseId) {
        require(courses[_courseId].isActive, "Course is not active");
        _;
    }

    function createCourse(
        string memory _name,
        string memory _description,
        uint256 _capacity,
        string memory _department,
        uint256 _credits,
        uint256 _startDate,
        uint256 _endDate,
        string[] memory _prerequisites
    ) external onlyRole(TEACHER_ROLE) {
        require(bytes(_name).length > 0, "Course name cannot be empty");
        require(_capacity > 0, "Capacity must be greater than 0");
        require(_startDate < _endDate, "Invalid course dates");
        require(_startDate > block.timestamp, "Course must start in the future");

        courseCount++;
        Course storage newCourse = courses[courseCount];
        newCourse.id = courseCount;
        newCourse.name = _name;
        newCourse.description = _description;
        newCourse.instructor = msg.sender;
        newCourse.capacity = _capacity;
        newCourse.department = _department;
        newCourse.credits = _credits;
        newCourse.startDate = _startDate;
        newCourse.endDate = _endDate;
        newCourse.prerequisites = _prerequisites;
        newCourse.isActive = true;
        newCourse.enrolledStudents = 0;
        newCourse.waitlistCount = 0;

        teacherCourses[msg.sender].push(courseCount);
        emit CourseCreated(courseCount, _name, msg.sender);
    }

    function enrollInCourse(uint256 _courseId) 
        external 
        onlyRole(STUDENT_ROLE) 
        courseExists(_courseId)
        courseIsActive(_courseId)
        onlyActiveUser(msg.sender)
    {
        Course storage course = courses[_courseId];
        require(!course.enrolledStudentsList[msg.sender], "Already enrolled in this course");
        require(!course.waitlist[msg.sender], "Already in waitlist");
        
        if (course.enrolledStudents < course.capacity) {
            course.enrolledStudents++;
            course.enrolledStudentsList[msg.sender] = true;
            studentCourses[msg.sender].push(_courseId);
            emit StudentEnrolled(_courseId, msg.sender);
        } else {
            course.waitlist[msg.sender] = true;
            course.waitlistCount++;
            emit AddedToWaitlist(_courseId, msg.sender);
        }
    }

    function dropCourse(uint256 _courseId)
        external
        onlyRole(STUDENT_ROLE)
        courseExists(_courseId)
    {
        Course storage course = courses[_courseId];
        require(course.enrolledStudentsList[msg.sender], "Not enrolled in this course");
        
        course.enrolledStudentsList[msg.sender] = false;
        course.enrolledStudents--;
        
        // Remove course from student's courses
        for (uint i = 0; i < studentCourses[msg.sender].length; i++) {
            if (studentCourses[msg.sender][i] == _courseId) {
                studentCourses[msg.sender][i] = studentCourses[msg.sender][studentCourses[msg.sender].length - 1];
                studentCourses[msg.sender].pop();
                break;
            }
        }
        
        emit StudentDropped(_courseId, msg.sender);
        
        // Process waitlist if any
        if (course.waitlistCount > 0) {
            address[] memory waitlistStudents = new address[](course.waitlistCount);
            uint256 index = 0;
            for (uint i = 0; i < waitlistStudents.length; i++) {
                if (course.waitlist[waitlistStudents[i]]) {
                    waitlistStudents[index] = waitlistStudents[i];
                    index++;
                }
            }
            if (index > 0) {
                address nextStudent = waitlistStudents[0];
                course.waitlist[nextStudent] = false;
                course.waitlistCount--;
                course.enrolledStudentsList[nextStudent] = true;
                course.enrolledStudents++;
                studentCourses[nextStudent].push(_courseId);
                emit RemovedFromWaitlist(_courseId, nextStudent);
                emit StudentEnrolled(_courseId, nextStudent);
            }
        }
    }

    function updateCourse(
        uint256 _courseId,
        string memory _name,
        string memory _description,
        uint256 _capacity,
        string memory _department,
        uint256 _credits,
        uint256 _startDate,
        uint256 _endDate,
        string[] memory _prerequisites
    ) 
        external 
        onlyInstructor(_courseId)
        courseExists(_courseId) 
    {
        require(bytes(_name).length > 0, "Course name cannot be empty");
        require(_capacity > 0, "Capacity must be greater than 0");
        require(_startDate < _endDate, "Invalid course dates");
        
        Course storage course = courses[_courseId];
        course.name = _name;
        course.description = _description;
        course.capacity = _capacity;
        course.department = _department;
        course.credits = _credits;
        course.startDate = _startDate;
        course.endDate = _endDate;
        course.prerequisites = _prerequisites;
        
        emit CourseUpdated(_courseId, _name, _description);
    }

    function setCourseStatus(uint256 _courseId, bool _isActive)
        external
        onlyInstructor(_courseId)
        courseExists(_courseId)
    {
        courses[_courseId].isActive = _isActive;
        emit CourseStatusChanged(_courseId, _isActive);
    }

    function getCourseDetails(uint256 _courseId) 
        external 
        view 
        courseExists(_courseId) 
        returns (CourseView memory) 
    {
        Course storage course = courses[_courseId];
        return CourseView({
            id: course.id,
            name: course.name,
            description: course.description,
            instructor: course.instructor,
            capacity: course.capacity,
            enrolledStudents: course.enrolledStudents,
            department: course.department,
            credits: course.credits,
            isActive: course.isActive,
            startDate: course.startDate,
            endDate: course.endDate,
            prerequisites: course.prerequisites,
            waitlistCount: course.waitlistCount
        });
    }

    function getStudentCourses(address _student) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return studentCourses[_student];
    }

    function getTeacherCourses(address _teacher) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return teacherCourses[_teacher];
    }

    function isEnrolled(uint256 _courseId, address _student) 
        external 
        view 
        returns (bool) 
    {
        return courses[_courseId].enrolledStudentsList[_student];
    }

    function isInWaitlist(uint256 _courseId, address _student) 
        external 
        view 
        returns (bool) 
    {
        return courses[_courseId].waitlist[_student];
    }
}
