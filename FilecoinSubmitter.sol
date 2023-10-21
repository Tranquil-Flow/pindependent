pragma solidity 0.8.21;

import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";

interface IDealStatus {
    function submit(bytes calldata _cid) external returns (uint256);
}

contract FilecoinSubmitter is AxelarExecutable {
    IDealStatus public dealStatus;

    event cidSubmitted(string indexed _cid, uint _txId);
    
    constructor() AxelarExecutable(0x999117D44220F33e0441fbAb2A5aDB8FF485c54D) {    // 0xe432150cce91c13a887f7D836923d5597adD8E31   EDIT mainnet
        dealStatus = IDealStatus(0x6ec8722e6543fB5976a547434c8644b51e24785b);   // Lighthouse SC on Filecoin Calibration Testnet
    }
    
    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload_
    ) internal override {
        string memory cid = abi.decode(payload_, (string));
        uint txId = dealStatus.submit(payload_);     
        emit cidSubmitted(cid, txId);
    }

}
