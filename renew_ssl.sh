#!/usr/bin/env bash

if [ $# -ne 1 ]; then
    echo "help: renew_ssl.sh domain.com"
    exit
fi

DOMAIN_TAIL=$1 

# Specify where we will install
# the xip.io certificate
SSL_DIR="/etc/ssl/$DOMAIN_TAIL"

if [ ! -d $SSL_DIR ]; then
    echo "error: not ssl certificate found for this domain"
    exit
fi

DATE=`date +%Y-%m-%d`
BACKUP_DIR=/etc/ssl/backup_"$DATE"_"$DOMAIN_TAIL"
cp -r $SSL_DIR $BACKUP_DIR

if [ ! -d $BACKUP_DIR ]; then
    echo "error: backup could not be made"
    exit
fi

# Set the wildcarded domain
# we want to use
DOMAIN="*.$DOMAIN_TAIL"

# A blank passphrase
PASSPHRASE=""

# Set CA CSR variables
SUBJ_CA="
C=US
ST=California
O=
localityName=LA
commonName=$DOMAIN CA
organizationUnitName=
emailAddress=
"

# Serial of cert
SERIAL=01

# Set our CSR variables
SUBJ="
C=US
ST=California
O=
localityName=LA
commonName=$DOMAIN
organizationalUnitName=
emailAddress=
"

# Create our SSL directory
# in case it doesn't exist
sudo mkdir -p "$SSL_DIR"

# Create CA
if [ ! -f $SSL_DIR/ca.key ]; then
sudo openssl genrsa -out "$SSL_DIR/ca.key" 2048
echo "New ssl root ca key"
fi

sudo openssl req -new -subj "$(echo -n "$SUBJ_CA" | tr "\n" "/")" -x509 -days 3650 -key "$SSL_DIR/ca.key" -out "$SSL_DIR/ca.crt" -passin pass:$PASSPHRASE


# Generate our Private Key, CSR and Certificate
if [ ! -f $SSL_DIR/$DOMAIN_TAIL".key" ]; then
sudo openssl genrsa -out "$SSL_DIR/$DOMAIN_TAIL.key" 2048

sudo openssl req -new -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -key "$SSL_DIR/$DOMAIN_TAIL.key" -out "$SSL_DIR/$DOMAIN_TAIL.csr" -passin pass:$PASSPHRASE
fi

#sudo openssl x509 -req -days 365 -in "$SSL_DIR/$DOMAIN_TAIL.csr" -signkey "$SSL_DIR/$DOMAIN_TAIL.key" -out "$SSL_DIR/$DOMAIN_TAIL.crt"
sudo openssl x509 -req -days 365 -in "$SSL_DIR/$DOMAIN_TAIL.csr" -CA "$SSL_DIR/ca.crt" -CAkey "$SSL_DIR/ca.key" -set_serial $SERIAL -out "$SSL_DIR/$DOMAIN_TAIL.crt"
echo "New ssl certificate"
