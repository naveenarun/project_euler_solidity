pragma solidity ^0.4.0;

contract Euler1 {
    uint public answer;
    function solve() public {
        getSumUnder(1000);
    }
    function getSumUnder(uint val) private {
        answer = 0;
        for (uint i=0; i<val; i++) {
            if (i % 3 == 0 || i % 5 == 0) {
                answer += i;
            }
        }
    }
}
