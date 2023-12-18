#! /bin/bash

cd $(dirname $0)

. ssl.cfg

set -e

declare -r SERVERNAME=$1
export CN=$SERVERNAME

if [ -z "$SERVERNAME" ]; then
	echo "usage: $0 SERVERNAME"
	exit 1
fi

declare CAPASSIN=""
# from ENV
if [ -n "$CAPASS" ]; then
        if $(echo "$CAPASS" | grep -q '[<>&;]'); then
                echo "ERROR: invalid char in CAPASS"
                exit 127
        fi
        CAPASSIN="-passin pass:$CAPASS"
fi


openssl ca $CFG $CAPASSIN -revoke $CA/certs/$SERVERNAME.pem

for f in $CA/certs/$SERVERNAME.pem $CA/certs/$SERVERNAME.key $CA/csr/$SERVERNAME.csr; do
	if [ -f $f ]; then
		rm $f
	fi
done
rm -rf $CA/certs/$SERVERNAME.*

./updateCRL.sh

