#!/bin/bash

: "${C_IMAGE:=cert_monitor}"

: "${WD:=$( cd "$( dirname "$0" )" && pwd )}"

usage() {
    echo -e "\nusage: $(basename $0) -d <days to report> -u <path to urllist file>"
    echo "Will get certificates from urls in urllist file (one per line), and print"
    echo "json status of certificates for certificates that expire within [-d days]."
    echo "URLFILE and DAYS can be given as environment variables."
}

while getopts "d:u:h" opt; do
    case ${opt} in
        d )
            : "${DAYS:=$OPTARG}"
            ;;
        u )
            : "${URLFILE:=$OPTARG}"
            ;;
        h )
            usage
            exit 0
            ;;
        : )
            echo "Invalid option: $OPTARG requires an argument" 1>&2
            usage
            exit 1
            ;;
        \? )
            echo "Invalid option: $OPTARG" 1>&2
            usage
            exit 1
            ;;
    esac
    #shift $((OPTIND -1))
done

if [[ -z ${DAYS} ]]; then
    echo "Parameter -d <days> or env variable DAYS is required"
    usage
    exit 1
fi

if [[ -z ${URLFILE} ]]; then
    echo "Parameter -u <urlfile> or env variable URLFILE is required"
    usage
    exit 1
fi

[[ ${URLFILE} =~ ^/ ]] || URLFILE="${WD}/${URLFILE}"

if [[ ! -r ${URLFILE} ]]; then
    echo "Given URL file ${URLFILE} is not readable."
    usage
    exit 1
fi



echo "DAYS: ${DAYS}, URLFILE: ${URLFILE}"


REZ=$(docker run --rm -ti \
    -v "${URLFILE}":/tmp/urllist.txt:ro \
    ${C_IMAGE} /tmp/urllist.txt ${DAYS})

strings ${REZ}
