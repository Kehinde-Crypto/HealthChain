// SPDX-License-Identifier:MIT
pragma solidity ^0.8.24; 


    interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        );
}

   

    contract SupplyChain{
    enum Category{Medicals, Food}

      struct Medicals {
          uint256 id;
          bool isTrue;
          uint256 amount_of_users;
          address users;
          string currentStatus; // e.g., AtWarehouse, InTransit, Delivered
          uint256 warehouseId;  // optional
          string name;          // Added field for product name
          string batch;         // Added field for batch number
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
  event ItemValidated(string batchId, bool status);
  event ItemVerified(uint256 indexed itemId, address verifier, bool status);
  event ItemMoved(uint256 indexed itemId, address movedBy, string location);


       AggregatorV3Interface internal priceFeed;
       constructor(address _priceFeedAddress) {
    priceFeed = AggregatorV3Interface(_priceFeedAddress);
      owner = payable(msg.sender);
}
      address constant EUR_TO_USD = 0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910;
   event ItemMovedWithPrice(
    uint256 indexed itemId,
    address movedBy,
    string location,
    uint256 priceInNGN
);
  


//   emit ItemValidated(itemId, msg.sender);
// emit ItemMoved(itemId, msg.sender, "Checkpoint A");
        Medicals[] public  medicals;
        Food[] public foodList;
        Transaction[] public transactionDetails;
        mapping (uint256 => Medicals) public warehouseInventory_;// itemId => Medicals
        address payable public owner;
            
         function getLatestPrice() public view returns(int){
            (, int price ,,,) = priceFeed.latestRoundData();
            return price;
         }
              
        // function transaction (movement) of the medical items , transfer of goods  medicine and equipments, from supplier to Hospital
        function transferMedicine(string memory batchId, string[] memory itemNames,
    uint[] memory quantities
    ) external {
          // and list them(ITEMS) by including the items
          uint[] memory itemIds;

         require(foodList.length == medicals.length, "Item and quantity length mismatch");
              uint[] memory combined = new uint[](foodList.length);
              for(uint i = 0; i < foodList.length; i++){
                 combined[i] =  quantities[i];
                
              }

           
          // we are going to add a way in which we can import these goods , it is important that the supplier has already been recorded by us .
           // we need a way to record the suppliers goods
           require(bytes(batchId).length > 0, "Batch ID is required");
           require(itemNames.length == quantities.length, "Item and quantity length mismatch");
             for (uint i = 0; i < itemNames.length; i++){
                 emit ItemValidated(batchId , true);
                emit ItemMoved(itemIds[i],msg.sender, "Lagos Central Warehouse");
            }
        }
         




        // a function that helps to get the ìmporting the Goods for nationality to another
        function authorizeImport(
    string memory batchId,
    string memory originCountry,
    string memory destinationCountry,
    uint256[] memory itemIds
) external {
    require(bytes(batchId).length > 0, "Batch Id is required");
    require(itemIds.length > 0, "Item list required");

    // Compare strings with keccak256 hash
    if (
        keccak256(bytes(originCountry)) == keccak256(bytes("Nigeria")) &&
        keccak256(bytes(destinationCountry)) != keccak256(bytes("Nigeria"))
    ) {
        for (uint i = 0; i < itemIds.length; i++) {
            emit ItemMoved(itemIds[i], msg.sender, "Lagos Central Warehouse");
        }
    }
}


        // a function that provide economic price feed of the goods among the state
         function authorizeImportWithPrice(
    string memory batchId,
    string memory originCountry,
    string memory destinationCountry,
    uint256[] memory itemIds
) external {
    require(bytes(batchId).length > 0, "Batch Id is required");
    require(itemIds.length > 0, "Item list required");

    // Check if it's an export from Nigeria
    if (
        keccak256(bytes(originCountry)) == keccak256(bytes("Nigeria")) &&
        keccak256(bytes(destinationCountry)) != keccak256(bytes("Nigeria"))
    ) {
        // Get price from Chainlink (e.g., NGN/USD)
        (, int price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");

        for (uint i = 0; i < itemIds.length; i++) {
            emit ItemMovedWithPrice(
                itemIds[i],
                msg.sender,
                "Lagos Central Warehouse",
                uint256(price) // emit NGN price
            );
        }
    }
}
   function addProduct(string memory name, string memory batch) public returns (uint256) {
    require(bytes(name).length > 0, "Product name is required");
    require(bytes(batch).length > 0, "Batch number is required");
    Medicals memory newProduct = Medicals({
        id: 0,
        isTrue: true,
        amount_of_users: 0,
        users: msg.sender,
        currentStatus: "Created",
        warehouseId: 0, // Optional, can be set later
        name: name,
        batch: batch
         
    });

    medicals.push(newProduct);
    emit ItemCreated(0, name, Category.Medicals);
    return 0;
}
    function getProduct(uint256 productId) public view returns (string memory, string memory, string memory, address) {
        require(productId > 0 && productId <= medicals.length, "Invalid product ID");
        Medicals storage product = medicals[productId - 1];
        return (product.name, product.batch, product.currentStatus, product.users);
    }

    function updateProductStatus(uint256 productId, string memory newStatus) public {
        require(productId > 0 && productId <= medicals.length, "Invalid product ID");
        Medicals storage product = medicals[productId - 1];
        product.currentStatus = newStatus;
        emit ItemValidated("", true);
    }
  }
   
    