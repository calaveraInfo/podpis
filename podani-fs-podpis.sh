#!/bin/bash
# TODO: Moznost zadat dokument k podepsani a certifikat jako parametr z prikazove radky
# TODO: Pridat dry-run mod

DOCUMENT=`zenity --file-selection --title="Dokument k podpisu"`
CERTIFICATE=`zenity --file-selection --title="Podpisový certifikát v PEM formátu"`
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
	echo Running zip command
	echo zip --junk-paths --compression-method deflate "$DOCUMENT.zip" "$DOCUMENT"
	echo 

	zip --junk-paths --compression-method deflate "$DOCUMENT.zip" "$DOCUMENT"

	COMPRESS="-binary"
	DOCUMENT="$DOCUMENT.zip"
fi

if [ "$CARD" = true ] ; then
	SMIME="smime -sign -engine pkcs11 -in \"$DOCUMENT\" $COMPRESS -out \"$DOCUMENT.p7s\" -inkey $KEYID -signer \"$CERTIFICATE\" -keyform engine -outform DER -nodetach"
else
	SMIME="smime -sign -in \"$DOCUMENT\" $COMPRESS -out \"$DOCUMENT.p7s\" -inkey \"$KEYID\" -signer \"$CERTIFICATE\" -outform DER -nodetach"
fi

echo Running openssl commands
echo $ENGINE
echo $SMIME
echo

openssl <<HereDoc
$ENGINE
$SMIME
HereDoc
echo
