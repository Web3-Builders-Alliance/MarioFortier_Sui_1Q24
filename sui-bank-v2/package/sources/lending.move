module sui_bank::lending {
  // === Imports ===

  use sui::coin::Coin;
  use sui::tx_context::TxContext;

  use sui_bank::bank::{Self, Bank, Account};
  use sui_bank::oracle::{Self, Price}; 
  use sui_bank::sui_dollar::{Self, CapWrapper, SUI_DOLLAR}; 

  // === Errors ===
  const EBorrowAmountIsTooHigh: u64 = 0;

  // === Public-Mutative Functions ===

  public fun borrow(bank: &Bank, account: &mut Account, cap: &mut CapWrapper, price: Price, value: u64, ctx: &mut TxContext): Coin<SUI_DOLLAR> {
    let (latest_result, scaling_factor, _) = oracle::destroy_price(price);
    let ltv = bank::ltv(bank);
    let max_borrow_amount = (((((bank::balance(account) as u128) * latest_result / scaling_factor) * ltv) / 100) as u64);

    let debt_mut = bank::debt_mut(account);

    assert!(max_borrow_amount >= *debt_mut + value, EBorrowAmountIsTooHigh);

    *debt_mut = *debt_mut + value;

    sui_dollar::mint(cap, value, ctx)
  }

  public fun repay(account: &mut Account, cap: &mut CapWrapper, coin_in: Coin<SUI_DOLLAR>) {
    let amount = sui_dollar::burn(cap, coin_in);

    let debt_mut = bank::debt_mut(account);

    *debt_mut = *debt_mut - amount;
  }    
}