# Adventure Mode – Erweiterung des Teleportato-Protokolls

**Prüfart:** statische Ablaufanalyse; Architektur und wesentliche Pfade beschrieben; offene Spezialverträge unten. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `Adventure Mode 1847959350`.

## Einstieg und Abhängigkeiten

Abhängig von Teleportato und dessen TUNING.TELEPORTATOMOD, adv_helpers, adventurejump/worldjump und Callbackslots. modworldgenmain definiert Kapitel-/Task-/Room-/Layoutdaten; Runtime modmain ergänzt Lobby, Story und Startwelt. Importierte ADVENTURE_STRINGS liefern Textbestand für historische Inhalte.

## Initialisierung, Interaktion und Serverwirkung

Worldgen wählt Kapitelwelt und Setpieces. Runtime wartet auf Levelinformationen, verkettet functionatplayerfirstspawn und functionpostloadworldONCE mit vorigen Funktionen. Diese richten Startinventar, Licht/Maxwellansprache, Wormholeverbindungen und kapitelbezogene Änderungen ein. [Adventure Mode 1847959350/modmain.lua — SpawnMaxwell](<../../Adventure Mode 1847959350/modmain.lua>) (Zeile 211) beginnt zeitgesteuerte Storyinteraktion; eigene maxwelltalker/maxlightspawner ergänzen vorhandene Entities. Kapitelwechsel delegiert an Teleportato statt eine unabhängige zweite Weltresetarchitektur zu bilden.

## Replikation, UI, Speicherung und Wiederherstellung

forest_network-Netstring synchronisiert die erzwungene Charakterauswahl/Lobby; Player-Netbools melden Ansprache/Cutscenezustand. Startinventar wird zwischengespeichert und kapitelabhängig vergeben. adventurejump speichert Kapitelinformationen; wormhole-/Startstuffdaten liegen in Teleportato-Komponenten. Reconnect darf einmalige Startgeschenke und Worldsetup nicht erneut ausführen. OnLoad von Storycomponents und gespeicherte Worldflags gehören zur Wiederherstellung, nicht bloß erneute Ausführung aller Startupcallbacks.

## Cleanup und Lebensdauer

Thread-/Tasklebensdauer von Cutscenes, zerstörtem Maxwell, Disconnect und Weltreset getrennt behandeln. Verbundene Wormholes sind Entityreferenzen; neue Welt braucht neue Verbindung, kein Wiederverwenden alter GUIDs. Ersetzte Managerfunktionen zum Entfernen spezieller Inseln sind invasive kapitelabhängige Eingriffe.

## Aktuelle Vanilla-Kette

[prefabs/forest.lua — world](<../../../_scripts/scripts_02_10_2026/scripts/prefabs/forest.lua>) (Zeile 1) / [prefabs/forest_network.lua — net](<../../../_scripts/scripts_02_10_2026/scripts/prefabs/forest_network.lua>) (Zeile 1) → [prefabs/wormhole.lua — OnSave](<../../../_scripts/scripts_02_10_2026/scripts/prefabs/wormhole.lua>) (Zeile 95) / [components/teleporter.lua — LoadPostPass](<../../../_scripts/scripts_02_10_2026/scripts/components/teleporter.lua>) (Zeile 410) → [components/teleporter.lua — targetTeleporter](<../../../_scripts/scripts_02_10_2026/scripts/components/teleporter.lua>) (Zeile 11) → [components/playerspawner.lua — Spawn](<../../../_scripts/scripts_02_10_2026/scripts/components/playerspawner.lua>) (Zeile 2); Callback-/Persistenzbasis siehe [Teleportato](11_teleportato.md).

## Altlasten und konkrete Prüfgrenze

Diese Architektur umfasst Hauptübergang, Lobby und Start-/Storypfade, nicht den Nachweis jeder Kapitelplatzierung und neueren Weltboss-Sonderregel. Teleportato-Callbacknamen sind Modverträge und benötigen passende Version/Ladepriorität. Task0/0.5/2 ersetzt keine belastbare Bereitschaftsbedingung, wenn die Abhängigkeit asynchron lädt. Missing Setpieces, Charaktermod-Kompatibilität und Startstuff-Doppelvergabe bleiben konkrete Abnahmepunkte.

## Szenarien für die spätere Laufzeitabnahme

