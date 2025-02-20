pragma solidity ^0.8.28;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

error NotEnoughMoneyToParticipate();
error NotAvailableNow();
error TransferFailed();

contract Raffle is VRFConsumerBaseV2Plus {

    event Result (
        address winner,
        uint number
    );

    uint256 s_subscriptionId;

    bytes32 keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;

    uint32 numWords = 1;

    uint32 callbackGasLimit = 100000;

    uint16 requestConfirmations = 3;

    address[5] participants;

    uint256[] public requestIds;

    uint counter = 0; // max 4

    constructor(uint subscriptionId, address vrfAddress) VRFConsumerBaseV2Plus(vrfAddress) {
        s_subscriptionId = subscriptionId;
    }


    function participate() external payable returns(uint) {
        require(msg.value >= 1000000000000000, NotEnoughMoneyToParticipate());
        require(counter < 4, NotAvailableNow());

        participants[counter] = msg.sender;

        counter++;
        
        payable(address(msg.sender)).transfer((msg.value - 1000000000000000));

        if(counter == 4) {
            startAuction();
        }

        return counter;      
    }

    function startAuction() private {
        uint requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );

        requestIds.push(requestId);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        uint _winnerNumber = randomWords[0] % 5;

        emit Result(participants[_winnerNumber], _winnerNumber);

        uint256 balance = address(this).balance;
        (bool success, ) = participants[_winnerNumber].call{value: balance}("");
        require(success, TransferFailed());

        counter = 0;
    }
}