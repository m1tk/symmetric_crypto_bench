extern crate cc;

fn main() {
    cc::Build::new()
        .file("src/gift.cpp")
        .compile("gift.a");
}
