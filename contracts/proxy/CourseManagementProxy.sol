// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BaseUpgradeableProxy.sol";

contract CourseManagementProxy is BaseUpgradeableProxy {
    constructor(
        address _logic,
        address _admin,
        bytes memory _data
    ) BaseUpgradeableProxy(_logic, _admin, _data) {}
}
