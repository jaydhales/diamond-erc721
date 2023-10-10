// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../../contracts/interfaces/IDiamondCut.sol";
import "../../contracts/facets/DiamondCutFacet.sol";
import "../../contracts/facets/DiamondLoupeFacet.sol";
import "../../contracts/facets/OwnershipFacet.sol";
import "../../contracts/Diamond.sol";
import "../../contracts/facets/MarketPlaceFacet.sol";
import "../../contracts/facets/NftFacet.sol";

import "./DiamondUtils.sol";

contract DiamondDeployer is DiamondUtils, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    NFTMarketPlace market;
    NFTRC nft;
    NFTRC nftC;
    NFTMarketPlace marketF;

    function setUp() public {
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet), "JAyNFT", "JNFT");
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        market = new NFTMarketPlace();
        nft = new NFTRC();
        nftC = NFTRC(address(diamond));
        marketF = NFTMarketPlace(address(diamond));

        //upgrade diamond with facets

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](4);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            FacetCut({
                facetAddress: address(market),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("NFTMarketPlace")
            })
        );

        cut[3] = (
            FacetCut({
                facetAddress: address(nft),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("NFTRC")
            })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();
    }

    function diamondCut(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external override {}
}
