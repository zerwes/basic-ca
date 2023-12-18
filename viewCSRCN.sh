#! /bin/bash

cd $(dirname $0)

. ssl.cfg

SERVERNAME=$1

# view csr
openssl req -noout -in $CA/csr/$SERVERNAME.csr -subject -nameopt multiline | grep commonName | awk '{print $3}'
exit ${PIPESTATUS[0]}

