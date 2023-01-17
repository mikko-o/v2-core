// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16;

interface IDelegatablePair {
    function delegate(address[] calldata _delegatees, uint256[] calldata _bips) external;

    function claimReward(
        address payable _recipient,
        uint256[] calldata _rewardEpochs
    ) external returns (uint256 _rewardAmount);

    function initializeDelegations() external;
}
