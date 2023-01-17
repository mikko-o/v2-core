// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16;

import './UniswapV2Factory.sol';
import './interfaces/IFactoryWithDelegations.sol';
import './interfaces/IDelegatablePair.sol';

contract FactoryWithDelegations is IFactoryWithDelegations, UniswapV2Factory {
    // The delegatees for all LPs
    address[] private delegatees;
    // The current delegation percentages for all LPs
    uint256[] private bips;

    IVPToken private vpToken;
    IFtsoRewardManager private ftsoRewardManager;

    address public delegationSetter;

    constructor(
        IVPToken _vpToken,
        address _delegationSetter,
        address _feeToSetter
    ) public UniswapV2Factory(_feeToSetter) {
        vpToken = _vpToken;
        delegationSetter = _delegationSetter;
    }

    /**
     * @return Current delegators
     */
    function getDelegatees() external view returns (address[] memory) {
        return delegatees;
    }

    /**
     * @return Current bips
     */
    function getBips() external view returns (uint256[] memory) {
        return bips;
    }

    function getVPToken() external view returns (IVPToken) {
        return vpToken;
    }

    /**
     * @notice For all pairs, clears old delegations and makes new delegations
     * @param _delegatees Addresses to delegate to
     * @param _bips The percentages of voting power to be delegated expressed in basis points (1/100 of one percent).
     */
    function delegate(address[] calldata _delegatees, uint256[] calldata _bips) external {
        require(msg.sender == delegationSetter, 'FORBIDDEN');
        require(_delegatees.length == _bips.length, 'Mismatched array lengths');
        require(_delegatees.length <= 2, 'Max 2 delegatees');

        for (uint256 i = 0; i < allPairs.length; i++) {
            IDelegatablePair(allPairs[i]).delegate(_delegatees, _bips);
        }

        delegatees = _delegatees;
        bips = _bips;
    }

    /**
     * @notice Claims rewards for all pairs
     * @param _recipient Address to transfer funds to
     * @param _rewardEpochs Array of reward epoch numbers to claim for
     * @return _rewardAmount Amount of total claimed rewards
     */
    function claimReward(
        address payable _recipient,
        uint256[] calldata _rewardEpochs
    ) external returns (uint256 _rewardAmount) {
        for (uint256 i = 0; i < allPairs.length; i++) {
            _rewardAmount += IDelegatablePair(allPairs[i]).claimReward(_recipient, _rewardEpochs);
        }
    }

    function getFtsoRewardManager() external view returns (IFtsoRewardManager) {
        return ftsoRewardManager;
    }

    function setFtsoRewardManager(IFtsoRewardManager _ftsoRewardManager) external {
        require(msg.sender == delegationSetter, 'FORBIDDEN');
        ftsoRewardManager = _ftsoRewardManager;
    }
}
