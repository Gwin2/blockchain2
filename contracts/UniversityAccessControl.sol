// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract UniversityAccessControl is Initializable, AccessControlUpgradeable {
    
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    function initialize() public initializer {
        __AccessControl_init();
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    enum Role { None, Student, Teacher, Admin }

    event RoleAssigned(address indexed account, Role role);

    modifier onlyRole(Role _role) {
        require(hasRole(_role, msg.sender), "AccessControl: Access denied");
        _;
    }

    function assignRole(address _account, Role _role) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_role != Role.None, "Invalid role");
        _grantRole(getRoleHash(_role), _account);
        emit RoleAssigned(_account, _role);
    }

    function addUser(address _account, Role _role) external onlyRole(Role.Admin) {
        require(_role != Role.None, "Invalid role");
        _grantRole(_role, _account);
        emit RoleAssigned(_account, _role);
    }

    function getRole(address _account) external view returns (Role) {
        uint256 role = getRoleHash(_account);
        if (role == getRoleHash(Role.Student)) return Role.Student;
        if (role == getRoleHash(Role.Teacher)) return Role.Teacher;
        if (role == getRoleHash(Role.Admin)) return Role.Admin;
        return Role.None;
    }

    function hasRole(address _account, Role _role) public view returns (bool) {
        return hasRole(_role, _account);
    }

    function getRoleHash(address _account) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_account)));
    }

    function getRoleHash(Role _role) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_role)));
    }
}
