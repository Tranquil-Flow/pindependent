pragma solidity 0.8.21;

import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";

contract PindependenceHandler is AxelarExecutable {
    IAxelarGasService public immutable gasService;

    mapping(string => address[]) public pinners;
    mapping(string => uint) public feeForCid;

    string destinationChain;
    string destinationCheckerAddress;
    string destinationSubmitterAddress;

    event RewardsProcessingStarted (string _cid);
    event RewardsProcessingFinished (string indexed _cid, uint rewardAmount, uint providersRewarded);
    event RewardsAdded(string _cid, uint rewardAmount);
    event CidSubmitted (string _cid);

    error NotEnoughValueForGas();

    // https://docs.axelar.dev/resources/mainnet
    constructor(address gateway_, address gasService_) AxelarExecutable(gateway_) {
        gasService = IAxelarGasService(gasService_);

        destinationChain = "filecoin-2";    // EDIT "filecoin"
        destinationCheckerAddress = "0xe4De066Cdada7702885CEf394031bC05e9b9D0Ac";  // EDIT mainnet deployment
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
        (pinners[cid], cid) = abi.decode(payload_, (address[], string));
        payRewards(cid);
    }

    function payRewards(string memory cid) internal {
        uint totalBalance = feeForCid[cid];
        uint amountPerPinner = totalBalance / pinners[cid].length;

        for (uint i = 0; i < pinners[cid].length; i++) {
            (bool success, ) = payable(pinners[cid][i]).call{value: amountPerPinner}("");
            require(success, "Transfer failed");
        }
        emit RewardsProcessingFinished(cid, totalBalance, pinners[cid].length);
    }

    function addFees(string calldata cid) external payable {
        feeForCid[cid] += msg.value;
        emit RewardsAdded(cid, msg.value);
    }

    receive() external payable {}
}