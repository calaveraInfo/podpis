# About (EN)
[Qualified digital signature][qualified] is considered equal to physical signature by laws of the Czech Republic and probably other European countries. It can be used for communication with many national authorities to digitize some paperwork like taxes, social security etc. Although it is based on standard X509 certificates, majority of manuals and directions from Czech authorities are based on proprietary technologies with bad reputation (java applets, explorer 10, activex etc.). This repo explores the possibilities of using more credible opensource tools instead. As it is intended for Czech audience only, the rest of the document and the project itself is in Czech language.

This is a continuation of work started in [this document][gist] after it became clear that it would be better to put the knowledge into actual working scripts instead of plain text.

# Úvod (CS)
[Kvalifikovaný digitální podpis][qualified] je českými a pravděpodobně i jinými evropskými zákony považován za ekvivalentní podpisu fyzickému. Může být mimo jiné použit i k digitálnímu vyřízení některých úředních povinností jako například daně, sociálka a podobně. Ačkoli je založen na standardních X509 certifikátech, většina návodů a instrukcí z úřadů je založena na proprietárních technologiích s nevalnou pověstí (java applety, explorer 10, activex prvky atd.). Tento repositář prozkoumává možnosti využít místo nich spolehlivější open source nástroje.

Toto je pokračování práce započaté v [tomto dokumentu][gist] poté, co začalo být jasné, že bude lepší vkládat vědomosti do reálně funkčních skriptů místo prostého textu.

# Status a kontribuce

Aktuálně je projekt v experimentální fázi, doporučuji ho používat jen když máte dost znalostí, abyste sami dokázali pochopit co a jak se dělá. Všechny skripty zde jsou bez jakékoli záruky.

Projekt nemá žádnou roadmapu, pracuji jen na věcech, které sám potřebuji a když je potřebuji. Nahlášené bugy a náměty na vylepšení ale budou brány v potaz.

Jakýkoli pull request s opravou, vylepšením nebo novými scénáři použití je vítaný.

# Nutné minimum vědomostí o elektronickém podpisu

Digitální podpis se skládá ze dvou částí (říká se jim klíče):

- Privátní klíč: tento klíč se nesmí dostat do ruky nikomu jinému, než majiteli podpisu.
- Veřejný klíč: tento klíč je veřejně známá informace.

Základem důvěry v digitální podpis je tzv. certifikát, což je dokument (soubor), který obsahuje veřejný klíč a k němu informaci o fyzické identitě toho, kdo se s ním podepisuje. Certifikátem se tento dokument stává ve chvíli, kdy je digitálně podepsán nějakou všeobecně známou autoritou. Komukoli stačí, aby znal a důvěřoval podpisu jedné takové všeobecně známé autority a může pak důvěřovat ve fyzickou identitu libovolného člověka, který se prokáže certifikátem podepsaným takovou autoritou. Tomuto schématu tranzitivního přenášení důvěry od autorit k neznámým cizincům se říká Public Key Infrastructure (PKI).

Digitální podpis je pak de facto jen připojení veřejného klíče k podepisovanému souboru. Specialita toho připojení (a celá magie digitálního podpisu) je v tom, že je matematicky zajištěno, že ho tím "správným" způsobem dokáže provést jen ten, kdo vlastní odpovídající privátní klíč.

Dohromady je to tedy takto: nikdo jiný než majitel privátního klíče nemůže správně připojit k dokumentu veřejný klíč a protože na fyzickou identitu majitele toho veřejného klíče vystavila důvěryhodná autorita certifikát, věříme, že daný soubor byl vědomě podepsán konkrétním člověkem.

## Úložiště klíčů

Z předchozího je vidět, že celá důvěra stojí na závazku majitele podpisu za žádných okolností nevydat nikomu jinému svůj privátní klíč. Proto je uložení privátního klíče nejdůležitější pro bezpečnost digitálního podpisu. Principiálně existují tyto možnosti:

- Uložit privátní klíč do souboru. V takovém případě musí být takový soubor zaheslovaný (podobně jako například zaheslovaný zip) a při každém použití klíče (podpisu) je potřeba heslo zadat. Každý soubor je ale z principu kdykoli možné nepozorovaně zkopírovat a heslo je možné odposlechnout a proto existuje bezpečnější varianta:
- Uložit privátní klíč na čipovou kartu. Bezpečnost této varianty spočívá v tom, že privátní klíč klíč nikdy čipovou kartu neopustí - celý podpis probíhá přímo na kartě a počítač dostane až výsledek podpisu, nikoli samotný klíč. K možnosti podepsat něco něčím jménem je proto potřeba fyzicky čipovou kartu zcizit, což se dá velmi rychle zjistit a je pak možné podpis odvolat (takzvaně revokovat certifikát).
- Úložiště certifikátů a klíčů může být systémová služba operačního systému (například ve Windows), která poskytuje jednotný přístup pro různé druhy úložišť a rozdíly mezi nimi se snaží zakrýt. Při použití open source nástrojů je ale většinou potřeba explicitně zadat kde a jak je privátní klíč a certifikáty uloženy.

## Vytvoření podpisu

Autority, kterým úředně důvěřuje český stát, jsou vyhlašovány [vyhláškou][autority]. Zřídit si kvalifikovaný podpis u nich znamená principálně vždy následující kroky:

1. Vygenerovat dvojici privátního a veřejného klíče.
2. Vytvořit žádost o vystavení certifikátu. Žádost je prakticky přímo onen certifikát (dokument s veřejným klíčem a fyzickou identitou k němu připojenou), který autorita jen podepíše.
3. Předat žádost autoritě.
4. Ověřit svojí totožnost udávanou v žádosti na ověřovacím místě autority.
5. Autorita žádost podepíše, tím z ní udělá plnohodnotný certifikát a ten vystaví veřejně ve svém registru a případně zašle zpět žadateli.

