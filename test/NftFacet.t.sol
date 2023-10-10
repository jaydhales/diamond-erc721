// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./helpers/DiamondDeployer.sol";

contract NFTTest is DiamondDeployer {
    function testTokenName() public {
        assertEq(nftC.name(), "JAyNFT");
    }

    function testTokenSymbol() public {
        assertEq(nftC.symbol(), "JNFT");
    }

    function testMinting() public {
        nftC.mint(msg.sender);
        assertEq(nftC.ownerOf(0), msg.sender);
        // assertEq(nftInt.tokenURI(0), "https://brknarsy.github.io/erc721-foundry/jsons/1.json");
    }

    function testBalances() public {
        testMinting();
        testMinting();
        assertEq(nftC.balanceOf(msg.sender), 2);
    }

    function testInvalidAddress() public {
        testMinting();
        vm.expectRevert("ERC721: address zero is not a valid owner");
        nftC.balanceOf((address(0)));
    }

    function testOwner() public {
        testMinting();
        assertEq(nftC.ownerOf(0), msg.sender);
    }

    function testApproval() public {
        address user1 = vm.addr(1232);
        testMinting();
        vm.prank(msg.sender);
        nftC.approve(user1, 0);
        assertEq(nftC.getApproved(0), user1);
    }

    function testAllAproval() public {
        address user1 = vm.addr(1232);
        testMinting();
        testMinting();
        vm.prank(msg.sender);
        nftC.setApprovalForAll(user1, true);

        assertTrue(nftC.isApprovedForAll(msg.sender, user1));
    }

    function testTransferFrom() public {
        address user1 = vm.addr(1232);
        testMinting();
        vm.prank(msg.sender);
        nftC.setApprovalForAll(user1, true);
        vm.prank(user1);
        nftC.transferFrom(msg.sender, address(this), 0);
        assertEq(nftC.ownerOf(0), address(this));
    }

    function testSafeTransferFrom() public {
        address user1 = vm.addr(1232);
        testMinting();
        vm.prank(msg.sender);
        nftC.setApprovalForAll(user1, true);
        vm.prank(user1);
        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");
        nftC.safeTransferFrom(msg.sender, address(this), 0);
    }
}
