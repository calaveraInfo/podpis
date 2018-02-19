# About (EN)
[Qualified digital signature][qualified] is considered equal to physical signature by laws of the Czech Republic and probably other European countries. It can be used for communication with many national authorities to digitize some paperwork like taxes, social security etc. Although it is based on standard X509 certificates, majority of manuals and directions from Czech authorities are based on proprietary technologies with bad reputation (java applets, explorer 10, activex etc.). This repo explores the possibilities of using more credible opensource tools instead. As it is intended for Czech audience only, the rest of the document and the project itself is in Czech language.

This is a continuation of work started in [this document][gist] after it became clear that it would be better to put the knowledge into actual working scripts instead of plain text.

# Úvod (CS)
[Kvalifikovaný digitální podpis][qualified] je českými a pravděpodobně i jinými evropskými zákony považován za ekvivalentní podpisu fyzickému. Může být mimo jiné použit i k digitálnímu vyřízení některých úředních povinností jako například daně, sociálka a podobně. Ačkoli je založen na standardních X509 certifikátech, většina návodů a instrukcí z úřadů je založena na proprietárních technologiích s nevalnou pověstí (java applety, explorer 10, activex prvky atd.). Tento repositář prozkoumává možnosti využít místo nich spolehlivější open source nástroje.

Toto je pokračování práce započaté v [tomto dokumentu][gist] poté, co začalo být jasné, že bude lepší vkládat vědomosti do reálně funkčních skriptů místo prostého textu.

# Status a kontribuce

Projekt nemá žádnou roadmapu, pracuji jen na věcech, které sám potřebuji a když je potřebuji. Všechny skripty zde jsou bez jakékoli záruky, aktuálně doporučuji je používat jen když máte dost znalostí, abyste sami dokázali pochopit co a jak dělají.

Jakýkoli pull request s vylepšením nebo novými scénáři použití je výtaný.

# Prerekvizity

- Uživatelské rozhraní: [Zenity][zenity].
- Kryptografie: [openssl][openssl]
- CLI HTTP klient: [cURL][curl]
- Čipová karta: [OpenSC][opensc]

Instalace standardními nástroji operačního systému:

    sudo apt install zenity openssl libengine-pkcs11-openssl1.1 curl pcscd pcsc-tools opensc opensc-pkcs11

# Scénáře
## Podání elektronického formuláře na Finanční Správu

1. Vyplnit formulář na [daňovém portálu FS][dpfs].
2. Zvolit v menu formuláře možnost "Uložit pracovní verzi".
3. Podepsat stažený soubor pomocí `podani-fs-podpis-kartou.sh`.
4. Odeslat podepsaný soubor pomocí `podani-fs-odeslani.sh`

[dpfs]: https://adisepo.mfcr.cz/adistc/adis/idpr_epo/epo2/uvod/vstup_expert.faces
[curl]: https://curl.haxx.se/
[openssl]: https://wiki.openssl.org/
[zenity]: https://help.gnome.org/users/zenity/3.22/
[qualified]: https://en.wikipedia.org/wiki/Qualified_electronic_signature
[gist]: https://gist.github.com/calaveraInfo/8c58ccd6c7900a7a79523428fb3644b0
