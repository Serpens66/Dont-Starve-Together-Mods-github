# 17 – Vanilla-Audit und Belegketten

## Quellenstand und Methode

Am 03.10.2026 wurden sämtliche **4.044 Archivdateien** des installierten `scripts.zip` gegen den entpackten Snapshot `scripts_02_10_2026` verglichen: keine fehlende Datei, keine Inhaltsabweichung. Archiv-SHA-256: `f8d7cff2e9f86cdab3de08c6e750ecec2986c9bc95b364724f4c77244a798bf1`. Das Archiv wurde am 02.10.2026 geändert. Ein Ordnername allein belegt keinen Spielstand; der Inhaltsvergleich tut dies für das untersuchte Archiv.

Die folgenden Ketten wurden vor dem Schreiben der zugehörigen Empfehlungen und Vorlagen verfolgt. „Geprüft“ bedeutet Lesen der einschlägigen Definitionen, Initialisierung und Aufrufer; es bedeutet weder vollständige Prüfung jeder Zeile aller verlinkten Dateien noch einen Laufzeittest. Internet-Tutorials sind Zusatzquellen. Das [Manifest](SOURCE_MANIFEST.json) trennt referenzierte Vanilla-Dateien von lediglich inventarisierten Workspace-Dateien.

| Thema | Verfolgte Kette | Ergebnis und zuständige Instanz |
|---|---|---|
| Mod-Lader | `mods.lua:CreateEnvironment`, `InitializeModMain` → `modutil.lua:InsertPostInitFunctions` → Mod-Einstieg | Eigene Mod-Umgebung mit GLOBAL; modimport verwendet diese Umgebung. worldgen/main unterscheiden sich. Runtime lädt auch modworldgenmain; Main-Hooks dort nicht benutzen. |
| Prefab-Hook | `modutil.lua:AddPrefabPostInit` → `mainfunctions.lua:SpawnPrefabFromSim` → `prefabs/spear.lua:fn` | Der Konstruktor beendet sich vor dem PostInit. Per-Prefab-Hook kommt vor Any-Hooks. Shared Netzdefinitionen vor SetPristine; Gameplay-Components nur Mastersim. |
| Component-Hook | `entityscript.lua:AddComponent` → Replica → Component-Konstruktor → Components-Tabelle → PostInit | PostInit sieht Component und Instanz; Prefab-Code kann danach Werte ändern. Constructor darf seine bereits eingetragene Component nicht voraussetzen. |
| Klassen, Brains, SG | `modutil.lua` Konstruktorwrapper → `brain.lua:_Start_Internal`, `stategraph.lua` Konstruktor | Class-PostConstruct folgt Original-Konstruktor; Brain-Hook folgt Startinitialisierung. SG-Definition ist geteilt; instanzbezogene Daten gehören in Instanz/State-Memory. |
| Replikation | `netvars.lua` → `entityreplica.lua:ReplicateComponent`/`ValidateReplicaComponent` → `health_replica.lua`, `container_replica.lua` | Replizierbare Componentnamen müssen registriert sein; die Replica ist keine automatische Kopie des Servers. Netvars werden auf beiden Peers gleich erzeugt, der Server setzt Werte. Classified kann Sichtbarkeit einschränken. |
| RPC | `modutil.lua:AddModRPCHandler` → `networkclientrpc.lua` Registrierungs-/Sendefunktionen → HandleModRPC/Client/Shard und Queues | Namespace/Name und Registrierungsfolge müssen übereinstimmen. Serverhandler erhält Player, Shardhandler Absender-Shard. Transport ersetzt keine Eigentums-, Reichweiten-, Typ- und Cooldownprüfung. |
| Gegenstand | `prefabs/spear.lua:fn`, Equip/Unequip → weapon, finiteuses, inventoryitem, equippable | Bank/Build und swap_object passen zusammen; SetMaxUses setzt die Kapazität, SetUses den aktuellen Wert. Endeffekt und Save-Verhalten separat beachten. |
| Zähler-Vorlage | Obige Prefab-/Replica-/RPC-Kette → `inventoryitem.lua:GetGrandOwner`, `inventory_replica.lua:GetActiveItem` | RPC akzeptiert nur echte registrierte Token-Entities im Eigentum des aufrufenden Spielers. Servercount wird gespeichert; Netvar transportiert ihn; Dirty-Event informiert Clients. |
| Save/Load | `entityscript.lua:GetSaveRecord`, `SetPersistData`, `LoadPostPass` → `mainfunctions.lua:SpawnSaveRecord` → container/health/finiteuses | Component-OnSave gibt Daten und Referenzen zurück; Prefab-OnSave füllt Daten. OnPreLoad vor Component-OnLoad, Prefab-OnLoad danach, PostPass später. Referenzen über newents auflösen. |
| Spieler/Shards | `playerspawner.lua:PlayerRemove` → Session serialisieren → `TheShard:StartMigration`; `player_common.lua` Save/PreLoad/Load | Migration ist ein eigener Sessionablauf. Eigene World-Daten reisen nicht automatisch mit dem Spieler. Native Transport-Interna bleiben offen. |
| Crafting | `modutil.lua:AddRecipe2` → `recipe.lua:Recipe2`/Recipe → `recipes.lua` → Filtertabellen | TECH ist eine Tabelle; MODS wird standardmäßig ergänzt, nounlock nimmt einen anderen Pfad. Rezeptregistrierung auf benötigten Peers, Zutatenverbrauch durch Spielablauf. |
| Kochen | AddIngredientValues/AddCookerRecipe → `cooking.lua:GetIngredientValues`, Kandidaten/Priorität → `stewer.lua:StartCooking` | Namen und Tags sind unterschiedliche Kriterien; höchste Priorität und Gewicht entscheiden. Stewer konsumiert Containerinhalt. Kein Crafting-Rezept. |
| Eigene Action | AddAction/AddComponentAction → `componentactions.lua` Registrierung/Sammeln → actionpicker/bufferedaction → SGwilson und SGwilson_client doshortaction | Auswahl darf replizierte Informationen verwenden; endgültige Wirkung und erneute Gültigkeitsprüfung liegen auf Server. Beide SG-Zuordnungen erforderlich. |
| KI/Charakter | `brains/rabbitbrain.lua:OnStart` → PriorityNode/RunAway/Wander; `player_common.lua:MakePlayerCharacter` → gemeinsame und Serverinitialisierung | Verhalten benötigt passende Components und SG; Playerfactory beinhaltet mehr als ein Prefabname. Vollständiger Charakter ist kein bloßer AddModCharacter-Aufruf. |
| Weltgenerierung | `map/level.lua` ChooseTasks → TaskSet-/Level-/Task-Hooks; `map/storygen.lua:ModRoom` → Roomkopie → `map/graphnode.lua` Verteilung | RoomPreInit ändert vorhandene Rooms; unbekannte Namen erzeugen keinen Room. Gewicht und Verteilungsdichte getrennt; neue Welt nötig. Oberfläche/Höhlen getrennt untersuchen. |
| Welt-Einstellungen | map/customize → More Worldsettings Einstieg → `worldsettingsutil.lua` Timer-Helfer/PreLoad | Optionsanzeige, Generierungswirkung und laufende Weltwirkung sind getrennte Verträge. Ein geänderter TUNING-Wert ersetzt keine Timer-Migration. |
| UI | `widgets/controls.lua` Konstruktor → Widget-Roots → `widgets/text.lua`; `widgets/widget.lua` Task-/Update-Lebenszyklus | HUD nur auf sichtbaren Clients; topleft_root ist verfügbar. Textvorlage hat keine globalen Inputhandler. Eingabe-/Fokuscode braucht bei Erweiterungen einen eigenen Cleanup-Audit. |
| Input-Cleanup | `input.lua:AddKeyDownHandler`/OnRawKey → `events.lua:EventProcessor`/EventHandler:Remove → `Widget:Kill` | Inputhandler besitzt eigenen Remove-Vertrag; Widgetentfernung beendet ihn nicht automatisch. KeyDowncallback erhält keine Key-/Entityargumente. Konkrete Fokuslogik weiterhin featurebezogen prüfen. |
| World-State-Watcher | EntityScript:WatchWorldState/ComponentWatchWorldState → `worldstate.lua:AddWatcher`/SetVariable/RemoveWatcher | Entitycallbackziel ist Entity, Componentcallbackziel Component. Erst Änderung ruft normalen Watcher; Anfangswert explizit anwenden. |
| Bilder/Animation | spear/treasurechest AnimState und Minimap → `simutil.lua:GetInventoryItemAtlas`/Register → `prefabutil.lua:MakePlacer` | Inventarbild, Atlas, Rezeptbild und Minimap sind separate Registrierungen. Vorlage nutzt vorhandene Assets, keine ungeprüfte neue Exportpipeline. |
| Sprache/Audio | STRINGS-Verwendungen → `translator.lua:LoadPOFile`; Prefab-SoundEmitter-Aufrufe → modutil RemapSoundEvent | Textschlüssel sind typabhängig. Audioeventnamen sind Pfade der Soundbank, nicht lose WAV-Dateien. Native Audiodekodierung wurde nicht untersucht. |
| Konsole/Betrieb | `consolecommands.lua` c_spawn/c_give/c_save/c_select → ModIndex/Mods Initialisierung | Konsolenbefehle hängen vom lokalen/remote Ausführungskontext ab. Syntaxcompiler lädt keine Spielengine. |

