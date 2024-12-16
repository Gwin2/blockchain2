// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../contracts/proxy/UniversityProxyAdmin.sol";

contract TestHelper {
    function deployProxy(address logic, address admin, bytes memory data) public returns (address) {
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            logic,
            admin,
            data
        );
        return address(proxy);
    }

    function getProxyAdmin() public returns (UniversityProxyAdmin) {
        return new UniversityProxyAdmin();
    }
}
