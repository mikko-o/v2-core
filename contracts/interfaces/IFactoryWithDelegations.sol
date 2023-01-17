// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16;

import './IVPToken.sol';
import './IFtsoRewardManager.sol';

interface IFactoryWithDelegations {
    function getDelegatees() external view returns (address[] memory);

    function getBips() external view returns (uint256[] memory);

    function getVPToken() external view returns (IVPToken);

    function getFtsoRewardManager() external view returns (IFtsoRewardManager);

    function setFtsoRewardManager(IFtsoRewardManager _ftsoRewardManager) external;
}