Alle Kapitel nacheinander; frischer Spieler, wiederkehrender Spieler und Zuschauer, Host/Client-Lobby, erzwungene Charakterwahl. Save/Load mitten in Ansprache, Reconnect nach Cutscene, Startinventar genau einmal. Forest/Cave und Kapitelwechsel mit Offlineprofilen. Abhängigkeit fehlt/falsche Version: verständlicher Fehler statt Teilinitialisierung.

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Dateiregister: Adventure Mode 1847959350

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../Adventure Mode 1847959350/modinfo.lua>)
- [modmain.lua](<../../Adventure Mode 1847959350/modmain.lua>)
- [modworldgenmain.lua](<../../Adventure Mode 1847959350/modworldgenmain.lua>)
- [scripts/adv_helpers.lua](<../../Adventure Mode 1847959350/scripts/adv_helpers.lua>)
- [scripts/ADVENTURE_STRINGS.lua](<../../Adventure Mode 1847959350/scripts/ADVENTURE_STRINGS.lua>)
- [scripts/components/maxlightspawner.lua](<../../Adventure Mode 1847959350/scripts/components/maxlightspawner.lua>)
- [scripts/components/maxwelltalker.lua](<../../Adventure Mode 1847959350/scripts/components/maxwelltalker.lua>)
- [scripts/map/layouts/ImpassableBlock.lua](<../../Adventure Mode 1847959350/scripts/map/layouts/ImpassableBlock.lua>)
- [scripts/map/layouts/TeleportatoRingLayoutSanityRocks.lua](<../../Adventure Mode 1847959350/scripts/map/layouts/TeleportatoRingLayoutSanityRocks.lua>)
- [scripts/map/static_layouts/adventure_portal_layoutnew.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/adventure_portal_layoutnew.lua>)
- [scripts/map/static_layouts/bargain_start_fixed.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/bargain_start_fixed.lua>)
- [scripts/map/static_layouts/bargain_start_new.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/bargain_start_new.lua>)
- [scripts/map/static_layouts/blue_mushy_entrance.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/blue_mushy_entrance.lua>)
- [scripts/map/static_layouts/cave_art_test_start.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/cave_art_test_start.lua>)
- [scripts/map/static_layouts/cave_test_start.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/cave_test_start.lua>)
- [scripts/map/static_layouts/default_startmaxwellhome.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/default_startmaxwellhome.lua>)
- [scripts/map/static_layouts/maxwellhome_fixed.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/maxwellhome_fixed.lua>)
- [scripts/map/static_layouts/nightmare_fixed.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/nightmare_fixed.lua>)
- [scripts/map/static_layouts/nightmare_new.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/nightmare_new.lua>)
- [scripts/map/static_layouts/nightmare_start_easy.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/nightmare_start_easy.lua>)
- [scripts/map/static_layouts/presummer_start_fixed.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/presummer_start_fixed.lua>)
- [scripts/map/static_layouts/presummer_start_new.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/presummer_start_new.lua>)
- [scripts/map/static_layouts/ruins_start.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/ruins_start.lua>)
- [scripts/map/static_layouts/ruins_start2.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/ruins_start2.lua>)
- [scripts/map/static_layouts/test.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/test.lua>)
- [scripts/map/static_layouts/thismeanswar_start_fixed.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/thismeanswar_start_fixed.lua>)
- [scripts/map/static_layouts/wes_unlock.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/wes_unlock.lua>)
- [scripts/map/static_layouts/winter_start_easy_fixed.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/winter_start_easy_fixed.lua>)
- [scripts/map/static_layouts/winter_start_easy_new.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/winter_start_easy_new.lua>)
- [scripts/map/static_layouts/winter_start_hard.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/winter_start_hard.lua>)
- [scripts/map/static_layouts/winter_start_medium_fixed.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/winter_start_medium_fixed.lua>)
- [scripts/map/static_layouts/winter_start_medium_new.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/winter_start_medium_new.lua>)
- [scripts/map/static_layouts/winter_start_vhard.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/winter_start_vhard.lua>)
- [scripts/map/static_layouts/wormhole_mod.lua](<../../Adventure Mode 1847959350/scripts/map/static_layouts/wormhole_mod.lua>)
- [scripts/prefabs/diviningrodstart.lua](<../../Adventure Mode 1847959350/scripts/prefabs/diviningrodstart.lua>)
- [scripts/prefabs/maxwell.lua](<../../Adventure Mode 1847959350/scripts/prefabs/maxwell.lua>)
- [scripts/prefabs/maxwellendgame.lua](<../../Adventure Mode 1847959350/scripts/prefabs/maxwellendgame.lua>)
- [scripts/prefabs/maxwellhead.lua](<../../Adventure Mode 1847959350/scripts/prefabs/maxwellhead.lua>)
- [scripts/prefabs/maxwellhead_trigger.lua](<../../Adventure Mode 1847959350/scripts/prefabs/maxwellhead_trigger.lua>)
- [scripts/prefabs/maxwellintro.lua](<../../Adventure Mode 1847959350/scripts/prefabs/maxwellintro.lua>)
- [scripts/prefabs/maxwellkey.lua](<../../Adventure Mode 1847959350/scripts/prefabs/maxwellkey.lua>)
- [scripts/prefabs/maxwelllight_flame.lua](<../../Adventure Mode 1847959350/scripts/prefabs/maxwelllight_flame.lua>)
- [scripts/prefabs/maxwelllight_p.lua](<../../Adventure Mode 1847959350/scripts/prefabs/maxwelllight_p.lua>)
- [scripts/prefabs/maxwelllock.lua](<../../Adventure Mode 1847959350/scripts/prefabs/maxwelllock.lua>)
- [scripts/prefabs/maxwellphonograph.lua](<../../Adventure Mode 1847959350/scripts/prefabs/maxwellphonograph.lua>)
- [scripts/prefabs/maxwellthrone.lua](<../../Adventure Mode 1847959350/scripts/prefabs/maxwellthrone.lua>)
- [scripts/prefabs/paired_maxwelllight.lua](<../../Adventure Mode 1847959350/scripts/prefabs/paired_maxwelllight.lua>)
- [scripts/prefabs/teleportato_checkmate.lua](<../../Adventure Mode 1847959350/scripts/prefabs/teleportato_checkmate.lua>)
- [scripts/prefabs/teleportlocation.lua](<../../Adventure Mode 1847959350/scripts/prefabs/teleportlocation.lua>)
- [scripts/scenarios/chest_presummer.lua](<../../Adventure Mode 1847959350/scripts/scenarios/chest_presummer.lua>)
- [scripts/scenarios/chest_random_good.lua](<../../Adventure Mode 1847959350/scripts/scenarios/chest_random_good.lua>)
- [scripts/scenarios/chest_total_random.lua](<../../Adventure Mode 1847959350/scripts/scenarios/chest_total_random.lua>)
- [scripts/scenarios/packloot_nightmare.lua](<../../Adventure Mode 1847959350/scripts/scenarios/packloot_nightmare.lua>)
- [scripts/scenarios/packloot_winter_start_medium.lua](<../../Adventure Mode 1847959350/scripts/scenarios/packloot_winter_start_medium.lua>)
- [scripts/scenarios/scen_shadowpieces.lua](<../../Adventure Mode 1847959350/scripts/scenarios/scen_shadowpieces.lua>)
- [scripts/tasksroomslayouts.lua](<../../Adventure Mode 1847959350/scripts/tasksroomslayouts.lua>)


