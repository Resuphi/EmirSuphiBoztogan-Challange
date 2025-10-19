// move/sources/arena.move

module challenge::arena;

// DÜZELTİLDİ: Gereksiz 'use' bildirimleri kaldırıldı (Uyarılar giderildi).
// Sadece projenizin kendi modüllerini ve event'i açıkça 'use' etmeniz yeterli.
use sui::object::{ID, UID};
use sui::tx_context::TxContext;
use challenge::hero::{Self, Hero};
use sui::event;


// ========= STRUCTS =========

public struct Arena has key, store {
    id: UID,
    warrior: Hero,
    owner: address,
}

// ========= EVENTS =========

public struct ArenaCreated has copy, drop {
    arena_id: ID,
    timestamp: u64,
}

public struct ArenaCompleted has copy, drop {
    winner_hero_id: ID,
    loser_hero_id: ID,
    timestamp: u64,
}

// ========= FUNCTIONS =========

public fun create_arena(hero: Hero, ctx: &mut TxContext) {
    let arena = Arena {
        id: object::new(ctx),
        warrior: hero,
        owner: ctx.sender()
    };

    event::emit(ArenaCreated {
        arena_id: object::id(&arena),
        timestamp: tx_context::epoch_timestamp_ms(ctx) // 'ctx.' yerine 'tx_context::'
    });

    transfer::share_object(arena);
}

#[allow(lint(self_transfer))]
public fun battle(hero: Hero, arena: Arena, ctx: &mut TxContext) {
    let Arena { id, warrior, owner } = arena;

    if (hero::hero_power(&hero) > hero::hero_power(&warrior)) {
        
        // DÜZELTİLDİ: ID'ler, objeler transfer edilmeden ÖNCE alındı.
        let winner_id = object::id(&hero);
        let loser_id = object::id(&warrior);

        // Şimdi objeleri güvenle transfer edebiliriz.
        transfer::public_transfer(warrior, ctx.sender());
        transfer::public_transfer(hero, ctx.sender());

        // Event'i, kopyaladığımız ID'leri kullanarak yayınlıyoruz.
        event::emit(ArenaCompleted {
            winner_hero_id: winner_id,
            loser_hero_id: loser_id,
            timestamp: tx_context::epoch_timestamp_ms(ctx)
        });
    } else {
        
        // DÜZELTİLDİ: ID'ler, objeler transfer edilmeden ÖNCE alındı.
        let winner_id = object::id(&warrior);
        let loser_id = object::id(&hero);

        // Şimdi objeleri güvenle transfer edebiliriz.
        transfer::public_transfer(warrior, owner);
        transfer::public_transfer(hero, owner);

        // Event'i, kopyaladığımız ID'leri kullanarak yayınlıyoruz.
        event::emit(ArenaCompleted {
            winner_hero_id: winner_id,
            loser_hero_id: loser_id,
            timestamp: tx_context::epoch_timestamp_ms(ctx)
        });
    };

    object::delete(id);
}