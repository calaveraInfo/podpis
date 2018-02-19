#!/bin/bash
# TODO: Prazdny email odebere polozku z url uplne
# TODO: Moznost defaultniho emailu v systemove promenne
# TODO: Oba mody pustit vzdycky, vystup z validace nejdriv zobrazit uzivateli a nechat jej rozhodnout, zda se ma pokracovat s opravdovym odeslanim
# TODO: Moznost zadat cestu k dokumentu jako vstupni parametr

SIGNED_DOCUMENT=`zenity --file-selection --title="Podepsaný dokument"`
RESULT="$(dirname $SIGNED_DOCUMENT)/potvrzeni-$(basename $SIGNED_DOCUMENT)"

MODE=$(zenity --list --radiolist  --print-column=3 --title="Režim odeslání" --text="Vyberte režim odeslání dokumentu" --column="" --column="Režim" --column="" TRUE Validace "&test=1" FALSE Odeslání "")

EMAIL=$(zenity --entry --title="Email" --text="Zadejte email, kam mají chodit informace o zpracování")

curl -X POST -H "content-type:application/octet-stream" --data-binary @$SIGNED_DOCUMENT "https://adisepo.mfcr.cz/adistc/epo_podani?email=$EMAIL$MODE" > $RESULT
