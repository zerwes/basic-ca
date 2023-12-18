#! /bin/bash

cd $(dirname $0)

. ssl.cfg

SERVERNAME=$1

# view csr
echo "CSR ..."
openssl req -text -noout -in $CA/csr/$SERVERNAME.csr

