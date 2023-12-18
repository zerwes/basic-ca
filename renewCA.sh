#! /bin/bash

# renew the CA root cert
# assumes genCA.sh has been run before

. ssl.cfg

export CN=ca.zero-sys.net
export DNSNAME="DNS:$CN"

# CA key
[ -f $CA/private/ca.pem ] || exit 1

# backup old CA root cert
[ -f $CA/ca.crt.old ] && exit 2
[ -f $CA/ca.crt ] && mv $CA/ca.crt $CA/ca.crt.old

# CA root cert
openssl req $CFG -batch -verbose -x509 -new -nodes -extensions v3_ca -key $CA/private/ca.pem -days 9125 -out $CA/ca.crt -sha512

./updateCRL.sh

openssl x509 -in $CA/ca.crt -noout -text
if [ -f $CA/ca.crt.old ]; then
	echo "old cert ..."
	openssl x509 -in $CA/ca.crt.old -noout -text
fi

# der form
openssl x509 -inform PEM -outform DER -in $CA/ca.crt -out $CA/ca.cer

# fingerprint
if [ -f $CA/ca.crt.old ]; then
	echo "old fingerprint"
	openssl x509 -in $CA/ca.crt.old -sha1 -noout -fingerprint
fi
echo "new fingerprint"
openssl x509 -in $CA/ca.crt -sha1 -noout -fingerprint

