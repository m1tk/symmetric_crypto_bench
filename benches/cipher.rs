use ascon_aead::{Ascon128, aead::AeadInPlace};
use chacha20::cipher::{KeyIvInit, StreamCipher, StreamCipherSeek};
use cipher::KeyInit;
use criterion::*;
use rand::RngCore;
use openssl::symm::{encrypt, Cipher, encrypt_aead, decrypt, decrypt_aead};
use chacha20poly1305::aead::Aead;



fn bench_decrypt(c: &mut Criterion, name: &str, size: usize) {
    let mut rand     = black_box(rand::rngs::OsRng {});
    let mut key      = [0u8; 32];
    rand.fill_bytes(&mut key);
    let mut key128   = [0u8; 16];
    rand.fill_bytes(&mut key128);
    let mut iv       = [0u8; 16];
    rand.fill_bytes(&mut iv);
    let mut nonce64  = [0u8; 8];
    rand.fill_bytes(&mut nonce64);
    let mut nonce96  = [0u8; 12];
    rand.fill_bytes(&mut nonce96);
    let mut nonce128 = [0u8; 16];
    rand.fill_bytes(&mut nonce128);
    let mut nonce192 = [0u8; 24];
    rand.fill_bytes(&mut nonce192);
    let ad           = [0u8; 32];
    let mut tag128   = [0u8; 16];


    let mut group  = c.benchmark_group(name);
    let mut input  = black_box(vec![0u8; size]);
    group.throughput(Throughput::Bytes(input.len() as u64));
    
    let chacha20      = Cipher::chacha20();
    let mut rchacha20 = chacha20::ChaCha20::new(&key.into(), &nonce96.into());
    let mut xchacha20 = chacha20::XChaCha20::new(&key.into(), &nonce192.into());
    let mut salsa20   = salsa20::Salsa20::new(&key.into(), &nonce64.into());
    let mut rabbit    = rabbit::Rabbit::new(&key128.into(), &nonce64.into());
    let aes_cbc       = Cipher::aes_256_cbc();
    let aes_ctr       = Cipher::aes_256_ctr();
    let camellia_cbc  = Cipher::camellia_256_cbc();
    let chacha20poly  = Cipher::chacha20_poly1305();
    let rchacha20poly = chacha20poly1305::ChaCha20Poly1305::new(&key.into());
    let xchacha20poly = chacha20poly1305::XChaCha20Poly1305::new(&key.into());
    let aes_gcm       = Cipher::aes_256_gcm();
    let ascon         = Ascon128::new(ascon_aead::Key::<Ascon128>::from_slice(key128.as_slice()));

    let r = encrypt(chacha20, &key, Some(&iv), &input).unwrap();
    group.bench_function("OpenSSL chacha20", |b| {
        b.iter(|| {
            let _r = decrypt(chacha20, &key, Some(&iv), &r).unwrap();
        })
    });

    let mut r = input.clone();
    rchacha20.apply_keystream(&mut r);
    group.bench_function("RustCrypto chacha20", |b| {
        b.iter(|| {
            // It doesn't matter if we are decrypting wrong thing we just want to measure speed
            rchacha20.seek(0u32);
            rchacha20.apply_keystream(&mut r);
        })
    });

    let mut r = input.clone();
    xchacha20.apply_keystream(&mut r);
    group.bench_function("RustCrypto xchacha20", |b| {
        b.iter(|| {
            // same
            xchacha20.seek(0u32);
            xchacha20.apply_keystream(&mut input);
        })
    });

    let mut r = input.clone();
    salsa20.apply_keystream(&mut r);
    group.bench_function("RustCrypto salsa20", |b| {
        b.iter(|| {
            // same
            salsa20.seek(0u32);
            salsa20.apply_keystream(&mut input);
        })
    });

    let mut r = input.clone();
    rabbit.apply_keystream(&mut r);
    group.bench_function("RustCrypto rabbit", |b| {
        b.iter(|| {
            // same
            rabbit.apply_keystream(&mut input);
        })
    });

    let r = encrypt(aes_cbc, &key, Some(&iv), &input).unwrap();
    group.bench_function("OpenSSL aes256-cbc", |b| {
        b.iter(|| {
            let _r = decrypt(aes_cbc, &key, Some(&iv), &r).unwrap();
        })
    });
    
    let r = encrypt(aes_ctr, &key, Some(&iv), &input).unwrap();
    group.bench_function("OpenSSL aes256-ctr", |b| {
        b.iter(|| {
            let _r = decrypt(aes_ctr, &key, Some(&iv), &r).unwrap();
        })
    });

    let r = encrypt(camellia_cbc, &key, Some(&iv), &input).unwrap();
    group.bench_function("OpenSSL camellia256-cbc", |b| {
        b.iter(|| {
            let _r = decrypt(camellia_cbc, &key, Some(&iv), &r).unwrap();
        })
    });

    let r = encrypt_aead(chacha20poly, &key, Some(&nonce96), &ad, &input, &mut tag128).unwrap();
    group.bench_function("OpenSSL chacha20poly1305", |b| {
        b.iter(|| {
            let _r = decrypt_aead(chacha20poly, &key, Some(&nonce96), &ad, &r, &tag128).unwrap();
        })
    });

    let r = rchacha20poly.encrypt(&nonce96.into(), input.as_ref()).unwrap();
    group.bench_function("RustCrypto chacha20poly1305", |b| {
        b.iter(|| {
            let _r = rchacha20poly.decrypt(&nonce96.into(), r.as_ref()).unwrap();
        })
    });

    let r = xchacha20poly.encrypt(&nonce192.into(), input.as_ref()).unwrap();
    group.bench_function("RustCrypto xchacha20poly1305", |b| {
        b.iter(|| {
            let _r = xchacha20poly.decrypt(&nonce192.into(), r.as_ref()).unwrap();
        })
    });

    let r = encrypt_aead(aes_gcm, &key, Some(&nonce96), &ad, &input, &mut tag128).unwrap();
    group.bench_function("OpenSSL aes256-gcm", |b| {
        b.iter(|| {
            let _r = decrypt_aead(aes_gcm, &key, Some(&nonce96), &ad, &r, &tag128).unwrap();
        })
    });

    let r = ascon.encrypt(nonce128.as_ref().into(), input.as_ref()).unwrap();
    group.bench_function("RustCrypto ascon128", |b| {
        b.iter(|| {
            let _r = ascon.decrypt(nonce128.as_ref().into(), r.as_ref()).unwrap();
        })
    });

    group.finish();
}

