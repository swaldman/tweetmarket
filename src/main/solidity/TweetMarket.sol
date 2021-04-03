pragma solidity ^0.8.1;

// SPDX-License-Identifier: GPL-3.0-only

// importing latest version, rather than a commit-specific version, while I'm developing in parallel.
// a particular commit should be set once this get concretized.
import "https://github.com/swaldman/open-first-price-auction/blob/main/src/main/solidity/OpenFirstPriceAuctioneerUInt256.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/74e03de7604ca99c2f8e476476a6dc362779c356/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract TweetMarket is ERC721Enumerable, OpenFirstPriceAuctioneerUInt256 {

  address public owner;
  
  string public twitterUser;

  string private _name;
  string private _symbol;

  // we divide initializtaion into a default no-arg constructor and an init(...) funtion for easy proxying.
  constructor() ERC721("SHADOWED","SHADOWED") {}

  function init(string memory _twitterUser) public {
    require( owner != address(0), "Once init() has been called, it is initialized and owned and cannot be called again." );
    
    require(bytes(_twitterUser)[0] != 0x40, "Don't prepend @ to Twitter username." );
    
    _name   = concat("Tweets-@", twitterUser);
    _symbol = concat("TWT-@", twitterUser );
    
    owner       =  msg.sender;
    twitterUser = _twitterUser;
  }
  
  // override name and symbol since we require them to be set in init() rather than in a constructor
  
  function name() public view virtual override returns (string memory) {
    return _name;
  }
  
  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  // override OpenFirstPriceAuctioneerUInt256  abstracts

  function keyOwner( uint256 _key ) internal override view returns(address) {
    return ownerOf( _key );
  }

  // nothing to do, since we have in-auction status of keys in parent class
  function handleAuctionStarted( OpenFirstPriceAuction, address, uint256 ) internal override {}   

  // Transfer ownership here!!!
  function handleAuctionCompleted( OpenFirstPriceAuction auction, address seller, address winner, uint256 key, uint256 /*winningBid*/ ) internal override {
    _safeTransfer( seller, winner, key, abi.encodePacked(address(auction)) );
  }

  // nothing to do
  function handleAuctionAborted( OpenFirstPriceAuction, address, uint256 ) internal override {}


  modifier onlyOwner {
    require( msg.sender == owner, "Function can only be called by owner." );
    _;
  }

  function claim( uint256 _status ) public onlyOwner {
    _mint( owner, _status );
  }

  function safeClaim( uint256 _status, bytes memory _data ) public onlyOwner {
    _safeMint( owner, _status, _data );
  }

  function safeClaim( uint256 _status ) public onlyOwner {
    _safeMint( owner, _status );
  }

  function updateTwitterUserName( string memory _twitterUser ) public onlyOwner {
    require(bytes(_twitterUser)[0] != 0x40, "Don't prepend @ to Twitter username." );
    twitterUser = _twitterUser;
  }

  function _baseURI() internal view override returns (string memory) {
    return concat(concat("https://twitter.com/", twitterUser), "status/");
  }

  // see https://eattheblocks.com/how-to-manipulate-strings-in-solidity/
  function concat( string memory a, string memory b ) internal pure returns(string memory) {
    return string(abi.encodePacked(a, b));
  }

  // prevent transfers of tokens mid-auction
  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
    super._beforeTokenTransfer(from, to, tokenId);
    
    require(address(keyToAuction[tokenId]) == address(0), "No transfers are permitted while a token is in an auction.");
  }
}

