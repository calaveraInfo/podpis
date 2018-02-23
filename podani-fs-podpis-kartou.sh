#!/bin/bash
# TODO: Moznost zadat dokument k podepsani a certifikat jako parametr z prikazove radky
# TODO: Nechat uzivatele dynamicky vybrat kartu a ctecku misto soucasneho hardcodovaneho 0:2
# TODO: Pridat variantu s privatnim klicem v souboru
# TODO: Pridat vyber distribuce a nastavit podle toho cesty k so modulum
# TODO: Pridat dry-run mod

DOCUMENT=`zenity --file-selection --title="Dokument k podpisu"`
CERTIFICATE=`zenity --file-selection --title="Podpisový certifikát"`
COMPRESS=
ENGINE=

if $(zenity --list --radiolist  --print-column=1 --title="Úložiště privátního klíče" --text="Kde máte uložený privátní klíč?" --column="" --column="Úložiště" TRUE "Na kartě" FALSE "V souboru") ; then
	CARD=TRUE
	ENGINE="engine dynamic -pre SO_PATH:/usr/lib/x86_64-linux-gnu/engines-1.1/pkcs11.so -pre ID:pkcs11 -pre NO_VCHECK:1 -pre LIST_ADD:1 -pre LOAD -pre MODULE_PATH:/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so"
	SMIME="smime -sign -engine pkcs11 -in \"$DOCUMENT\" $COMPRESS -out \"$DOCUMENT.p7s\" -inkey 0:2 -signer \"$CERTIFICATE\" -keyform engine -outform DER -nodetach"
else
	CARD=FALSE
	echo "Použití klíče ze souboru není ještě implementováno."
	exit 1
fi

if $(zenity --question --text="Má se dokument před podpisem komprimovat?\nNěkterá podání se komprimovat nemusí (přiznání DPH),\nněkterá jsou komprimovaná povinně (kontrolní hlášení).") ; then
	zip --junk-paths --compression-method deflate "$DOCUMENT.zip" "$DOCUMENT"
	COMPRESS="-binary"
	DOCUMENT="$DOCUMENT.zip"
fi

openssl <<HereDoc
$ENGINE
$SMIME
HereDoc
