set terminal svg size 1200,800
set output 'encrypt_plot.svg'

set multiplot layout 1,2
set bmargin at screen 0.3
set xlabel "Input Size (Megabyte)" font ",16"
set ylabel "Throughput (Megabyte/Second)" font ",16"
set xtics font ",15"
set ytics font ",15"
set key outside bottom center maxrows 7 font ",16"

set xrange [0:0.01]
set yrange [0:4500]

plot 'results/encrypt_OpenSSL chacha20.txt' using 2:1 with linespoints title 'OpenSSL chacha20', \
'results/encrypt_RustCrypto chacha20.txt' using 2:1 with linespoints title 'RustCrypto chacha20', \
'results/encrypt_RustCrypto xchacha20.txt' using 2:1 with linespoints title 'RustCrypto xchacha20', \
'results/encrypt_RustCrypto salsa20.txt' using 2:1 with linespoints title 'RustCrypto salsa20', \
'results/encrypt_RustCrypto rabbit.txt' using 2:1 with linespoints title 'RustCrypto rabbit', \
'results/encrypt_OpenSSL aes256-cbc.txt' using 2:1 with linespoints title 'OpenSSL aes256-cbc', \
'results/encrypt_OpenSSL aes256-ctr.txt' using 2:1 with linespoints title 'OpenSSL aes256-ctr', \
'results/encrypt_OpenSSL camellia256-cbc.txt' using 2:1 with linespoints title 'OpenSSL camellia256-cbc', \
'results/encrypt_OpenSSL chacha20poly1305.txt' using 2:1 with linespoints title 'OpenSSL chacha20poly1305', \
'results/encrypt_RustCrypto chacha20poly1305.txt' using 2:1 with linespoints title 'RustCrypto chacha20poly1305', \
'results/encrypt_RustCrypto xchacha20poly1305.txt' using 2:1 with linespoints title 'RustCrypto xchacha20poly1305', \
'results/encrypt_OpenSSL aes256-gcm.txt' using 2:1 with linespoints title 'OpenSSL aes256-gcm', \
'results/encrypt_RustCrypto ascon128.txt' using 2:1 with linespoints title 'RustCrypto ascon128'

unset key
set xrange [1:1050]
set xtics add ("1" 1)

plot 'results/encrypt_OpenSSL chacha20.txt' using 2:1 with linespoints title 'OpenSSL chacha20', \
'results/encrypt_RustCrypto chacha20.txt' using 2:1 with linespoints title 'RustCrypto chacha20', \
'results/encrypt_RustCrypto xchacha20.txt' using 2:1 with linespoints title 'RustCrypto xchacha20', \
'results/encrypt_RustCrypto salsa20.txt' using 2:1 with linespoints title 'RustCrypto salsa20', \
'results/encrypt_RustCrypto rabbit.txt' using 2:1 with linespoints title 'RustCrypto rabbit', \
'results/encrypt_OpenSSL aes256-cbc.txt' using 2:1 with linespoints title 'OpenSSL aes256-cbc', \
'results/encrypt_OpenSSL aes256-ctr.txt' using 2:1 with linespoints title 'OpenSSL aes256-ctr', \
'results/encrypt_OpenSSL camellia256-cbc.txt' using 2:1 with linespoints title 'OpenSSL camellia256-cbc', \
'results/encrypt_OpenSSL chacha20poly1305.txt' using 2:1 with linespoints title 'OpenSSL chacha20poly1305', \
'results/encrypt_RustCrypto chacha20poly1305.txt' using 2:1 with linespoints title 'RustCrypto chacha20poly1305', \
'results/encrypt_RustCrypto xchacha20poly1305.txt' using 2:1 with linespoints title 'RustCrypto xchacha20poly1305', \
'results/encrypt_OpenSSL aes256-gcm.txt' using 2:1 with linespoints title 'OpenSSL aes256-gcm', \
'results/encrypt_RustCrypto ascon128.txt' using 2:1 with linespoints title 'RustCrypto ascon128'

