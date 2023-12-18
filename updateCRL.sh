#! /bin/bash

cd $(dirname $0)

set -e

. ssl.cfg

if [ -z "$CN" ]; then
	export CN=$DNSNAME
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

openssl ca $CFG $CAPASSIN -gencrl -out $CA/crl/crl.pem
openssl crl -inform PEM -outform DER -in $CA/crl/crl.pem -out $CA/crl/crl-der.pem
