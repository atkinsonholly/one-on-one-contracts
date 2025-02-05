// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

/// @notice Demo ERC721-agent implementation.
/// @author OneOnOne - Agentic Hackathon 2025.

import { ERC721 } from "solady/contracts/tokens/ERC721.sol";
import { Ownable } from "solady/contracts/auth/Ownable.sol";
import { LibString } from "solady/contracts/utils/LibString.sol";

/// @dev Absolutely not production-ready code here.
contract OneOnOne is ERC721, Ownable {

    /// @dev The recipient's balance must be zero.
    error AccountBalanceNotZero();

    uint256 tokenId;

    /// @dev Mint a token with `tokenId` to address `to`.
    /// @dev Requires ETH value greater than or equal to 0.001 ETH.
    /// @dev Requires that `to` does not already own a OneOnOne NFT.
    /// @dev Requires token id to be minted is within the limit.
    function mintWithETH(
        address to
    ) external {
        assembly {
            mstore(0x00, to)
            let toBalanceSlot := keccak256(0x0c, 0x1c)
            let toBalanceSlotPacked := sload(toBalanceSlot)
            // Revert if `balanceOf(to)` is greater than 0
            if gt(toBalanceSlotPacked, 0) {
                mstore(0x00, 0x00cc9b6f) // `AccountBalanceNotZero()`.
                revert(0x1c, 0x04)
            }
        }
        assembly {
            // TODO: revert if tokenId to be minted > [10]
        }
        assembly {
            // TODO: revert if ETH value is not enough
        }
        _mint(to, tokenId +=1); // TODO: check counter is safe
    }

    /// @dev Returns the token collection name.
    function name() public pure override returns (string memory) {
        return unicode"OneOnOne 💬";
    }

    /// @dev Returns the token collection symbol.
    function symbol() public pure override returns (string memory) {
        return "1o1";
    }

    // TODO: update CID
    /// @dev Returns the Uniform Resource Identifier (URI) for token `id`.
    function tokenURI(uint256 id) public pure override returns (string memory) {
        return string.concat("ipfs://<CID>/", LibString.toString(id));
    }
}
