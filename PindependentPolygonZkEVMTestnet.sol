pragma solidity ^0.8.0;

import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";

// Pindependent PolygonZkEVMTestnet
contract Pindependent is AxelarExecutable {
    IAxelarGasService public immutable gasService;

    address[] public pinners;

    mapping(string => uint) public feeForCid;

    string destinationChain;
    string destinationCheckerAddress;
    string destinationSubmitterAddress;

    event RewardsProcessingStarted (string _cid);
    event RewardsProcessingFinished (string indexed _cid, uint rewardAmount, uint providersRewarded);
    event RewardsAdded(string _cid, uint rewardAmount);
    event CidSubmitted (string _cid);

    error NotEnoughValueForGas();

    constructor() AxelarExecutable(0x999117D44220F33e0441fbAb2A5aDB8FF485c54D) {
        gasService = IAxelarGasService(0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6);

        destinationChain = "filecoin-2";
        destinationCheckerAddress = "0xe4De066Cdada7702885CEf394031bC05e9b9D0Ac";
        destinationSubmitterAddress = "0x0EA396A60CbcA1158cd3ACB0bf1a85fa7A6E193D";
    }

    function processRewards(string calldata cid) public payable {
        if (msg.value == 0)  revert NotEnoughValueForGas();

        bytes memory payload = abi.encode(cid);
        gasService.payNativeGasForContractCall{value: msg.value} (
            address(this),
            destinationChain,
            destinationCheckerAddress,
            payload,
            msg.sender
        );

        gateway.callContract(destinationChain,destinationCheckerAddress,payload);
        emit RewardsProcessingStarted(cid);
    }

    function submitCid(string calldata cid) external payable {
        if (msg.value == 0)  revert NotEnoughValueForGas();
        
        bytes memory payload = abi.encode(cid);
        gasService.payNativeGasForContractCall{value: msg.value} (
            address(this),
            destinationChain,
            destinationSubmitterAddress,
            payload,
            msg.sender
        );

        gateway.callContract(destinationChain,destinationSubmitterAddress,payload);
        emit CidSubmitted(cid);
    }

    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload_
    ) internal override {
        string memory cid;
        (pinners, cid) = abi.decode(payload_, (address[], string));
        payRewards(cid);
    }

    function payRewards(string memory cid) internal {
        uint totalBalance = feeForCid[cid];
        uint amountPerPinner = totalBalance / pinners.length;

        for (uint i = 0; i < pinners.length; i++) {
            (bool success, ) = payable(pinners[i]).call{value: amountPerPinner}("");
            require(success, "Transfer failed");
        }
        emit RewardsProcessingFinished(cid, totalBalance, pinners.length);
    }

    function addFees(string calldata cid) external payable {
        feeForCid[cid] += msg.value;
        emit RewardsAdded(cid, msg.value);
    }

    receive() external payable {}

}