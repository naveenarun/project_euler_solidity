pragma solidity ^0.4.0;

contract Euler2 {
    uint public answer;
    function solve() public {
        evenFiboSum(1,2,4e6);
    }
    function evenFiboSum(uint a, uint b, uint maxVal) private {
        if (a > maxVal) {
            return;
        }
        if (a % 2 == 0) {
            answer += a;
        }
        evenFiboSum(b, a+b, maxVal);
    }
}
