#!/bin/bash
for ((i=1; i<=103; i++)); do 
    python health_test_v3_parallel.py $i &
  done
