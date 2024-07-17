use ascon_aead::{Ascon128, aead::AeadInPlace};
use cipher::KeyInit;
use criterion::*;
use rand::RngCore;
use openssl::symm::{encrypt, Cipher, encrypt_aead, decrypt, decrypt_aead};

fn bench_decrypt(c: &mut Criterion, name: &str, size: usize) {
    let mut rand     = black_box(rand::rngs::OsRng {});
    let mut key      = [0u8; 32];
    rand.fill_bytes(&mut key);
    let mut key128   = [0u8; 16];
    rand.fill_bytes(&mut key128);
    let mut iv       = [0u8; 16];
    rand.fill_bytes(&mut iv);
    let mut nonce96  = [0u8; 12];
    rand.fill_bytes(&mut nonce96);
    let mut nonce128 = [0u8; 16];
    rand.fill_bytes(&mut nonce128);
    let ad           = [0u8; 32];
    let mut tag128   = [0u8; 16];


    let mut group  = c.benchmark_group(name);
    let mut input  = black_box(vec![0u8; size]);
    group.throughput(Throughput::Bytes(input.len() as u64));
    
    let chacha20     = Cipher::chacha20();
    let aes_cbc      = Cipher::aes_256_cbc();
    let aes_ctr      = Cipher::aes_256_ctr();
    let camellia_cbc = Cipher::camellia_256_cbc();
    let chacha20poly = Cipher::chacha20_poly1305();
    let aes_gcm      = Cipher::aes_256_gcm();
    let ascon        = Ascon128::new(ascon_aead::Key::<Ascon128>::from_slice(key128.as_slice()));

    let r = encrypt(chacha20, &key, Some(&iv), &input).unwrap();
    group.bench_function("OpenSSL chacha20", |b| {
        b.iter(|| {
            let _r = decrypt(chacha20, &key, Some(&iv), &r).unwrap();
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

    let r = encrypt_aead(aes_gcm, &key, Some(&nonce96), &ad, &input, &mut tag128).unwrap();
    group.bench_function("OpenSSL aes256-gcm", |b| {
        b.iter(|| {
            let _r = decrypt_aead(aes_gcm, &key, Some(&nonce96), &ad, &r, &tag128).unwrap();
        })
    });

    let tag = ascon.encrypt_in_place_detached(nonce128.as_ref().into(), &ad, &mut input).unwrap();
    group.bench_function("RustCrypto ascon128", |b| {
        b.iter(|| {
            ascon.decrypt_in_place_detached(nonce128.as_ref().into(), &ad, &mut input, &tag)
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
    let mut nonce96  = [0u8; 12];
    rand.fill_bytes(&mut nonce96);
    let mut nonce128 = [0u8; 16];
    rand.fill_bytes(&mut nonce128);
    let ad           = [0u8; 32];
    let mut tag128   = [0u8; 16];


    let mut group  = c.benchmark_group(name);
    let mut input  = black_box(vec![0u8; size]);
    group.throughput(Throughput::Bytes(input.len() as u64));
    
    let chacha20     = Cipher::chacha20();
    let aes_cbc      = Cipher::aes_256_cbc();
    let aes_ctr      = Cipher::aes_256_ctr();
    let camellia_cbc = Cipher::camellia_256_cbc();
    let chacha20poly = Cipher::chacha20_poly1305();
    let aes_gcm      = Cipher::aes_256_gcm();
    let ascon        = Ascon128::new(ascon_aead::Key::<Ascon128>::from_slice(key128.as_slice()));

    group.bench_function("OpenSSL chacha20", |b| {
        b.iter(|| {
            let _r = encrypt(chacha20, &key, Some(&iv), &input).unwrap();
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
    bench_encrypt(c, "Encrypt 1MB", 1_000_000);
    bench_encrypt(c, "Encrypt 100MB", 100_000_000);
    bench_decrypt(c, "Decrypt 100B", 100);
    bench_decrypt(c, "Decrypt 1MB", 1_000_000);
    bench_decrypt(c, "Decrypt 100MB", 100_000_000);
}

criterion_group!(benches, bench);
criterion_main!(benches);
