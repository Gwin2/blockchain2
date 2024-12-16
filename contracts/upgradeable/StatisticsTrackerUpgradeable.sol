// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./GradeManagementUpgradeable.sol";
import "./ScheduleManagementUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract StatisticsTrackerUpgradeable is Initializable, GradeManagementUpgradeable, ScheduleManagementUpgradeable {
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
 
    function initialize() public initializer {
        __AccessControl_init();
        _grantRole(ADMIN_ROLE, msg.sender);
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
                if (courseAttendance[i].attended) {
                    attendedCount++;
                }
                totalCount++;
            }
        }
        return totalCount > 0 ? (attendedCount * 100) / totalCount : 0;
    }

    uint256[50] private __gap;
}
