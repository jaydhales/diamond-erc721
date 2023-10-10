// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {LibDiamond, Order} from "../libraries/LibDiamond.sol";
import "./NftFacet.sol";

contract NFTMarketPlace {
    event OrderListed(address indexed _owner, uint256 indexed _orderID, uint256 indexed price);
    event OrderExecuted(uint256 indexed _orderID, uint256 indexed price, address indexed _buyer);

    error Invalid_Signature();
    error Invalid_Order_Id();
    error Order_Expired();
    error Order_Not_Active();
    error Incorrect_Ether_Value();

    function ds() internal pure returns (LibDiamond.DiamondStorage storage) {
        return LibDiamond.diamondStorage();
    }

    function createOrder(uint256 tokenID, uint256 price, uint256 deadline) external {
        require(price > 0, "Price can not be zero");
        require(deadline > 3600, "Deadline too short");

        require(NFTRC(address(this)).ownerOf(tokenID) == msg.sender, "You do not own this nft");
        require(
            NFTRC(address(this)).isApprovedForAll(msg.sender, address(this)),
            "Permission not granted to spent this token"
        );

        ds().orders[ds().orderCount] = Order(msg.sender, tokenID, price, block.timestamp + deadline, true);
        ds().orderCount++;

        emit OrderListed(msg.sender, ds().orderCount, price);
    }

    function executeOrder(uint256 _orderId) external payable {
        if (_orderId >= ds().orderCount) revert Invalid_Order_Id();

        Order storage _order = ds().orders[_orderId];

        if (_order.deadline < block.timestamp) revert Order_Expired();
        if (!_order.isActive) revert Order_Not_Active();
        if (_order.price != msg.value) revert Incorrect_Ether_Value();

        _order.isActive = false;
        NFTRC(address(this)).safeTransferFrom(_order.creator, msg.sender, _order.tokenID);
        payable(_order.creator).transfer(msg.value);

        emit OrderExecuted(_orderId, _order.price, msg.sender);
    }

    function getOrder(uint256 _orderID) external view returns (Order memory _order) {
        _order = ds().orders[_orderID];
    }
}
