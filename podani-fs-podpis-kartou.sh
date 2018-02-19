#!/bin/bash
# TODO: Moznost zadat dokument k podepsani jako parametr z prikazove radky
# TODO: Moznost zadat cestu k certifikatu v systemove promenne

DOCUMENT=`zenity --file-selection --title="Dokument k podpisu"`
CERTIFICATE=`zenity --file-selection --title="Podpisový certifikát"`

if $(zenity --question --text="Má se dokument před podpisem komprimovat?\nNěkterá podání se komprimovat nemusí (přiznání DPH),\nněkterá jsou komprimovaná povinně (kontrolní hlášení).") ; then
	zip --junk-paths --compression-method deflate "$DOCUMENT.zip" "$DOCUMENT"
	DOCUMENT="$DOCUMENT.zip"
fi

openssl <<HereDoc
engine dynamic -pre SO_PATH:/usr/lib/x86_64-linux-gnu/engines-1.1/pkcs11.so -pre ID:pkcs11 -pre NO_VCHECK:1 -pre LIST_ADD:1 -pre LOAD -pre MODULE_PATH:/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
smime -sign -engine pkcs11 -in "$DOCUMENT" -binary -out "$DOCUMENT.p7s" -inkey 0:2 -signer "$CERTIFICATE" -keyform engine -outform DER -nodetach
HereDoc