Tyto kroky mohou být poskládány do různých scénářů. Je možné například na web stránkách autority jednou akcí absolvovat kroky 1-3 dohromady. Klíče se ale mohou generovat i zcela offline a žádost je možné předat například na USB disku, pak jsou většinou spojeny kroky 3-4. Za pozornost také stojí, že autorita z principu nemusí znát privátní klíč (certifikát vystavuje na veřejný klíč), ale může úschovu privátního klíče nabízet jako doplňkovou službu. Například pro případ jeho ztráty nebo protože službu nabízejí včetně vydání čipové karty s privátním klíčem. Možností jak kroky poskládat je prostě mnoho, ale vždy se budou nějak mapovat na výše uvedený seznam.

# Instalace

Tento repositář stačí pouze stáhnout, shellové skripty zde není potřeba nijak instalovat.
Je ale potřeba instalovat nástroje, které jsou ze skriptů volány. Jejich výčet závisí
na způsobu a scénáři použití:

- Uživatelské rozhraní (pro možnost použití skriptů formou wizardu): [Zenity][zenity]
    - Debian Jessie, Stretch

            sudo apt install zenity
- Podepisovani (potřeba skoro vždy): [openssl][openssl], zip
    - Debian Jessie, Stretch

            sudo apt install openssl zip
- CLI HTTP klient (pro odesílání na elektronické podatelny): [cURL][curl]
    - Debian Jessie, Stretch

            sudo apt install curl
- Čipová karta (pokud je digitální podpis na čipové kartě): [OpenSC][opensc]
    - Debian Stretch

            sudo apt install pcscd pcsc-tools opensc opensc-pkcs11 libengine-pkcs11-openssl1.1
    - Debian Jessie (Podrobněji také viz článek o provozování [Yubikey v Debian Jessie][yubikey])

            sudo apt install pcscd pcsc-tools opensc opensc-pkcs11 libengine-pkcs11-openssl

# Použití

Skripty je možné spustit:

- Se všemi potřebnými parametry z příkazové řádky. Skript pak nemá žádné grafické rozhraní kromě zadávání hesel nebo PINů. (zatím nerealizováno)
- Bez parametrů nebo pouze s částí potřebných parametrů. Skript pak zjišťuje chybějící informace pomocí grafického rozhraní typu wizard.

Přestože mají skripty ve wizard módu grafické rozhraní, je potřeba je spouštět z příkazové řádky,
protože z bezpečnostních důvodů jsou případná hesla nebo PINy zadávány přímo v terminálu.

## `podani-fs-podpis.sh`

Podepíše dokument pro podání na elektronickou podatelnu Finanční Správy.

### Identifikátor klíče na kartě

Při podpisu čipovou kartou je potřeba zadat identifikátor klíče, který se má použít.
Tento identifikátor může mít následující formáty:

>     <id>
>     <slot>:<id>
>     id_<id>
>     slot_<slot>-id_<id>
>     label_<label>
>     slot_<slot>-label_<label>

Kde

- `<slot>` je číslo slotu čtečky karty. To je možné zjistit příkazem `opensc-tool --list-readers`, jehož výstup vypadá ukázkově takto (číslo slotu je číslo ve sloupci Nr.):
    
    >     # Detected readers (pcsc)
    >     Nr.  Card  Features  Name
    >     0    Yes             Yubico Yubikey 4 OTP+U2F+CCID 00 00
- `<id>` je identifikátor klíče na kartě jako hexadecimální řetězec. Je možné jej zjistit příkazem `pkcs15-tool --list-keys`, jehož výstup vypadá ukázkově takto (identifikátor klíče je položka "ID"):
    
    >     ...
    >     Private RSA Key [SIGN key]
	>     Object Flags   : [0x1], private
	>     Usage          : [0x20E], decrypt, sign, signRecover, nonRepudiation
	>     Access Flags   : [0x1D], sensitive, alwaysSensitive, neverExtract, local
	>     ModLength      : 2048
	>     Key ref        : 156 (0x9C)
	>     Native         : yes
	>     Auth ID        : 01
	>     ID             : 02
	>     ...
- `<label>` je textový popisek klíče (co přesně to znamená a jak to zjistit a použít se nepodařilo dohledat)

Správný identifikátor podle předchozí ukázky by tedy byl například `0:2`.

## `podani-fs-odeslani.sh`

Odešle dokument na elektronickou podatelnu Finanční Správy.

## Popis celých scénářů

### Podání elektronického formuláře na Finanční Správu

1. Vyplnit formulář na [daňovém portálu FS][dpfs].
2. Zvolit v menu formuláře možnost "Uložit pracovní verzi".
3. Podepsat stažený soubor pomocí `podani-fs-podpis-kartou.sh`.
4. Odeslat podepsaný soubor pomocí `podani-fs-odeslani.sh`

[autority]: http://www.mvcr.cz/clanek/prehled-kvalifikovanych-poskytovatelu-certifikacnich-sluzeb-a-jejich-kvalifikovanych-sluzeb.aspx
[yubikey]: https://calavera.info/v3/blog/2017/02/26/yubikey-v-debian-jessie.html
[opensc]: https://github.com/OpenSC/OpenSC/wiki
[dpfs]: https://adisepo.mfcr.cz/adistc/adis/idpr_epo/epo2/uvod/vstup_expert.faces
[curl]: https://curl.haxx.se/
[openssl]: https://wiki.openssl.org/
[zenity]: https://help.gnome.org/users/zenity/3.22/
[qualified]: https://en.wikipedia.org/wiki/Qualified_electronic_signature
[gist]: https://gist.github.com/calaveraInfo/8c58ccd6c7900a7a79523428fb3644b0
