pragma solidity ^0.8.1;

// SPDX-License-Identifier: GPL-3.0-only

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/74e03de7604ca99c2f8e476476a6dc362779c356/contracts/token/ERC721/ERC721.sol";

contract TweetMarket is ERC721 {

  address public owner;
  
  string public twitterUser;
  
  constructor(string memory _twitterUser) ERC721(concat("Tweets-@", twitterUser), concat("TWT-@", twitterUser)) {
    require(bytes(_twitterUser)[0] != 0x40, "Don't prepend @ to Twitter username." );

    owner       =  msg.sender;
    twitterUser = _twitterUser;
  }

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

  function _baseURI() internal view override returns (string memory) {
    return concat(concat("https://twitter.com/", twitterUser), "status/");
  }

  // see https://eattheblocks.com/how-to-manipulate-strings-in-solidity/
  function concat( string memory a, string memory b ) internal pure returns(string memory) {
    return string(abi.encodePacked(a, b));
  }
}

