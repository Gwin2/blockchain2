// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./UniversityAccessControl.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./CourseManagement.sol";

contract GradeManagement is Initializable, UniversityAccessControl {
    CourseManagement public courseManagement;

    function initialize(address _courseManagement) public virtual override initializer {
        UniversityAccessControl.initialize();
        courseManagement = CourseManagement(_courseManagement);
    }

    struct Grade {
        uint256 courseId;
        address student;
        uint8 grade;
        uint256 date;
        string description;
        GradeType gradeType;
        bool isFinalized;
    }

    struct Attendance {
        uint256 courseId;
        address student;
        bool attended;
        uint256 date;
        string reason;
    }

    enum GradeType { Assignment, Midterm, Final, Project, Quiz }

    mapping(uint256 => Grade[]) private grades;
    mapping(uint256 => mapping(address => mapping(GradeType => Grade[]))) private studentGradesByType;
    mapping(uint256 => Attendance[]) private attendanceRecords;
    mapping(uint256 => mapping(address => uint256)) private studentAttendanceCount;
    mapping(uint256 => mapping(GradeType => uint256)) private gradeTypeWeights;

    event GradeRecorded(uint256 courseId, address indexed student, uint8 grade, GradeType gradeType);
    event GradeUpdated(uint256 courseId, address indexed student, uint8 oldGrade, uint8 newGrade);
    event GradeFinalized(uint256 courseId, address indexed student, GradeType gradeType);
    event AttendanceMarked(uint256 courseId, address indexed student, bool attended, string reason);
    event GradeWeightSet(uint256 courseId, GradeType gradeType, uint256 weight);

    modifier onlyCourseInstructor(uint256 _courseId) {
        CourseManagement.CourseView memory course = courseManagement.getCourseDetails(_courseId);
        require(course.instructor == msg.sender, "Only course instructor can perform this action");
        _;
    }

    modifier studentEnrolled(uint256 _courseId, address _student) {
        require(courseManagement.isEnrolled(_courseId, _student), "Student not enrolled in course");
        _;
    }

    modifier validGrade(uint8 _grade) {
        require(_grade <= 100, "Grade must be between 0 and 100");
        _;
    }

    function setGradeTypeWeight(
        uint256 _courseId,
        GradeType _gradeType,
        uint256 _weight
    ) external onlyCourseInstructor(_courseId) {
        require(_weight <= 100, "Weight must be between 0 and 100");
        
        uint256 totalWeight = _weight;
        for (uint i = 0; i < 5; i++) {
            if (GradeType(i) != _gradeType) {
                totalWeight += gradeTypeWeights[_courseId][GradeType(i)];
            }
        }
        require(totalWeight <= 100, "Total weights cannot exceed 100%");
        
        gradeTypeWeights[_courseId][_gradeType] = _weight;
        emit GradeWeightSet(_courseId, _gradeType, _weight);
    }

    function recordGrade(
        uint256 _courseId,
        address _student,
        uint8 _grade,
        string memory _description,
        GradeType _gradeType
    ) 
        external 
        onlyCourseInstructor(_courseId)
        studentEnrolled(_courseId, _student)
        validGrade(_grade)
    {
        Grade memory newGrade = Grade({
            courseId: _courseId,
            student: _student,
            grade: _grade,
            date: block.timestamp,
            description: _description,
            gradeType: _gradeType,
            isFinalized: false
        });
        
        grades[_courseId].push(newGrade);
        studentGradesByType[_courseId][_student][_gradeType].push(newGrade);
        
        emit GradeRecorded(_courseId, _student, _grade, _gradeType);
    }

    function updateGrade(
        uint256 _courseId,
        address _student,
        uint8 _newGrade,
        uint256 _gradeIndex,
        GradeType _gradeType
    )
        external
        onlyCourseInstructor(_courseId)
        studentEnrolled(_courseId, _student)
        validGrade(_newGrade)
    {
        Grade[] storage studentGrades = studentGradesByType[_courseId][_student][_gradeType];
        require(_gradeIndex < studentGrades.length, "Grade index out of bounds");
        require(!studentGrades[_gradeIndex].isFinalized, "Grade is finalized");
        
        uint8 oldGrade = studentGrades[_gradeIndex].grade;
        studentGrades[_gradeIndex].grade = _newGrade;
        
        emit GradeUpdated(_courseId, _student, oldGrade, _newGrade);
    }

    function finalizeGrade(
        uint256 _courseId,
        address _student,
        uint256 _gradeIndex,
        GradeType _gradeType
    )
        external
        onlyCourseInstructor(_courseId)
        studentEnrolled(_courseId, _student)
    {
        Grade[] storage studentGrades = studentGradesByType[_courseId][_student][_gradeType];
        require(_gradeIndex < studentGrades.length, "Grade index out of bounds");
        require(!studentGrades[_gradeIndex].isFinalized, "Grade already finalized");
        
        studentGrades[_gradeIndex].isFinalized = true;
        emit GradeFinalized(_courseId, _student, _gradeType);
    }

    function markAttendance(
        uint256 _courseId,
        address _student,
        bool _attended,
        string memory _reason
    ) 
        external 
        onlyCourseInstructor(_courseId)
        studentEnrolled(_courseId, _student)
    {
        attendanceRecords[_courseId].push(Attendance({
            courseId: _courseId,
            student: _student,
            attended: _attended,
            date: block.timestamp,
            reason: _reason
        }));

        if (_attended) {
            studentAttendanceCount[_courseId][_student]++;
        }
        
        emit AttendanceMarked(_courseId, _student, _attended, _reason);
    }

    function getStudentGrades(
        uint256 _courseId,
        address _student
    ) 
        external 
        view 
        returns (Grade[] memory) 
    {
        uint256 totalGrades = 0;
        for (uint i = 0; i < 5; i++) {
            totalGrades += studentGradesByType[_courseId][_student][GradeType(i)].length;
        }
        
        Grade[] memory allGrades = new Grade[](totalGrades);
        uint256 currentIndex = 0;
        
        for (uint i = 0; i < 5; i++) {
            Grade[] memory gradesByType = studentGradesByType[_courseId][_student][GradeType(i)];
            for (uint j = 0; j < gradesByType.length; j++) {
                allGrades[currentIndex] = gradesByType[j];
                currentIndex++;
            }
        }
        
        return allGrades;
    }

    function getStudentFinalGrade(
        uint256 _courseId,
        address _student
    ) 
        external 
        view 
        returns (uint256) 
    {
        uint256 weightedSum = 0;
        uint256 totalWeight = 0;
        
        for (uint i = 0; i < 5; i++) {
            GradeType gradeType = GradeType(i);
            Grade[] memory gradesByType = studentGradesByType[_courseId][_student][gradeType];
            
            if (gradesByType.length > 0 && gradeTypeWeights[_courseId][gradeType] > 0) {
                // Use the last grade of each type (most recent)
                uint256 lastIndex = gradesByType.length - 1;
                weightedSum += gradesByType[lastIndex].grade * gradeTypeWeights[_courseId][gradeType];
                totalWeight += gradeTypeWeights[_courseId][gradeType];
            }
        }
        
        if (totalWeight == 0) return 0;
        return weightedSum / totalWeight;
    }

    function getStudentAttendance(
        uint256 _courseId,
        address _student
    ) 
        external 
        view 
        returns (Attendance[] memory) 
    {
        uint256 count = 0;
        for (uint256 i = 0; i < attendanceRecords[_courseId].length; i++) {
            if (attendanceRecords[_courseId][i].student == _student) {
                count++;
            }
        }
        
        Attendance[] memory studentAttendance = new Attendance[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < attendanceRecords[_courseId].length; i++) {
            if (attendanceRecords[_courseId][i].student == _student) {
                studentAttendance[index] = attendanceRecords[_courseId][i];
                index++;
            }
        }
        
        return studentAttendance;
    }

    function getAttendanceRate(
        uint256 _courseId,
        address _student
    ) 
        external 
        view 
        returns (uint256) 
    {
        uint256 totalClasses = attendanceRecords[_courseId].length;
        if (totalClasses == 0) return 0;
        
        uint256 attended = studentAttendanceCount[_courseId][_student];
        return (attended * 100) / totalClasses;
    }
}
