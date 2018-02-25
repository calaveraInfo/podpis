#!/bin/bash
# TODO: Prazdny email odebere jeho polozku z url uplne
# TODO: Moznost zadat email jako vstupni parametr
# TODO: Moznost zadat cestu k dokumentu jako vstupni parametr

DRY_RUN=false

while getopts ":d" opt; do
  case $opt in
    d)
      DRY_RUN=true
      ;;
    \?)
      echo "Nesprávný parametr: -$OPTARG" >&2
      ;;
  esac
done

SIGNED_DOCUMENT=`zenity --file-selection --title="Podepsaný dokument ve formátu P7S"`
RESULT="$(dirname $SIGNED_DOCUMENT)/potvrzeni-$(basename $SIGNED_DOCUMENT)"

EMAIL=$(zenity --entry --title="Email" --text="Zadejte email, kam mají chodit informace o zpracování")

echo Odesílám dokument k otestování
echo "curl -X POST -H \"content-type:application/octet-stream\" --data-binary \"@$SIGNED_DOCUMENT\" \"https://adisepo.mfcr.cz/adistc/epo_podani?email=$EMAIL&test=1\""
echo 

if [ "$DRY_RUN" = false ] ; then
	curl -X POST -H "content-type:application/octet-stream" --data-binary "@$SIGNED_DOCUMENT" "https://adisepo.mfcr.cz/adistc/epo_podani?email=$EMAIL&test=1"
fi

if $(zenity --question --text="Má se dokument opravdu odeslat do podatelny?\n(Před potvrzením zkontrolujte prosím výsledek testovacího odeslání zobrazený v terminálu).") ; then
	echo Odesílám dokument na podatelnu FS
	echo "curl -X POST -H \"content-type:application/octet-stream\" --data-binary \"@$SIGNED_DOCUMENT\" \"https://adisepo.mfcr.cz/adistc/epo_podani?email=$EMAIL\" > $RESULT"
	echo 

	if [ "$DRY_RUN" = false ] ; then
		curl -X POST -H "content-type:application/octet-stream" --data-binary "@$SIGNED_DOCUMENT" "https://adisepo.mfcr.cz/adistc/epo_podani?email=$EMAIL" > $RESULT
	fi
fi