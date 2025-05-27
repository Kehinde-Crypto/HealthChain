// SPDX-Lisence-Identifier:MIT
pragma solidity ^
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SupplyChain.sol";

contract SupplyChainTest is Test {
    SupplyChain supplyChain;
    address owner = address(0x1);
    address user = address(0x2);

    function setUp() public {
        vm.prank(owner);
        supplyChain = new SupplyChain();
    }

    function testOwnerIsSetCorrectly() public {
        assertEq(supplyChain.owner(), owner);
    }

    function testAddProduct() public {
        vm.prank(owner);
        uint256 productId = supplyChain.addProduct("Medicine", "Batch001");
        (string memory name, string memory batch, , ) = supplyChain.getProduct(
            productId
        );
        assertEq(name, "Medicine");
        assertEq(batch, "Batch001");
    }

    function testOnlyOwnerCanAddProduct() public {
        vm.prank(user);
        vm.expectRevert("Ownable: caller is not the owner");
        supplyChain.addProduct("Medicine", "Batch002");
    }

    function testUpdateProductStatus() public {
        vm.prank(owner);
        uint256 productId = supplyChain.addProduct("Vaccine", "Batch003");
        supplyChain.updateProductStatus(productId, "Shipped");
        (, , string memory status, ) = supplyChain.getProduct(productId);
        assertEq(status, "Shipped");
    }

    function testGetProductReturnsCorrectData() public {
        vm.prank(owner);
        uint256 productId = supplyChain.addProduct("TestKit", "Batch004");
        (
            string memory name,
            string memory batch,
            string memory status,
            address addedBy
        ) = supplyChain.getProduct(productId);
        assertEq(name, "TestKit");
        assertEq(batch, "Batch004");
        assertEq(status, "Created");
        assertEq(addedBy, owner);
    }
}
function testAddMultipleProducts() public {
  vm.prank(owner);
  uint256 id1 = supplyChain.addProduct("DrugA", "BatchA");
  uint256 id2 = supplyChain.addProduct("DrugB", "BatchB");
  (string memory name1, , , ) = supplyChain.getProduct(id1);
  (string memory name2, , , ) = supplyChain.getProduct(id2);
  assertEq(name1, "DrugA");
  assertEq(name2, "DrugB");
}

function testUpdateProductStatusEmitsEvent() public {
  vm.prank(owner);
  uint256 productId = supplyChain.addProduct("Device", "Batch005");
  vm.expectEmit(true, false, false, true);
  emit supplyChain.ProductStatusUpdated(productId, "Delivered");
  supplyChain.updateProductStatus(productId, "Delivered");
}

function testUpdateProductStatusRevertsForNonOwner() public {
  vm.prank(owner);
  uint256 productId = supplyChain.addProduct("Mask", "Batch006");
  vm.prank(user);
  vm.expectRevert("Ownable: caller is not the owner");
  supplyChain.updateProductStatus(productId, "Lost");
}

function testGetProductRevertsForInvalidId() public {
  vm.prank(owner);
  supplyChain.addProduct("Gloves", "Batch007");
  vm.expectRevert();
  supplyChain.getProduct(9999);
}