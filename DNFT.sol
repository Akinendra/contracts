// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./token/ERC721/ERC721.sol";
import "./token/ERC721/extensions/ERC721Enumerable.sol";
import "./token/ERC721/extensions/ERC721URIStorage.sol";
import "./security/Pausable.sol";
import "./access/Ownable.sol";
import "./access/AccessControl.sol";
import "./token/ERC721/extensions/ERC721Burnable.sol";
import "./utils/Counters.sol";
import "./WhitelistVerifier.sol";

contract DNFT is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Pausable,
    Ownable,
    AccessControl,
    ERC721Burnable,
    WhitelistVerifier
{
    using Counters for Counters.Counter;
    using Strings for uint256;

    // File extension for metadata file
    string private extension;
    string private baseURI;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    Counters.Counter private _tokenIdCounter;

    struct Diamond {
        string lab;
        string certificateNumber;
        string shape;
        uint256 caratWeight;
        string color;
        string clarity;
        string cut;
        string polish;
        string symmetry;
        string fluorescence;
    }

    mapping(uint256 => Diamond) public diamonds;

    constructor()
        ERC721("Diamond NFT", "DNFT")
        WhitelistVerifier(0x7C8b65CA927BBdbaf31026eddEa7B8226988b1eb)
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
        baseURI = "https://dnxt.app/json/";
        extension = ".json";
        verificationActive = false;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /**
     * @dev Allows an admin to change the base URI.
     * @param newBaseURI The new base URI to be set.
     */

    function setBaseURI(string memory newBaseURI)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        baseURI = newBaseURI;
    }

    /**
     * @dev Allows an admin to change the extension of the URI.
     * @param _extension The new extension to be set.
     */

    function setExtension(string memory _extension)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        extension = _extension;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @dev Mints a new token and sets the diamond information.
     * @param to The address to mint the token to.
     * @param lab The lab that certified the diamond.
     * @param certificateNumber The certificate number from the lab.
     * @param shape The shape of the diamond.
     * @param caratWeight The weight of the diamond in carats.
     * @param color The color grade of the diamond.
     * @param clarity The clarity grade of the diamond.
     * @param cut The cut grade of the diamond.
     * @param polish The polish grade of the diamond.
     * @param symmetry The symmetry grade of the diamond.
     * @param fluorescence The fluorescence grade of the diamond.
     */
    function safeMintWithDiamondInfo(
        address to,
        string memory lab,
        string memory certificateNumber,
        string memory shape,
        uint256 caratWeight,
        string memory color,
        string memory clarity,
        string memory cut,
        string memory polish,
        string memory symmetry,
        string memory fluorescence
    ) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        Diamond storage diamond = diamonds[tokenId];
        diamond.lab = lab;
        diamond.certificateNumber = certificateNumber;
        diamond.shape = shape;
        diamond.caratWeight = caratWeight;
        diamond.color = color;
        diamond.clarity = clarity;
        diamond.cut = cut;
        diamond.polish = polish;
        diamond.symmetry = symmetry;
        diamond.fluorescence = fluorescence;
    }

    /**
     * @dev Sets the diamond attributes for a specific token ID.
     * Can only be called internally.
     * @param tokenId The token ID to set the attributes for.
     * @param lab The lab that certified the diamond.
     * @param certificateNumber The certificate number from the lab.
     * @param shape The shape of the diamond.
     * @param caratWeight The weight of the diamond in carats.
     * @param color The color grade of the diamond.
     * @param clarity The clarity grade of the diamond.
     * @param cut The cut grade of the diamond.
     * @param polish The polish grade of the diamond.
     * @param symmetry The symmetry grade of the diamond.
     * @param fluorescence The fluorescence grade of the diamond.
     */
    function setDiamondAttributes(
        uint256 tokenId,
        string memory lab,
        string memory certificateNumber,
        string memory shape,
        uint256 caratWeight,
        string memory color,
        string memory clarity,
        string memory cut,
        string memory polish,
        string memory symmetry,
        string memory fluorescence
    ) internal {
        Diamond storage diamond = diamonds[tokenId];
        if (bytes(diamond.lab).length == 0) {
            diamond.lab = lab;
        }
        if (bytes(diamond.certificateNumber).length == 0) {
            diamond.certificateNumber = certificateNumber;
        }
        if (bytes(diamond.shape).length == 0) {
            diamond.shape = shape;
        }
        if (diamond.caratWeight == 0) {
            diamond.caratWeight = caratWeight;
        }
        if (bytes(diamond.color).length == 0) {
            diamond.color = color;
        }
        if (bytes(diamond.clarity).length == 0) {
            diamond.clarity = clarity;
        }
        if (bytes(diamond.cut).length == 0) {
            diamond.cut = cut;
        }
        if (bytes(diamond.polish).length == 0) {
            diamond.polish = polish;
        }
        if (bytes(diamond.symmetry).length == 0) {
            diamond.symmetry = symmetry;
        }
        if (bytes(diamond.fluorescence).length == 0) {
            diamond.fluorescence = fluorescence;
        }
    }

    function safeMint(address to) public onlyRole(MINTER_ROLE) {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
    }

    /**
     * @dev Mint multiple accounts at once by passing an array of addresses.
     * @param users The array of addresses to mint to.
     */
    function batchMint(address[] memory users) public onlyRole(MINTER_ROLE) {
        uint8 i = 0;
        for (i; i < users.length; i++) {
            safeMint(users[i]);
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        verifyAccounts(from, to);
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721) {
        super._afterTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory base = _baseURI();
        string memory id = tokenId.toString();

        return
            bytes(base).length > 0
                ? string(abi.encodePacked(base, id, extension))
                : "";
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
