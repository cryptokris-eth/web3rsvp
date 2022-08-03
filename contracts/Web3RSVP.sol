// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Web3RSVP {
    
    struct CreateEvent {
        bytes32 eventId;
        string eventDataCID; //a reference to an IPFS to store event name and description
        address eventOwner;
        uint256 eventTimestamp;
        uint256 deposit;
        uint256 maxCapacity;
        address[] confirmedRSVPs;
        address[] claimedRSVPs;
        bool paidOut;
    }

    mapping(bytes32 => CreateEvent) public idToEvent;

    function createNewEvent(
        uint256 eventTimestamp,
        uint256 deposit,
        uint256 maxCapacity,
        string calldata eventDataCID
    ) external {
        //generate an eventId based on other things passed in => hash
        bytes32 eventId = keccak256(abi.encodePacked(
            msg.sender,
            address(this),
            eventTimestamp,
            deposit,
            maxCapacity));

        address[] memory confirmedRSVPs; //initialize the array to be used in the struct
        address[] memory claimedRSVPs;

        //this creates a new CreateEvent struct and adds it to the idToEvent mapping
        idToEvent[eventId] = CreateEvent(
            eventId,
            eventDataCID,
            msg.sender,
            eventTimestamp,
            deposit,
            maxCapacity,
            confirmedRSVPs,
            claimedRSVPs,
            false
        );
    }

    function createNewRSVP(bytes32 eventId) external payable {
        //look up event from our mapping
        CreateEvent storage myEvent = idToEvent[eventId];

        //transfer deposit to our contract / require min amout
        require(msg.value == myEvent.deposit, "NOT ENOUGH token provided");

        //require that the event hasn't started yet
        require(block.timestamp <= myEvent.eventTimestamp, "The event has already passed");

        //make sure the event is under the maxCapacity
        require(
            myEvent.confirmedRSVPs.length < myEvent.maxCapacity, 
            "This event has reached its max capacity"
        );

        //require that the msg.sender isn't already in the list of confirmedRSVPs
        for(uint8 i=0; i < myEvent.confirmedRSVPs.length; i++){
            require(myEvent.confirmedRSVPs[i] != msg.sender, "Already confirmed");
        }

        myEvent.confirmedRSVPs.push(payable(msg.sender));
    }

}
