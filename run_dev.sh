#!/bin/bash

: "${DAYS:=45}"
: "${URLFILE:=urllist.txt}"

write_urlfile() {
    echo "https://api.infobip.com" > urllist.txt
    echo "https://zap.grisia.com" >> urllist.txt
    echo "https://dev.infobip.com" >> urllist.txt
    echo "https://www.yahoo.com" >> urllist.txt
    echo "https://google.com" >> urllist.txt
}

#write_urlfile

docker run --rm -ti \
    -v $(pwd)/"${URLFILE}":/tmp/urls/urllist.txt \
    -v $(pwd)/certmon.rb:/opt/certificate_monitor.rb:ro \
    --entrypoint=/bin/sh \
    cert_monitor

exit 0
    --user=nobody \
