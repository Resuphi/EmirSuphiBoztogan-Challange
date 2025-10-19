// move/sources/marketplace.move

module challenge::marketplace;

// GEREKLİ 'USE' BİLDİRİMLERİ (MİNİMAL)
// Sui, 'object', 'transfer', 'event', 'coin' ve 'tx_context'
// modüllerini otomatik olarak import eder.
// Sadece kendi modüllerimizi ve spesifik TİPLERİ 'use' etmemiz yeterlidir.

use challenge::hero::Hero;
use sui::sui::SUI;
use sui::coin::Coin;
use sui::object::{ID, UID};
use sui::tx_context::TxContext;

// ========= ERRORS =========

const EInvalidPayment: u64 = 1;

// ========= STRUCTS =========

public struct ListHero has key, store {
    id: UID,
    nft: Hero,
    price: u64,
    seller: address,
}

// ========= CAPABILITIES =========

public struct AdminCap has key, store {
    id: UID,
}

// ========= EVENTS =========

public struct HeroListed has copy, drop {
    list_hero_id: ID,
    price: u64,
    seller: address,
    timestamp: u64,
}

public struct HeroBought has copy, drop {
    list_hero_id: ID,
    price: u64,
    buyer: address,
    seller: address,
    timestamp: u64,
}

// ========= FUNCTIONS =========

fun init(ctx: &mut TxContext) {
    let admin_cap = AdminCap {
        id: object::new(ctx)
    };
    transfer::public_transfer(admin_cap, ctx.sender());
}

public fun list_hero(nft: Hero, price: u64, ctx: &mut TxContext) {
    let list_hero = ListHero {
        id: object::new(ctx),
        nft: nft, // 'nft' burada tüketildi
        price: price,
        seller: ctx.sender()
    };

    event::emit(HeroListed {
        list_hero_id: object::id(&list_hero), 
        price: price,
        seller: ctx.sender(),
        timestamp: tx_context::epoch_timestamp_ms(ctx)
    });

    transfer::share_object(list_hero);
}

#[allow(lint(self_transfer))]
public fun buy_hero(list_hero: ListHero, coin: Coin<SUI>, ctx: &mut TxContext) {
    // 'list_hero' objesi burada parçalanarak tüketiliyor.
    let ListHero { id, nft, price, seller } = list_hero;

    assert!(coin::value(&coin) == price, EInvalidPayment);

    // 'coin' objesi burada transfer edilerek tüketiliyor.
    transfer::public_transfer(coin, seller);

    // 'nft' objesi burada transfer edilerek tüketiliyor.
    transfer::public_transfer(nft, ctx.sender());

    event::emit(HeroBought {
        listing_id: object::uid_to_inner(&id),
        price: price,
        buyer: ctx.sender(),
        seller: seller,
        timestamp: tx_context::epoch_timestamp_ms(ctx)
    });

    // 'id' objesi burada silinerek tüketiliyor.
    object::delete(id);
}

// ========= ADMIN FUNCTIONS =========

public fun delist(_: &AdminCap, list_hero: ListHero) {
    // 'list_hero' objesi burada parçalanarak tüketiliyor.
    let ListHero { id, nft, price: _, seller } = list_hero;

    // 'nft' objesi burada transfer edilerek tüketiliyor.
    transfer::public_transfer(nft, seller);

    // 'id' objesi burada silinerek tüketiliyor.
    object::delete(id);
}

public fun change_the_price(_: &AdminCap, list_hero: &mut ListHero, new_price: u64) {
    list_hero.price = new_price;
}

// ========= GETTER FUNCTIONS =========

#[test_only]
public fun listing_price(list_hero: &ListHero): u64 {
    list_hero.price
}

// ========= TEST ONLY FUNCTIONS =========

#[test_only]
public fun test_init(ctx: &mut TxContext) {
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };
    transfer::transfer(admin_cap, ctx.sender());
}