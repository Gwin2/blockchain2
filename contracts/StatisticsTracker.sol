// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./GradeManagement.sol";
import "./ScheduleManagement.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./CourseManagement.sol";

contract StatisticsTracker is Initializable, GradeManagement, ScheduleManagement {
    CourseManagement public courseManagementContract;
    
    struct CourseStatistics {
        uint256 courseId;
        uint256 totalStudents;
        uint256 averageGrade;
        uint256 highestGrade;
        uint256 lowestGrade;
        uint256 averageAttendance;
        uint256 totalClasses;
        uint256 completionRate;
    }
    
    struct StudentStatistics {
        address student;
        uint256[] enrolledCourses;
        uint256 averageGrade;
        uint256 attendanceRate;
        uint256 completedCourses;
        uint256 ongoingCourses;
    }
    
    struct DepartmentStatistics {
        string department;
        uint256 totalStudents;
        uint256 totalCourses;
        uint256 averageGrade;
        uint256 averageAttendance;
        uint256 completionRate;
    }

    mapping(string => DepartmentStatistics) private departmentStats;
    string[] private departments;

    event StatisticsUpdated(uint256 courseId);
    event DepartmentStatisticsUpdated(string department);

    function initialize(
        address _courseManagement,
        address _gradeManagement,
        address _scheduleManagement
    ) public virtual override(GradeManagement, ScheduleManagement) initializer {
        courseManagementContract = CourseManagement(_courseManagement);
        GradeManagement.initialize(_gradeManagement);
        ScheduleManagement.initialize(_scheduleManagement);
    }

    function calculateCourseStatistics(uint256 _courseId) 
        public 
        view 
        returns (CourseStatistics memory) 
    {
        CourseManagement.CourseView memory course = courseManagementContract.getCourseDetails(_courseId);
        Grade[] memory courseGrades = this.getGrades(_courseId);
        
        uint256 totalGrades = 0;
        uint256 highestGrade = 0;
        uint256 lowestGrade = 100;
        
        for (uint256 i = 0; i < courseGrades.length; i++) {
            totalGrades += courseGrades[i].grade;
            if (courseGrades[i].grade > highestGrade) {
                highestGrade = courseGrades[i].grade;
            }
            if (courseGrades[i].grade < lowestGrade) {
                lowestGrade = courseGrades[i].grade;
            }
        }
        
        uint256 averageGrade = courseGrades.length > 0 ? totalGrades / courseGrades.length : 0;
        uint256 attendanceRate = this.getAttendanceRate(_courseId, address(0));
        
        return CourseStatistics({
            courseId: _courseId,
            totalStudents: course.enrolledStudents,
            averageGrade: averageGrade,
            highestGrade: highestGrade,
            lowestGrade: lowestGrade,
            averageAttendance: attendanceRate,
            totalClasses: this.getActiveSchedules(_courseId).length,
            completionRate: calculateCompletionRate(_courseId)
        });
    }

    function calculateStudentStatistics(address _student) 
        public 
        view 
        returns (StudentStatistics memory) 
    {
        uint256[] memory courses = courseManagementContract.getStudentCourses(_student);
        uint256 totalGrades = 0;
        uint256 totalAttendance = 0;
        uint256 completedCourses = 0;
        uint256 ongoingCourses = 0;
        
        for (uint256 i = 0; i < courses.length; i++) {
            uint256 courseId = courses[i];
            CourseManagement.CourseView memory course = courseManagementContract.getCourseDetails(courseId);
            
            if (block.timestamp > course.endDate) {
                completedCourses++;
            } else {
                ongoingCourses++;
            }
            
            totalGrades += this.getStudentFinalGrade(courseId, _student);
            totalAttendance += this.getAttendanceRate(courseId, _student);
        }
        
        return StudentStatistics({
            student: _student,
            enrolledCourses: courses,
            averageGrade: courses.length > 0 ? totalGrades / courses.length : 0,
            attendanceRate: courses.length > 0 ? totalAttendance / courses.length : 0,
            completedCourses: completedCourses,
            ongoingCourses: ongoingCourses
        });
    }

    function calculateDepartmentStatistics(string memory _department) 
        public 
        returns (DepartmentStatistics memory) 
    {
        uint256 totalStudents = 0;
        uint256 totalCourses = 0;
        uint256 totalGrades = 0;
        uint256 totalAttendance = 0;
        uint256 completedCourses = 0;
        
        for (uint256 i = 1; i <= courseManagementContract.courseCount(); i++) {
            CourseManagement.CourseView memory course = courseManagementContract.getCourseDetails(i);
            
            if (keccak256(bytes(course.department)) == keccak256(bytes(_department))) {
                totalCourses++;
                totalStudents += course.enrolledStudents;
                
                CourseStatistics memory stats = calculateCourseStatistics(i);
                totalGrades += stats.averageGrade;
                totalAttendance += stats.averageAttendance;
                
                if (block.timestamp > course.endDate) {
                    completedCourses++;
                }
            }
        }
        
        DepartmentStatistics memory stats = DepartmentStatistics({
            department: _department,
            totalStudents: totalStudents,
            totalCourses: totalCourses,
            averageGrade: totalCourses > 0 ? totalGrades / totalCourses : 0,
            averageAttendance: totalCourses > 0 ? totalAttendance / totalCourses : 0,
            completionRate: totalCourses > 0 ? (completedCourses * 100) / totalCourses : 0
        });
        
        departmentStats[_department] = stats;
        
        bool departmentExists = false;
        for (uint256 i = 0; i < departments.length; i++) {
            if (keccak256(bytes(departments[i])) == keccak256(bytes(_department))) {
                departmentExists = true;
                break;
            }
        }
        
        if (!departmentExists) {
            departments.push(_department);
        }
        
        emit DepartmentStatisticsUpdated(_department);
        return stats;
    }

    function getAllDepartmentStatistics() 
        external 
        view 
        returns (DepartmentStatistics[] memory) 
    {
        DepartmentStatistics[] memory allStats = new DepartmentStatistics[](departments.length);
        
        for (uint256 i = 0; i < departments.length; i++) {
            allStats[i] = departmentStats[departments[i]];
        }
        
        return allStats;
    }

    function calculateCompletionRate(uint256 _courseId) 
        internal 
        view 
        returns (uint256) 
    {
        CourseManagement.CourseView memory course = courseManagementContract.getCourseDetails(_courseId);
        
        if (block.timestamp <= course.startDate) {
            return 0;
        }
        
        if (block.timestamp >= course.endDate) {
            return 100;
        }
        
        uint256 totalDuration = course.endDate - course.startDate;
        uint256 elapsed = block.timestamp - course.startDate;
        
        return (elapsed * 100) / totalDuration;
    }

    function getAverageGradesByTimeRange(
        uint256 _courseId, 
        uint256 _startDate, 
        uint256 _endDate
    ) 
        external 
        view 
        returns (uint256) 
    {
        Grade[] memory courseGrades = this.getGrades(_courseId);
        uint256 totalGrades = 0;
        uint256 count = 0;
        
        for (uint256 i = 0; i < courseGrades.length; i++) {
            if (courseGrades[i].date >= _startDate && courseGrades[i].date <= _endDate) {
                totalGrades += courseGrades[i].grade;
                count++;
            }
        }
        
        return count > 0 ? totalGrades / count : 0;
    }

    function getTopPerformingStudents(uint256 _courseId, uint256 _limit) 
        external 
        view 
        returns (address[] memory students, uint256[] memory grades) 
    {
        CourseManagement.CourseView memory course = courseManagementContract.getCourseDetails(_courseId);
        address[] memory allStudents = new address[](course.enrolledStudents);
        uint256[] memory allGrades = new uint256[](course.enrolledStudents);
        uint256 count = 0;
        
        // Get all students and their grades
        for (uint256 i = 1; i <= courseManagementContract.courseCount(); i++) {
            if (courseManagementContract.isEnrolled(_courseId, address(uint160(i)))) {
                allStudents[count] = address(uint160(i));
                allGrades[count] = this.getStudentFinalGrade(_courseId, address(uint160(i)));
                count++;
            }
        }
        
        // Sort students by grades (bubble sort)
        for (uint256 i = 0; i < count - 1; i++) {
            for (uint256 j = 0; j < count - i - 1; j++) {
                if (allGrades[j] < allGrades[j + 1]) {
                    // Swap grades
                    uint256 tempGrade = allGrades[j];
                    allGrades[j] = allGrades[j + 1];
                    allGrades[j + 1] = tempGrade;
                    
                    // Swap addresses
                    address tempAddr = allStudents[j];
                    allStudents[j] = allStudents[j + 1];
                    allStudents[j + 1] = tempAddr;
                }
            }
        }
        
        // Return top N students
        uint256 resultSize = _limit < count ? _limit : count;
        students = new address[](resultSize);
        grades = new uint256[](resultSize);
        
        for (uint256 i = 0; i < resultSize; i++) {
            students[i] = allStudents[i];
            grades[i] = allGrades[i];
        }
        
        return (students, grades);
    }
}
