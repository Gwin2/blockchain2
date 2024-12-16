// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./UniversityAccessControl.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./CourseManagement.sol";

contract ScheduleManagement is Initializable, UniversityAccessControl {
    CourseManagement public courseManagement;

    function initialize(address _courseManagement) public virtual override initializer {
        UniversityAccessControl.initialize();
        courseManagement = CourseManagement(_courseManagement);
    }

    struct Schedule {
        uint256 courseId;
        uint256 date;
        uint256 startTime;
        uint256 endTime;
        string location;
        string description;
        bool isRecurring;
        uint256 recurringInterval; // in days
        uint256 recurringEndDate;
        bool isCancelled;
    }

    struct ScheduleConflict {
        uint256 courseId1;
        uint256 courseId2;
        uint256 date;
        uint256 startTime;
        uint256 endTime;
    }

    mapping(uint256 => Schedule[]) private schedules;
    mapping(uint256 => mapping(uint256 => bool)) private dateScheduled; // courseId => date => bool
    mapping(address => mapping(uint256 => mapping(uint256 => bool))) private studentAvailability; // student => date => timeSlot => bool

    event ScheduleCreated(
        uint256 courseId, 
        uint256 date, 
        uint256 startTime, 
        uint256 endTime, 
        string location
    );
    event ScheduleUpdated(uint256 courseId, uint256 scheduleIndex);
    event ScheduleCancelled(uint256 courseId, uint256 scheduleIndex);
    event ConflictDetected(uint256 courseId1, uint256 courseId2, uint256 date);
    event StudentAvailabilitySet(address student, uint256 date, uint256 timeSlot, bool isAvailable);

    modifier onlyCourseInstructor(uint256 _courseId) {
        CourseManagement.CourseView memory course = courseManagement.getCourseDetails(_courseId);
        require(course.instructor == msg.sender, "Only course instructor can perform this action");
        _;
    }

    modifier validTimeRange(uint256 _startTime, uint256 _endTime) {
        require(_startTime < _endTime, "Invalid time range");
        require(_startTime >= 0 && _startTime < 24 * 60 * 60, "Invalid start time");
        require(_endTime > 0 && _endTime <= 24 * 60 * 60, "Invalid end time");
        _;
    }

    function createSchedule(
        uint256 _courseId,
        uint256 _date,
        uint256 _startTime,
        uint256 _endTime,
        string memory _location,
        string memory _description,
        bool _isRecurring,
        uint256 _recurringInterval,
        uint256 _recurringEndDate
    ) 
        external 
        onlyCourseInstructor(_courseId)
        validTimeRange(_startTime, _endTime)
    {
        require(_date >= block.timestamp, "Cannot schedule in the past");
        if (_isRecurring) {
            require(_recurringEndDate > _date, "Invalid recurring end date");
            require(_recurringInterval > 0, "Invalid recurring interval");
        }

        Schedule memory newSchedule = Schedule({
            courseId: _courseId,
            date: _date,
            startTime: _startTime,
            endTime: _endTime,
            location: _location,
            description: _description,
            isRecurring: _isRecurring,
            recurringInterval: _recurringInterval,
            recurringEndDate: _recurringEndDate,
            isCancelled: false
        });

        // Check for conflicts
        require(!hasScheduleConflict(_courseId, _date, _startTime, _endTime), "Schedule conflict detected");

        schedules[_courseId].push(newSchedule);
        dateScheduled[_courseId][_date] = true;

        emit ScheduleCreated(_courseId, _date, _startTime, _endTime, _location);

        // Create recurring schedules
        if (_isRecurring) {
            uint256 nextDate = _date + (_recurringInterval * 1 days);
            while (nextDate <= _recurringEndDate) {
                Schedule memory recurringSchedule = Schedule({
                    courseId: _courseId,
                    date: nextDate,
                    startTime: _startTime,
                    endTime: _endTime,
                    location: _location,
                    description: _description,
                    isRecurring: true,
                    recurringInterval: _recurringInterval,
                    recurringEndDate: _recurringEndDate,
                    isCancelled: false
                });

                if (!hasScheduleConflict(_courseId, nextDate, _startTime, _endTime)) {
                    schedules[_courseId].push(recurringSchedule);
                    dateScheduled[_courseId][nextDate] = true;
                    emit ScheduleCreated(_courseId, nextDate, _startTime, _endTime, _location);
                }

                nextDate += (_recurringInterval * 1 days);
            }
        }
    }

    function updateSchedule(
        uint256 _courseId,
        uint256 _scheduleIndex,
        uint256 _newDate,
        uint256 _newStartTime,
        uint256 _newEndTime,
        string memory _newLocation,
        string memory _newDescription
    ) 
        external 
        onlyCourseInstructor(_courseId)
        validTimeRange(_newStartTime, _newEndTime)
    {
        require(_scheduleIndex < schedules[_courseId].length, "Invalid schedule index");
        Schedule storage schedule = schedules[_courseId][_scheduleIndex];
        require(!schedule.isCancelled, "Schedule is cancelled");
        require(_newDate >= block.timestamp, "Cannot schedule in the past");

        // Remove old date scheduling
        dateScheduled[_courseId][schedule.date] = false;

        // Check for conflicts with new time
        require(!hasScheduleConflict(_courseId, _newDate, _newStartTime, _newEndTime), "Schedule conflict detected");

        schedule.date = _newDate;
        schedule.startTime = _newStartTime;
        schedule.endTime = _newEndTime;
        schedule.location = _newLocation;
        schedule.description = _newDescription;

        // Update date scheduling
        dateScheduled[_courseId][_newDate] = true;

        emit ScheduleUpdated(_courseId, _scheduleIndex);
    }

    function cancelSchedule(uint256 _courseId, uint256 _scheduleIndex) 
        external 
        onlyCourseInstructor(_courseId) 
    {
        require(_scheduleIndex < schedules[_courseId].length, "Invalid schedule index");
        Schedule storage schedule = schedules[_courseId][_scheduleIndex];
        require(!schedule.isCancelled, "Schedule already cancelled");

        schedule.isCancelled = true;
        dateScheduled[_courseId][schedule.date] = false;

        emit ScheduleCancelled(_courseId, _scheduleIndex);
    }

    function setStudentAvailability(
        uint256 _date,
        uint256 _timeSlot,
        bool _isAvailable
    ) 
        external 
        onlyRole(STUDENT_ROLE) 
    {
        require(_date >= block.timestamp, "Cannot set availability for past dates");
        require(_timeSlot < 24, "Invalid time slot");

        studentAvailability[msg.sender][_date][_timeSlot] = _isAvailable;
        emit StudentAvailabilitySet(msg.sender, _date, _timeSlot, _isAvailable);
    }

    function getSchedule(uint256 _courseId) 
        external 
        view 
        returns (Schedule[] memory) 
    {
        return schedules[_courseId];
    }

    function getActiveSchedules(uint256 _courseId) 
        external 
        view 
        returns (Schedule[] memory) 
    {
        uint256 activeCount = 0;
        for (uint256 i = 0; i < schedules[_courseId].length; i++) {
            if (!schedules[_courseId][i].isCancelled && schedules[_courseId][i].date >= block.timestamp) {
                activeCount++;
            }
        }

        Schedule[] memory activeSchedules = new Schedule[](activeCount);
        uint256 index = 0;
        for (uint256 i = 0; i < schedules[_courseId].length; i++) {
            if (!schedules[_courseId][i].isCancelled && schedules[_courseId][i].date >= block.timestamp) {
                activeSchedules[index] = schedules[_courseId][i];
                index++;
            }
        }

        return activeSchedules;
    }

    function getSchedulesByDateRange(
        uint256 _courseId, 
        uint256 _startDate, 
        uint256 _endDate
    ) 
        external 
        view 
        returns (Schedule[] memory) 
    {
        require(_startDate <= _endDate, "Invalid date range");

        uint256 count = 0;
        for (uint256 i = 0; i < schedules[_courseId].length; i++) {
            Schedule memory schedule = schedules[_courseId][i];
            if (!schedule.isCancelled && 
                schedule.date >= _startDate && 
                schedule.date <= _endDate) {
                count++;
            }
        }

        Schedule[] memory filteredSchedules = new Schedule[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < schedules[_courseId].length; i++) {
            Schedule memory schedule = schedules[_courseId][i];
            if (!schedule.isCancelled && 
                schedule.date >= _startDate && 
                schedule.date <= _endDate) {
                filteredSchedules[index] = schedule;
                index++;
            }
        }

        return filteredSchedules;
    }

    function hasScheduleConflict(
        uint256 _courseId,
        uint256 _date,
        uint256 _startTime,
        uint256 _endTime
    ) 
        internal 
        view 
        returns (bool) 
    {
        for (uint256 i = 0; i < schedules[_courseId].length; i++) {
            Schedule memory existingSchedule = schedules[_courseId][i];
            if (!existingSchedule.isCancelled && 
                existingSchedule.date == _date &&
                !((existingSchedule.endTime <= _startTime) || 
                  (existingSchedule.startTime >= _endTime))) {
                return true;
            }
        }
        return false;
    }

    function getStudentAvailability(
        address _student,
        uint256 _date
    ) 
        external 
        view 
        returns (bool[] memory) 
    {
        bool[] memory availability = new bool[](24);
        for (uint256 i = 0; i < 24; i++) {
            availability[i] = studentAvailability[_student][_date][i];
        }
        return availability;
    }
}
