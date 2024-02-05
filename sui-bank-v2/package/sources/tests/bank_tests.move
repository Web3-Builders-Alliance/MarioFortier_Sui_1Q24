#[test_only]
module sui_bank::bank_tests {
    use sui::test_utils::assert_eq;
    use sui::coin::{mint_for_testing, burn_for_testing};
    use sui::test_scenario as ts;    
    use sui_bank::bank::{Self, Bank, ENotEnoughBalance};
    use sui::sui::{SUI};
    use sui::transfer;

    const ADMIN: address = @0xBEEF;
    const ALICE: address =  @0x1337;

    // Unit-tests error codes.
    const EUnexpectedZeroDeposit: u64 = 0x1000;

    fun init_test_helper(): ts::Scenario {
        let scenario_val = ts::begin(ADMIN);
        let scenario = &mut scenario_val;
        ts::next_tx(scenario, ADMIN);
        {
            bank::init_for_testing(ts::ctx(scenario));
        };
        scenario_val
    }

    // Calculate fee for a deposit.
    fun calculate_fee(bank: &Bank, value: u64): u64 {
        (((value as u128) * bank::fee(bank) / 100) as u64)
    }

    // Same as calculate_fee, but doing its own txn.
    fun calculate_fee_helper(scenario: &mut ts::Scenario, value: u64 ): u64 {
        ts::next_tx(scenario, ADMIN);
        {
            let bank = ts::take_shared<Bank>(scenario);            
            let fee_collected = calculate_fee(&bank, value);
            ts::return_shared(bank);
            fee_collected
        }
    }

    // Simulate deposit. Return the amount deposited minus fee.
    fun create_account_helper(scenario: &mut ts::Scenario, user: address) {
        ts::next_tx(scenario, user);
        {
            let account = bank::new_account(ts::ctx(scenario));
            transfer::public_transfer(account, ts::sender(scenario));
        };        
    }

    // Deposit the specified amount. Returns the fee amount collected by the bank.    
    fun deposit_helper(scenario: &mut ts::Scenario, user: address, deposit: u64): u64 {
        
        assert!(deposit > 0, EUnexpectedZeroDeposit);

        // Create account if does not exists.        
        ts::next_tx(scenario, user);
        {
            if (ts::has_most_recent_for_sender<bank::Account>(scenario) == false) {
              let account = bank::new_account(ts::ctx(scenario));
              transfer::public_transfer(account, ts::sender(scenario));
            }
        };

        ts::next_tx(scenario, user);
        {
            let coin = mint_for_testing<SUI>(deposit, ts::ctx(scenario));
            let bank = ts::take_shared<Bank>(scenario);
            let fee = calculate_fee(&bank,deposit);
            let account_increase = deposit - fee;
            
            let account = ts::take_from_sender<bank::Account>(scenario);            
            let user_before = bank::balance(&account);
            let bank_before = bank::admin_balance(&bank);
            bank::deposit(&mut bank, &mut account, coin, ts::ctx(scenario));
            let user_after = bank::balance(&account);
            let bank_after = bank::admin_balance(&bank);
            // Verify UserBalance properly increased.
            assert_eq(user_after-user_before, account_increase);
            // Verify BankBalance properly increased by the fee amount.
            assert_eq(bank_after-bank_before, fee);

            ts::return_shared(bank);
            ts::return_to_sender(scenario, account);
            fee
        }        
    }

    fun assert_bank_balance(scenario: &mut ts::Scenario, expected: u64) {
        ts::next_tx(scenario, ADMIN);
        {
            let bank = ts::take_shared<Bank>(scenario);
            let bank_balance = bank::admin_balance(&bank);
            assert_eq(bank_balance, expected);
            ts::return_shared(bank);
        };
    }

    fun assert_account_balance(scenario: &mut ts::Scenario, user: address, expected: u64) {
        ts::next_tx(scenario, user);
        {
            let bank = ts::take_shared<Bank>(scenario);
            let account = ts::take_from_sender<bank::Account>(scenario);
            let user_balance = bank::balance(&account);
            assert_eq(user_balance, expected);
            ts::return_shared(bank);
            ts::return_to_sender(scenario, account);
        };    
    }

