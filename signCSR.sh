#! /bin/bash

function help() {
	echo "usage: $0 [-V|-U] SERVERNAME"
}

cd $(dirname $0)

. ssl.cfg

declare EXTARG=""
declare CAPASSIN=""
if [ -n "$CAPASS" ]; then
	if $(echo "$CAPASS" | grep -q '[<>&;]'); then
		echo "ERROR: invalid char in CAPASS"
		exit 127
	fi
	CAPASSIN="-passin pass:$CAPASS"
fi

while getopts h?VUf opt; do
        case $opt in
                h|\?)
                        help
                        exit 0
                        ;;
                V)
                        EXTARG="-extfile extensions.vpn"
                        shift
                        ;;
                U)
                        EXTARG="-extfile extensions.user"
                        shift
                        ;;
		f)
			# ignored
			;;
                *)
                        echo "ERROR unhandled opt: $opt"
                        help
                        exit 1
        esac
done


declare -r SERVERNAME=${1,,}
declare -r CN=$SERVERNAME
export CN
 
declare DNSNAME="DNS:$SERVERNAME"
shift
while [ "${1+defined}" ]; do
	DNSNAME="${DNSNAME}, DNS:${1,,}"
	if valid_ip $1; then
		DNSNAME="${DNSNAME}, IP:$1"
	fi
	shift
done
export DNSNAME



if [ -f $CA/csr/$SERVERNAME.csr ]; then
	if [ -f $CA/certs/$SERVERNAME.pem ]; then
		echo "ERROR: cert '$CA/certs/$SERVERNAME.pem' exists"
		exit 1
	else
		openssl ca $CFG \
			-extensions v3_req $EXTARG \
			-in $CA/csr/$SERVERNAME.csr \
			-out $CA/certs/$SERVERNAME.pem \
			-batch -notext $CAPASSIN
		./viewCert.sh $SERVERNAME
	fi
else
	echo "ERROR: missing CSR $CA/csr/$SERVERNAME.csr"
	exit 1
fi