## Erneute Prüfung: Registry, Startzustände und Nebenobjekte

Die aktive [`Adventure Mode 1847959350/modworldgenmain.lua`](<../../Adventure Mode 1847959350/modworldgenmain.lua>) registriert acht Welten. Eine Siebener-Fallbackliste ist nicht die vollständige Registry:

| Name | Forestfunktion | Defaultpositionen |
|---|---|---|
| Maxwells Door | AdventurePortalWorld | 1 |
| A Cold Reception | AdventureColdReception | 2,3,4 |
| King of Winter | AdventureKingWinter | 2,3,4,5 |
| The Game is Afoot | AdventureGameAfoot | 2,3,4,5 |
| Archipelago | AdventureArchipelago | 2,3,4,5 |
| Two Worlds | AdventureTwoWorlds | 4,5 |
| Darkness | AdventureDarkness | 6 |
| Checkmate | AdventureMaxwellHome | 7 |

AlwaysTinyCave reduziert Cave auf CaveExitTask1, löscht optionale Tasks/Setpieces und setzt gültigen Start. Forestfunktionen bestimmen Tasks/Startlocation/Saison/Gefahren/Inseln; PortalWorld unterscheidet Sandboxvorkonfiguration, Darkness dunkle Tagesgestaltung, Checkmate MaxHome. Teleportatos Registry/Kapitelpersistenz verbindet Generierung mit Runtime; Registryänderung ändert kein bestehendes Terrain.

[`Adventure Mode 1847959350/modmain.lua`](<../../Adventure Mode 1847959350/modmain.lua>) verkettet Startcallbacks und verzögert Hilfen auf Tasks nach Worldinitialisierung. Spielerhilfe, Dialogbeginn und einmalige Welthilfe sind verschiedene Zustände. Archipelago verknüpft zehn Wormhole-Enden; erst bei erfolgreicher Verbindung sperrt es SEAFARING-Rezepte auf TECH.LOST. Bei Fehler bleiben Boote als Ausweg; Two Worlds prüft seine eigene Verbindung.

[`Adventure Mode 1847959350/scripts/components/maxwelltalker.lua`](<../../Adventure Mode 1847959350/scripts/components/maxwelltalker.lua>) steuert Threads, Dialogabschnitte, Controller/HUD/Kamera und Clientanimation/Sounds, Kapitelabschluss spawnt ggf. Gegner/Items serverseitig. Er besitzt keine allgemeine eigene OnSave-/OnLoad-Routine. StopTalking beendet Task/Sound/Speech, stellt nicht sämtliche veränderten UI-/Controllerzustände zurück. Dialogabbruch/Tod/Entfernung brauchen explizite Rückbauprüfung.

[`Adventure Mode 1847959350/scripts/components/maxlightspawner.lua`](<../../Adventure Mode 1847959350/scripts/components/maxlightspawner.lua>) speichert Light-GUIDs+Referenzen, übernimmt Entities im LoadPostPass. SpawnAllLights erzeugt bei numlights<maxlights die volle Maximalzahl statt Differenz: Eine erhaltene von zwei Leuchten kann um zwei ergänzt werden. Fehlende GUIDs/doppelte Ownership/Maxänderung sind Restorefälle. Ein vollständiger Nebenlichtcleanup darf nicht vorausgesetzt werden. Offen: Lobbyzwang/Reconnect, Shardjump, Dialogabbruch, fehlende Wormholes und Load mit einer erhaltenen Leuchte.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
