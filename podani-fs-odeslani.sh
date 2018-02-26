#!/bin/bash
# TODO: Prazdny email odebere jeho polozku z url uplne
# TODO: Moznost zadat email jako vstupni parametr
# TODO: Moznost zadat cestu k dokumentu jako vstupni parametr
# TODO: Presmerovat chybovy vystup do dev null

PROGRAM="${0##*/}"

cmd_help() {
	cat <<HereDoc
Odešle podepsaný dokument na elektronickou podatelnu Finanční Správy.
Soubor je nejdřív odeslán v testovacím režimu a výsledek je vypsán
na standardní výstup. Pak je teprve uživatel dotázán, zda se má
soubor doopravdy odeslat. Podepsané potvrzení o podání je pak uloženo
v souboru se stejným názvem jako odesílaný soubor jen s přidaným
prefixem "potvrzeni-".

Použití:
    $PROGRAM
        Spustí program v režimu grafického průvodce.
    $PROGRAM [parametry] [podepsaný soubor k odeslání na podatelnu]
        Zatím neimplementováno.
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

while getopts "dh" opt; do
  case $opt in
  	h)
    	cmd_help
		  exit 0
      ;;
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