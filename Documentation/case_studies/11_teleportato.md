# Teleportato – persistenten Weltwechsel verstehen

**Prüfart:** statische Ablaufanalyse; Architektur und wesentliche Pfade beschrieben; offene Spezialverträge unten. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `Teleportato 756229217`.

## Einstieg und Abhängigkeiten

Worldgen registriert Teile/Base/Layouts und TUNING.TELEPORTATOMOD; Runtime fügt worldjump und optional adventurejump/startstuff hinzu. [Teleportato 756229217/modmain.lua — DoTheWorldJump](<../../Teleportato 756229217/modmain.lua>) (Zeile 649) führt zum Wechsel, [Teleportato 756229217/scripts/components/worldjump.lua — DoJump(](<../../Teleportato 756229217/scripts/components/worldjump.lua>) (Zeile 322) ist der Mastershard-Koordinator. GEM API ist eine externe optionale Shardintegration; sein Vorhandensein wird nicht durch diese Dokumentation garantiert.

## Initialisierung, Interaktion und Serverwirkung

Aktivierung prüft den geplanten Spieler-/Teileablauf und löst verzögert DoJump aus. Ohne Shardzweig: SavePlayerData sammelt Online-/zwischengespeicherte Offlineprofile und schreibt TeleJson-PersistentString; anschließend SendWorldResetRequestToServer. Mit GEM API fragt shard_teleplayersave über Netbool andere Shards ab; deren SaveAndSendDataToMaster sendet Playerdaten über externes Shard-RPC zurück. Master vereinigt diese und startet erst nach erwarteter Anzahl Antworten DoJumpFinalWithCave.

SavePlayerData hat **zwei Pfade**. Einzelspielerpfad dropt irreplaceable vor GetSaveRecord; Sammelpfad erzeugt SaveRecord vor DropEverythingWithTag. Diese Reihenfolge ist relevant für das, was im Record enthalten sein kann. Statsdaten setzen Untergrenzen für Health/Sanity/Hunger; Config steuert Age/Inventory/Recipes und vollständige Chardaten.

## Replikation, UI, Speicherung und Wiederherstellung

OnSave der worldjump-Component speichert Spieler-IDs und player_data_save im alten Worldsave; PersistentString ist zusätzlich eine weltübergreifende Übergabedatei mit Sessionkennung. LoadPlayerData liest asynchron, ordnet Session und Daten zu. OnPlayerSpawn stellt nach Task0 gewählte Chardaten/Components und Standardwerte wieder her, berücksichtigt Charaktergleichheit und Ausschlusslisten. OnLoad-Aufrufe mit leerem newents sind keine vollständige Vanilla-Referenzrestauration. Mods können eigene versionsfähige Daten über functionsavewithteleportato und passenden Loadhook beitragen. UI/Player-Netfelder informieren über Kapitel/Startbedingungen, sind kein Ersatz für gesicherte Übergabedaten.

## Cleanup und Lebensdauer

Ein Weltreset entfernt die alte Entitywelt. Daten dürfen daher keine lebenden Entity-/Task-/Funktionsreferenzen enthalten. Der async Persistenzschreibpfad braucht Fehlermeldung und Erfolgskriterium vor Freigabe eines produktiven Resets. Ein ausbleibender Shard, doppelte Antwort, Spielerdisconnect und erneut auf true gesetztes Request-Netbool benötigen eigenen Retry-/Idempotenzvertrag.

## Aktuelle Vanilla-Kette

[entityscript.lua — GetSaveRecord](<../../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 248) → [entityscript.lua — SetPersistData](<../../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 1954) / [entityscript.lua — LoadPostPass](<../../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 1939) → [components/inventory.lua — OnSave](<../../../_scripts/scripts_02_10_2026/scripts/components/inventory.lua>) (Zeile 192) / [components/inventory.lua — OnLoad](<../../../_scripts/scripts_02_10_2026/scripts/components/inventory.lua>) (Zeile 293); [shardnetworking.lua — Shard](<../../../_scripts/scripts_02_10_2026/scripts/shardnetworking.lua>) (Zeile 4) / [gamelogic.lua — DoResetAction](<../../../_scripts/scripts_02_10_2026/scripts/gamelogic.lua>) (Zeile 1135) grenzen die sichtbare Lua-Seite ab. Native Reset-/PersistentString-Dauerhaftigkeit ist hier nicht als atomare Transaktion belegt.

## Altlasten und konkrete Prüfgrenze

Kein universeller "alle Componentdaten in neue Welt kopieren"-Vertrag: GUIDs, Partner, Weltkoordinaten, Timer und einmalige Initialisierung sind weltgebunden. GetSaveRecord ohne Übernahme des zweiten refs-Rückgabewertes reicht für referenzhaltige Systeme nicht. stats_data wird vor der Schleife angelegt und für mehrere Spieler wiederverwendet; Tablealiasing vor Encoding separat prüfen. Die externen GEM-Shard-RPCs sind nicht mit dem aktuellen ModShardRPC gleichzusetzen. Vollständige Crash-/Dateisystem-/Verbindungssicherheit bleibt außerhalb statischer Lua-Belege.

## Szenarien für die spätere Laufzeitabnahme

Nur später in gesichertem Testcluster: Spieler online/offline auf beiden Shards, Charaktergleichheit/-wechsel, Inventory/Age/Recipes je Option, unique Items und verlinkte Begleiter. Reset zwischen Sammeln/Schreiben/Antwort/Neustart simulieren; keine Duplikate/Verlust. Restart nach Übergabedatei und vor erstem Spawn, spätes Reconnect, mehrfacher Reset. Diese Tests wurden ausdrücklich **nicht** ausgeführt.

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Shardzusammenführung und Persistenzgrenze

[Teleportato 756229217/modmain.lua — SavePlayerDatainMaster](<../../Teleportato 756229217/modmain.lua>) (Zeile 104) fügt jede Antwort-Shard-ID in eine Liste ein, vereinigt Daten nach userid und ersetzt vorhandene Daten bei größerem timefromsave. Anschließend wird die **Anzahl** Antworten mit SHARD_LIST verglichen. Eine Mengenkontrolle eindeutiger Shard-IDs, gemeinsame Request-ID und ein expliziter Fehler-/Timeoutpfad sind hier nicht belegt. Deshalb ist "alle Shards sicher erfasst" stärker als das, was diese Routine statisch garantiert.

timefromsave stammt aus GetTime der jeweiligen Instanz. Ob diese Werte in einer konkreten Clusterkonfiguration eine ausreichend gemeinsame Zeitbasis bilden, muss gesondert geprüft werden; sie sind kein ausdrücklich gespeicherter UTC-Zeitstempel. Native SetPersistentString ohne ausgewerteten Erfolgsrückruf und nachfolgendem Reset liefert aus diesem Luaablauf keinen nachgewiesenen atomaren Commit. Für eine neue Resetlösung Übergabegeneration, Schreibbestätigung, erwartete Shardmenge und wiederholbare Restorezustände festlegen.


## Dateiregister: Teleportato 756229217

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../Teleportato 756229217/modinfo.lua>)
- [modmain.lua](<../../Teleportato 756229217/modmain.lua>)
- [modworldgenmain.lua](<../../Teleportato 756229217/modworldgenmain.lua>)
- [scripts/components/adv_startstuff.lua](<../../Teleportato 756229217/scripts/components/adv_startstuff.lua>)
- [scripts/components/adventurejump.lua](<../../Teleportato 756229217/scripts/components/adventurejump.lua>)
- [scripts/components/shard_teleplayersave.lua](<../../Teleportato 756229217/scripts/components/shard_teleplayersave.lua>)
- [scripts/components/worldjump.lua](<../../Teleportato 756229217/scripts/components/worldjump.lua>)
- [scripts/map/layouts/TeleportatoRingLayoutSanityRocks.lua](<../../Teleportato 756229217/scripts/map/layouts/TeleportatoRingLayoutSanityRocks.lua>)
- [scripts/prefabs/adventure_portal.lua](<../../Teleportato 756229217/scripts/prefabs/adventure_portal.lua>)
- [scripts/prefabs/diviningrod.lua](<../../Teleportato 756229217/scripts/prefabs/diviningrod.lua>)
- [scripts/prefabs/teleportato.lua](<../../Teleportato 756229217/scripts/prefabs/teleportato.lua>)
- [scripts/prefabs/teleportato_parts.lua](<../../Teleportato 756229217/scripts/prefabs/teleportato_parts.lua>)
- [scripts/scenarios/chest_total_random.lua](<../../Teleportato 756229217/scripts/scenarios/chest_total_random.lua>)
- [scripts/tele_helpers.lua](<../../Teleportato 756229217/scripts/tele_helpers.lua>)
- [scripts/tele_itemskinsave.lua](<../../Teleportato 756229217/scripts/tele_itemskinsave.lua>)
- [scripts/tele_json.lua](<../../Teleportato 756229217/scripts/tele_json.lua>)
- [scripts/TELE_STRINGS.lua](<../../Teleportato 756229217/scripts/TELE_STRINGS.lua>)
- [scripts/upvaluehacker.lua](<../../Teleportato 756229217/scripts/upvaluehacker.lua>)


