#! /bin/bash

. ssl.cfg

if [ -z "$1" ]; then
	CERT=$CA/ocsp/ocsp-signing-cert.pem
else
	CERT=$CA/certs/$1.pem
fi

# issuer option must come before cert!
openssl ocsp -url http://127.0.0.1:8081 -CAfile $CA/ca.crt -issuer $CA/ca.crt  -cert $CERT
