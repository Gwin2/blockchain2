// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GradeManagement.sol";
import "./ScheduleManagement.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract StatisticsTracker is Initializable, GradeManagement, ScheduleManagement {
 
    function initialize() public initializer {
        GradeManagement.initialize();
        ScheduleManagement.initialize();
    }

    function getGrades(uint256 _courseId) public view override returns (Grade[] memory) {
        return GradeManagement.getGrades(_courseId);
    }

    function getAttendance(uint256 _courseId) public view override returns (Attendance[] memory) {
        return GradeManagement.getAttendance(_courseId);
    }

    function getAverageGrade(uint256 _courseId) external view returns (uint256) {
        Grade[] memory courseGrades = getGrades(_courseId);
        uint256 total = 0;
        for (uint256 i = 0; i < courseGrades.length; i++) {
            total += courseGrades[i].grade;
        }
        return courseGrades.length > 0 ? total / courseGrades.length : 0;
    }

    function getAttendanceRate(uint256 _courseId) external view returns (uint256) {
        Attendance[] memory courseAttendance = getAttendance(_courseId);
        uint256 attendedCount = 0;
        for (uint256 i = 0; i < courseAttendance.length; i++) {
            if (courseAttendance[i].attended) {
                attendedCount++;
            }
        }
        return courseAttendance.length > 0 ? (attendedCount * 100) / courseAttendance.length : 0;
    }

    function getAverageGradeByStudent(uint256 _courseId, address _student) external view returns (uint256) {
        Grade[] memory courseGrades = getGrades(_courseId);
        uint256 total = 0;
        uint256 count = 0;
        for (uint256 i = 0; i < courseGrades.length; i++) {
            if (courseGrades[i].student == _student) {
                total += courseGrades[i].grade;
                count++;
            }
        }
        return count > 0 ? total / count : 0;
    }

    function getAttendanceRateByStudent(uint256 _courseId, address _student) external view returns (uint256) {
        Attendance[] memory courseAttendance = getAttendance(_courseId);
        uint256 attendedCount = 0;
        uint256 totalCount = 0;
        for (uint256 i = 0; i < courseAttendance.length; i++) {
            if (courseAttendance[i].student == _student) {
                totalCount++;
                if (courseAttendance[i].attended) {
                    attendedCount++;
                }
            }
        }
        return totalCount > 0 ? (attendedCount * 100) / totalCount : 0;
    }
}
