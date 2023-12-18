#!/bin/bash
#
# generate pkcs#7 file

. ssl.cfg

set -e

declare -r SERVERNAME=$1

if [ -z "$SERVERNAME" ]; then
	echo $0 SERVERNAME
	exit 1
fi

if [ -f "$CA/certs/$SERVERNAME.pem" ]; then
    openssl crl2pkcs7 -nocrl -certfile $CA/certs/$SERVERNAME.pem -certfile $CA/ca.crt -out $CA/certs/${SERVERNAME}.p7b
    if [ -f "$CA/certs/${SERVERNAME}.p7b" ]; then
        echo "pkcs#7 file saved as '$CA/certs/${SERVERNAME}.p7b'"
        echo "you may examine the file using:"
        echo "openssl pkcs7 -print_certs -in $CA/certs/${SERVERNAME}.p7b"
    else
        echo "ERROR: missing outputfile '$CA/certs/${SERVERNAME}.p7b'"
        echo "something went wrong: ABORTING"
        exit 2
    fi
else
    echo "file '$CA/certs/$SERVERNAME.pem' not found: ABORTING"
    exit 1
fi

exit 0

