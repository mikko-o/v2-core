// SPDX-License-Identifier: MIT
pragma solidity =0.5.16;

import './interfaces/IVPToken.sol';
import './interfaces/IDelegatablePair.sol';
import './interfaces/IFactoryWithDelegations.sol';
import './UniswapV2Pair.sol';

contract DelegatablePair is IDelegatablePair, UniswapV2Pair {
    function initializeDelegations() external {
        require(msg.sender == factory, 'FORBIDDEN');
        address[] memory delegatees = IFactoryWithDelegations(msg.sender).getDelegatees();
        uint256[] memory bips = IFactoryWithDelegations(msg.sender).getBips();
        delegate(delegatees, bips);
    }

    function delegate(address[] memory _delegatees, uint256[] memory _bips) public {
        require(msg.sender == factory, 'FORBIDDEN');
        _clearDelegations();
        _delegate(_delegatees, _bips);
    }

    function claimReward(
        address payable _recipient,
        uint256[] calldata _rewardEpochs
    ) external returns (uint256 _rewardAmount) {
        require(msg.sender == factory, 'FORBIDDEN');
        IFtsoRewardManager ftsoRewardManager = IFactoryWithDelegations(factory).getFtsoRewardManager();
        _rewardAmount += ftsoRewardManager.claimReward(_recipient, _rewardEpochs);
    }

    function _clearDelegations() private {
        address[] memory currentDelegatees = IFactoryWithDelegations(factory).getDelegatees();
        IVPToken vpToken = IFactoryWithDelegations(factory).getVPToken();

        for (uint256 i = 0; i < currentDelegatees.length; i++) {
            vpToken.delegate(currentDelegatees[i], 0);
        }
    }

    function _delegate(address[] memory _delegatees, uint256[] memory _bips) private {
        IVPToken vpToken = IFactoryWithDelegations(factory).getVPToken();
        for (uint256 i = 0; i < _delegatees.length; i++) {
            vpToken.delegate(_delegatees[i], _bips[i]);
        }
    }
}
