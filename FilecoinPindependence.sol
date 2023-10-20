// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import {MarketAPI} from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";

interface IDealStatus {
    function submit(bytes calldata _cid) external returns (uint256);
    function getActiveDeals(bytes calldata _cid) external returns (FilecoinPindependence.Deal[] memory);
}

contract FilecoinPindependence is AxelarExecutable {
    IDealStatus public dealStatus;

    struct Deal {
        uint64 dealId;
        uint64 minerId;
    }

    mapping(string => address[]) public pinnerList;

    // EDIT filecoin:  0xe432150cce91c13a887f7D836923d5597adD8E31
    // filecoin testnet: 0x999117D44220F33e0441fbAb2A5aDB8FF485c54D
    constructor() AxelarExecutable(0x999117D44220F33e0441fbAb2A5aDB8FF485c54D) {
        pinnerList["test"].push(0xd35Fd30DfD459F786Da68e6A09129FDC13850dc1);
        pinnerList["test"].push(0x91179Ce40f3ef7A490FB35DE3A277C4Ba711c568);
        dealStatus = IDealStatus(0x91179Ce40f3ef7A490FB35DE3A277C4Ba711c568);   // EDIT change to lighthouse deployment address
    }

    function _execute(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) internal override {
        string memory cid = abi.decode(payload, (string));
        
        Deal[] memory deals = dealStatus.getActiveDeals(payload);

        for (uint256 i = 0; i < deals.length; i++) {
            uint64 dealId = deals[i].dealId;
            
            // get the filecoin address of the pinner
            uint64 provider = MarketAPI.getDealProvider(dealId);
            
            // convert provider number to ethereum address
            address pinner = uint64ToAddress(provider);

            // add to list of pinners
            pinnerList[cid].push(pinner);
        }

        gateway.callContract(sourceChain, sourceAddress, abi.encode(pinnerList[cid]));
        success = true;
    }

    function uint64ToAddress(uint64 value) public pure returns (address) {
        return address(uint160(value));
    }

    bool public success;

    function submitCID(string calldata cid) external {
        pinnerList[cid].push(msg.sender);
    }
}