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

Základem důvěry v digitální podpis je tzv. certifikát, což je dokument (soubor), který obsahuje veřejný klíč a k němu informaci o fyzické identitě toho, kdo se s ním podepisuje. Certifikátem se tento dokument stává ve chvíli, kdy je takový dokument sám digitálně podepsán nějakou všeobecně známou autoritou. Komukoli stačí, aby znal a důvěřoval podpisu jedné takové všeobecně známé autority a může pak důvěřovat ve fyzickou identitu libovolného podpisu, ke kterému existuje certifikát podepsaný takovou autoritou. Tomuto schématu tranzitivního přenášení důvěry od autorit k neznámým cizincům se říká Public Key Infrastructure (PKI).

Digitální podpis je pak de facto jen připojení veřejného klíče k podepisovanému souboru. Specialita toho připojení (a celá magie digitálního podpisu) je v tom, že je matematicky zajištěno, že ho tím "správným" způsobem dokáže provést jen ten, kdo vlastní odpovídající privátní klíč.

Rekapitulace: nikdo jiný než majitel privátního klíče nemůže připojit k dokumentu veřejný klíč "správným" způsobem. Protože navíc na fyzickou identitu majitele toho veřejného klíče vystavila důvěryhodná autorita certifikát, je to důkaz, že daný soubor byl vědomě podepsán konkrétním člověkem.

## Úložiště klíčů

Z předchozího je vidět, že celá důvěra stojí na závazku majitele podpisu za žádných okolností nevydat nikomu jinému svůj privátní klíč. Proto je uložení privátního klíče nejdůležitější pro bezpečnost digitálního podpisu. Principiálně existují tyto možnosti:

- Uložit privátní klíč do souboru. V takovém případě musí být takový soubor zaheslovaný (podobně jako například zaheslovaný zip) a při každém použití klíče (podpisu) je potřeba heslo zadat. Každý soubor je ale z principu kdykoli možné nepozorovaně zkopírovat a heslo je možné odposlechnout a proto existuje bezpečnější varianta:
- Uložit privátní klíč na čipovou kartu. Bezpečnost této varianty spočívá v tom, že privátní klíč klíč nikdy čipovou kartu neopustí - celý podpis probíhá přímo na kartě a počítač dostane až výsledek podpisu, nikoli samotný klíč. K možnosti podepsat něco něčím jménem je proto potřeba fyzicky čipovou kartu zcizit, což se dá velmi rychle zjistit a zabránit zneužití odvoláním platnosti podpisu (takzvaně revokovat certifikát).
- Čím dál častěji jsou počítače vybaveny součástkami, které fungují stejně, jako čipová karta, jen jsou napevno fyzicky spojeny s konkrétním počítačem.
- Úložiště certifikátů a klíčů může být systémová služba operačního systému, která funguje jeko jednotné rozhraní k různým druhům úložišť, aby se sjednotil způsob práce s nimi. V případě Windows navíc tato služba příliš nerozlišuje mezi privátním a veřejným klíčem a certifikátem a vše dohromady označuje prostě jako certifikát, takže dohromady je trochu obtížné si při práci s ní udělat jasný mentální model problematiky. Z principů popsaných doteď ale nijak vybočit nemůže.

## Vytvoření podpisu

Autority, kterým úředně důvěřuje český stát, jsou vyhlašovány [vyhláškou][autority]. Zřídit si u nich digitální podpis znamená principálně vždy následující kroky:

1. Vygenerovat dvojici privátního a veřejného klíče.
2. Vytvořit žádost o vystavení certifikátu. Žádost je prakticky přímo onen dokument, který se po podpisu autoritou stane certifikátem.
3. Předat žádost autoritě.
4. Prokázat svojí totožnost udávanou v žádosti na ověřovacím místě autority.
5. Autorita žádost podepíše, tím z ní udělá plnohodnotný certifikát a ten vystaví veřejně ve svém registru (a případně zašle zpět žadateli).

