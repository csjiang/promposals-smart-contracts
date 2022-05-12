// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./StudentFactory.sol";

error StudentHasDateAlready(uint studentIdPromposee);

contract Promposal {
    mapping (uint => uint[]) promposals;
    Student[] private studentsWithPromDateAlready;

    uint256 dateOfProm;

    event PromposalAccepted(uint studentId1, uint studentId2);
    event PromposalPending(uint promposalReceiverStudentId);
    event PromDateSet(uint utcPromTime);

    // once date of prom is set by an external admin, the race begins!
    function setDateOfProm(uint utcPromTime) public {
        dateOfProm = utcPromTime;
        emit PromDateSet(dateOfProm);
    }

    function send(uint _senderStudentId, uint _receiverStudentId) public {

        require(now <= dateOfProm); // don't be late!

        // check if student already has a prom date
        for (uint i = 0; i < studentsWithPromDateAlready.length; i++) {
            if (_receiverStudentId == studentsWithPromDateAlready[i]) {
                revert StudentHasDateAlready({ studentIdPromposee: _receiverStudentId });
            }
        }

        // check if interest is receiprocated!
        bool isInterestReciprocated = false;
        uint[] studentsReceiverHasPromposedTo = promposals[_receiverStudentId];
        for (uint i = 0; i < studentsReceiverHasPromposedTo.length; i++) {
            uint promposeeStudentId = studentsReceiverHasPromposedTo[i];
            if (_senderStudentId == promposeeStudentId) {
                isInterestReciprocated = true;
            }
        }

        if (isInterestReciprocated) {
            emit PromposalAccepted(_senderStudentId, _receiverStudentId);
            // take students out of the running
            studentsWithPromDateAlready.push(_senderStudentId);
            studentsWithPromDateAlready.push(_receiverStudentId);
        } else {
            promposals[_senderStudentId].push(_receiverStudentId)
            emit PromposalPending(_receiverStudentId); // off-chain, imagine that this will send notification email/text prompting receiver to submit their own promposals
        }
    }
}
