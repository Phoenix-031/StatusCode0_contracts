// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NFTManager {
    struct NFT {
        address nftAddress;
        uint256 nftValue;
        string nftUrl;
        uint256 tokenUid;
        address owner; // Added owner field
    }

    mapping(address => NFT[]) private nftsByAddress;

    function nftAdd(
        address _walletAddress,
        address _nftAddress,
        uint256 _nftValue,
        string memory _nftUrl,
        uint256 _tokenUid
    ) external {
        NFT memory newNFT = NFT({
            nftAddress: _nftAddress,
            nftValue: _nftValue,
            nftUrl: _nftUrl,
            tokenUid: _tokenUid,
            owner: _walletAddress // Set owner to the wallet address
        });

        nftsByAddress[_walletAddress].push(newNFT);
    }

    function nftTransfer(
        address _from,
        address _to,
        address _nftAddress,
        uint256 _tokenUid
    ) external {
        NFT[] storage nftsFrom = nftsByAddress[_from];

        for (uint256 i = 0; i < nftsFrom.length; i++) {
            if (
                nftsFrom[i].nftAddress == _nftAddress &&
                nftsFrom[i].tokenUid == _tokenUid
            ) {
                // Store the current owner's address before transferring
                address previousOwner = nftsFrom[i].owner;

                // Update the owner to the new address
                nftsFrom[i].owner = _to;

                // Push the NFT to the receiving address's collection
                nftsByAddress[_to].push(nftsFrom[i]);

                // Remove the NFT from the sender's collection
                if (i < nftsFrom.length - 1) {
                    nftsFrom[i] = nftsFrom[nftsFrom.length - 1];
                }
                nftsFrom.pop();

                // Emit an event to indicate the transfer
                emit NFTTransferred(_from, _to, _nftAddress, _tokenUid, previousOwner);

                return;
            }
        }

        revert("NFT not found");
    }

    function getAll(address _walletAddress) external view returns (NFT[] memory) {
        return nftsByAddress[_walletAddress];
    }

    function checkNft(
        address _walletAddress,
        address _nftAddress,
        uint256 _tokenUid
    ) external view returns (bool, uint256) {
        NFT[] storage nfts = nftsByAddress[_walletAddress];

        for (uint256 i = 0; i < nfts.length; i++) {
            if (
                nfts[i].nftAddress == _nftAddress &&
                nfts[i].tokenUid == _tokenUid
            ) {
                return (true, nfts[i].nftValue);
            }
        }

        return (false, 0);
    }

    event NFTTransferred(
        address indexed from,
        address indexed to,
        address nftAddress,
        uint256 tokenUid,
        address previousOwner
    );
}
