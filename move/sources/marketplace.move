// move/sources/marketplace.move

module challenge::marketplace;

// GEREKLİ 'USE' BİLDİRİMLERİ EKLENDİ
use sui::object::{Self, ID, UID};
use sui::transfer;
use sui::tx_context::{Self, TxContext};
use challenge::hero::Hero;
use sui::coin::{Self, Coin};
use sui::event;
use sui::sui::SUI;
use sui::event;
use sui::coin;
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
    // TODO: Initialize the module by creating AdminCap
    let admin_cap = AdminCap {
        id: object::new(ctx) // Hint: Create AdminCap id
    };

    // TODO: Transfer it to the module publisher (ctx.sender()) using transfer::public_transfer() function
    transfer::public_transfer(admin_cap, ctx.sender());
}

public fun list_hero(nft: Hero, price: u64, ctx: &mut TxContext) {

    // TODO: Create a list_hero object for marketplace
    // DÜZELTME: 'nft' objesi, yeni 'ListHero' struct'ının içine taşınıyor.
    // 'nft', 'price' ve 'ctx' parametreleri artık kullanılıyor.
    let list_hero = ListHero {
        id: object::new(ctx),     // Hint: Use object::new(ctx)
        nft: nft,                 // 'nft' burada tüketildi
        price: price,
        seller: ctx.sender()      // Hint: Set seller
    };

    // TODO: Emit HeroListed event with listing details (Don't forget to use object::id(&list_hero) )
    // DÜZELTME: Gerekli event'i yayınlıyoruz
    event::emit(HeroListed {
        list_hero_id: object::id(&list_hero), 
        price: price,
        seller: ctx.sender(),
        timestamp: tx_context::epoch_timestamp_ms(ctx) // timestamp'i de ekleyelim
    });

    // TODO: Use transfer::share_object() to make it publicly tradeable
    // DÜZELTME: Yeni oluşturulan 'list_hero' objesini paylaşıyoruz.
    transfer::share_object(list_hero);
}

#[allow(lint(self_transfer))]

public fun buy_hero(list_hero: ListHero, coin: Coin<SUI>, ctx: &mut TxContext) {

    // TODO: Destructure list_hero to get id, nft, price, and seller
    // DÜZELTME: 'list_hero' objesi burada parçalanarak tüketiliyor.
    let ListHero { id, nft, price, seller } = list_hero;

    // TODO: Use assert! to verify coin value equals listing price
    assert!(coin::value(&coin) == price, EInvalidPayment);

    // TODO: Transfer coin to seller
    // DÜZELTME: 'coin' objesi burada transfer edilerek tüketiliyor.
    transfer::public_transfer(coin, seller);

    // TODO: Transfer hero NFT to buyer (ctx.sender())
    // DÜZELTME: 'nft' objesi burada transfer edilerek tüketiliyor.
    transfer::public_transfer(nft, ctx.sender());

    // TODO: Emit HeroBought event with transaction details
    event::emit(HeroBought {
        listing_id: object::uid_to_inner(&id),
        price: price,
        buyer: ctx.sender(),
        seller: seller,
        timestamp: tx_context::epoch_timestamp_ms(ctx)
    });

    // TODO: Delete the listing ID (object::delete(id))
    // DÜZELTME: 'id' objesi burada silinerek tüketiliyor.
    object::delete(id);
}

// ========= ADMIN FUNCTIONS =========

public fun delist(_: &AdminCap, list_hero: ListHero) {

    // NOTE: The AdminCap parameter ensures only admin can call this
    
    // TODO: Implement admin delist functionality
    // Hint: Destructure list_hero (ignore price with "price: _")
    // DÜZELTME: 'list_hero' objesini burada parçalayarak tüketiyoruz.
    let ListHero { id, nft, price: _, seller } = list_hero;

    // TODO:Transfer NFT back to original seller
    // DÜZELTME: 'nft' objesini burada transfer ederek tüketiyoruz.
    transfer::public_transfer(nft, seller);

    // TODO:Delete the listing ID (object::delete(id))
    // DÜZELTME: 'id' objesini burada silerek tüketiyoruz.
    object::delete(id);
}

public fun change_the_price(_: &AdminCap, list_hero: &mut ListHero, new_price: u64) {
    // TODO: Update the listing price
    // Hint: Access the price field of list_hero and update it
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