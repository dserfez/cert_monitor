# Certificate Monitor

Packed in a relatively small (23MB) Docker container, tool that will take a given list of URLs in a file (mounted as Docker volume, of course), and a number of days as second parameter. Tool will connect to each URL, retrieve the certificate, and if it expires in less than days given as second parameter, it will output it on stdout, JSON formatted array of objects containing:
* url - the URL taken from file given as first parameter input
* subject - subject extracted from the certificate
* valid_days - for how many days the certificate is still valid
* last_check - the time of checking, in ISO8601 format

## Prerequisites
* Docker running on host
* List of urls serving certificates, text, one per line. (given as `-u path/to/urlfile` or env `URLFILE`)

## Quickstart
* Get run script from: https://raw.githubusercontent.com/dserfez/cert_monitor/master/get_certs_validity.sh
* Execute run script (be careful with what you allow to execute!)
    * with parameters inline: `./get_certs_validity.sh -d 45 -u myurls.txt`
    * with parameters given through ENV `DAYS=45 URLFILE=myurls.txt ./get_certs_validity.sh`

## Build
`./build.sh` will build the container image _cert\_monitor_

### Use your image
* Pass env param _C\_IMAGE_ with container image. default: `C_IMAGE=cert_monitor`