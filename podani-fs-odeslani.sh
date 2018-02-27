#!/bin/bash

PROGRAM="${0##*/}"

cmd_help() {
	cat <<HereDoc
Odešle podepsaný dokument na elektronickou podatelnu Finanční Správy.
Soubor je nejdřív odeslán v testovacím režimu a výsledek je vypsán
na standardní výstup. Pak je teprve uživatel dotázán, zda se má
soubor doopravdy odeslat. Podepsané potvrzení o podání je pak uloženo
v souboru se stejným názvem a cestou jako odesílaný soubor jen s přidaným
prefixem "potvrzeni-".

Použití:
    $PROGRAM
        Spustí program v režimu grafického průvodce.
    $PROGRAM [parametry] [podepsaný soubor k odeslání na podatelnu]
        Zatím neimplementováno.
    $PROGRAM -d
    	  Dry run mód. Vypisuje všechny prováděné příkazy
        na standardní výstup, ale nevykonává je.
Parametry:
    -e email: Email, kam mají chodit informace o průběhu zpracování podání.
    -f: Vynechat testovací odeslání a bez dalších dotazů rovnou odeslat soubor do podatelny.

Více informací viz README.md soubor.
HereDoc
}

if [ "$1" = "--help" ]; then
	cmd_help
	exit 0
fi

DRY_RUN=false
FORCE=false
EMAIL=
SIGNED_DOCUMENT=

while getopts ":dhe:f" opt; do
  case $opt in
    e)
      EMAIL=$OPTARG
      ;;
    f)
      FORCE=true
      ;;
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

shift $((OPTIND-1))

if [ -n "$1" ] && [ -f "$1" ] ; then
  SIGNED_DOCUMENT="$1"
else
  SIGNED_DOCUMENT=`zenity --file-selection --title="Podepsaný dokument ve formátu P7S"`
fi

RESULT="$(dirname $SIGNED_DOCUMENT)/potvrzeni-$(basename $SIGNED_DOCUMENT)"

if [ -z "$EMAIL" ] ; then
  EMAIL=$(zenity --entry --title="Email" --text="Zadejte email, kam mají chodit informace o zpracování")
fi

if [ "$FORCE" = false ] ; then
  echo Odesílám dokument k otestování
  echo "curl -X POST -H \"content-type:application/octet-stream\" --data-binary \"@$SIGNED_DOCUMENT\" \"https://adisepo.mfcr.cz/adistc/epo_podani?email=$EMAIL&test=1\""
  echo
  if [ "$DRY_RUN" = false ] ; then
  	curl -X POST -H "content-type:application/octet-stream" --data-binary "@$SIGNED_DOCUMENT" "https://adisepo.mfcr.cz/adistc/epo_podani?email=$EMAIL&test=1"
  fi
fi

if [ "$FORCE" = true ] || $(zenity --question --text="Má se dokument opravdu odeslat do podatelny?\n(Před potvrzením zkontrolujte prosím výsledek testovacího odeslání zobrazený v terminálu).") ; then
	echo Odesílám dokument na podatelnu FS
	echo "curl -X POST -H \"content-type:application/octet-stream\" --data-binary \"@$SIGNED_DOCUMENT\" \"https://adisepo.mfcr.cz/adistc/epo_podani?email=$EMAIL\" > $RESULT"
	echo 

	if [ "$DRY_RUN" = false ] ; then
		curl -X POST -H "content-type:application/octet-stream" --data-binary "@$SIGNED_DOCUMENT" "https://adisepo.mfcr.cz/adistc/epo_podani?email=$EMAIL" > $RESULT
	fi
fi