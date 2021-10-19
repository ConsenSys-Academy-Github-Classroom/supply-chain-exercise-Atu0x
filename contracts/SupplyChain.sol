// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {

  // <owner>
  address payable public owner;

  // <skuCount>
  uint public skuCount;

  // <items mapping>
  mapping (uint256 => Item) public items;

  // <enum State: ForSale, Sold, Shipped, Received>

  enum State {ForSale, Sold, Shipped, Received}

  // <struct Item: name, sku, price, state, seller, and buyer>

  struct Item {
    string name;
    uint sku;
    uint price;
    State state;
    address payable seller;
    address payable buyer;
  
  }
  
  /* 
   * Events
   */

  // <LogForSale event: sku arg>
  event LogForSale (uint sku);

  // <LogSold event: sku arg>
  event LogSold (uint indexed sku);

  // <LogShipped event: sku arg>
  event LogShipped (uint sku);

  // <LogReceived event: sku arg>
  event LogReceived (uint sku);

  // event test_value1(uint value1);
  // event test_value2(address payable value2);
  // event test_value3(State state);


  /* 
   * Modifiers
   */

  // Create a modifer, `isOwner` that checks if the msg.sender is the owner of the contract
  modifier isOwner(address _address) {require (owner == _address); _;}

  // <modifier: isOwner

  modifier verifyCaller (address _address) { 
    require (msg.sender == _address); 
    _;
  }

  modifier paidEnough(uint _price) { 
    // emit test_value1(msg.value);
    // emit test_value1(_price);
    require(msg.value >= _price); 
    
    _;
  }

  modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    

    _;
    // emit test_value1(1);
    uint _price = items[_sku].price;
    // emit test_value1(_price);
    // emit test_value1(msg.value);
    uint amountToRefund = msg.value - _price;
    // emit test_value1(amountToRefund);
    // emit test_value2(items[_sku].buyer);
    // emit test_value1(items[_sku].buyer.balance);
    // items[_sku].buyer.transfer(amountToRefund);
    // emit test_value1(items[_sku].buyer.balance);
    // emit test_value1(10);
    
      
  }

  // For each of the following modifiers, use what you learned about modifiers
  // to give them functionality. For example, the forSale modifier should
  // require that the item with the given sku has the state ForSale. Note that
  // the uninitialized Item.State is 0, which is also the index of the ForSale
  // value, so checking that Item.State == ForSale is not sufficient to check
  // that an Item is for sale. Hint: What item properties will be non-zero when
  // an Item has been added?

  modifier forSale(uint256 _sku) {
    
    // emit test_value3(State.ForSale);
    require (items[_sku].state == State.ForSale);

  
  _;}
  modifier sold(uint _sku) {require (items[_sku].state == State.Sold); _;}
  modifier shipped(uint _sku) {require (items[_sku].state == State.Shipped); _;}
  modifier received(uint _sku) {require (items[_sku].state == State.Received); _;}

  constructor() public {
    /* Here, set the owner as the person who instantiated the contract
       and set your skuCount to 0. */
    
    owner = address(uint160(msg.sender));
    skuCount = 0;
  }


  function addItem(string memory _name, uint _price) public payable returns (bool) {
    // 1. Create a new item and put in array
    // 2. Increment the skuCount by one
    // 3. Emit the appropriate event
    // 4. return true

    // hint:
    items[skuCount] = Item({
        name: _name, 
        sku: skuCount, 
        price: _price, 
        state: State.ForSale, 
        seller: address(uint160(msg.sender)), 
        // seller: msg.sender, 
        // buyer: address(0)
        buyer: address(uint160(address(0)))
    });

    // emit test_value1(msg.value);
    // emit test_value1(_price);
    // emit test_value2(address(uint160(msg.sender)));
    // emit test_value2(address(uint160(address(0))));
    //
    skuCount = skuCount + 1;
    emit LogForSale(skuCount);
  
    return true;
  }

  // Implement this buyItem function. 
  // 1. it should be payable in order to receive refunds
  // 2. this should transfer money to the seller, 
  // 3. set the buyer as the person who called this transaction, 
  // 4. set the state to Sold. 
  // 5. this function should use 3 modifiers to check 
  //    - if the item is for sale, 
  //    - if the buyer paid enough, 
  //    - check the value after the function is called to make 
  //      sure the buyer is refunded any excess ether sent. 
  // 6. call the event associated with this function!
  
// forSale(sku) paidEnough(items[sku].price) checkValue(sku)
  function buyItem(uint sku) payable public forSale(sku) paidEnough(items[sku].price) checkValue(sku) {


    items[sku].state = State.Sold;
    // items[sku].buyer = msg.sender;

    
    items[sku].buyer = address(uint160(msg.sender));
    
    // emit test_value2(items[sku].buyer);
    
    // emit test_value1(2);
    // uint _value = msg.value;
    // emit test_value1(msg.value);
    // emit test_value1(2);
    // emit test_value1(items[sku].seller.balance);
    items[sku].seller.transfer(items[sku].price);
    // emit test_value1(items[sku].seller.balance);
    emit LogSold(sku);


  }



  // 1. Add modifiers to check:
  //    - the item is sold already 
  //    - the person calling this function is the seller. 
  // 2. Change the state of the item to shipped. 
  // 3. call the event associated with this function!
  function shipItem(uint sku) public sold(sku) verifyCaller(items[sku].seller) {
    items[sku].state = State.Shipped;
    emit LogShipped(sku);


  }

  // 1. Add modifiers to check 
  //    - the item is shipped already 
  //    - the person calling this function is the buyer. 
  // 2. Change the state of the item to received. 
  // 3. Call the event associated with this function!
  function receiveItem(uint sku) public shipped(sku) verifyCaller(items[sku].buyer) {
    items[sku].state = State.Received;
    emit LogReceived(sku);


  }

  // Uncomment the following code block. it is needed to run tests
  function fetchItem(uint _sku) public view
  returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) {
      name = items[_sku].name; 
      sku = items[_sku].sku; 
      price = items[_sku].price; 
      state = uint(items[_sku].state); 
      seller = items[_sku].seller; 
      buyer = items[_sku].buyer; 
      return (name, sku, price, state, seller, buyer);
  }

  // function() external{
  //   revert();
  // }
}
