#! /bin/bash

. ssl.cfg

SERVERNAME=ocsp-signing-cert

# the -text option is only for debug
openssl ocsp -index $CA/index.txt -port 8081 -rsigner $CA/ocsp/$SERVERNAME.pem -rkey $CA/ocsp/$SERVERNAME.key -CA $CA/ca.crt -ignore_err -text #-out log.txt &
