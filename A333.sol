// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract A333 is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string public baseURI;            // base URI for token metadata (e.g. ipfs://<CID>/)
    string public provenance;         // optional provenance hash
    uint256 public maxSupply = 333;   // default supply
    uint256 public price = 0.02 ether;
    bool public saleActive = false;
    address public treasury;

    constructor(string memory _initBaseURI, address _treasury) ERC721("A333 Special", "A333") {
        baseURI = _initBaseURI;
        treasury = _treasury == address(0) ? msg.sender : _treasury;
    }

    // ---------- Mint ----------
    function mint(uint256 quantity) external payable {
        require(saleActive, "Sale is not active");
        require(quantity > 0 && quantity <= 20, "Invalid quantity (1-20)");
        require(totalSupply() + quantity <= maxSupply, "Exceeds max supply");
        require(msg.value >= price * quantity, "Insufficient ETH sent");

        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = totalSupply() + 1;
            _safeMint(msg.sender, tokenId);
        }
    }

    // Owner can airdrop / reserve
    function reserveMint(address to, uint256 quantity) external onlyOwner {
        require(totalSupply() + quantity <= maxSupply, "Exceeds max supply");
        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = totalSupply() + 1;
            _safeMint(to, tokenId);
        }
    }

    // ---------- Admin ----------
    function setBaseURI(string calldata _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function flipSaleActive() external onlyOwner {
        saleActive = !saleActive;
    }

    function setPrice(uint256 _newPrice) external onlyOwner {
        price = _newPrice;
    }

    function setMaxSupply(uint256 _newMax) external onlyOwner {
        require(_newMax >= totalSupply(), "New max < minted");
        maxSupply = _newMax;
    }

    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
    }

    function setProvenance(string calldata _prov) external onlyOwner {
        provenance = _prov;
    }

    function withdraw() external onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "No funds");
        (bool sent, ) = treasury.call{value: bal}("");
        require(sent, "Withdraw failed");
    }

    // ---------- Metadata override ----------
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    // tokenURI will be baseURI + tokenId
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Nonexistent token");
        string memory base = _baseURI();
        return bytes(base).length > 0 ? string(abi.encodePacked(base, tokenId.toString(), ".json")) : "";
    }
}
