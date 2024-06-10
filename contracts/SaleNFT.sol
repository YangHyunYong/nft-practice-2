// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MintNFT.sol";

contract SaleNft {
    MintNft mintNftContract;

    mapping(uint => uint) tokenPrice;
    uint[] onSaleTokens;

    constructor(address _mintNftAddress) {
        mintNftContract = MintNft(_mintNftAddress);
    }

    function setForSaleNft(uint _tokenId, uint _price) public {
        require(msg.sender == mintNftContract.ownerOf(_tokenId), "Caller is not token owner.");
        require(_price > 0, "Price is zero.");

        //setApprovalForAll - saleNftContract에 대한 지갑별 권한설정
        //msg.sender의 address(this)-입력주소(saleNftContract)에 대한 권한 승인 여부 확인(지갑 or 컨트랙트 둘다 가능)
        require(mintNftContract.isApprovedForAll(msg.sender, address(this)), "Token owner did not approve token.");
        require(tokenPrice[_tokenId] == 0, "This token is already on sale.");

        tokenPrice[_tokenId] = _price;
        onSaleTokens.push(_tokenId); 
    }

    function purchaseNft(uint _tokenId) public payable {
        require(msg.sender != mintNftContract.ownerOf(_tokenId), "Caller is token owner.");
        require(msg.value >= tokenPrice[_tokenId], "Caller sent lower than price.");
        require(tokenPrice[_tokenId] != 0, "Token is not sale.");

        payable(mintNftContract.ownerOf(_tokenId)).transfer(msg.value);
        mintNftContract.transferFrom(mintNftContract.ownerOf(_tokenId), msg.sender, _tokenId);

        tokenPrice[_tokenId] = 0;

        for(uint i = 0; i < onSaleTokens.length; i++) {
            if(onSaleTokens[i] == _tokenId) {
                onSaleTokens[i] = onSaleTokens[onSaleTokens.length - 1];
                onSaleTokens.pop();
            }
        }
    }

    function getOnSaleTokens() public view returns (uint[] memory) {
        return onSaleTokens;
    }

    function getTokenPrice(uint _tokenId) public view returns (uint) {
        return tokenPrice[_tokenId];
    } 
}