// SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;    
    
    contract SupplyChain{
    enum Category{Medicals, Food}

          struct Medicals {
          uint256 id;
          bool isTrue;
          uint256 amount_of_users;
          address users;
          string currentStatus; // e.g., AtWarehouse, InTransit, Delivered
         uint256 warehouseId;  // optional
      }
        struct Food{
          uint256 id;
          string name;
          uint256 price_in_usd;
          string currencyCode;
          uint256 delivery_days;
          uint256 delivery_fee_in_usd;
          uint256 amount_of_users;
        }
        struct ValidationResult{
            uint256 medical_id;
            uint256 medical_report;
            address block;
            bool is_validated;
            mapping (address => VerificationResult)  verificationResults;
        }
        struct VerificationResult{
            string transactionHash; 
            string rpc_result ;// RPC result of the current verification (whether it was verified or not).
            address verifier;
            bool isApproved;
            string name_of_verified_users;
        }
        struct MovementDetails{
            uint256 tracking_id;
             string trunk_id; // Plate number
             string delivery_company ;// Company name
             uint256 delivery_fee_in_usd; // Delivery fee in usd
            bool delivered_on_time; 
        }
        struct Trackers{
            bool isOrders;
            mapping (uint256 => MovementDetails) tracking_details;
            address trackers_id;
            address tracker_owner;
            uint256 owner_product;
        }
        struct Transaction{
         bool isTransact_Successful;
         uint256 amountOfUsers;
         address payment_receiver;
        uint256 payment_receiver_id ; // for tracking the user who paid.
         address medicalsId;
        }
        struct Users{
            address user_id;
            string name;
            mapping (uint256 => Medicals) medical_id ;
            mapping (uint256 => Trackers) tracker_id ; // itemId => MovementDetails
            uint256[] users;
            mapping (string => Transaction)  transaction;
        }
        struct Product{
            address producer;
            uint256 unit_price;
            bool has_Transacted;
            Medicals[]  medicals;
            Food[]  foodList;
            address[]  consumersAddresses;
            string name;
        }
        mapping(uint256 => ValidationResult) public itemValidations; // itemId => Validation
        mapping (string => Transaction) public transaction;
        mapping(address => Medicals) public usersAddressToMedicalId; 
       mapping(Category => mapping(uint256 => Food)) public categorizedItems;
        mapping(uint256 => mapping(address => Medicals)) public warehouseInventory;
        mapping(uint256 => mapping (address =>ValidationResult)) public validationResults;
        address[] public consumersAddress;
        mapping(uint256 => MovementDetails) public movementLogs; // itemId => MovementDetails
        mapping(uint256 => Transaction) public transactions;


  event Nationality(uint256 indexed itemId,string nationalityId, Category category  , bool isArrived);
  event ItemCreated(uint256 indexed itemId, string name, Category category);
  event ItemValidated(uint256 indexed itemId, address validatedBy);
  event ItemVerified(uint256 indexed itemId, address verifier, bool status);
  event ItemMoved(uint256 indexed itemId, address movedBy, string location);

//   emit ItemValidated(itemId, msg.sender);
// emit ItemMoved(itemId, msg.sender, "Checkpoint A");
        Medicals[] public medicals;
        Food[] public foodList;
        Transaction[] public transactionDetails;
        mapping (uint256 => Medicals) public warehouseInventory_;// itemId => Medicals
        address payable public owner;

        constructor() {
            owner = payable(msg.sender);
        }
        

        



     

     
  }
   
    