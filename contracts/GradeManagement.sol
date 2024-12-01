// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./UniversityAccessControl.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract GradeManagement is Initializable, UniversityAccessControl {
    function initialize() public initializer {
        UniversityAccessControl.initialize();
    }

    struct Grade {
        uint256 courseId;
        address student;
        uint8 grade;
        uint256 date;
    }

    struct Attendance {
        uint256 courseId;
        address student;
        bool attended;
    }

    mapping(uint256 => Grade[]) private grades;
    mapping(uint256 => Attendance[]) private attendanceRecords;

    event GradeRecorded(uint256 courseId, address indexed student, uint8 grade);
    event AttendanceMarked(uint256 courseId, address indexed student, bool attended);

    function recordGrade(uint256 _courseId, address _student, uint8 _grade) external onlyRole(Role.Teacher) {
        require(hasRole(msg.sender, Role.Teacher), "Assigned teacher must have Teacher role");
        grades[_courseId].push(Grade(_courseId, _student, _grade, block.timestamp));
        emit GradeRecorded(_courseId, _student, _grade);
    }

    function markAttendance(uint256 _courseId, address _student, bool _attended) external onlyRole(Role.Teacher) {
        require(hasRole(msg.sender, Role.Teacher), "Assigned teacher must have Teacher role");
        attendanceRecords[_courseId].push(Attendance(_courseId, _student, _attended));
        emit AttendanceMarked(_courseId, _student, _attended);
    }

    function getGrades(uint256 _courseId) public view returns (Grade[] memory) {
        return grades[_courseId];
    }

    function getAttendance(uint256 _courseId) public view returns (Attendance[] memory) {
        return attendanceRecords[_courseId];
    }

    function getGradesByDate(uint256 _courseId, uint256 _date) external view returns (Grade[] memory) {
        Grade[] memory courseGrades = grades[_courseId];
        uint256 count = 0;
        for (uint256 i = 0; i < courseGrades.length; i++) {
            if (courseGrades[i].date == _date) {
                count++;
            }
        }
        Grade[] memory filteredGrades = new Grade[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < courseGrades.length; i++) {
            if (courseGrades[i].date == _date) {
                filteredGrades[index] = courseGrades[i];
                index++;
            }
        }
        return filteredGrades;
    }

    function viewGradesByCourse(uint256 _courseId) external view returns (Grade[] memory) {
        return grades[_courseId];
    }

    function viewGradesByStudent(uint256 _courseId, address _student) external view returns (Grade[] memory) {
        Grade[] memory courseGrades = grades[_courseId];
        uint256 count = 0;
        for (uint256 i = 0; i < courseGrades.length; i++) {
            if (courseGrades[i].student == _student) {
                count++;
            }
        }
        Grade[] memory studentGrades = new Grade[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < courseGrades.length; i++) {
            if (courseGrades[i].student == _student) {
                studentGrades[index] = courseGrades[i];
                index++;
            }
        }
        return studentGrades;
    }

    function viewGradesByTeacher(uint256 _courseId, address _teacher) external view returns (Grade[] memory) {
        require(hasRole(_teacher, Role.Teacher), "Address is not a teacher");
        return grades[_courseId];
    }

    function viewGradesByDate(uint256 _courseId, uint256 _startDate, uint256 _endDate) external view returns (Grade[] memory) {
        Grade[] memory courseGrades = grades[_courseId];
        uint256 count = 0;
        for (uint256 i = 0; i < courseGrades.length; i++) {
            if (courseGrades[i].date >= _startDate && courseGrades[i].date <= _endDate) {
                count++;
            }
        }
        Grade[] memory dateFilteredGrades = new Grade[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < courseGrades.length; i++) {
            if (courseGrades[i].date >= _startDate && courseGrades[i].date <= _endDate) {
                dateFilteredGrades[index] = courseGrades[i];
                index++;
            }
        }
        return dateFilteredGrades;
    }
}
