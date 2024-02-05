#[test_only]
module sui_bank::amm_tests {
    use sui::test_utils::assert_eq;
    // use sui::coin::{mint_for_testing, burn_for_testing};
    use sui::test_scenario as ts;    
    use sui_bank::amm::{Self};
    use sui_bank::bank::{Self, Bank};
    //use sui::sui::{SUI};
    //use sui::transfer;

    const ADMIN: address = @0xBEEF;
    // const ALICE: address =  @0x1337;

    fun init_test_helper(): ts::Scenario {
        let scenario_val = ts::begin(ADMIN);
        let scenario = &mut scenario_val;
        ts::next_tx(scenario, ADMIN);
        {            
            bank::init_for_testing(ts::ctx(scenario));
            amm::init_for_testing(ts::ctx(scenario));
        };
        scenario_val
    }

    // Calculate value after exchange.
    fun calculate_exchange(bank: &Bank, value: u64): u64 {
        (((value as u128) * bank::ltv(bank) / 100) as u64)
    }

    // Same as calculate_exchange, but doing its own txn.
    #[allow(unused_function)]
    fun calculate_exchange_helper(scenario: &mut ts::Scenario, value: u64 ): u64 {
        ts::next_tx(scenario, ADMIN);
        {
            let bank = ts::take_shared<Bank>(scenario);            
            let ret_value = calculate_exchange(&bank, value);
            ts::return_shared(bank);
            ret_value
        }
    }

    #[allow(unused_function)]
    fun assert_bank_balance(scenario: &mut ts::Scenario, expected: u64) {
        ts::next_tx(scenario, ADMIN);
        {
            let bank = ts::take_shared<Bank>(scenario);
            let bank_balance = bank::admin_balance(&bank);
            assert_eq(bank_balance, expected);
            ts::return_shared(bank);
        };
    }

    #[allow(unused_function)]
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


    #[test, allow(unused_mut_ref)]
    fun test_something() {
        let scenario_val = init_test_helper();
        //let scenario = &mut scenario_val;        
       
        ts::end(scenario_val);
    }
}