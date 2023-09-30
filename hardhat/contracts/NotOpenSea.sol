//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
/*
FILE LAYOUT
License statement 
Pragma statements
Import Statements 
Interfaces
libraries
Contracts
*/
contract NotOpenSea is ERC721URIStorage {
 
/* 
CONTRACT LAYOUT
Type declarations
State variables
Errors
Events
Modifiers
Functions

*/
    struct NFTData {
        uint256 tokenID;
        uint256 price;
        address payable seller;
        address payable owner;
        bool isListed;
    }

    address payable mpOwner;

// Fixed listing royalty of 0.005 eth
    uint256 private mpRoyalty = 0.005 ether;

// we are only allowing NFTs above the floor of 0.05 eth during initial listing
    uint256 private constant MIN_INITIAL_LIST_PRICE = 0.05 ether;   

// total tokenIds minted    
    uint256 public tokenIds; 


    mapping(uint256 => NFTData) private idToNFTData;

    error OnlyOwnerAllowed();
    error MpRoyaltyNotPaid();
    error InitPriceLessThanReqd();
    error NotEligibleHandler();
    error NftNotListed();
    error NftPriceNotMet();
    error WithdrawalFailed();
    

    event NewMint (uint256 indexed tokenId, address seller, uint256 price);
    event NftTransfer (uint256 indexed tokenId, address from, address to);
    event RoyaltyChanged(uint256 oldRoyalty, uint256 newRoyalty);
/* 
FUNCTIONS LAYOUT
modifiers()
constructor()
receive()/ fallback()
external
public
internal
private
view / getter functions
*/  

    modifier OnlyOwner() {
     if(msg.sender != mpOwner) 
        revert OnlyOwnerAllowed();
   
    _;
    } 


    constructor() ERC721("NotOpensea", "NOS") {

        mpOwner = payable (msg.sender);
    }

    receive() external payable {}
    fallback() external payable {}
 

/* OWNER CONTROLLED FUNCTIONS */

    //withdraw the marketplace balance to any address they you want - callable only by the owner
    function withdraw (address payable payee) external OnlyOwner  {
            uint256 balance = address(this).balance;
            (bool transferTx, ) = payee.call{value: balance}("");
            if (!transferTx) {
            revert WithdrawalFailed();
        }
    }

    // A feature to update the royalties - callable only by the owner
    function updateRoyalty (uint256 _newRoyalty) external OnlyOwner {
        emit RoyaltyChanged(mpRoyalty, _newRoyalty);
        mpRoyalty = _newRoyalty;
        
    }


/* EXTERNAL FUNCTIONS */
    // function to unlist / relist and change price of an NFT 
    function changeListingStatusAndPrice (uint256 _tokenId, bool _isListed, uint256 _price) external {

        if(msg.sender != idToNFTData[_tokenId].seller ||  msg.sender != idToNFTData[_tokenId].owner) {
            revert NotEligibleHandler();
        }

        idToNFTData[_tokenId].price = _price;

        idToNFTData[_tokenId].isListed = _isListed;
    }

/* PUBLIC FUNCTIONS to list and sell NFTs */ 

    // The seller has to pay 0.005 ether to the marketPlace for minting & listing an newNFT 
    function listNewNFT(string memory _tokenURI, uint256 _initialPrice) public payable returns(uint256 newTokenId) {

        //custom errors saves gas
        if(msg.value < mpRoyalty) {
           revert MpRoyaltyNotPaid();
        }

        if(_initialPrice < MIN_INITIAL_LIST_PRICE) {
           revert InitPriceLessThanReqd();
        }
        //keep track of the number of  NFTs minted
        tokenIds = tokenIds + 1;
        // caching to local variable to save gas on further operation
        newTokenId = tokenIds;

        //Mint the NFT 
        _safeMint(msg.sender, newTokenId);

        emit NewMint (newTokenId, msg.sender, _initialPrice);

        //Set the tokenId to the tokenURI 
        // (IPFS URL with the NFT metadata)
        _setTokenURI(newTokenId, _tokenURI);


        idToNFTData[newTokenId] = NFTData (
            newTokenId,
            _initialPrice,
            payable (msg.sender),
            payable (address(this)),
            true
        );

        // transfer the minted NFT to the MP address
        _transfer(msg.sender, address(this), newTokenId);

        // emit an Event
        emit NftTransfer(newTokenId, msg.sender, address(this));
    }

    // Every time an NFT is sold, the marketplace charges a fixed 0.005 eth royalty
    function sellNft(uint256 _tokenId) public payable {

        if(!idToNFTData[_tokenId].isListed) {
            revert NftNotListed();
        }

        if(msg.value < idToNFTData[_tokenId].price) {
            revert NftPriceNotMet();
        }

        idToNFTData[_tokenId].seller = payable(msg.sender);

        _transfer(address(this), msg.sender, _tokenId);

        // approving the marketplace to sell this NFT for future listing
        approve(address(this), _tokenId);

        (bool isRoyaltySent, ) = payable(address(this)).call{value : mpRoyalty}("");
        require(isRoyaltySent, "Royalty Tx failed");


        address payable seller = idToNFTData[_tokenId].seller;
        (bool isSellerPaid, ) = seller.call{value : msg.value - mpRoyalty}("");
        require(isSellerPaid, "Eth Tx to Seller failed");

    }   

/* GETTER FUNCTIONS */

    function getRoyalty() external view returns (uint256) {
        return mpRoyalty;

    }

    function getLatestTokenId() external view returns (uint256) {
        return tokenIds;
    }

    function getNFTDataForId(uint256 tokenId) external view returns (NFTData memory) {
        return idToNFTData[tokenId];
    }


/* FRONT END SUPPORTING FUNCTIONS */
    //Returns all NFTs available in the marketplace to be displayed

    function showAllNFTs() public view returns (NFTData[] memory) {

        uint256 totalNfts = tokenIds;
        NFTData[] memory tokens = new NFTData[](totalNfts); 
        uint256 currentIndex = 0;

        for(uint256 i=1; i <= totalNfts;i++)
        {   

            NFTData storage currentItem = idToNFTData[i];
            tokens[currentIndex] = currentItem;
            currentIndex += 1;

        }
        //the array 'tokens' has the list of all listed NFTs in the marketplace
        return tokens;
    }


    //Returns all the NFTs that the current user is owner or seller 
    function showCurrentUserNFTs() public view returns (NFTData[] memory) {
        uint256 totalNfts = tokenIds;
        uint256 itemsOwnedCount = 0;
        uint256 currentIndex = 0;

        //getting the count of the NFTs owned by the user
        for(uint i=1; i <= totalNfts; i++)
        {
            if(msg.sender == idToNFTData[i].owner || msg.sender == idToNFTData[i].seller ) {
                itemsOwnedCount = itemsOwnedCount + 1;
            }
        }

        // creating an array to store the data of all NFTs Owned by the user / owner
        NFTData[] memory nftsOwned = new NFTData[](itemsOwnedCount);
        for(uint i=1; i <= totalNfts; i++) {
            if(idToNFTData[i].owner == msg.sender || idToNFTData[i].seller == msg.sender) {

                NFTData storage currentItem = idToNFTData[i];
                nftsOwned[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return nftsOwned;
    }

}

