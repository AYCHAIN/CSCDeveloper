pragma solidity ^0.4.24;
/**
 * Sellable contract should be inherited by any other contract that
 * wants to provide a mechanism for selling its ownership to another account
 */
contract Sellable {
    
    // The owner of the contract
    address public owner;
    
    // Current sale status
    bool public selling = false;
    
    // Who is the selected buyer, if any.
    // Optional
    address public sellingTo;
    
    // How much ether (wei) the seller has asked the buyer to send
    uint public askingPrice;
    
    //
    // Modifiers
    // 
    
    // Makes functions require the called to be the owner of the contract
    modifier onlyOwner {
        require(msg.sender == owner, "Sender is not owner");
        _;
    }
    
    // Add to functions that the owner wants to prevent being called while the
    // contract is for sale.
    modifier ifNotLocked {
        require(!selling, "Contract is already on sale");
        _;
    }
    
    event Transfer(uint _saleDate, address _from, address _to, uint _salePrice);
    constructor() public{
        owner = msg.sender;
        emit Transfer(now,address(0),owner,0);
    }
    
    /**
     * initiateSale is called by the owner of the contract to start
     * the sale process.
     * @param _price is the asking price for the sale
     * @param _to (OPTIONAL) is the address of the person that the owner
     * wants to sell the contract to. If set to 0x0, anyone can buy it.
     */
    function initiateSale(uint _price, address _to) public onlyOwner {
        require(_to != address(this) && _to != owner, "cannot sell to contract itself or owner");
        require(!selling,"Contract is already on sale");
        
        selling = true;
        
        // Set the target buyer, if specified.
        sellingTo = _to;
        
        askingPrice = _price;
    }
    
    /**
     * cancelSale allows the owner to cancel the sale before someone buys
     * the contract.
     */
    function cancelSale() public onlyOwner {
        require(selling, "Contract is not on sale");
        
        // Reset sale variables
        resetSale();
    }
    
    /** 
     * completeSale is called buy the specified buyer (or anyone if sellingTo)
     * was not set, to make the purchase.
     * Value sent must match the asking price.
     */
    function completeSale(uint valued) public payable{
        require(selling,"Contract is not on sale");
        require(msg.sender != owner, "owner cannot buy contract");
        require(msg.sender == sellingTo || sellingTo == address(0), "buyer not authorised");
        require(valued == askingPrice, "price not matched");
        // Swap ownership
        address prevOwner = owner;
        address newOwner = msg.sender;
        uint salePrice = askingPrice;
        
        owner = newOwner;
        
        // Transaction cleanup
       
        
        emit Transfer(now,prevOwner,newOwner,salePrice);
        resetSale();
    }
    
    //
    // Internal functions
    //
    
    /**
     * resets the variables related to a sale process
     */
    function resetSale() internal{
        selling = false;
        sellingTo = address(0);
        askingPrice = 0;
    }
}


