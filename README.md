# basic-ca
some sample scripts to setup and maintain a basic CA with openssl

# setup

## edit cfg

edit `ca.cfg` and `ssl.cfg`

 * in `ca.cfg`
   * settings in `req_distinguished_name` section
   * `nsCaRevocationUrl`, `crlDistributionPoints` and `authorityInfoAccess` (multiple occurrence, dito in the èxtension.*` files)
   * `new_oids` if required
 * in `ssl.cfg`
   * `UMAIL` env var
 * CA name defaults to ... **CA** :-) but can can be adjusted (`ca.cfg` and `ssl.cfg`)

## gen CA

edit ths script and set the CN for the CA; then run:

`./genCA.sh`

## gen ocsp signing cert

`./genOCSPsignCert.sh`

## gen server cert

`./genCert.sh SERVERNAME [DNSALTNAME|IP [DNSALTNAME|IP [...]]]`

## gen VPN/USR cert

this will use different extensions

`./genCert.sh -[V|U] ...`

## revoke a cert

`./revokeCert.sh CN`

## start OCSP server

port used in `authorityInfoAccess` must be set in the script!

`./startOCSPserver.sh`

## test OCSP server

test a existing cert

`./testOCSPserver.sh [CN]`

the ocsp check can be used with a serial too, not just with existing certs; just use `-serial $SN` instead of `-cert $CERT`

## other scripts

should be self-explanatory
