#!/bin/bash
for ((i=1; i<=103; i++)); do 
    python cold_pvm_handler_22hours_parallel.py $i >> cold_cluster_$i.log &
  done
