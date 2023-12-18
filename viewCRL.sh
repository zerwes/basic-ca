#! /bin/bash

. ssl.cfg

openssl crl -in $CA/crl/crl.pem -text
