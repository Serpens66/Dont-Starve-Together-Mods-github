# More Worldsettings – Option, Tuning und laufender Timer

**Prüfart:** statische Ablaufanalyse; wesentlicher Ablauf beschrieben. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `More Worldsettings 2838382897`.

## Einstieg und Abhängigkeiten

modworldgenmain lädt Mapping-/Hilfsmodule, erzeugt Customizegruppen, Optionen, Bilder und WorldSettings-Overrides. Runtime modmain bindet passende Pickables an die Worldsettingsutil-Helfer. Übersetzungstabellen lösen Abweichungen zwischen Prefab-, Tuning- und Bildnamen auf.

## Initialisierung, Interaktion und Serverwirkung

Die Optionsoberfläche allein bewirkt nichts. Override-Pre verändert Tuning, bevor Prefabs entstehen. [More Worldsettings 2838382897/modmain.lua — WorldSettings_Pickable_RegenTime](<../../More Worldsettings 2838382897/modmain.lua>) (Zeile 41) bindet serverseitige Pickables mit baseregentime und ohne bestehenden externen Timer an Worldsettingsutil. OnPreLoad ruft bisherigen Handler und danach WorldSettings_Pickable_PreLoad, damit alte Timerdaten zur neuen Skalierung passen. Bananabush ersetzt stage.time-Funktionen separat; Growable ist ein anderer Vertrag.

## Replikation, UI, Speicherung und Wiederherstellung

Werte liegen in Welt-Overrides/Save, nicht in einer eigenen UI-Netvar. Optionen werden über Vanilla-Welteinstellungspfad auf Shards angewandt; Regeneration benutzt worldsettingstimer bzw. jeweilige Component. Reload unter anderer Config benötigt PreLoad-Konvertierung, nicht bloß Änderung zukünftiger Regrowzeit. Nach Reconnect zeigt Standard-Welteinstellungs-UI die gespeicherten Werte; kein Modwidget nötig.

## Cleanup und Lebensdauer

Pickable/Welt-Timer besitzen eigene Componentcleanup-Pfade. Keine zweite Timerquelle parallel starten. Bei remove_when_picked gibt es keine Regeneration; der Hook nimmt solche Prefabs aus. fehlende Mappingwerte/Bilder werden ins Log gemeldet und sind gezielt nachzutragen.

## Aktuelle Vanilla-Kette

[mods.lua — "modworldgenmain.lua"](<../../../_scripts/scripts_02_10_2026/scripts/mods.lua>) (Zeile 445) → [map/customize.lua — GetWorldSettingsFromLevelSettings](<../../../_scripts/scripts_02_10_2026/scripts/map/customize.lua>) (Zeile 805) → [gamelogic.lua — WorldSettings_Overrides.Pre](<../../../_scripts/scripts_02_10_2026/scripts/gamelogic.lua>) (Zeile 386) → [worldsettingsutil.lua — WorldSettings_Pickable_RegenTime](<../../../_scripts/scripts_02_10_2026/scripts/worldsettingsutil.lua>) (Zeile 252) / [worldsettingsutil.lua — WorldSettings_Pickable_PreLoad](<../../../_scripts/scripts_02_10_2026/scripts/worldsettingsutil.lua>) (Zeile 241) → [components/worldsettingstimer.lua — OnLoad](<../../../_scripts/scripts_02_10_2026/scripts/components/worldsettingstimer.lua>) (Zeile 192) → [networkclientrpc.lua — SyncWorldSettings](<../../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>) (Zeile 1571).

## Altlasten und konkrete Prüfgrenze

Mapping und Upvaluezugriffe sind abhängig vom konkreten Scriptstand; Annahme des Modkommentars über zukünftige Klei-Ausweitung ist keine Tatsache. Neue Pickables mit bereits vorhandenem useexternaltimer dürfen nicht doppelt registriert werden. Modulnamen/TUNING-Keys müssen konfliktfrei sein. Liveänderung laufender Timer ist pro Helper nachzuweisen; Growable-Stages nicht automatisch wie Pickable behandeln.

## Szenarien für die spätere Laufzeitabnahme

Gras pflücken, halbe Regrowzeit warten, speichern und mit schneller/langsamer Einstellung laden. Nie-Option, Caveoption, eigener Mod-Pickable und bereits Vanilla-externer Timer. Liveänderung und Neustart; kein doppelter Task. UIbilder und Logwarnungen prüfen. [Timerbeispiel 12](../templates/12_world_option/README.md) zeigt eine klar begrenzte eigene Restzeitregel.

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Dateiregister: More Worldsettings 2838382897

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../More Worldsettings 2838382897/modinfo.lua>)
- [modmain.lua](<../../More Worldsettings 2838382897/modmain.lua>)
- [modworldgenmain.lua](<../../More Worldsettings 2838382897/modworldgenmain.lua>)
- [scripts/define_globals.lua](<../../More Worldsettings 2838382897/scripts/define_globals.lua>)
- [scripts/moresettings_helpers.lua](<../../More Worldsettings 2838382897/scripts/moresettings_helpers.lua>)
- [scripts/strings.lua](<../../More Worldsettings 2838382897/scripts/strings.lua>)
- [scripts/upvaluehacker.lua](<../../More Worldsettings 2838382897/scripts/upvaluehacker.lua>)


## Erneute Prüfung: Zahlen, Tabellen und laufende Timer

Das aktive Worldgenmodul übersetzt MODMULTS-Namen in Zahlen, registriert Customizeitems und verändert WSO.Pre. Zahlen werden multipliziert; GROW_TIME-artige Tabellen ändern base/random in-place, damit gehaltene Tabellenreferenzen weiterhin wirken. Farm-/Weeddefs haben eine andere Tabelle: full/oversized/regrow bleiben ausgeschlossen, andere numerische bzw. Arraystadien werden skaliert. Mehrfach ausgeführte Multiplikation und bereits fremd veränderte Werte sind eigene Reihenfolgefragen.

Der numerische Faktor 1000 setzt bei Regrow außerdem PICKABLE=false; andere Systeme bekommen teils lediglich sehr lange Zeiten. 0.001 ist nahe sofort, nicht die Zahl null. Die Anzeige „never/instant“ beweist daher kein einheitliches Verhalten. modmain rüstet nur geeignete Pickables ohne bestehenden externen Timer nach, verwendet PrefabTuningTansl und verkettet WorldSettings_Pickable_PreLoad. Bananabush verändert growable-stage.time-Funktionen; eine schon laufende gespeicherte Stage wird dadurch nicht automatisch neu terminiert.

GetFittingImage sucht Atlasregionen und fällt auf regrowth zurück. Abwesenheit des Bildes ist getrennt vom fehlenden TUNINGmapping zu diagnostizieren. Alte auskommentierte Saisonlängen-Upvaluebeispiele sind keine aktive Funktion. Neue Einstellungen pro Timersystem mit Quelle des Defaultwerts, Migration von Restzeit, Pause-/Sleepverhalten und actual Runtimeconsumer dokumentieren; Vorlage 12 zeigt dafür einen kleinen eigenen vollständigen Timervertrag, keinen pauschalen Growableersatz.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
