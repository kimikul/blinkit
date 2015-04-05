#!/bin/sh

i=6190
max=6192

h1="X-Parse-Application-Id:QXBNXOh5TYU1oUc6rYMPqG5XNct5zZdjhlbQLrhQ"
h2="X-Parse-REST-API-Key:eFt3WQZryc41RDTSEeT2abtZr1o1QPjeKJwN3EqC"
h3="Content-Type:application/json"

while [ $i -lt $max ]; do
  sleep 2
  d="{\"skip\":"$i"}"
  raw="$(curl -X POST -H $h1 -H $h2 -H $h3 -d $d https://api.parse.com/1/functions/parseSearchTermsForBlinks)"
  let i=i+9
done