    #[test]
    fun test_deposit() {
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;        
        let deposit = 100;
        
        create_account_helper(scenario, ALICE);

        // The helpers includes some unit testing as well...
        let fee_collected = deposit_helper(scenario, ALICE, deposit);
        
        // Do it again to verify the fee cumulates.
        fee_collected = fee_collected + deposit_helper(scenario, ALICE, deposit);
        let expected_total_fee = calculate_fee_helper(scenario, deposit*2);
        assert_eq(fee_collected, expected_total_fee); // Sanity test of the helper itself.

        // Verify fee accumulated on-chain.
        assert_bank_balance(scenario, expected_total_fee );
                
        // Verify that the user balance on-chain.
        let expected_user_balance = deposit*2 - expected_total_fee;
        assert_account_balance(scenario, ALICE, expected_user_balance);

        ts::end(scenario_val);
    }

    #[test]
    fun test_withdraw() {
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;
        let deposit = 100;
        let fee = calculate_fee_helper(scenario, deposit);

        create_account_helper(scenario, ALICE);
        let fee_collected = deposit_helper(scenario, ALICE, deposit);
        let user_balance = deposit - fee_collected;

        ts::next_tx(scenario, ALICE);
        {
            let bank = ts::take_shared<Bank>(scenario);
            let account = ts::take_from_sender<bank::Account>(scenario);            
            let coin = bank::withdraw(&mut bank, &mut account, user_balance, ts::ctx(scenario));
            let value = burn_for_testing(coin);

            // Verify UserBalance
            assert_eq(value, user_balance);
            assert_eq(bank::balance(&account), 0);

            // Verify BankBalance. Only the fee from the deposit should remain.
            let bank_balance = bank::admin_balance(&bank);
            assert_eq(bank_balance, fee);
            
            ts::return_shared(bank);
            ts::return_to_sender(scenario, account);
        };

        ts::end(scenario_val);        
    }

    #[test]
    #[expected_failure( abort_code = ENotEnoughBalance )]
    fun test_withdraw_no_fund() {
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;

        create_account_helper(scenario, ALICE);

        ts::next_tx(scenario, ALICE);
        {
            let bank = ts::take_shared<Bank>(scenario);
            let account = ts::take_from_sender<bank::Account>(scenario);
            // Should abort here...
            let coin = bank::withdraw(&mut bank, &mut account, 1, ts::ctx(scenario));            
            let _value = burn_for_testing(coin);            
            ts::return_shared(bank);
            ts::return_to_sender(scenario, account);
        };
        ts::end(scenario_val);        
    }

    #[test]
    fun claim_test_empty() {
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;
        
        // Call claim when there was no deposit.
        ts::next_tx(scenario, ADMIN);
        {
            let bank = ts::take_shared<Bank>(scenario);
            let ownerCap = ts::take_from_sender<bank::OwnerCap>(scenario);
            let coin = bank::claim(&ownerCap,&mut bank, ts::ctx(scenario));
            let value = burn_for_testing(coin);
            assert_eq(value, 0);
            ts::return_to_sender(scenario, ownerCap);
            ts::return_shared(bank);
        };
        assert_bank_balance(scenario, 0);      
        ts::end(scenario_val);            
    }

    #[test]
    fun claim_fee_test() {
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;

        // Make two deposits.
        let deposit = 100;
        let fee = calculate_fee_helper(scenario, deposit);
        create_account_helper(scenario, ALICE);
        let fee_collected = deposit_helper(scenario, ALICE, deposit);
        fee_collected = fee_collected + deposit_helper(scenario, ALICE, deposit);
        let user_balance = deposit*2 - fee_collected;

        // Call claim as the ADMIN.
        ts::next_tx(scenario, ADMIN);
        {
            let bank = ts::take_shared<Bank>(scenario);
            let ownerCap = ts::take_from_sender<bank::OwnerCap>(scenario);
            let coin = bank::claim(&ownerCap,&mut bank, ts::ctx(scenario));
            assert_eq(burn_for_testing<SUI>(coin), fee*2);
            ts::return_to_sender(scenario, ownerCap);
            ts::return_shared(bank);
        };
        assert_bank_balance(scenario, 0);   
        assert_account_balance(scenario, ALICE, user_balance);   
        ts::end(scenario_val);
    }
}