#!/bin/bash

main() {
s=""
for ((i=1;i<=10;i++)); do
  s+=http://35.190.22.73:80/hotcluster/$i/match_progressive,
done
s=${s%?};
echo "--------------THIS IS FOR HOTCLUSTER-----------------"
echo $s;
echo "-----------------------------------------------------"

t=""
for ((i=1;i<=50;i++)); do
  t+=http://35.190.22.73:80/coldcluster/$i/match_progressive,
done
t=${t%?};
echo "--------------THIS IS FOR COLDCLUSTER-1-----------------"
echo $t;
echo "------------------------------------------------------"
echo "======================================================"
u=""
for ((i=51;i<=100;i++)); do
  u+=http://35.244.147.101:80/coldcluster/$i/match_progressive,
done
u=${u%?};
echo "--------------THIS IS FOR COLDCLUSTER-2-----------------"
echo $u;
echo "========================================================"
v=""
for ((i=101;i<=103;i++)); do
  v+=http://35.201.104.120:80/coldcluster/$i/match_progressive,
done
v=${v%?};
echo "--------------THIS IS FOR COLDCLUSTER-3-----------------"
echo $v;
echo "========================================================"
}

main