## Erneute Prüfung: Transfersatz, Shardantworten und Wiederherstellung

[`Teleportato 756229217/scripts/components/worldjump.lua`](<../../Teleportato 756229217/scripts/components/worldjump.lua>) bildet die Kette: persistenten Spielertransfer laden → Spawnlistener → SaveRecords sammeln → optionale Shardantworten → Transfersatz schreiben → Reset anfordern → UserID-/Sessiongebundener Restore. GetPersistentString ist callbackbasiert; anschließend aus player_data abgeleitete Flags haben keine ausdrückliche gemeinsame Load-abgeschlossen-Schranke. Resetaufruf beweist weder bestätigten Schreibabschluss noch erfolgreiche nächste Welt.

Gleicher Charakter mit vollständiger Saveoption übernimmt viele Character-/Componentdaten; sonst werden gezielt Alter/Builder/Inventory/Skins und Healthanteil rekonstruiert. Der erste Pfad ruft Prefab-OnPreLoad/OnLoad vor der eigenen Component-OnLoad-Schleife. Das weicht von [`entityscript.lua`](<../../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) SetPersistData ab: OnPreLoad, Components über pairs, Prefab-OnLoad, später PostPass. Leere newents und ausgelassener PostPass rekonstruieren Beziehungen nicht vollständig. WX-78 erhält Sonderbehandlung. xpcall protokolliert Restorefehler, trotzdem kann UserID als erledigt eingetragen werden; kein atomarer Retry.

