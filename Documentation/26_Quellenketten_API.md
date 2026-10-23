# Ladeumgebung, API und aktuelle Aufrufer

## Modumgebung und Closurelebensdauer

[mods.lua](<../../_scripts/scripts_02_10_2026/scripts/mods.lua>) definiert CreateEnvironment/InitializeModMain. Normales modmain erhält explizit pairs, ipairs, print, math, table, type, string, tostring, require, Class, GLOBAL, modname, MODROOT und weitere bezeichnete Spieltabellen. Kein universeller __index auf GLOBAL. modimport verwendet diese Umgebung. Fehlende Builtins wie tonumber, pcall und unpack über GLOBAL bzw. bewusste lokale Aliase verwenden.

[util.lua](<../../_scripts/scripts_02_10_2026/scripts/util.lua>) setzt bei RunInEnvironmentSafe die Funktionsumgebung. Darin erzeugte Closures behalten sie, auch wenn Vanilla sie später als Widget/RPC/Prefabcallback aufruft. Update der Vorlage 10 ist weiterhin Modcode und benötigt GLOBAL.tonumber. Der spätere Aufrufer überträgt keine eigenen Globals in die Closure.

Prefabfiles lädt [mainfunctions.lua](<../../_scripts/scripts_02_10_2026/scripts/mainfunctions.lua>) über LoadPrefabFile. Components/Replicas sind require-Module mit Spielglobals, nicht automatisch mit GetModConfigData/modname aus modmain. Konfigwerte bewusst übergeben oder eindeutig benannte TUNING-Werte verwenden. Eigene historische Environmentloader sind andere Verträge.

## Replicas und RPCs

[entityscript.lua](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) AddComponent ruft ReplicateComponent vor dem Componentkonstruktor. [entityreplica.lua](<../../_scripts/scripts_02_10_2026/scripts/entityreplica.lua>) verwendet Registrierungsliste/Konstruktionstags; replica und components sind unterschiedliche Tabellen. Netvariablen müssen beim gemeinsamen Entityaufbau konsistent existieren, bevor Pristine den serverseitigen Aufbau trennt. Späte rein serverseitige Netvariablen sind kein verlässlicher Clientbauplan.

[modutil.lua](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) exportiert Modhilfen; [networkclientrpc.lua](<../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>) definiert globale Registrierung, Referenztabellen, Sendefunktionen und Empfangsqueues. Namespace/Namen werden casefolded zugeordnet, Codes anhand Registrierungsreihenfolge vergeben. Gemeinsame Registrierung auf beteiligten Instanzen erforderlich. Normaler Gameplayhandler arbeitet mit Spielersender; MarkUserIDRPCFn kennzeichnet einen Sonderpfad. Clienthandler besitzt keine implizite Spielerentity; Shardhandler einen Shardsender.

Der Queue-Limiter begrenzt ausstehende Transportarbeit, kein modfachliches „ein Klick pro Sekunde“-Budget. Vorlage 03 prüft Entity/GUID, Gültigkeit, Prefab, GrandOwner und Cooldown. Vorlage 10 akzeptiert nur Sequenznummer und sucht um den serverseitig bestimmten Spieler. Ein versteckter Button schafft keine Serverberechtigung.

Verarbeitung verwendet TheNet:CallRPC/CallClientRPC/CallShardRPC. Deren C++-Implementierung liegt nicht in scripts.zip. Serialisierung, Größenlimits und native Timinggarantien nicht aus einem erfundenen Lua-fn(unpack(...))-Aufruf ableiten. Externe GemCore-ShardRPCs sind ein zusätzliches API. Ein ShardRPC, das im gleichen Frame weitere an sich selbst sendet, wird im aktuellen Queuecode ausdrücklich als problematisch diagnostiziert; verzögerte Verarbeitung oder ein anderes Protokoll vorsehen.

## Persistenz und Cleanup

SetPersistData in entityscript: OnPreLoad, Component-OnLoad über pairs, Prefab-OnLoad. Componentreihenfolge ist kein gesichertes Abhängigkeitsprotokoll. LoadPostPass verwendet neu erzeugte Referenzen; rohe Runtime-GUIDs oder leeres newents rekonstruieren keine Beziehungen. [container.lua](<../../_scripts/scripts_02_10_2026/scripts/components/container.lua>) sammelt Content-SaveRecords und Referenzen.

RemoveComponent ruft Componentrückbau; Entityentfernung entfernt ihre Listener. Ein fremder Wrapper kann eine alte eigene Closure behalten. Vorlage 08 setzt zusätzlich active=false: ursprüngliche Funktion durchreichen, eigenen Effekt deaktivieren. Naives oldfn-Zurücksetzen verliert dagegen später installierte Fremdfunktionen. Isolierter Test belegt diesen eigenen Logikpfad.

## Register und Belege

[API-Register](15_API_Register.md) enthält 93 extrahierte modutil-Signaturen, nicht automatisch jedes globale RPC-/Engineverfahren. [Manifest](SOURCE_MANIFEST.json) ergänzt konkrete Definitionszeilen/Signaturen/Excerpt und Datei-SHA-256. Symbol-Link zeigt lesbare Stelle; nur expliziter Definitionsbeleg wird als Definition geprüft. Lexer verwirft Kommentare und Strings, beweist weder Kontrollfluss noch tatsächliche Registrierung.

## Praktische Ergänzung

AddCookerRecipe/AddIngredientValues → cooking/Stewer/Produkt/Cookbook sind in [28](28_Kochinhalte.md) verbunden. AddModCharacter → Playerfactory → Callback-Capture/Spawn/Ghost in [29](29_Kreaturen_Charaktere_Lebenszyklus.md). Netvars/Classified/Actionprediction/Sessionmigration und die zuständigen Vanilla-Aufrufer stehen in [30](30_Multiplayer_Lebenszyklen.md). [31](31_Praxis_Auditnachweise.md) grenzt die neuen Audits ab.