unset multiplot

set terminal svg size 1200,800
set output 'decrypt_plot.svg'

set multiplot layout 1,2
set bmargin at screen 0.3
set xlabel "Input Size (Megabyte)" font ",16"
set ylabel "Throughput (Megabyte/Second)" font ",16"
set xtics font ",15"
set ytics font ",15"
set key outside bottom center maxrows 7 font ",16"

set xrange [0:0.01]
set yrange [0:4500]

plot 'results/decrypt_OpenSSL chacha20.txt' using 2:1 with linespoints title 'OpenSSL chacha20', \
'results/decrypt_RustCrypto chacha20.txt' using 2:1 with linespoints title 'RustCrypto chacha20', \
'results/decrypt_RustCrypto xchacha20.txt' using 2:1 with linespoints title 'RustCrypto xchacha20', \
'results/decrypt_RustCrypto salsa20.txt' using 2:1 with linespoints title 'RustCrypto salsa20', \
'results/decrypt_RustCrypto rabbit.txt' using 2:1 with linespoints title 'RustCrypto rabbit', \
'results/decrypt_OpenSSL aes256-cbc.txt' using 2:1 with linespoints title 'OpenSSL aes256-cbc', \
'results/decrypt_OpenSSL aes256-ctr.txt' using 2:1 with linespoints title 'OpenSSL aes256-ctr', \
'results/decrypt_OpenSSL camellia256-cbc.txt' using 2:1 with linespoints title 'OpenSSL camellia256-cbc', \
'results/decrypt_OpenSSL chacha20poly1305.txt' using 2:1 with linespoints title 'OpenSSL chacha20poly1305', \
'results/decrypt_RustCrypto chacha20poly1305.txt' using 2:1 with linespoints title 'RustCrypto chacha20poly1305', \
'results/decrypt_RustCrypto xchacha20poly1305.txt' using 2:1 with linespoints title 'RustCrypto xchacha20poly1305', \
'results/decrypt_OpenSSL aes256-gcm.txt' using 2:1 with linespoints title 'OpenSSL aes256-gcm', \
'results/decrypt_RustCrypto ascon128.txt' using 2:1 with linespoints title 'RustCrypto ascon128'

unset key
set xrange [1:1050]
set xtics add ("1" 1)

plot 'results/decrypt_OpenSSL chacha20.txt' using 2:1 with linespoints title 'OpenSSL chacha20', \
'results/decrypt_RustCrypto chacha20.txt' using 2:1 with linespoints title 'RustCrypto chacha20', \
'results/decrypt_RustCrypto xchacha20.txt' using 2:1 with linespoints title 'RustCrypto xchacha20', \
'results/decrypt_RustCrypto salsa20.txt' using 2:1 with linespoints title 'RustCrypto salsa20', \
'results/decrypt_RustCrypto rabbit.txt' using 2:1 with linespoints title 'RustCrypto rabbit', \
'results/decrypt_OpenSSL aes256-cbc.txt' using 2:1 with linespoints title 'OpenSSL aes256-cbc', \
'results/decrypt_OpenSSL aes256-ctr.txt' using 2:1 with linespoints title 'OpenSSL aes256-ctr', \
'results/decrypt_OpenSSL camellia256-cbc.txt' using 2:1 with linespoints title 'OpenSSL camellia256-cbc', \
'results/decrypt_OpenSSL chacha20poly1305.txt' using 2:1 with linespoints title 'OpenSSL chacha20poly1305', \
'results/decrypt_RustCrypto chacha20poly1305.txt' using 2:1 with linespoints title 'RustCrypto chacha20poly1305', \
'results/decrypt_RustCrypto xchacha20poly1305.txt' using 2:1 with linespoints title 'RustCrypto xchacha20poly1305', \
'results/decrypt_OpenSSL aes256-gcm.txt' using 2:1 with linespoints title 'OpenSSL aes256-gcm', \
'results/decrypt_RustCrypto ascon128.txt' using 2:1 with linespoints title 'RustCrypto ascon128'
