# Certificate Monitor

Packed in a relatively small (23MB) Docker container, tool that will take a given list of URLs in a file (mounted as Docker volume, of course), and a number of days as second parameter. Tool will connect to each URL, retrieve the certificate, and if it expires in less than days given as second parameter, it will output it on stdout, JSON formatted array of objects containing:
* url - the URL taken from file given as first parameter input
* subject - subject extracted from the certificate
* valid_days - for how many days the certificate is still valid
* last_check - the time of checking, in ISO8601 format

