// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.4;
//import "./ABDKMath64x64.sol";
//import "./Strings.sol";
//import "./Integers.sol";
import "./PRBMathSD59x18.sol";

library VectorUtils {
    using PRBMathSD59x18 for int256;
    function normalize(int256[] memory a) internal pure returns (int256[] memory) {
        int256 total = 0e18;
        int256[] memory newVec = new int256[](a.length);
        for (uint i=0; i<a.length; i++) {
            // Square sum
            total += a[i].mul(a[i]);
        }
        for (uint i=0; i<a.length; i++) {
            // Input normalized values
            newVec[i] = a[i].div(total.sqrt());
        }
        return newVec;
    }
    function dot(int256[] memory a, int256[] memory b) internal pure returns (int256) {
        int256 total = 0e18;
        for (uint i=0; i<a.length; i++) {
            total += a[i]*b[i];
        }
        return total;
    }
    function add(int256[] memory a, int256[] memory b) internal pure returns (int256[] memory) {
        int256[] memory result = new int256[](a.length);
        for (uint i=0; i<a.length; i++) {
            result[i] = a[i] + b[i];
        }
        return result;
    }
    function mul(int256[] memory a, int256 b) internal pure returns (int256[] memory) {
        int256[] memory result = new int256[](a.length);
        for (uint i=0; i<a.length; i++) {
            result[i] = a[i].mul(b);
        }
        return result;
    }
    function projection(int256[] memory a, int256[] memory u) internal pure returns (int256[] memory) {
        // Projects first vector onto second vector
        int256 coeff = dot(u,a).div(dot(u,u));
        int256[] memory result = mul(u, coeff);
        return result;
    }
}

library MatrixUtils {
    using PRBMathSD59x18 for int256;
    function dot(int256[][] memory a, int256[][] memory b) internal pure returns (int256[][] memory) {
        uint l1 = a.length;
        uint l2 = b[0].length;
        uint zipsize = b.length;
        int256[][] memory c = new int256[][](l1);
        for (uint fi=0; fi<l1; fi++) {
            c[fi] = new int256[](l2);
            for (uint fj=0; fj<l2; fj++) {
                int256 entry = 0e18;
                for (uint i=0; i<zipsize; i++) {
                    entry += a[fi][i].mul(b[i][fj]);
                }
                c[fi][fj] = entry;
            }
        }
        return c;
    } 
    function T(int256[][] memory a) internal pure returns (int256[][] memory) {
        int256[][] memory transpose = new int256[][](a[0].length);
        for (uint j=0; j<a[0].length; j++) {
            transpose[j] = new int256[](a.length);
            for (uint i=0; i<a.length; i++) {
                transpose[j][i] = a[i][j];
            }
        }
        return transpose;
    }
}
contract QR {
    using PRBMathSD59x18 for int256;
    using VectorUtils for int256[];
    using MatrixUtils for int256[][];
    //using Strings for string;
    //using Integers for uint;
    function testTranspose() public pure returns (int256[][] memory) {
        int256[][] memory a = new int256[][](3);
        a[0] = new int256[](3);
        a[1] = new int256[](3);
        a[2] = new int256[](3);
        a[0][0] = 12e18;
        a[1][0] = 6e18;
        a[2][0] = -4e18;
        a[0][1] = -51e18;
        a[1][1] = 167e18;
        a[2][1] = 24e18;
        a[0][2] = 4e18;
        a[1][2] = -68e18;
        a[2][2] = -41e18;
        return a.T();
    }

    function eigensolve() public pure returns (int256[][] memory) {
        int256[][] memory a = new int256[][](3);
        int256[][] memory q;
        int256[][] memory r;
        a[0] = new int256[](3);
        a[1] = new int256[](3);
        a[2] = new int256[](3);
        a[0][0] = 12e18;
        a[1][0] = 6e18;
        a[2][0] = -4e18;
        a[0][1] = -51e18;
        a[1][1] = 167e18;
        a[2][1] = 24e18;
        a[0][2] = 4e18;
        a[1][2] = -68e18;
        a[2][2] = -41e18;
        (q,r) = QRDecomposition(a);
        return q;
    }

    function QRDecomposition(int256[][] memory a) public pure returns (int256[][] memory, int256[][] memory) {
        // int256[][] memory a = new int256[][](3);
        // a[0] = new int256[](3);
        // a[1] = new int256[](3);
        // a[2] = new int256[](3);
        // a[0][0] = 12e18;
        // a[1][0] = 6e18;
        // a[2][0] = -4e18;
        // a[0][1] = -51e18;
        // a[1][1] = 167e18;
        // a[2][1] = 24e18;
        // a[0][2] = 4e18;
        // a[1][2] = -68e18;
        // a[2][2] = -41e18;

        // Initialize result matrix
        int256[][] memory q = new int256[][](a.length);
        for (uint i=0; i<a.length; i++) {
            q[i] = new int256[](a[0].length);
        }

        // Initialize U matrix
        int256[][] memory u_columns = new int256[][](a[0].length);

        // Populate U matrix
        for (uint i=0; i<a[0].length; i++) {
            // Grab the i'th column from a and store into a_column
            int256[] memory a_column = new int256[](a.length);
            int256[] memory u_column = new int256[](a.length);
            int256[] memory e_column = new int256[](a.length);
            for (uint j=0; j<a.length; j++) {
                a_column[j] = a[j][i];
            }
            // Calculate the i'th U column
            u_column = a_column; // Assume solidity copies arrays upon assignment (not necessarily true)
            for (uint j=0; j<i; j++) {
                u_column = u_column.add(a_column.projection(u_columns[j]).mul(-1e18));
            }
            u_columns[i] = u_column;

            // Calculate the i'th E column
            e_column = u_column.normalize();

            // Load the E column into Q
            for (uint j=0; j<a.length; j++) {
                q[j][i] = e_column[j];
            }
        }
        int256[][] memory r = q.T().dot(a);

        return (q,r);
    }
}