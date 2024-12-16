// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract UniversityAccessControl is Initializable, AccessControl {
    
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant STUDENT_ROLE = keccak256("STUDENT_ROLE");
    bytes32 public constant TEACHER_ROLE = keccak256("TEACHER_ROLE");
    bytes32 public constant DEPARTMENT_HEAD_ROLE = keccak256("DEPARTMENT_HEAD_ROLE");

    // Mapping to store additional user information
    mapping(address => UserInfo) public userInfo;
    
    struct UserInfo {
        string name;
        string department;
        uint256 registrationDate;
        bool isActive;
    }

    event RoleAssigned(address indexed account, Role role);
    event UserInfoUpdated(address indexed account, string name, string department);
    event UserStatusChanged(address indexed account, bool isActive);

    function initialize() public virtual initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(STUDENT_ROLE, ADMIN_ROLE);
        _setRoleAdmin(TEACHER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(DEPARTMENT_HEAD_ROLE, ADMIN_ROLE);
    }
    
    enum Role { None, Student, Teacher, Admin, DepartmentHead }

    modifier onlyActiveUser(address _account) {
        require(userInfo[_account].isActive, "User is not active");
        _;
    }

    function assignRole(address _account, Role _role, string memory _name, string memory _department) 
        external 
        onlyRole(ADMIN_ROLE) 
    {
        require(_account != address(0), "Invalid address");
        require(_role != Role.None, "Invalid role");
        require(bytes(_name).length > 0, "Name cannot be empty");
        
        _grantRole(getRoleHash(_role), _account);
        
        userInfo[_account] = UserInfo({
            name: _name,
            department: _department,
            registrationDate: block.timestamp,
            isActive: true
        });
        
        emit RoleAssigned(_account, _role);
        emit UserInfoUpdated(_account, _name, _department);
    }

    function updateUserInfo(address _account, string memory _name, string memory _department) 
        external 
        onlyRole(ADMIN_ROLE) 
    {
        require(_account != address(0), "Invalid address");
        require(bytes(_name).length > 0, "Name cannot be empty");
        
        userInfo[_account].name = _name;
        userInfo[_account].department = _department;
        
        emit UserInfoUpdated(_account, _name, _department);
    }

    function setUserStatus(address _account, bool _isActive) 
        external 
        onlyRole(ADMIN_ROLE) 
    {
        require(_account != address(0), "Invalid address");
        userInfo[_account].isActive = _isActive;
        emit UserStatusChanged(_account, _isActive);
    }

    function getRoleHash(Role _role) internal pure returns (bytes32) {
        if (_role == Role.Student) return STUDENT_ROLE;
        if (_role == Role.Teacher) return TEACHER_ROLE;
        if (_role == Role.Admin) return ADMIN_ROLE;
        if (_role == Role.DepartmentHead) return DEPARTMENT_HEAD_ROLE;
        return bytes32(0);
    }

    function hasRole(bytes32 _role, address _account) public view override returns (bool) {
        return super.hasRole(_role, _account);
    }

    function getRole(address _account) external view returns (Role) {
        if (hasRole(STUDENT_ROLE, _account)) return Role.Student;
        if (hasRole(TEACHER_ROLE, _account)) return Role.Teacher;
        if (hasRole(ADMIN_ROLE, _account)) return Role.Admin;
        if (hasRole(DEPARTMENT_HEAD_ROLE, _account)) return Role.DepartmentHead;
        return Role.None;
    }

    function getUserInfo(address _account) 
        external 
        view 
        returns (
            string memory name,
            string memory department,
            uint256 registrationDate,
            bool isActive,
            Role role
        ) 
    {
        UserInfo storage info = userInfo[_account];
        return (
            info.name,
            info.department,
            info.registrationDate,
            info.isActive,
            this.getRole(_account)
        );
    }
}
