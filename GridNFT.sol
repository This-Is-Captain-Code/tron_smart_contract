// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITRC721 {
    // Events required for TRC721 compliance
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // Required functions
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function tokenURI(uint256 tokenId) external view returns (string memory); // Added tokenURI function

    // Approval and transfer functions
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

contract Grid is ITRC721 {
    string public name = "Grid";
    string public symbol = "GRID";
    uint256 private _tokenIdCounter = 1;

    // Struct to hold NFT metadata
    struct Metadata {
        string downloadLink;
        string image;
        string name;  // Token name
    }

    // Mapping for token ownership and metadata
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => Metadata) public tokenMetadata;

    // Mint new NFTs (any user can mint)
    function mint(string memory downloadLink, string memory image, string memory tokenName) public {
        uint256 tokenId = _tokenIdCounter;
        _balances[msg.sender] += 1;
        _owners[tokenId] = msg.sender;

        tokenMetadata[tokenId] = Metadata({
            downloadLink: downloadLink,
            image: image,
            name: tokenName // Assign name as per input
        });

        emit Transfer(address(0), msg.sender, tokenId); // Transfer event for minting
        _tokenIdCounter += 1;
    }

    // Get token ownership details
    function balanceOf(address ownerAddr) external view override returns (uint256) {
        require(ownerAddr != address(0), "Invalid address");
        return _balances[ownerAddr];
    }

    // Get the owner of a specific token
    function ownerOf(uint256 tokenId) public view override returns (address) {
        address tokenOwner = _owners[tokenId];
        require(tokenOwner != address(0), "Token does not exist");
        return tokenOwner;
    }

    // Function to fetch token metadata URI
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        Metadata memory metadata = tokenMetadata[tokenId];

        // Return JSON metadata in string format
        return string(abi.encodePacked(
            'data:application/json;utf8,',
            '{"name":"', metadata.name, '",',
            '"description":"Download link: ', metadata.downloadLink, '",',
            '"image":"', metadata.image, '"}'
        ));
    }

    // Disable transfer functions for soulbound NFTs
    function transferFrom(address, address, uint256) external pure override {
        revert("Soulbound NFTs cannot be transferred.");
    }

    function safeTransferFrom(address, address, uint256) external pure override {
        revert("Soulbound NFTs cannot be transferred.");
    }

    function safeTransferFrom(address, address, uint256, bytes calldata) external pure override {
        revert("Soulbound NFTs cannot be transferred.");
    }

    // Disable approval functions for soulbound NFTs
    function approve(address, uint256) external pure override {
        revert("Approval not supported for soulbound NFTs.");
    }

    function setApprovalForAll(address, bool) external pure override {
        revert("Approval for all not supported for soulbound NFTs.");
    }

    function getApproved(uint256) external pure override returns (address) {
        return address(0); // No approvals
    }

    function isApprovedForAll(address, address) external pure override returns (bool) {
        return false;
    }
}
