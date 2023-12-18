#! /bin/bash

cd $(dirname $0)

. ssl.cfg

declare -r SERVERNAME=$1

if [ -z "$SERVERNAME" ]; then
	echo "usage: $0 SERVERNAME"
	exit 1
fi

echo ""
echo "CERT:"
openssl x509 -in $CA/certs/$SERVERNAME.pem -noout -text
echo ""
cat $CA/certs/$SERVERNAME.pem

