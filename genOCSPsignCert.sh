#! /bin/bash

. ssl.cfg

SERVERNAME=ocsp-signing-cert
declare -r CN=$SERVERNAME
export CN

# DNSNAME is required for v3_req
declare -r DNSNAME="DNS:$SERVERNAME"
export DNSNAME

mkdir -p $CA/ocsp

for F in $CA/ocsp/$SERVERNAME.key $CA/ocsp/$SERVERNAME.csr $CA/ocsp/$SERVERNAME.pem; do
	if [ -f $F ]; then
		echo "ERROR: file $F exists!"
		exit 1
	fi
done

# key
openssl genrsa -out $CA/ocsp/$SERVERNAME.key 2048
chmod 600 $CA/ocsp/$SERVERNAME.key

# csr
openssl req $CFG -new -nodes -key $CA/ocsp/$SERVERNAME.key -out $CA/ocsp/$SERVERNAME.csr <<EOF








EOF

# sign cert
openssl ca $CFG -extensions v3_OCSP -days 9125 -in $CA/ocsp/$SERVERNAME.csr -out $CA/ocsp/$SERVERNAME.pem -batch -notext
