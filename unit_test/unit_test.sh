#!/bin/bash

zlib_hash='2c183c9f93a328bfb3121284da13cf89a0f7e64a'

if [ -d zlib ]; then
    echo "skip git clone" 1>&2
else
    git clone https://chromium.googlesource.com/chromium/src/third_party/zlib
    (cd zlib/ && git checkout $zlib_hash)
fi

if [ -d out_cloc ]; then
    echo "rm -rf ./out_cloc" 1>&2
    rm -rf ./out_cloc
fi
mkdir ./out_cloc
(cd zlib && cloc --quiet .) | tail +3 > out_cloc/zlib
(cd zlib && for i in ./*; do if [ -d $i ]; then cloc --quiet $i | tail +3 ;fi  ; done)  > out_cloc/zlib_dir
(cd zlib && for i in ./*; do if [ -d $i ]; then cloc --quiet --csv $i | tail +3 ;fi ; done)  > out_cloc/zlib_dircsv
(cd zlib && cloc --quiet --csv ./google) | tail +3 > out_cloc/zlib_google_csv
(cd zlib && for i in ./google/*; do if [ -d $i ]; then cloc --quiet --csv $i | tail +3 ;fi  ; done)  > out_cloc/zlib_google_dircsv

if [ -d out_git_cloc ]; then
    echo "rm -rf ./out_git_cloc" 1>&2
    rm -rf ./out_git_cloc
fi
mkdir ./out_git_cloc
(cd zlib && ../../git_cloc $zlib_hash .) > out_git_cloc/zlib
(cd zlib && ../../git_cloc --dir  $zlib_hash ./) > out_git_cloc/zlib_dir
(cd zlib && ../../git_cloc --dir --csv  $zlib_hash ./././) > out_git_cloc/zlib_dircsv
(cd zlib && ../../git_cloc --csv  $zlib_hash ./google) > out_git_cloc/zlib_google_csv
(cd zlib && ../../git_cloc --dir --csv  $zlib_hash ./google/././) > out_git_cloc/zlib_google_dircsv

for i in `ls out_cloc`; do
    echo "======================================================"
    echo ">>> diff out_cloc/$i out_git_cloc/$i" 
    echo ">>> if there are no difference of counting, it is OK"
    echo "======================================================"
    if [ `echo $i | grep -v 'csv'` ]; then
        diff -y out_cloc/$i out_git_cloc/$i
    else
        cat out_git_cloc/$i | awk -F "," '{ print $2 "," $3 "," $4 "," $5 "," $6 }' | \
        diff -y out_cloc/$i -
    fi
done
