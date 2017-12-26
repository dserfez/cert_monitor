#!/bin/bash

: "${DAYS:=112}"

write_urlfile() {
    echo "https://api.infobip.com" > urllist.txt
    echo "https://zap.grisia.com" >> urllist.txt
    echo "https://dev.infobip.com" >> urllist.txt
    echo "https://www.yahoo.com" >> urllist.txt
    echo "https://google.com" >> urllist.txt
    echo "%x[pwd]" >> urllist.txt
}

write_urlfile

docker run --rm -ti \
    -v $(pwd):/tmp/urls \
    cert_monitor /tmp/urls/urllist.txt ${DAYS}

#echo "Certificates which will expire within ${DAYS} days"
#cat urllist.txt.out