Die konkreten Dateilinks und Symbolstellen stehen jeweils in den [Themenkapiteln](README.md). Das [API-Register](15_API_Register.md) belegt alle extrahierten Wrapper unmittelbar in modutil.lua.

## Grenzen und Erweiterungen

Alle Wrapper-Signaturen wurden geprüft. Für Rand-APIs wie Shader, Skilltree-Atlanten, Popup-Transport, neue Tile-Definitionen und Abstimmungskommandos wurde deren Registrierung geprüft, aber kein vollständiges neues Feature durch sämtliche Konsumenten entwickelt. Sie sind im Register entsprechend als Schnittstellenhinweis zu lesen, nicht als getestete Bauanleitung.

Auch Layout-Export, neue Animationsexporte, benutzerdefinierte Audio-Banken, vollständige Charaktere und komplexe Shard-Weltwechsel benötigen vor konkreter Implementierung einen zusätzlichen Audit. Lua zeigt Engineaufrufe, aber nicht deren C++-Implementierung, Speicherlayout oder alle Transportgrenzen. Diese Sammlung erfindet dafür keine Garantien.

## Nach einem Update

1. Mit [audit_scripts.py](tools/audit_scripts.py) Archiv und bisherige Entpackung vergleichen.
2. Bei Abweichung Archiv in einen neuen Datumsordner entpacken; alten Snapshot behalten. Dieser Schritt schreibt außerhalb des Workspace und muss gemäß aktueller Berechtigungen ausgeführt werden.
3. Für das geplante Feature alle beteiligten Dateien vergleichen, nicht nur den sichtbaren Hook. Initialisierung, Aufrufer, Netzwerkdefinitionen und Save-Vertrag erneut verfolgen.
4. Quellenlinks/Manifest und betroffene Beispiele aktualisieren. Neue Hashes allein sind kein fachlicher Audit.
5. Syntax- und Laufzeitmatrix erneut prüfen; Save-Kompatibilität ausdrücklich testen.

## Weitere praktische Quellenketten

[Auditnachweise 31](31_Praxis_Auditnachweise.md) ergänzen Kochen, Rabbit, Charactercallbacks/Ghost, Classifieds, Actionprediction und Player-Sessions/Migration. Das Manifest enthält die zusätzlich gelesenen Quellstände und tatsächlichen Definitionsbelege; native Enginegrenzen bleiben ausdrücklich offen.
