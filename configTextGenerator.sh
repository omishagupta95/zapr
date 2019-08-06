  c=""
  for ((i=1;i<=93;i++)); do
    c+=http://35.190.22.73:80/coldcluster/$i/match_progressive,
  done
  c=${c%?}; 
  echo $c;

  h=""
  for ((i=1;i<=11;i++)); do
    h+=http://35.190.22.73:80/hotcluster/$i/match_progressive,
  done
  h=${h%?}; 
  echo $h;
