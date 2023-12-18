#! /bin/bash

. ssl.cfg

declare -r SERVERNAME=$1

if [ -z "$SERVERNAME" ]; then
	echo "usage: $0 SERVERNAME"
	exit 1
fi

openssl verify -verbose -CAfile $CA/ca.crt -CRLfile $CA/crl/crl.pem -policy_check -x509_strict -crl_check -verbose $CA/certs/$SERVERNAME.pem

