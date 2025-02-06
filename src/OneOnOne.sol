// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

/// @notice Demo ERC721-agent implementation.
/// @author OneOnOne - Agentic Hackathon 2025.

import { ERC721 } from "solady/contracts/tokens/ERC721.sol";
import { Ownable } from "solady/contracts/auth/Ownable.sol";
import { LibString } from "solady/contracts/utils/LibString.sol";
import { ReentrancyGuard } from "solady/contracts/utils/ReentrancyGuard.sol";

/// @notice ERC721 contract with AI-infused metadata.
/// @dev Absolutely not production-ready code here.
contract OneOnOne is ERC721, Ownable, ReentrancyGuard  {

    /// @dev The recipient's balance must be zero.
    error AccountBalanceNotZero();

    /// @dev The minting limit must not be exceeded.
    error ExceedsMintingLimit();

    /// @dev The minting price must be paid.
    error NotEnoughETH();

    uint256 public counter;

    /// @dev Minting limit for demo.
    uint256 private constant _MAX_MINT = 10;

    /// @dev Minting price for demo 0.001 ETH.
    uint256 private constant _PRICE = 1000000000000000;

    /// @dev Taken directly from ERC721 and included here for readability.
    uint256 private constant _ERC721_MASTER_SLOT_SEED = 0x7d8825530a5a2e7a << 192;

    /// @dev Mint a token with `tokenId` to address `to`.
    /// @dev Requires ETH value greater than or equal to 0.001 ETH.
    /// @dev Requires that `to` does not already own a OneOnOne NFT.
    /// @dev Limited to a small number of NFTs for demo.
    function mintWithETH(
        address to
    ) external payable nonReentrant {
        assembly {
            // Read balance of `to`.
            // Refer to ERC721 bits layout.
            mstore(0x1c, _ERC721_MASTER_SLOT_SEED)
            mstore(0x00, to)
            let toBalanceSlot := keccak256(0x0c, 0x1c)
            let toBalanceSlotPacked := sload(toBalanceSlot)

            // Revert if `balanceOf(to)` is greater than 0.
            if gt(toBalanceSlotPacked, 0) {
                mstore(0x00, 0x00cc9b6f) // `AccountBalanceNotZero()`.
                revert(0x1c, 0x04)
            }
        }
        assembly {
            // Read `counter`.
            let counterSlot := sload(counter.slot)

            // Token `id` to be minted = `counter` + 1.
            // Revert if `id` > minting limit.
            if gt(add(counterSlot, 1), _MAX_MINT) {
                mstore(0x00, 0x383196b7) // `ExceedsMintingLimit()`.
                revert(0x1c, 0x04)
            }
        }
        assembly {
            // Read msg.value.
            // Revert if ETH value < price.
            if lt(callvalue(), _PRICE) {
                mstore(0x00, 0x583aa026) // `NotEnoughETH`.
                revert(0x1c, 0x04)
            }
        }
        _mint(to, counter +=1);
    }

    function retrieveETH(address payable beneficiary) onlyOwner nonReentrant external {
        beneficiary.transfer(address(this).balance);
    }

    /// @dev Burn token `id`.
    function burn(uint256 id) public {
        _burn(msg.sender, id);
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

    /// @dev Returns whether token `id` exists.
    function exists(uint256 id) public view returns (bool) {
        return _exists(id);
    }

}
