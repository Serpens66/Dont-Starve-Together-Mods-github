# Breakable Ice – alter Prefabport und Temperaturcomponent

**Prüfart:** statische Ablaufanalyse; Architektur und wesentliche Pfade beschrieben; offene Spezialverträge unten. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `Breakable Ice 385979230`.

## Einstieg und Abhängigkeiten

Prefab-/Componentdateien enthalten portierte Pond-/Ice-/Crystallizable-Inhalte. modmain registriert Hooks/optionale Descriptorintegration. Dateien unter data/prefabs sind historische Beispiele; ihre bloße Existenz beweist keine Registrierung als aktuelle PrefabFiles.

## Initialisierung, Interaktion und Serverwirkung

crystallizable sammelt Temperaturwirkung und entscheidet über Kristall-/Bruchzustand. Prefabhooks ergänzen Interaktionen mit gefrorenen Ponds. Der aktive Einstieg ist von alten Vollprefabkopien getrennt zu lesen: Vanilla konstruiert aktuelle Pondentity, PostInit ergänzt sie; ein alter Pondcode überschreibt nicht automatisch das ganze Prefab.

## Replikation, UI, Speicherung und Wiederherstellung

Save-/Loadwrapper halten eigenen Zustand, aber Signaturen sind kritisch. Prefab-OnLoad erhält inst,data,newents, Component-OnLoad self,data,newents. Client muss Interaktion aus Tags/Replica ableiten können; allein serverseitiges Componentfeld reicht dafür nicht.

## Cleanup und Lebensdauer

Temperaturtasks/Entityentfernung und Bruch dürfen nur einmal Drops/Statewechsel auslösen. Ältere Action-/Animationstexte nicht als heutigen Componentvertrag übernehmen.

## Aktuelle Vanilla-Kette

[Breakable Ice 385979230/scripts/components/crystallizable.lua — AddTemperature](<../../Breakable Ice 385979230/scripts/components/crystallizable.lua>) (Zeile 147) → [prefabs/pond.lua — OnLoad](<../../../_scripts/scripts_02_10_2026/scripts/prefabs/pond.lua>) (Zeile 194) / [components/temperature.lua — OnUpdate](<../../../_scripts/scripts_02_10_2026/scripts/components/temperature.lua>) (Zeile 55) → [entityscript.lua — SetPersistData](<../../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 1954).

## Altlasten und konkrete Prüfgrenze

Historischer OnLoad(data)-Wrapper in modmain passt nicht zum aktuellen Prefabvertrag; inst kann fälschlich als data behandelt werden. Der vollständige portierte Eiscontent und Assetpfad ist nicht als heutiger DST-Stand bestätigt. Konkrete verbleibende Grenze: saisonale Übergänge und Clientzustand müssen vor neuen Eisfeatures vollständig neu entworfen/getestet werden.

## Szenarien für die spätere Laufzeitabnahme

Pond friert/taut, wiederholter Bruch, Save/Load in jeder Phase, Temperaturänderung bei Sleep/Wake, Clientaktion unter Lag. Dedicated, Cavepond und neues Spielupdate. Alte data/prefabs-Kopien nicht ungeprüft aktivieren.

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Dateiregister: Breakable Ice 385979230

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [data/configs/pond.lua](<../../Breakable Ice 385979230/data/configs/pond.lua>)
- [data/globals.lua](<../../Breakable Ice 385979230/data/globals.lua>)
- [data/prefabs/pond.lua](<../../Breakable Ice 385979230/data/prefabs/pond.lua>)
- [libs/env.lua](<../../Breakable Ice 385979230/libs/env.lua>)
- [libs/mod_env.lua](<../../Breakable Ice 385979230/libs/mod_env.lua>)
- [libs/reflection.lua](<../../Breakable Ice 385979230/libs/reflection.lua>)
- [libs/use.lua](<../../Breakable Ice 385979230/libs/use.lua>)
- [modinfo.lua](<../../Breakable Ice 385979230/modinfo.lua>)
- [modmain.lua](<../../Breakable Ice 385979230/modmain.lua>)
- [scripts/components/crystallizable.lua](<../../Breakable Ice 385979230/scripts/components/crystallizable.lua>)


## Erneute Prüfung: aktive Phasen und konkrete Sprach-/Restorefehler

libs/use lädt eine eigene GLOBAL-Fallbackumgebung und den aktiven Pondpostinit aus [`Breakable Ice 385979230/data/prefabs/pond.lua`](<../../Breakable Ice 385979230/data/prefabs/pond.lua>). Andere alte Vollprefabs sind nicht allein durch Dateiexistenz aktiv. Diese besondere Umgebung gilt nicht für normales modmain.

[`Breakable Ice 385979230/scripts/components/crystallizable.lua`](<../../Breakable Ice 385979230/scripts/components/crystallizable.lua>) sammelt Temperatur/Clocksegmente, prüft Growth/Schelle, setzt Established und Anfangsdicke. Ticks erhöhen/vermindern Dicke; unter null folgt Destroyed und erneute Bildung. Saisonwatcher reduzieren Dicke. Pondlistener schalten Bild, Fishable, Kollision, Pflanzen, Watersource und MINE-Workable; Arbeit liefert Eis und ändert Dicke. Frozenanimation beweist keine konsistente Clientaktion.

`not snowlevel == 0` negiert vor Vergleich und ist für numerische snowlevel immer false, nicht snowlevel~=0. Der Prefab-OnLoad-Wrapper function(data) erhält bei [`entityscript.lua`](<../../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) dagegen inst als ersten Parameter und delegiert damit falsche Daten. Crystallizable-Load überschreibt gespeichertes false durch `or true`; Save hält timer.delay, Load liest data.delay. Beim Neuplanen wird eine alte Taskreferenz auf nil gesetzt ohne zwingendes Cancel; gespeicherte Delaylänge ist keine verbleibende Deadline.

Heute trennt [`prefabs/pond.lua`](<../../../_scripts/scripts_02_10_2026/scripts/prefabs/pond.lua>) gespeicherte plants-Offsets von plant_ents. Portlogik verwendet alte Decorstrukturen; Persistenz/neue Pflanzen/Load/Sleep müssen gemeinsam betrachtet werden. [Isolierte Tests](../tests/README.md) bestätigen nur Lua-Negation und Tabellenwerte. Für neue Eisfeatures versionierte Phasen/Restzeit, Taskcancel, einmalige Rekonstruktion und aktuellen Pond-/Collision-/Watersourcevertrag entwerfen. Saison, gefrorener Load, wiederholter Bruch, Clientlatejoin und Assetkompatibilität bleiben offen.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