Tyto kroky mohou být realizovány různě. Je možné například na web stránkách autority jednou akcí absolvovat kroky 1-3 dohromady. Klíče se ale mohou generovat i zcela offline a žádost je možné předat třeba na USB disku, pak jsou většinou spojeny kroky 3-5 do jedné osobní návštěvy. Za pozornost také stojí, že autorita z principu nepotřebuje znát privátní klíč (certifikát vystavuje na veřejný klíč), ale může úschovu privátního klíče nabízet jako doplňkovou službu. Například pro případ jeho ztráty nebo protože službu nabízí včetně vydání čipové karty s podpisem. Možností jak kroky poskládat je prostě mnoho, ale vždy se budou nějak mapovat na výše uvedený seznam.

# Instalace

Tento repositář stačí pouze stáhnout, shellové skripty zde není potřeba nijak instalovat.
Je ale potřeba instalovat nástroje, které jsou ze skriptů volány (s výjimkou dry run módu, viz níže). Jejich výčet závisí na způsobu a scénáři použití:

- Uživatelské rozhraní (pro možnost použití skriptů formou wizardu): [Zenity][zenity]
    - Debian Jessie, Stretch

            sudo apt install zenity
- Podepisování a jiná kryptografie (potřeba skoro vždy): [openssl][openssl], zip
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

Všechny skripty je možné spustit s parametrem `--help`, který vypíše jejich nápovědu.

Přestože mají skripty ve wizard módu grafické rozhraní, je potřeba je vždy spouštět z příkazové řádky,
protože z bezpečnostních důvodů jsou případná hesla nebo PINy zadávány přímo v terminálu.

## Dry run mód

Všechny skripty je možné spustit s parametrem `-d`, který způsobí, že skript žádné příkazy neprovádí, ale pouze vypíše v terminálu jejich přesné znění. Není pak potřeba instalovat žádný nástroj (kromě Zenity na uživatelské rozhraní) a zkopírované příkazy je pak možné použít i na úplně jiném stroji.

## Identifikátor klíče na kartě

Při použití čipové karty je potřeba zadat identifikátor klíče, který se má použít.
Tento identifikátor může mít jeden z následujících formátů:

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

## Popis celých scénářů

### Podání elektronického formuláře na Finanční Správu

1. Vyplnit formulář na [daňovém portálu FS][dpfs].
2. Zvolit v menu formuláře možnost "Uložit pracovní verzi".
3. Podepsat stažený soubor pomocí `podani-fs-podpis-kartou.sh`.
4. Odeslat podepsaný soubor pomocí `podani-fs-odeslani.sh`

[cssz osvc]: http://www.cssz.cz/cz/e-podani/ke-stazeni/e-podani-OSVC/e-podani-OSVC.htm
[cssz osvc dev]: http://www.cssz.cz/cz/e-podani/pro-vyvojare/definice-druhu-e-podani/osvc/
[dokumentace cssz]: http://www.cssz.cz/cz/e-podani/pro-vyvojare/
[dokumentace fs]: http://adisspr.mfcr.cz/adistc/adis/idpr_pub/dpr_info/dokumentace.faces
[autority]: http://www.mvcr.cz/clanek/prehled-kvalifikovanych-poskytovatelu-certifikacnich-sluzeb-a-jejich-kvalifikovanych-sluzeb.aspx
[yubikey]: https://calavera.info/v3/blog/2017/02/26/yubikey-v-debian-jessie.html
[opensc]: https://github.com/OpenSC/OpenSC/wiki
[dpfs]: https://adisepo.mfcr.cz/adistc/adis/idpr_epo/epo2/uvod/vstup_expert.faces
[curl]: https://curl.haxx.se/
[openssl]: https://wiki.openssl.org/
[zenity]: https://help.gnome.org/users/zenity/3.22/
[qualified]: https://en.wikipedia.org/wiki/Qualified_electronic_signature
[gist]: https://gist.github.com/calaveraInfo/8c58ccd6c7900a7a79523428fb3644b0
