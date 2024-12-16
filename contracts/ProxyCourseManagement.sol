// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract ProxyCourseManagement {
    address public implementation;
    address public admin;

    constructor(address _implementation) {
        implementation = _implementation;
        admin = msg.sender;
    }

    fallback() external payable {
        require(msg.sender != admin, "Admin cannot call fallback");
        address impl = implementation;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function updateImplementation(address newImplementation) external {
        require(msg.sender == admin, "Only admin can update implementation");
        implementation = newImplementation;
    }
}
