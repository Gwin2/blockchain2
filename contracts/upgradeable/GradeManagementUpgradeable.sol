// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./UniversityAccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract GradeManagementUpgradeable is Initializable, UniversityAccessControlUpgradeable {
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

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public override initializer {
        __AccessControl_init();
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function recordGrade(uint256 _courseId, address _student, uint8 _grade) external onlyRole(TEACHER_ROLE) {
        require(hasRole(TEACHER_ROLE, msg.sender), "Assigned teacher must have Teacher role");
        grades[_courseId].push(Grade(_courseId, _student, _grade, block.timestamp));
        emit GradeRecorded(_courseId, _student, _grade);
    }

    function markAttendance(uint256 _courseId, address _student, bool _attended) external onlyRole(TEACHER_ROLE) {
        require(hasRole(TEACHER_ROLE, msg.sender), "Assigned teacher must have Teacher role");
        attendanceRecords[_courseId].push(Attendance(_courseId, _student, _attended));
        emit AttendanceMarked(_courseId, _student, _attended);
    }

    function getGrades(uint256 _courseId) public view returns (Grade[] memory) {
        return grades[_courseId];
    }

    function getAttendance(uint256 _courseId) public view returns (Attendance[] memory) {
        return attendanceRecords[_courseId];
    }

    uint256[50] private __gap;
}
