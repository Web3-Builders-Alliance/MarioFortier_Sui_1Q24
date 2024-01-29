#[test_only]
module bank::bank_tests {
    use sui::test_utils::assert_eq;
    use sui::coin::{mint_for_testing, burn_for_testing};
    use sui::test_scenario as ts;    
    use bank::bank::{Self, Bank, ENoFund};
    use sui::sui::{SUI};

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

    fun calculate_fee(value: u64): u64 {
        (((value as u128) * bank::fee() / 100) as u64)
    }

    // Simulate deposit. Return the amount deposited minus fee.
    fun deposit_helper(scenario: &mut ts::Scenario, user: address, deposit: u64): u64 {
        assert!(deposit > 0, EUnexpectedZeroDeposit);
        let fee = calculate_fee(deposit);
        let user_balance_increase = deposit - fee;
        ts::next_tx(scenario, user);
        {
            let coin = mint_for_testing<SUI>(deposit, ts::ctx(scenario));
            let bank = ts::take_shared<Bank>(scenario);
            let user_before = bank::balance(&bank, user);
            let bank_before = bank::admin_balance(&bank);
            bank::deposit(&mut bank, coin, ts::ctx(scenario));
            let user_after = bank::balance(&bank, user);
            let bank_after = bank::admin_balance(&bank);
            // Verify UserBalance properly increased.
            assert_eq(user_after-user_before, user_balance_increase);
            // Verify BankBalance properly increased by the fee amount.
            assert_eq(bank_after-bank_before, fee);

            ts::return_shared(bank);
        };
        user_balance_increase
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

    #[test]
    fun test_deposit() {
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;        
        let deposit = 100;

        // The helper includes unit testing of the deposit txn.
        let _user_balance = deposit_helper(scenario, ALICE, deposit);

        // Do it again to verify the fee cumulates.
        let _user_balance = deposit_helper(scenario, ALICE, deposit);        
        assert_bank_balance(scenario, calculate_fee(deposit)*2);

        ts::end(scenario_val);
    }

    #[test]
    fun test_withdraw() {
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;
        let deposit = 100;
        let fee = calculate_fee(deposit);        
        let user_balance = deposit_helper(scenario, ALICE, deposit);
                
        ts::next_tx(scenario, ALICE);
        {
            let bank = ts::take_shared<Bank>(scenario);
            let coin = bank::withdraw(&mut bank, ts::ctx(scenario));
            let value = burn_for_testing(coin);

            // Verify UserBalance
            assert_eq(value, user_balance);
            assert_eq(bank::balance(&bank, ALICE), 0);

            // Verify BankBalance. Only the fee from the deposit should remain.
            let bank_balance = bank::admin_balance(&bank);
            assert_eq(bank_balance, fee);
            
            ts::return_shared(bank);
        };

        ts::end(scenario_val);        
    }

    #[test]
    #[expected_failure( abort_code = ENoFund )]
    fun test_withdraw_no_fund() {
        let scenario_val = init_test_helper();
        let scenario = &mut scenario_val;
        ts::next_tx(scenario, ALICE);
        {
            let bank = ts::take_shared<Bank>(scenario);
            // Should abort here...
            let coin = bank::withdraw(&mut bank, ts::ctx(scenario));            
            let _value = burn_for_testing(coin);            
            ts::return_shared(bank);
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
        let fee = calculate_fee(deposit);
        let _user_balance = deposit_helper(scenario, ALICE, deposit);
        let _user_balance = deposit_helper(scenario, ALICE, deposit);

        // Call claim as the ADMIN.
        ts::next_tx(scenario, ADMIN);
        {
            let bank = ts::take_shared<Bank>(scenario);
            let ownerCap = ts::take_from_sender<bank::OwnerCap>(scenario);
            let coin = bank::claim(&ownerCap,&mut bank, ts::ctx(scenario));
            assert_eq(burn_for_testing(coin), fee*2);
            ts::return_to_sender(scenario, ownerCap);
            ts::return_shared(bank);
        };
        assert_bank_balance(scenario, 0);      
        ts::end(scenario_val);
    }
}