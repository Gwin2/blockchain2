// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract UniversityAccessControl is Initializable, AccessControlUpgradeable {
    
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant STUDENT_ROLE = keccak256("STUDENT_ROLE");
    bytes32 public constant TEACHER_ROLE = keccak256("TEACHER_ROLE");

    function initialize() public initializer {
        __AccessControl_init();
        _setupRole(msg.sender, ADMIN_ROLE);
    }

    enum Role { None, Student, Teacher, Admin }

    event RoleAssigned(address indexed account, Role role);

    modifier onlyRole(Role _role) {
        require(hasRole(_role, msg.sender), "AccessControl: Access denied");
        _;
    }

    function assignRole(address _account, Role _role) external onlyRole(ADMIN_ROLE) {
        require(_role != Role.None, "Invalid role");
        _grantRole(getRoleHash(_role), _account);
        emit RoleAssigned(_account, _role);
    }

    function addUser(address _account, Role _role) external onlyRole(ADMIN_ROLE) {
        require(_role != Role.None, "Invalid role");
        _grantRole(getRoleHash(_role), _account);
        emit RoleAssigned(_account, _role);
    }

    function getRoleHash(Role _role) internal pure returns (bytes32) {
        if (_role == Role.Student) return STUDENT_ROLE;
        if (_role == Role.Teacher) return TEACHER_ROLE;
        if (_role == Role.Admin) return ADMIN_ROLE;
        return keccak256("");
    }

    function hasRole(Role _role, address _account) public view returns (bool) {
        return hasRole(getRoleHash(_role), _account);
    }

    function getRole(address _account) external view returns (Role) {
        if (hasRole(getRoleHash(Role.Student), _account)) return Role.Student;
        if (hasRole(getRoleHash(Role.Teacher), _account)) return Role.Teacher;
        if (hasRole(getRoleHash(Role.Admin), _account)) return Role.Admin;
        return Role.None;
    }
}
