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
for ((i=1;i<=100;i++)); do
  t+=http://35.190.22.73:80/coldcluster/$i/match_progressive,
done
t=${t%?};
echo "--------------THIS IS FOR COLDCLUSTER-----------------"
echo $t;
echo "------------------------------------------------------"

}

main
