module bank::bank {
  use sui::object::{Self, UID};
  use sui::tx_context::{TxContext, sender};
  use sui::coin::{Self, Coin};
  use sui::balance::{Self, Balance};
  use sui::sui::{SUI};
  use sui::transfer;
  
  use sui::dynamic_field as df;

  const ENoFund: u64 = 1;

  struct Bank has key {
    id: UID
  }

  struct OwnerCap has key, store {
    id: UID
  }


  // Dynamic field keys
  struct UserBalance has copy, drop, store { user: address }
  struct AdminBalance has copy, drop, store {}    

  const FEE: u128 = 5; // percent
  public fun fee() : u128 { FEE }
  
  fun init(ctx: &mut TxContext) {
    transfer::transfer(OwnerCap { id: object::new(ctx) }, sender(ctx));
    let bank = Bank { id: object::new(ctx) };    
    df::add(&mut bank.id, AdminBalance {}, balance::zero<SUI>());
    transfer::share_object(bank);
  }

  public fun deposit(self: &mut Bank, token: Coin<SUI>, ctx: &mut TxContext) {

    let token_value = coin::value<SUI>(&token);
    let admin_fee = (((token_value as u128) * FEE / 100) as u64);
    // let deposit_val = token_value - admin_fee;

    // Get the Bank balance object (See init).
    let bank_balance = df::borrow_mut<AdminBalance, Balance<SUI>>(
      &mut self.id,
      AdminBalance {},
    );

    // Subtracts admin_fee from token, and create a balance object for it.
    let admin_fee_coin = coin::split<SUI>(
      &mut token,
      admin_fee,
      ctx
    );
    let admin_fee_balance = coin::into_balance(admin_fee_coin);

    // Add the admin fee to the Bank balance.
    balance::join(bank_balance, admin_fee_balance);

    // Create balance object to be deposited for that user.
    let deposit_balance = coin::into_balance(token);    

    // Check if a UserBalance exists for this sender, if not then create it.
    let user_balance_key = UserBalance { user: sender(ctx) };
    let exists = df::exists_with_type<UserBalance, Balance<SUI>>(
       &self.id,
       user_balance_key
    );

    if (exists) {
      let existing_user_balance = df::borrow_mut(&mut self.id, user_balance_key);
      balance::join(existing_user_balance, deposit_balance);
    } else {
      df::add(&mut self.id, user_balance_key, deposit_balance);
    }
  }

  public fun withdraw(self: &mut Bank, ctx: &mut TxContext): Coin<SUI> {
    // Check if a UserBalance exists for this sender, if yes, then return it (convert balance to a coin).
    let user_balance_key = UserBalance { user: sender(ctx) };
    let exists = df::exists_with_type<UserBalance, Balance<SUI>>(
       &self.id,
       user_balance_key
    );
    assert!(exists, ENoFund );
    let existing_user_balance = df::borrow_mut(&mut self.id, user_balance_key);

    // Withdraw all the balance from UserBalance into a local variable.
    let withdraw_balance = balance::withdraw_all<SUI>(existing_user_balance);
        
    // Return the coin built from the balance subtracted from the Bank.
    coin::from_balance<SUI>(withdraw_balance, ctx)
  }

  public fun claim(_: &OwnerCap, self: &mut Bank, ctx: &mut TxContext): Coin<SUI>
  {
    // Empty the Bank!  
    let bank_balance = df::borrow_mut<AdminBalance, Balance<SUI>>(
      &mut self.id,
      AdminBalance {},
    );
    let withdraw_balance = balance::withdraw_all<SUI>(bank_balance);
    coin::from_balance<SUI>(withdraw_balance, ctx)
  }

  public fun balance(self: &Bank, user: address): u64 {
    let user_balance_key = UserBalance { user: user };
    let exists = df::exists_with_type<UserBalance, Balance<SUI>>(
       &self.id,
       user_balance_key
    );
    let ret_value = 0u64;
    if (exists) {
      let existing_user_balance = df::borrow(&self.id, user_balance_key);
      ret_value=balance::value<SUI>(existing_user_balance);
    };
    ret_value
  }

  public fun admin_balance(self: &Bank): u64 {
    let bank_balance = df::borrow<AdminBalance, Balance<SUI>>(
      &self.id,
      AdminBalance {},
    );
    balance::value<SUI>(bank_balance)
  }

  #[test_only]
  public fun init_for_testing(ctx: &mut TxContext) {
    init(ctx);
  }  
}

