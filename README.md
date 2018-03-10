# About (EN)
[Qualified digital signature][qualified] is considered equal to physical signature by laws of the Czech Republic and probably other European countries. It can be used for communication with many national authorities to digitize some paperwork like taxes, social security etc. Although it is based on standard X509 certificates, majority of manuals and directions from Czech authorities are based on proprietary technologies with bad reputation (java applets, explorer 10, activex etc.). This repo explores the possibilities of using more credible opensource tools instead. As it is intended for Czech audience only, the rest of the document and the project itself is in Czech language.

# Úvod (CS)
[Kvalifikovaný digitální podpis][qualified] je českými a pravděpodobně i jinými evropskými zákony považován za ekvivalentní podpisu fyzickému. Může být mimo jiné použit i k digitálnímu vyřízení některých úředních povinností jako například daně, sociálka a podobně. Ačkoli je založen na standardních X509 certifikátech, většina návodů a instrukcí z úřadů je založena na proprietárních technologiích s nevalnou pověstí (java applety, explorer 10, activex prvky atd.). Tento repositář prozkoumává možnosti využít místo nich spolehlivější open source nástroje.

# Status a kontribuce

Aktuálně je projekt v experimentální fázi, doporučuji ho používat jen když máte dost znalostí, abyste sami dokázali pochopit co a jak se dělá. Všechny skripty zde jsou bez jakékoli záruky.

Projekt nemá žádnou roadmapu, pracuji jen na věcech, které sám potřebuji a když je potřebuji. Nahlášené bugy a náměty na vylepšení ale budou brány v potaz.

Jakýkoli pull request s opravou, vylepšením nebo novými scénáři použití je vítaný.

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

### Vytvoření osobního kvalifikovaného podpisu u ICA

1. Vygenerovat privátní klíč a žádost o certifikát pomocí `zadost-vytvoreni.sh`.
2. Odnést žádost (soubor s příponou .req) na USB disku na [některé z validačních míst][ica-validace].
    - Prokázat tam totožnost podle požadavků.
    - Prokázat oprávněnost všech akademických titulů uvedených v žádosti příslušnými diplomy nebo jejich uvedením v dokladech totožnosti.
    - Ujistit se, že k podpisu bude vygenerován i [identifikátor MPSV][ik].
3. Stáhnout si z veřejného rejstříku (nebo ze zaslaného mailu) vystavený certifikát.

### Vytvoření zaměstnaneckého podpisu u PostSignum

1. Avizovat jménem firmy novou žádost o zaměstnanecký podpis na stránkách PostSignum.
2. Vygenerovat privátní klíč a žádost o certifikát pomocí `zadost-vytvoreni.sh`.
3. Odnést žádost (soubor s příponou .req) na USB disku do některé pobočky [CzechPoint][czechpoint].
    - Prokázat tam totožnost podle požadavků.
    - Pozor, pracovníci velké části CzechPoint poboček věcem okolo digitálního podpisu vůbec nerozumí a bojí se ho. V případě zaměstnaneckého podpisu je potřeba dát pozor alespoň na to, aby v počítači otevřeli nejdřív avízo z firmy (podané online) a až k němu přidali samotnou žádost. Otevření žádosti bez kontextu firmy skončí chybou, kterou neumí řešit ani na technické podpoře.
3. Stáhnout si z veřejného rejstříku (nebo ze zaslaného mailu) vystavený certifikát.

### Podání elektronického formuláře na Finanční Správu

1. Vyplnit formulář na [daňovém portálu FS][dpfs].
2. Zvolit v menu formuláře možnost "Uložit pracovní verzi".
3. Podepsat stažený soubor pomocí `podani-fs-podpis.sh`.
4. Odeslat podepsaný soubor pomocí `podani-fs-odeslani.sh`

# Nutné minimum vědomostí o elektronickém podpisu

## Klíče

Digitální podpis se skládá ze dvou částí (říká se jim klíče):

- Veřejný klíč: tento klíč je veřejně známá informace.
- Privátní klíč: tento klíč se nesmí dostat do ruky nikomu jinému, než majiteli podpisu. Ačkoli jsou spolu privátní a veřejný klíč matematicky jednoznačně svázány, je také matematicky zajištěno, že privátní klíč nelze z veřejného nijak odhadnout ani odvodit.

## Certifikát

Výše uvedené klíče jsou ve skutečnosti pouze dlouhá náhodná čísla, kterých si může kdo chce vymyslet kolik chce. Abychom věřili, že nějaké takové klíče mají význam opravdového fyzického podpisu, musí k nim být vyroben takzvaný "certifikát". Certifikát v tomto kontextu není žádný termínus technikus, ale skutečně v původním slova smyslu **osvědčení**. Konkrétně je to osvědčení o tom, že konkrétní veřejný klíč reprezentuje konkrétní fyzickou osobu. Instituce, která ověřuje fyzickou totožnost a na jejím základě tyto certifikáty vydává, se nazývá certifikační autorita.

Fakticky je certifikát běžný soubor, kde je ve standardizovaném formátu zapsán veřejný klíč a k němu osobní údaje člověka, kterému patří. Kouzlo je v tom, že tento soubor je sám digitálně podepsán podpisem certifikační autority, která tak potvrzuje pravost údajů v něm uvedených. Podpis samotné certifikační autority se považuje za *veřejně známý*, takže je nutné mu slepě věřit, resp. je podtřeba si ho jednorázově stáhnout z web stránek autority, ručně jej importovat do operačního systému a označit jako důvěryhodný. Pak je ale možné důvěřovat ve fyzickou identitu libovolného podpisu, ke kterému existuje certifikát podepsaný takovou autoritou. Tomuto schématu tranzitivního přenášení důvěry od autorit k předem neznámým cizincům se říká Public Key Infrastructure. Odtud plyne někdy používaný termín PKI certifikáty.

