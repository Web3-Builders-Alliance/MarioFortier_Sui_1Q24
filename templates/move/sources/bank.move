module bank::bank {
  use sui::object::{Self, UID};
  use sui::tx_context::{TxContext, sender};
  use sui::coin::{Self, Coin};
  //use sui::balance::{Self};
  use sui::sui::{SUI};
  use sui::transfer;
  //use sui::dynamic_field as df;

  struct Bank has key {
    id: UID
  }

  struct OwnerCap has key, store {
    id: UID
  }

  struct UserBalance has copy, drop, store { user: address }
  struct AdminBalance has copy, drop, store {}    

  const FEE: u128 = 5; // percent

  fun init(ctx: &mut TxContext) {
    transfer::transfer(OwnerCap { id: object::new(ctx) }, sender(ctx));
    let bank = Bank { id: object::new(ctx) };    
    /*df::add(&mut bank, AdminBalance {}, balance::zero<Sui>());*/
    transfer::share_object(bank);
  }
/*
  public fun deposit(_self: &mut Bank, token: Coin<SUI>, _ctx: &mut TxContext) {
    let deposit_val = coin::value<SUI>(&token);
    let admin_fee = (((deposit_val as u128) * FEE / 100) as u64);
    let _deposit_val = deposit_val - admin_fee;

    // The admin balance increase by the fee and the user balance increase by the deposit_value.

    let value = df::borrow_mut<AdminBalance, Balance<Sui>>(
      &mut self.id,
      AdminBalance {},
    );

    // Split the coin into 2.
    let admin_coin = coins::split<SUI>(
      &mut token,
      admin_fee,
      ctx
    );
    let admin_balance = coin::into_balance(admincoin);

    let new_balance = balance::join(value, admin_balance); // You can drop new_balance.

    // Check if the user has deposited or not.
    let exists = df::exists( &self.id,
       user_balance_key
    );

    // Store the coin in the Bank.
    let user_balance_key = UserBalance();
    let user_balance = coin::into_balance(token);
    if (exists) {
    } else {
      df::add(&mut self.id, user_balance_key, user_balance);
    }
    
  }

  public fun withdraw(self: &mut Bank, ctx: &mut TxContext): Coin<SUI> {
  
  }


  public fun claim(_: &OwnerCap, self: &mut Bank, ctx: &mut TxContext): Coin<SUI> {
    
  }*/
}