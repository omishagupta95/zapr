#!/bin/bash
set -x
  gcloud compute url-maps remove-path-matcher cold-http-lb --path-matcher-name path-matcher-1 -q
  s=""
  for ((i=1;i<=50;i++)); do
    s+=/coldcluster/$i/*=cold-backend-$i,
  done
  s=${s%?}; // To remove the last comma
  gcloud compute url-maps add-path-matcher cold-http-lb --default-service cold-backend-1 --path-matcher-name path-matcher-1 --path-rules $s --new-hosts "*" --delete-orphane
d-path-matcher
  gcloud compute url-maps remove-path-matcher cold-http-lb-2 --path-matcher-name path-matcher-1 -q
  t=""
  for ((i=51;i<=100;i++)); do
    t+=/coldcluster/$i/*=cold-backend-$i,
  done
  t=${t%?}; // To remove the last comma
  gcloud compute url-maps add-path-matcher cold-http-lb-2 --default-service cold-backend-51 --path-matcher-name path-matcher-1 --path-rules $t --new-hosts "*" --delete-orph
aned-path-matcher
  gcloud compute url-maps remove-path-matcher cold-http-lb-3 --path-matcher-name path-matcher-1 -q
  u=""
  for ((i=101;i<=103;i++)); do
    u+=/coldcluster/$i/*=cold-backend-$i,
  done
  u=${u%?}; // To remove the last comma
  gcloud compute url-maps add-path-matcher cold-http-lb-3 --default-service cold-backend-101 --path-matcher-name path-matcher-1 --path-rules $u --new-hosts "*" --delete-orp
haned-path-matcher