## Podpis

Digitální podpis je pak ve skutečnosti jen připojení veřejného klíče k podepisovanému souboru. Připojení musí být ale provedeno speciálním způsobem, který matematicky zajišťuje, že jej správně dokáže udělat jen ten, kdo vlastní odpovídající privátní klíč. K podepisovanému souboru se většinou také rovnou připojí certifikát, aby jej druhá strana nemusela shánět v nějakých veřejných registrech.

Důvěru v digitální podpis tedy odvozujeme takto: nikdo jiný než majitel privátního klíče nemůže připojit k dokumentu veřejný klíč ověřitelně "správným" způsobem. Na fyzickou identitu majitele toho veřejného klíče vystavila důvěryhodná autorita certifikát a proto věříme, že daný soubor byl vědomě podepsán konkrétním člověkem aniž bychom potřebovali ten podpis dopředu znát nebo to ověřovat bokem.

## Úložiště klíčů

Z předchozího je vidět, že celá důvěra stojí na závazku majitele podpisu za žádných okolností nevydat nikomu jinému svůj privátní klíč. Proto je uložení privátního klíče nejdůležitější pro bezpečnost digitálního podpisu. Principiálně existují tyto možnosti:

- Uložit privátní klíč do souboru. V takovém případě musí být takový soubor zaheslovaný (podobně jako například zaheslovaný zip) a při každém použití klíče (podpisu) je potřeba heslo zadat. Každý soubor je ale z principu kdykoli možné nepozorovaně zkopírovat a heslo je možné odposlechnout a proto existuje bezpečnější varianta:
- Uložit privátní klíč na čipovou kartu. Bezpečnost této varianty spočívá v tom, že privátní klíč nikdy čipovou kartu neopustí - celý podpis probíhá přímo na kartě a počítač dostane až výsledek podpisu, nikoli samotný klíč. K možnosti podepsat něco něčím jménem je proto potřeba fyzicky čipovou kartu zcizit, což se dá velmi rychle zjistit a zabránit zneužití odvoláním platnosti podpisu (odborně: revokovat certifikát).
- Čím dál častěji jsou počítače vybaveny součástkami, které fungují stejně, jako čipová karta, ale jsou přímo součástí počítače. Souhrně se jim říká TPM (Trusted Platform Module).
- Úložiště certifikátů a klíčů může být systémová služba operačního systému, která funguje jako jednotné rozhraní k různým druhům úložišť, aby se sjednotil způsob práce s nimi. V případě Windows navíc tato služba příliš nerozlišuje mezi privátním a veřejným klíčem a certifikátem a vše dohromady označuje prostě jako certifikát. Vede to ke vzniku nonsensuálních termínů jako např. "veřejná část certifikátu" a jiným zmatkům, ale z principů popsaných doteď to nijak vybočit nemůže.

## Žádost o certifikát

Autority, kterým úředně důvěřuje český stát, jsou vyhlašovány [vyhláškou][autority]. Zřídit si u nich digitální podpis znamená principálně vždy následující kroky:

1. Vygenerovat dvojici privátního a veřejného klíče.
2. Vytvořit žádost o vystavení certifikátu. Žádost je ve skutečnosti většinou přímo onen soubor, který se po podpisu autoritou stane certifikátem.
3. Předat žádost autoritě.
4. Prokázat svojí totožnost udávanou v žádosti na ověřovacím místě autority.
5. Autorita žádost podepíše, tím z ní udělá plnohodnotný certifikát a ten vystaví veřejně ve svém registru (a případně zašle zpět žadateli).

Tyto kroky mohou být realizovány různě. Je možné například na web stránkách autority jednou akcí absolvovat kroky 1-3 dohromady. Klíče se ale mohou generovat i zcela offline a žádost je možné předat třeba na USB disku, pak jsou většinou spojeny kroky 3-5 do jedné osobní návštěvy. Za pozornost také stojí, že autorita z principu nepotřebuje znát privátní klíč (certifikát vystavuje na veřejný klíč), ale může úschovu privátního klíče nabízet jako doplňkovou službu. Například pro případ jeho ztráty nebo protože službu nabízí včetně vydání čipové karty s podpisem. Možností jak kroky poskládat je prostě mnoho, ale vždy se budou nějak mapovat na výše uvedený seznam.

## Standardizace

Všechny části použití digitálního podpisu jsou standardizovány (norma X.509). Mělo by tedy platit, že je možné používat libovolný software k vytvoření, použití a komunikaci digitálního podpisu s libovolnou protistranou i autoritou. Návody na stránkách autorit nebo státních úřadů s využitím konkrétních aplikací proto mohou být formálně maximálně doporučené, nikoli exkluzivní postupy.

Bohužel kromě čistě technických aspektů podpisu existuje daleko víc netechnických požadavků (např. na informace obsažené v certifikátu, obsah podepisovaného souboru atd.), které se mohou lišit pro každé z různých použití podpisu. Tento projekt má za cíl zdokumentovat právě tuto mezeru mezi jasně definovanými standardy digitálního podpisu a dodatečnými požadavky jednotlivých scénářů použití.

[czechpoint]: http://www.czechpoint.cz/
[ik]: http://www.ica.cz/Casto-kladene-otazky
[ica-validace]: http://www.ica.cz/Pobocky-Registracni-autority
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
