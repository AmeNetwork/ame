// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StringEscape {
    function escapeString(string memory input) public pure returns (string memory) {
        bytes memory inputBytes = bytes(input);
        bytes memory escapedBytes = new bytes(inputBytes.length * 2); // 预分配足够的空间
        uint j = 0;

        for (uint i = 0; i < inputBytes.length; i++) {
            bytes1 currentChar = inputBytes[i];

            if (currentChar == '"') {
                escapedBytes[j++] = '\\';
                escapedBytes[j++] = '"';
            } else if (currentChar == '\\') {
                escapedBytes[j++] = '\\';
                escapedBytes[j++] = '\\';
            } else {
                escapedBytes[j++] = currentChar;
            }
        }

        // 截取到实际长度
        bytes memory result = new bytes(j);
        for (uint k = 0; k < j; k++) {
            result[k] = escapedBytes[k];
        }

        return string(result);
    }
}