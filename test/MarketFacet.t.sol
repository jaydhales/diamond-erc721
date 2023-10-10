// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./helpers/DiamondDeployer.sol";

contract MarketPlaceTest is DiamondDeployer {
    event OrderListed(address indexed _owner, uint256 indexed _orderID, uint256 indexed price);
    event OrderExecuted(uint256 indexed _orderID, uint256 indexed price, address indexed _buyer);

    //  function testTokenAddrNotZero() public {
    //      vm.expectRevert("Address can not be zero");
    //      marketF.createOrder(address(0), 256, 1 ether, 0);
    //  }

    function testPriceNotZero() public {
        vm.expectRevert("Price can not be zero");
        marketF.createOrder(256, 0, 0);
    }

    function testShortDeadline() public {
        vm.expectRevert("Deadline too short");
        marketF.createOrder(256, 2 ether, 500);
    }

    function testInvalidTokenID() public {
        vm.expectRevert();
        marketF.createOrder(246, 1 ether, 3700);
    }

    function testNotOwner() public {
        nftC.mint(creator);
        switchSigner(spender);
        vm.expectRevert("You do not own this nft");
        marketF.createOrder(0, 1 ether, 3700);
    }

    function testNoApproval() public {
        nftC.mint(creator);
        switchSigner(creator);
        vm.expectRevert("Permission not granted to spent this token");
        marketF.createOrder(0, 1 ether, 3700);
    }

    function testCreateOrder() public {
        nftC.mint(creator);
        switchSigner(creator);
        nftC.setApprovalForAll(address(diamond), true);
        marketF.createOrder(0, 1 ether, 5000);
        Order memory o = marketF.getOrder(0);
        assertEq(o.tokenID, 0);
        assertEq(o.price, 1 ether);
        assertEq(o.deadline, block.timestamp + 5000);
        assertEq(o.creator, creator);
    }

    function testOrderExpired() public {
        _preOrder();
        vm.warp(6000);
        vm.expectRevert(NFTMarketPlace.Order_Expired.selector);
        marketF.executeOrder(0);
    }

    function testIncorrectEther() public {
        _preOrder();
        vm.expectRevert(NFTMarketPlace.Incorrect_Ether_Value.selector);
        marketF.executeOrder{value: 2 ether}(0);
    }

    function testExecuteOrder() public {
        _preOrder();
        switchSigner(spender);
        uint256 balanceBefore = spender.balance;
        marketF.executeOrder{value: 1 ether}(0);

        assertEq(nftC.ownerOf(0), spender);
        assertEq(spender.balance, balanceBefore - 1 ether);
    }

    function testEmitExecuteEvent() public {
        nftC.mint(creator);
        switchSigner(creator);
        nftC.setApprovalForAll(spender, true);
        marketF.createOrder(0, 1 ether, 5000);
        switchSigner(spender);
        //   vm.expectEmit(true, true, true, false);
        //   emit OrderExecuted(0, 1 ether, creator);
        marketF.executeOrder{value: 1 ether}(0);
    }

    function testEmitOrderEvent() public {
        nftC.mint(creator);
        switchSigner(creator);
        nftC.setApprovalForAll(address(diamond), true);
        vm.expectEmit(true, true, true, false);
        emit OrderListed(creator, 1, 1 ether);
        marketF.createOrder(0, 1 ether, 5000);
    }

    function _preOrder() internal {
        nftC.mint(creator);
        switchSigner(creator);
        nftC.setApprovalForAll(address(diamond), true);
        marketF.createOrder(0, 1 ether, 5000);
        vm.stopPrank();
    }
}
