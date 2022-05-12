// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract StudentFactory is Ownable {
    event NewStudent(uint256 studentId, string name);

    struct Student {
        string name;
        uint256 studentId;
    }

    Student[] public students;

    mapping(uint256 => address) public studentIdToWallet;
    mapping(address => uint256) studentIdsPerWallet; // enforce 1:1 mapping

    function registerStudent(string _name, uint256 _studentId) internal {
        require(studentIdsPerWallet[msg.sender] == 0);
        uint256 id = students.push(Student(_name, _studentId)) - 1;
        studentIdToWallet[id] = msg.sender;
        studentIdsPerWallet[msg.sender]++;
        emit NewStudent(id, _name);
    }

    function getStudents() public view returns (Student[]) {
        return students;
    }
}
