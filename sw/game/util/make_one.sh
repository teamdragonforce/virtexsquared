gcc -o $1 -include $1.c build_res.c -DIMG=$1_img && ./$1 > $1.res && rm $1
