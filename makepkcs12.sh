#!/bin/bash
#
# generate pkcs#12 file

cd $(dirname $0)

. ssl.cfg

set -e

declare -r SERVERNAME=$1

if [ -z "$SERVERNAME" ]; then
	echo $0 SERVERNAME
	exit 1
fi

if [ -f "$CA/certs/$SERVERNAME.pem" ]; then
	if [ -z "$PKCS12PASSWORD" ]; then
		declare -r GEN_PASSWORD=$(echo -n "$SERVERNAME" | md5sum - | awk '{print $1}')
	else
		declare -r GEN_PASSWORD=$PKCS12PASSWORD
	fi
	export GEN_PASSWORD
	openssl pkcs12 -export -in $CA/certs/$SERVERNAME.pem -out $CA/certs/$SERVERNAME.p12 -name "$SERVERNAME" \
		-inkey $CA/certs/$SERVERNAME.key \
		-certfile $CA/ca.crt -caname ca.zero-sys.net \
		-passout env:GEN_PASSWORD
	openssl pkcs12 -info -in $CA/certs/$SERVERNAME.p12 -nokeys -password env:GEN_PASSWORD
	echo ""
	echo "password for $CA/certs/$SERVERNAME.p12: '$GEN_PASSWORD'"
	echo ""
else
    echo "file '$CA/certs/$SERVERNAME.pem' not found: ABORTING"
    exit 1
fi

exit 0

