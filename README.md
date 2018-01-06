# Certificate Monitor

Packed in a relatively small (23MB) Docker container, tool that will take a given list of URLs in a file (mounted as Docker volume, of course), and a number of days as second parameter. Tool will connect to each URL, retrieve the certificate, and if it expires in less than days given as second parameter, it will output it on stdout, JSON formatted array of objects containing:
* url - the URL taken from file given as first parameter input
* subject - subject extracted from the certificate
* valid_days - for how many days the certificate is still valid
* last_check - the time of checking, in ISO8601 format
* error - pressent only if there are errors (mainly certificate validation fails)

It does 10 concurrent connections to speed things up a little.

## Prerequisites
* Docker running on host
* List of urls serving certificates, text, one per line. (given as `-u path/to/urlfile` or env `URLFILE`)
    * **NOTE**: user inside the container is `uid=405(guest) gid=100(users)`, and URL file must be readable by it

## Quickstart
The script `get_certs_validity.sh` is an example wrapper for using this tool.

* Get run script from: https://raw.githubusercontent.com/dserfez/cert_monitor/master/get_certs_validity.sh
* Execute run script (be careful with what you allow to execute!)
    * with parameters inline: `./get_certs_validity.sh -d 45 -u myurls.txt`
    * with parameters given through ENV `DAYS=45 URLFILE=myurls.txt ./get_certs_validity.sh`


## Build the Docker container yourself
Don't blindly trust images from the internet, build your own using the provided Dockerfile.

Building is simple. Just run `./build.sh` and the container image _cert\_monitor_ will be built.

### Use different image name
* Pass env param _C\_IMAGE_ with container image name. default: `C_IMAGE=cycomf/cert_monitor`
* Or tag the image with default name used in _get\_certs\_validity.sh_ script: `tag cert_monitor cycomf/cert_monitor`

## Beyond Quickstart
Besides using the provided wrapper bash script, the cert_monitor tool can be used in different use cases. It is enough to create a Docker container from it, mount the urllist file and give the container two parameters (command not required, since it is provided as container entrypoint), which represent the mounted urlfile inside the container and number of days.

```
docker run --rm -i \
    -v "${URLFILE}":/tmp/urllist.txt:ro \
    ${C_IMAGE} /tmp/urllist.txt ${DAYS}
```

# TODO
This is a small weekend project/experiment, and there is alot that can be done to improve it. Feel free to contribute with ideas, or better with code.

* Concurrency as parameter

