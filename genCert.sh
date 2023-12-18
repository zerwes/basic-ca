#! /bin/bash

cd $(dirname $0)

function help() {
	echo "usage: $0 [-f|-F] [-a] [-A] [-V] [-l] SERVERNAME [DNSALTNAME|IP [DNSALTNAME|IP [...]]]"
	echo "options:"
	echo -e "\t-V\tcreate a VPN cert"
	echo -e "\t-U\tcreate a user cert"
	echo -e "\t-f\tskip FQDN check"
	echo -e "\t-F\texit w/ error on failed FQDN check"
	echo -e "\t-a\tperform a FQDN check for altnames too"
	echo -e "\t-A\texit w/ error on failed FQDN check for altnames"
	echo -e "\t-l\tlist existing cert name for SERVERNAME and exit"
	echo -e "\t-D\tskip check for duplicated host names"
}


declare EXTARG=""
declare -i FQDNCHECK=1
declare -i FQDNCHECKEXIT=0
declare -i AFQDNCHECK=0
declare -i AFQDNCHECKEXIT=0
declare -i LISTEXISTINGCERTS=0
declare -i DUPCHECK=1
while getopts h?VUSfFaAlD opt; do
	case $opt in
		h|\?)
			help
			exit 0
			;;
		V)
			EXTARG="-V"
			;;
		U)
			EXTARG="-U"
			FQDNCHECK=0
			;;
		S)
			#default: server cert; dummy option
			;;
		f)
			FQDNCHECK=0
			;;
		F)
			FQDNCHECK=1
			FQDNCHECKEXIT=1
			;;
		a)
			AFQDNCHECK=1
			;;
		A)
			AFQDNCHECK=1
			AFQDNCHECKEXIT=1
			;;
		l)
			LISTEXISTINGCERTS=1
			;;
		D)
			DUPCHECK=0
			;;
		*)
			echo "ERROR unhandled opt: $opt"
			help
			exit 1
	esac
done
shift $((OPTIND -1))


. ssl.cfg

ARGS=$@

SERVERNAME=${1,,}
declare -r CN=$SERVERNAME
export CN

if [ -z "$SERVERNAME" ]; then
	help
	exit 1
fi

if [ "$EXTARG" = "-U" ]; then
	export UMAIL=$SERVERNAME
	# TODO mail syntax check
fi

# check if hostname is uniq
if [ $DUPCHECK = 1 ]; then
	for k in $(find $CA/certs/ -iname ${SERVERNAME%%.*}.*.pem); do
		if [ $LISTEXISTINGCERTS = 0 ]; then
			echo "ERROR: hostname ${SERVERNAME%%.*} (from $SERVERNAME)) already in use @ $(basename $k .pem)"
			exit 1
		else
			basename $k .pem
		fi
	done
fi
if [ $LISTEXISTINGCERTS -gt 0 ]; then
	exit 0
fi

# fqdn check for servername
if ! valid_fqdn $SERVERNAME; then
	if [ $FQDNCHECKEXIT -gt 0 ]; then
		echo "$SERVERNAME is not a valid FQDN"
		exit $FQDNCHECKEXIT
	fi
	echo "$SERVERNAME is not a valid FQDN; continue?"
	if [ $FQDNCHECK -gt 0 ]; then
		CONT=""
		read -n 1 -p "y|n " CONT;
		if [ "$CONT" != "y" ]; then
			echo " exit"
			exit 0
		fi
	fi
	echo " continuing using invalid FQDN: $SERVERNAME"
fi

declare DNSNAME="DNS:$SERVERNAME"
shift
while [ "${1+defined}" ]; do
	DNSNAME="${DNSNAME}, DNS:${1,,}"
	if valid_ip $1; then
		DNSNAME="${DNSNAME}, IP:$1"
	else
		# hostname from fqdn is OK
		if [ "${SERVERNAME/\.*/}" != "$1" ]; then
			if ! valid_fqdn $1; then
				if [ $AFQDNCHECKEXIT -gt 0 ]; then
					echo "$1 is not a valid FQDN"
					exit $AFQDNCHECKEXIT
				fi
				if [ $AFQDNCHECK -gt 0 ]; then
					echo "$1 is not a valid FQDN; continue?"
					CONT=""
					read -n 1 -p "y|n " CONT;
					if [ "$CONT" != "y" ]; then
						echo " exit"
						exit 0
					fi
				fi
				echo "... continuing using invalid FQDN: $1"
			fi
		fi
	fi
	shift
done
export DNSNAME
echo "using DNSNAME: $DNSNAME"


for F in $CA/certs/$SERVERNAME.key $CA/csr/$SERVERNAME.csr $CA/certs/$SERVERNAME.pem; do
	if [ -f $F ]; then
		echo "ERROR: file $F exists!"
		exit 1
	fi
done

# key
openssl genrsa -out $CA/certs/$SERVERNAME.key 2048
chmod 600 $CA/certs/$SERVERNAME.key

# csr
openssl req $CFG -new -nodes -key $CA/certs/$SERVERNAME.key -out $CA/csr/$SERVERNAME.csr <<EOF








EOF

# view csr
echo ""
./viewCSR.sh $SERVERNAME

# cert
./signCSR.sh $EXTARG $ARGS

