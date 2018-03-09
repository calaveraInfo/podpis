#!/bin/bash

cmd_help() {
	cat <<HereDoc
Vygeneruje digitální podpis - privátní a veřejný
klíč a žádost o vydání certifikátu. Výzva k zadání
hesla v terminálu se týká zaheslování privátního klíče.
Vygenerované soubory (private-key.pem a <příjmení>.req)
budou uloženy v aktuálním adresáři.

Použití:
    $PROGRAM
        Spustí grafického průvodce, který zjistí 
        všechny potřebné informace a vygeneruje podpis.
    $PROGRAM -d 
    	Dry run mód. Vypisuje všechny prováděné příkazy
      na standardní výstup, ale nevykonává je.

Více informací viz README.md soubor.
HereDoc
}

if [ "$1" = "--help" ]; then
	cmd_help
	exit 0
fi

DRY_RUN=false

while getopts ":dh" opt; do
  case $opt in
    d)
      DRY_RUN=true
      ;;
  	h)
      cmd_help
	  exit 0
      ;;
    \?)
      echo "Nesprávný parametr: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Parametr -$OPTARG vyžaduje hodnotu" >&2
      exit 1
      ;;
  esac
done

TEMP=$(mktemp)

GIVEN_NAME=$(zenity --entry --title="Křestní jméno" --text="Zadejte své křestní jméno.")
SURNAME=$(zenity --entry --title="Příjmení" --text="Zadejte své příjmení.")
COMMON_NAME=$(zenity --entry --title="Celé jméno" --text="Zadejte své celé jméno včetně titulů.")
EMAIL=$(zenity --entry --title="Celé jméno" --text="Zadejte svůj e-mail.")

cat <<HereDoc > $TEMP
oid_section=new_oids
prompt=no

[ new_oids ]
oid_mpsv=1.3.6.1.4.1.11801.2.1

[ req ]
default_bits=2048
default_keyfile=private-key.pem
default_md=sha256
distinguished_name=req_distinguished_name

string_mask=utf8only
req_extensions=v3_req

[ req_distinguished_name ]

C=CZ
CN=$COMMON_NAME
GN=$GIVEN_NAME
SN=$SURNAME

# Email zamerne neni v DN, ale v subjectAltName, jak si zada ICA
# Name nesmi byt v inicialni zadosti
# oid_mpsv nesmi byt v inicialni zadosti

[ v3_req ]
# basicConstraints = CA:FALSE # podle novych pravidel ICA je treba tohle zakomentovat
keyUsage = nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment
subjectAltName = email:$EMAIL
HereDoc

echo "Vytvářím podpis (konec následujícího víceřádkového příkazu označen hvězdičkami)"
echo openssl req -config /dev/fd/3 3\<\<HereDoc -sha256 -newkey rsa:2048 -utf8 -out "$SURNAME.req" -keyout private-key.pem
cat $TEMP
echo HereDoc
echo "************************************************************"

if [ "$DRY_RUN" = false ] ; then
  openssl req -config $TEMP -sha256 -newkey rsa:2048 -utf8 -out "$SURNAME.req" -keyout private-key.pem
fi

rm $TEMP