Bulk-Save erzeugt Records vor irreplaceable-Drops, Einzelspielerpfad danach: unterschiedliche eingeschlossene Items. Eine wiederverwendete stats_data-Tabelle steht außerhalb der Spielerschleife; mehrere UserIDs können dieselbe veränderte Tabelle referenzieren. Für neue Transfers pro Benutzer unabhängige Datensätze und expliziten Uniqueitemausschluss verwenden.

[`Teleportato 756229217/modmain.lua`](<../../Teleportato 756229217/modmain.lua>) und [`Teleportato 756229217/scripts/components/shard_teleplayersave.lua`](<../../Teleportato 756229217/scripts/components/shard_teleplayersave.lua>) verwenden externe GemCore-APIs AddShardComponent/AddShardRPCHandler/SendShardRPCToServer. Das ist kein gleichnamiges Vanilla-ModRPC-Protokoll. Antwortzähler hat keinen expliziten Epoch-/Deduplizierungsvertrag; doppelte/verspätete Antwort kann die Anzahl verfälschen. Request-Netbool wird true, kein fortlaufender Requestcode. SetPersistentString-Schreibbestätigung wird vor Reset nicht über Callback synchronisiert.

Auditauftrag für eigene Weltwechsel: versioniertes Format; Request-ID und UserID; deduplizierte vollständige Shards oder definierter Abbruch; Schreiben bestätigen; idempotenter Restore mit Fehlerstatus; vor Commit keine einzige Kopie verwerfen. Native Reset-/Speicheratomarität und externe GemCoreversion bleiben offen. Tests: fehlende Caveantwort, doppelte Jumps, Disconnect während Snapshot, anderer Charakter, verlorene Referenz, Fehler mitten im Loader, erneuter Start nach teilweisem Restore. Keine universelle ungeprüfte Resetvorlage.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
