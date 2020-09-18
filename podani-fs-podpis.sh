#!/bin/bash

PROGRAM="${0##*/}"

cmd_help() {
	cat <<HereDoc
Podepíše soubor pro podání na elektronickou podatelnu Finanční Správy.
Podepsaný soubor bude umístěn ve stejném adresáři jako původní
a se stejným jménem jen navíc s příponou `.p7s`, případně `.zip.p7s`.

Použití:
    $PROGRAM [parametry] [soubor k podepsání]
    	Žádný parametr ani samotný podepisovaný soubor není povinný.
        Hodnoty potřebných parametrů nezadaných z příkazové
        řádky budou zjištěny otázkami v grafickém průvodci.
    $PROGRAM -d [parametry] [soubor k podepsání]
    	Dry run mód. Vypisuje všechny prováděné příkazy
    	na standardní výstup, ale nevykonává je.
Parametry:
    -c certifikát: Soubor v PEM formátu obsahující certifikát podepisujícího.

Více informací viz README.md soubor.
HereDoc
}

if [ "$1" = "--help" ]; then
	cmd_help
	exit 0
fi

DRY_RUN=false
CERTIFICATE=

while getopts "dhc:" opt; do
  case $opt in
  	h)
    	cmd_help
		exit 0
      ;;
    c)
      if [ -f $OPTARG ] ; then
      	CERTIFICATE=$OPTARG
      fi
      ;;
    d)
      DRY_RUN=true
      ;;
    \?)
      echo "Nesprávný parametr: -$OPTARG" >&2
      ;;
    :)
      echo "Parametr -$OPTARG vyžaduje hodnotu" >&2
      exit 1
      ;;
  esac
done

shift $((OPTIND-1))

if [ -n "$1" ] && [ -f "$1" ] ; then
  DOCUMENT="$1"
else
  DOCUMENT=`zenity --file-selection --title="Dokument k podpisu"`
fi

if [ -z "$CERTIFICATE" ] ; then
	CERTIFICATE=`zenity --file-selection --title="Podpisový certifikát v PEM formátu"`
fi

if !(openssl x509 -in $CERTIFICATE -text | grep -q qcStatements) ; then
	echo 'Použitý certifikát není kvalifikovaný' >&2
	exit 1
fi

COMPRESS=
ENGINE=

KEY_STORAGE=$(zenity --list --radiolist  --print-column=3 --title="Úložiště privátního klíče" --text="Kde máte uložený privátní klíč?" --column="" --column="Úložiště" --column="" true "Na kartě" "CARD" false "V souboru" "FILE")
echo "$KEY_STORAGE"

if [ "$KEY_STORAGE" == "CARD" ] ; then
	PKCS_LIB_PATHS=$(zenity --list --radiolist "--separator=|" --print-column=ALL --title="Výběr distribuce" --text="Jakou distribuci operačího systému používáte?" --column="" --column="Distribuce" --column="SO path" --column="Module path" TRUE "Debian Stretch a odvozeniny" "/usr/lib/x86_64-linux-gnu/engines-1.1/pkcs11.so" "/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so" FALSE "Debian Jessie a odvozeniny" "/usr/lib/engines/engine_pkcs11.so" "/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so" )
	SO_PATH=$(echo $PKCS_LIB_PATHS | cut --fields=2 "--delimiter=|")
	MODULE_PATH=$(echo $PKCS_LIB_PATHS | cut --fields=3 "--delimiter=|")
	KEYID=$(zenity --entry --title="Výběr klíče na kartě" --text="Zadejte identifikátor klíče na kartě, který se má použít.\nPro návok k zjištění správné hodnoty viz README.")
	ENGINE="engine dynamic -pre SO_PATH:$SO_PATH -pre ID:pkcs11 -pre NO_VCHECK:1 -pre LIST_ADD:1 -pre LOAD -pre MODULE_PATH:$MODULE_PATH"
	CARD=true
else
	CARD=false
	KEYID=`zenity --file-selection --title="Soubor s privátním klíčem v PEM formátu"`
fi

if $(zenity --question --text="Má se dokument před podpisem komprimovat?\nNěkterá podání se komprimovat nemusí (přiznání DPH),\nněkterá jsou komprimovaná povinně (kontrolní hlášení).") ; then
	echo Komprimuji soubor k podepsání pomocí příkazu zip
	echo zip --junk-paths --compression-method deflate "$DOCUMENT.zip" "$DOCUMENT"
	echo 

	if [ "$DRY_RUN" = false ] ; then
		zip --junk-paths --compression-method deflate "$DOCUMENT.zip" "$DOCUMENT"
	fi

	COMPRESS="-binary"
	DOCUMENT="$DOCUMENT.zip"
fi

if [ "$CARD" = true ] ; then
	SMIME="smime -sign -engine pkcs11 -in \"$DOCUMENT\" $COMPRESS -out \"$DOCUMENT.p7s\" -inkey $KEYID -signer \"$CERTIFICATE\" -keyform engine -outform DER -nodetach"
else
	SMIME="smime -sign -in \"$DOCUMENT\" $COMPRESS -out \"$DOCUMENT.p7s\" -inkey \"$KEYID\" -signer \"$CERTIFICATE\" -outform DER -nodetach"
fi

echo Podepisuji soubor pomocí openssl příkazů
echo $ENGINE
echo $SMIME
echo

if [ "$DRY_RUN" = false ] ; then
	openssl <<HereDoc
	$ENGINE
	$SMIME
HereDoc
fi