fn bench_encrypt(c: &mut Criterion, name: &str, size: usize) {
    let mut rand     = black_box(rand::rngs::OsRng {});
    let mut key      = [0u8; 32];
    rand.fill_bytes(&mut key);
    let mut key128   = [0u8; 16];
    rand.fill_bytes(&mut key128);
    let mut iv       = [0u8; 16];
    rand.fill_bytes(&mut iv);
    let mut nonce64  = [0u8; 8];
    rand.fill_bytes(&mut nonce64);
    let mut nonce96  = [0u8; 12];
    rand.fill_bytes(&mut nonce96);
    let mut nonce128 = [0u8; 16];
    rand.fill_bytes(&mut nonce128);
    let mut nonce192 = [0u8; 24];
    rand.fill_bytes(&mut nonce192);
    let ad           = [0u8; 32];
    let mut tag128   = [0u8; 16];


    let mut group  = c.benchmark_group(name);
    let mut input  = black_box(vec![0u8; size]);
    group.throughput(Throughput::Bytes(input.len() as u64));
    
    let chacha20      = Cipher::chacha20();
    let mut rchacha20 = chacha20::ChaCha20::new(&key.into(), &nonce96.into());
    let mut xchacha20 = chacha20::XChaCha20::new(&key.into(), &nonce192.into());
    let mut salsa20   = salsa20::Salsa20::new(&key.into(), &nonce64.into());
    let mut rabbit    = rabbit::Rabbit::new(&key128.into(), &nonce64.into());
    let aes_cbc       = Cipher::aes_256_cbc();
    let aes_ctr       = Cipher::aes_256_ctr();
    let camellia_cbc  = Cipher::camellia_256_cbc();
    let chacha20poly  = Cipher::chacha20_poly1305();
    let rchacha20poly = chacha20poly1305::ChaCha20Poly1305::new(&key.into());
    let xchacha20poly = chacha20poly1305::XChaCha20Poly1305::new(&key.into());
    let aes_gcm       = Cipher::aes_256_gcm();
    let ascon         = Ascon128::new(ascon_aead::Key::<Ascon128>::from_slice(key128.as_slice()));

    group.bench_function("OpenSSL chacha20", |b| {
        b.iter(|| {
            let _r = encrypt(chacha20, &key, Some(&iv), &input).unwrap();
        })
    });

    group.bench_function("RustCrypto chacha20", |b| {
        b.iter(|| {
            rchacha20.apply_keystream(&mut input);
        })
    });

    group.bench_function("RustCrypto xchacha20", |b| {
        b.iter(|| {
            xchacha20.apply_keystream(&mut input);
        })
    });

    group.bench_function("RustCrypto salsa20", |b| {
        b.iter(|| {
            salsa20.apply_keystream(&mut input);
        })
    });

    group.bench_function("RustCrypto rabbit", |b| {
        b.iter(|| {
            rabbit.apply_keystream(&mut input);
        })
    });

    group.bench_function("OpenSSL aes256-cbc", |b| {
        b.iter(|| {
            let _r = encrypt(aes_cbc, &key, Some(&iv), &input).unwrap();
        })
    });
    
    group.bench_function("OpenSSL aes256-ctr", |b| {
        b.iter(|| {
            let _r = encrypt(aes_ctr, &key, Some(&iv), &input).unwrap();
        })
    });

    group.bench_function("OpenSSL camellia256-cbc", |b| {
        b.iter(|| {
            let _r = encrypt(camellia_cbc, &key, Some(&iv), &input).unwrap();
        })
    });

    group.bench_function("OpenSSL chacha20poly1305", |b| {
        b.iter(|| {
            let _r = encrypt_aead(chacha20poly, &key, Some(&nonce96), &ad, &input, &mut tag128).unwrap();
        })
    });

    group.bench_function("RustCrypto chacha20poly1305", |b| {
        b.iter(|| {
            rchacha20poly.encrypt_in_place_detached(&nonce96.into(), b"aad", &mut input).unwrap();
        })
    });

    group.bench_function("RustCrypto xchacha20poly1305", |b| {
        b.iter(|| {
            xchacha20poly.encrypt_in_place_detached(&nonce192.into(), b"aad", &mut input).unwrap();
        })
    });

    group.bench_function("OpenSSL aes256-gcm", |b| {
        b.iter(|| {
            let _r = encrypt_aead(aes_gcm, &key, Some(&nonce96), &ad, &input, &mut tag128).unwrap();
        })
    });

    group.bench_function("RustCrypto ascon128", |b| {
        b.iter(|| {
            ascon.encrypt_in_place_detached(nonce128.as_ref().into(), &ad, &mut input)
        })
    });

    group.finish();
}

fn bench(c: &mut Criterion) {
    bench_encrypt(c, "Encrypt 100B", 100);
    bench_encrypt(c, "Encrypt 10KB", 10_240);
    bench_encrypt(c, "Encrypt 1MB", 1_048_576);
    bench_encrypt(c, "Encrypt 100MB", 104_857_600);
    bench_encrypt(c, "Encrypt 1GB", 1_073_741_824);
    
    bench_decrypt(c, "Decrypt 100B", 100);
    bench_decrypt(c, "Decrypt 10KB", 10_000);
    bench_decrypt(c, "Decrypt 1MB", 1_048_576);
    bench_decrypt(c, "Decrypt 100MB", 104_857_600);
    bench_decrypt(c, "Decrypt 1GB", 1_073_741_824);
}

criterion_group!(benches, bench);
criterion_main!(benches);
