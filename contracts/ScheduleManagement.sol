// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./UniversityAccessControl.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ScheduleManagement is Initializable, UniversityAccessControl {

    function initialize() public virtual override initializer {
        UniversityAccessControl.initialize();
    }

    struct Schedule {
        uint256 courseId;
        string date;
        string time;
    }

    mapping(uint256 => Schedule[]) private schedules;

    event ScheduleCreated(uint256 courseId, string date, string time);

    function createSchedule(uint256 _courseId, string memory _date, string memory _time) external onlyRole(TEACHER_ROLE) {
        schedules[_courseId].push(Schedule(_courseId, _date, _time));
        emit ScheduleCreated(_courseId, _date, _time);
    }

    function getSchedule(uint256 _courseId) external view returns (Schedule[] memory) {
        return schedules[_courseId];
    }

    function editSchedule(uint256 _courseId, uint256 _scheduleIndex, string memory _newDate, string memory _newTime) external onlyRole(TEACHER_ROLE) {
        Schedule storage schedule = schedules[_courseId][_scheduleIndex];
        schedule.date = _newDate;
        schedule.time = _newTime;
    }

    function getScheduleByDate(uint256 _courseId, string memory _date) external view returns (Schedule[] memory) {
        Schedule[] memory courseSchedules = schedules[_courseId];
        uint256 count = 0;
        for (uint256 i = 0; i < courseSchedules.length; i++) {
            if (keccak256(bytes(courseSchedules[i].date)) == keccak256(bytes(_date))) {
                count++;
            }
        }
        Schedule[] memory filteredSchedules = new Schedule[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < courseSchedules.length; i++) {
            if (keccak256(bytes(courseSchedules[i].date)) == keccak256(bytes(_date))) {
                filteredSchedules[index] = courseSchedules[i];
                index++;
            }
        }
        return filteredSchedules;
    }
}
