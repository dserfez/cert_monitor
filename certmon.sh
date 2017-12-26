#!/bin/bash

: "${DAYS:=45}"

: "${URL_FILE:=urllist.txt}"

docker run --rm -ti \
    -v $(pwd):/tmp/urls \
    cert_monitor /tmp/urls/urllist.txt ${DAYS}

#echo "Certificates which will expire within ${DAYS} days"
#cat urllist.txt.out