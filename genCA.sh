#! /bin/bash

. ssl.cfg

export CN=ca.zero-sys.net
export DNSNAME="DNS:$CN"

# make dirs
for d in certs crl newcerts csr private; do
	[ -d $CA/$d ] || mkdir -p $CA/$d
done

# CA key
[ -f $CA/private/ca.pem ] || openssl genrsa -aes256 -out $CA/private/ca.pem  2048

# CA root cert
[ -f $CA/ca.crt ] || openssl req $CFG -batch -verbose -x509 -new -nodes -extensions v3_ca -key $CA/private/ca.pem -days 9125 -out $CA/ca.crt -sha512

# serial
[ -f $CA/serial ] || echo "01" > $CA/serial

# index
[ -f $CA/index.txt ] || touch $CA/index.txt

# crl
[ -f $CA/crlnumber ] || echo 1000 > $CA/crlnumber
./updateCRL.sh

openssl x509 -in $CA/ca.crt -noout -text

# der form
openssl x509 -inform PEM -outform DER -in $CA/ca.crt -out $CA/ca.cer

# fingerprint
openssl x509 -in $CA/ca.crt -sha1 -noout -fingerprint

