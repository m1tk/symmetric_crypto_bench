use std::ffi::c_uchar;


extern "C" {
    pub fn encrypt(
        input: *mut c_uchar,
        key: *const c_uchar,
    );
    pub fn decrypt(
        input: *mut c_uchar,
        key: *const c_uchar,
    );
}

#[cfg(test)]
mod tests {
    pub use super::*;
    use rand::RngCore;

    #[test]
    fn gift() {
        let mut rand = rand::rngs::OsRng {};
        let mut text = [0; 32];
        text[..5].copy_from_slice(b"Hello");
        let mut key  = [0; 32];
        rand.fill_bytes(&mut key);

        unsafe {
            encrypt(text.as_mut_ptr(), &key as *const c_uchar);
            decrypt(text.as_mut_ptr(), &key as *const c_uchar);
        }
    }
}
