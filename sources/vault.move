module vault::Vault {
    use std::signer;
    use vault::BasicCoin;

    const ModuleAddr: address = @vault;

    /// Error codes
    const ENOT_MODULE_OWNER: u64 = 0;
    const MODULE_PAUSED: u64 = 1;


    struct State has key, store {
        is_paused: bool
    }

    public entry fun create_pool<CoinType: drop>(owner: &signer) {
        assert!(signer::address_of(owner) == ModuleAddr, ENOT_MODULE_OWNER);
        BasicCoin::publish_balance<CoinType>(owner);
    }

    // deposit token
    public entry fun deposit<CoinType: drop> (account: &signer, amount: u64, witness: CoinType) acquires State {
        let is_paused = get_state();
        assert!(is_paused == false, MODULE_PAUSED);
        BasicCoin::transfer<CoinType>(account, ModuleAddr, amount, witness);
        BasicCoin::mint<CoinType>(signer::address_of(account), amount);
    } 

    // withdraw token
    public entry fun withdraw<CoinType: drop> (account: &signer, owner: &signer, amount: u64, witness: CoinType) acquires State{
        let is_paused = get_state();
        assert!(is_paused == false, MODULE_PAUSED);
        BasicCoin::transfer<CoinType>(owner, signer::address_of(account), amount, witness);
        BasicCoin::burn<CoinType>(signer::address_of(account), amount);
    }

    // get balance of coin
    public fun balance_of<CoinType: drop>(owner: address): u64{
        BasicCoin::balance_of<CoinType>(owner)
    }

    // init function. 
    public entry fun init(module_owner: &signer) {
        assert!(signer::address_of(module_owner) == ModuleAddr, ENOT_MODULE_OWNER);
        move_to(module_owner, State { is_paused : false});
    }

    public fun get_state(): bool acquires State {
        borrow_global<State>(ModuleAddr).is_paused
    }

    // pause smart contract
    public entry fun pause(module_owner: &signer) acquires State{
        assert!(signer::address_of(module_owner) == ModuleAddr, ENOT_MODULE_OWNER);
        let is_current_paused = borrow_global_mut<State>(ModuleAddr);
        is_current_paused.is_paused = true;
    }

    // unpause smart contract
    public entry fun unpause(module_owner: &signer) acquires State {
        assert!(signer::address_of(module_owner) == ModuleAddr, ENOT_MODULE_OWNER);
        let is_current_paused = borrow_global_mut<State>(ModuleAddr);
        is_current_paused.is_paused = false;
    }





}