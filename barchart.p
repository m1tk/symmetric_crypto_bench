set terminal svg size 1200,800 enhanced font ",16"
set style data histogram
set style histogram clustered
set style fill solid border rgb "black"


# Remove top and right borders and tics
set border 3
set tics nomirror

set output 'encrypt_barchart.svg'
set ylabel "Throughput (Megabyte/Second)"
set xlabel "Input Size (Megabyte)\n" offset 0,1
set xtics rotate by -45
set key outside bottom center horizontal maxrows 2

plot for [i=1:5] 'results/encrypt_data.dat' using i:xtic(1) title columnheader

set output 'decrypt_barchart.svg'
set ylabel "Throughput (Megabyte/Second)"

plot for [i=1:5] 'results/decrypt_data.dat' using i:xtic(1) title columnheader
