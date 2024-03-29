module sui_bank::bank {
  use sui::sui::SUI;
  use sui::transfer;
  use sui::coin::{Self, Coin};
  use sui::object::{Self, UID};
  use sui::balance::{Self, Balance};
  use sui::tx_context::{Self, TxContext};

  use sui_bank::sui_dollar::{Self, CapWrapper, SUI_DOLLAR};  

  friend sui_bank::amm;
  friend sui_bank::lending;

  #[test_only]
  friend sui_bank::bank_tests;
  #[test_only]
  friend sui_bank::amm_tests;
  #[test_only]
  friend sui_bank::sui_dollar_tests;
  

  // === Constants ===
  const ENotEnoughBalance: u64 = 0;
  const EBorrowAmountIsTooHigh: u64 = 1;
  const EAccountMustBeEmpty: u64 = 2;
  const EPayYourLoan: u64 = 3;
  const EOutOfRangeFee: u64 = 4;
  const EOutOfRangeLTV: u64 = 5;

  const MIN_FEE: u8 = 0;
  const MAX_FEE: u8 = 15;
  const DEFAULT_FEE: u8 = 5;

  const MIN_LTV: u8 = 1; // 1 Sui = 0.01 SUI_DOLLAR
  const MAX_LTV: u8 = 100; // 1 Sui = 1 SUI_DOLLAR
  const DEFAULT_LTV: u8 = 40;  // 1 SUI = 0.4 SUI_DOLLAR
  
  public fun fee(self: &Bank): u128 {
    self.fee
  }

  public fun ltv(self: &Bank): u128 {
    self.ltv    
  }

  // === Structs ===
  struct Bank has key {
    id: UID,
    balance: Balance<SUI>, // Custody of Customer SUI coins.
    admin_balance: Balance<SUI>, // Fee collected by the bank.
    fee: u128, // [MIN_FEE..MAX_FEE] % charged on deposits
    ltv: u128, // [MIN_LTV..MAX_LTV] Sui to Sui Dollar exchange rate.
  }

  struct Account has key, store {
    id: UID,
    user: address,
    debt: u64,
    balance: u64
  }

  struct OwnerCap has key, store {
    id: UID
  }

  
  fun init(ctx: &mut TxContext) {
    transfer::share_object(
      Bank {
        id: object::new(ctx),
        balance: balance::zero(),
        admin_balance: balance::zero(),
        fee: (DEFAULT_FEE as u128),
        ltv: (DEFAULT_LTV as u128)
      }
    );

    transfer::transfer(OwnerCap { id: object::new(ctx) }, tx_context::sender(ctx));
  }

  // === Public Read Functions ===    

  public fun new_account(ctx: &mut TxContext): Account {
    Account {
      id: object::new(ctx),
      user: tx_context::sender(ctx),
      debt: 0,
      balance: 0
    }
  }

  public fun user(account: &Account): address {
    account.user
  }

  public fun debt(account: &Account): u64 {
    account.debt
  } 

  public fun balance(acc: &Account): u64 {
    acc.balance
  }   

  // === Public Mut Functions ===    

  public fun deposit(self: &mut Bank, account: &mut Account, token: Coin<SUI>, ctx: &mut TxContext) {
    let value = coin::value(&token);
    let deposit_value = value - (((value as u128) * self.fee / 100) as u64);
    let admin_fee = value - deposit_value;

    let admin_coin = coin::split(&mut token, admin_fee, ctx);
    balance::join(&mut self.admin_balance, coin::into_balance(admin_coin));
    balance::join(&mut self.balance, coin::into_balance(token));

    account.balance = account.balance + deposit_value;
  }  

  public fun withdraw(self: &mut Bank, account: &mut Account, value: u64, ctx: &mut TxContext): Coin<SUI> {
    assert!(account.debt == 0, EPayYourLoan);
    assert!(account.balance >= value, ENotEnoughBalance);

    account.balance = account.balance - value;

    coin::from_balance(balance::split(&mut self.balance, value), ctx)
  }

  public fun borrow(self: &mut Bank, account: &mut Account, cap: &mut CapWrapper, value: u64, ctx: &mut TxContext): Coin<SUI_DOLLAR> {
    let max_borrow_amount = (((account.balance as u128) * self.ltv / 100) as u64);

    assert!(max_borrow_amount >= account.debt + value, EBorrowAmountIsTooHigh);

    account.debt = account.debt + value;

    sui_dollar::mint(cap, value, ctx)
  }

  public fun repay(account: &mut Account, cap: &mut CapWrapper, coin_in: Coin<SUI_DOLLAR>) {
    let amount = sui_dollar::burn(cap, coin_in);

    account.debt = account.debt - amount;
  }  
  
  public fun destroy_empty_account(account: Account) {
    let Account { id, debt: _, balance, user: _ } = account;
    assert!(balance == 0, EAccountMustBeEmpty);
    object::delete(id);
  }  

  public fun swap_sui(self: &mut Bank, cap: &mut CapWrapper, coin_in: Coin<SUI>, ctx: &mut TxContext): Coin<SUI_DOLLAR> {

    // Convert to SUI_DOLLAR at exchange rate
    // 1 SUI = 0.4 SUI_DOLLAR
    let coin_value = coin::value(&coin_in);
    let mint_amount = (((coin_value as u128) * self.ltv / 100) as u64);

    // Take custody of the coin_in    
    let _ = balance::join<SUI>(&mut self.balance, coin::into_balance(coin_in));

    // Mint SUI_DOLLAR and return it.
    sui_dollar::mint(cap, mint_amount, ctx)
  }

  public fun swap_sui_dollar(self: &mut Bank, cap: &mut CapWrapper, coin_in: Coin<SUI_DOLLAR>, ctx: &mut TxContext): Coin<SUI> {
    // Burn the SUI_DOLLAR
    let burn_amount = sui_dollar::burn(cap,coin_in);

    // Convert to SUI at exchange rate
    // let return_amount = (((burn_amount as u128) * (100 + EXCHANGE_RATE)) as u64);
    // TODO Suspense is that OK!?
    let return_amount = (((burn_amount as u128) / self.ltv * 100) as u64);

    // Return SUI from balance
    let return_balance = balance::split(&mut self.balance, return_amount);
    coin::from_balance(return_balance, ctx)
  }

  // === Admin Functions ===

  public fun claim(_: &OwnerCap, self: &mut Bank, ctx: &mut TxContext): Coin<SUI> {
    let value = balance::value(&self.admin_balance);
    coin::take(&mut self.admin_balance, value, ctx)
  }    

  public fun adjust_fee(_: &OwnerCap, self: &mut Bank, new_fee: u8 ) {
    assert!(new_fee >= MIN_FEE && new_fee <= MAX_FEE, EOutOfRangeFee);
    self.fee = (new_fee as u128);
  }

  public fun adjust_ltv(_: &OwnerCap, self: &mut Bank, new_ltv: u8 ) {
    assert!(new_ltv >= MIN_LTV && new_ltv <= MAX_LTV, EOutOfRangeLTV);
    self.fee = (new_ltv as u128);
  }

  // === Public-Friend Functions ===
  
  public(friend) fun balance_mut(self: &mut Bank): &mut Balance<SUI> {
    &mut self.balance
  }

  public(friend) fun admin_balance(self: &Bank): u64 {
    balance::value<SUI>(&self.admin_balance)
  }

  public(friend) fun admin_balance_mut(self: &mut Bank): &mut Balance<SUI> {
    &mut self.admin_balance
  }

  public(friend) fun debt_mut(acc: &mut Account): &mut u64 {
    &mut acc.debt
  }  

  public(friend) fun account_balance_mut(acc: &mut Account): &mut u64 {
    &mut acc.balance
  }   
  // === Tests ===
  #[test_only]
  public fun init_for_testing(ctx: &mut TxContext) {
    init(ctx);
  }

}
