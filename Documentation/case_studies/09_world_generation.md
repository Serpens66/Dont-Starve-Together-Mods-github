# Worldgen – Verteilungen und Setpieces

**Prüfart:** statische Ablaufanalyse; wesentlicher Ablauf beschrieben. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `Advanced World Generation (without infuse!) 756647525`, `Increase Animals 758921911`.

## Einstieg und Abhängigkeiten

Advanced World Generation verändert Forest-/Cave-Tasksets und deren set_pieces/count/tasks. Increase Animals registriert RoomPreInit-Hooks, Terrainfilter sowie zusätzliche Layoutdaten. Die Runtime-Einstiege sind nicht der Ort, an dem existierende Weltobjekte nachträglich vervielfacht werden.

## Initialisierung, Interaktion und Serverwirkung

Advanced filtert taskset.location, setzt optionale Taskanzahlen und Layoutanzahlen mit erlaubten Tasknamen. Increase wählt Roommengen aus Config, vereinigt diese, verteilt clockwork auf bishop/knight, verändert contents.distributepercent und distributeprefabs. [Increase Animals 758921911/modworldgenmain.lua — AddAnimaltoWorldGeneration](<../../Increase Animals 758921911/modworldgenmain.lua>) (Zeile 122) versucht zusätzliche Dichte unter Erhaltung vorhandener Anteile zu berechnen. Terrainfilter verhindern unerwünschte Bodentypen. Ein Layout ist ein eigener Platzierungsweg, kein Eintrag in derselben Gewichtstabelle.

## Replikation, UI, Speicherung und Wiederherstellung

Worldgen arbeitet vor Runtime und erzeugt Savewelt/Entities. Es gibt keine Netvar für diese Häufigkeit; Clients erhalten die erzeugte Welt. Bestehende Saves werden durch Room-Hooks nicht neu generiert. Ein Seedvergleich muss Konfiguration, aktives Taskset und weitere Worldgenmods konstant halten. Tasks, Rooms und Layoutdefinitionen sind Abhängigkeiten mit exakten Namen.

## Cleanup und Lebensdauer

Kein laufender Polltask und keine eigene Reconnect-Persistenz. Generierungsfehler werden am Worldgenlog untersucht; Layoutreservierung kann an Terrain/Platz scheitern. Wiederholtes Hookregistrieren und geteilte Definitions-Tabellen vermeiden; Modnamen für zusätzliche Rooms/Tasks eindeutig wählen.

## Aktuelle Vanilla-Kette

[map/rooms.lua — AddModRoom](<../../../_scripts/scripts_02_10_2026/scripts/map/rooms.lua>) (Zeile 27) → [map/tasksets.lua — GetGenTasks](<../../../_scripts/scripts_02_10_2026/scripts/map/tasksets.lua>) (Zeile 9) → [map/level.lua — ChooseTasks](<../../../_scripts/scripts_02_10_2026/scripts/map/level.lua>) (Zeile 89) → [map/graphnode.lua — distributepercent](<../../../_scripts/scripts_02_10_2026/scripts/map/graphnode.lua>) (Zeile 449) / [map/graphnode.lua — countstaticlayouts](<../../../_scripts/scripts_02_10_2026/scripts/map/graphnode.lua>) (Zeile 259) → [map/object_layout.lua — ReserveAndPlaceLayout](<../../../_scripts/scripts_02_10_2026/scripts/map/object_layout.lua>) (Zeile 294).

## Altlasten und konkrete Prüfgrenze

Kommentar in Increase behauptet, fehlende Rooms würden durch AddRoomPreInit angelegt. Die Hookkette ist kein Ersatz für AddRoom; nur tatsächlich geladene Roomdefinitionen durchlaufen die Initialisierung. Tabellengewichte können strukturierte Einträge haben: nicht alle Werte schlicht addieren. Historische Task-/Layoutnamen sind gegenüber aktueller Definition zu prüfen. Native Graphplatzierung und exakte statistische Spawnzahlen bleiben Seed-/Laufzeitfragen.

## Szenarien für die spätere Laufzeitabnahme

Jede Mod einzeln: mehrere Forest/Cave-Seeds bei default und Extremconfig; pro Room Dichte und Population vergleichen. Kombiniert Reihenfolge prüfen. Save/Load/Clientbeitritt erzeugt keine zweite Population. Worldgenfehler bei fehlendem Layout und nicht gewählten Task unterscheiden. Aktuelles minimales Muster: [Room/Task](../templates/11_room_task/README.md).

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Dateiregister: Advanced World Generation (without infuse!) 756647525

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../Advanced World Generation (without infuse!) 756647525/modinfo.lua>)
- [modmain.lua](<../../Advanced World Generation (without infuse!) 756647525/modmain.lua>)
- [modworldgenmain.lua](<../../Advanced World Generation (without infuse!) 756647525/modworldgenmain.lua>)


## Dateiregister: Increase Animals 758921911

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../Increase Animals 758921911/modinfo.lua>)
- [modmain.lua](<../../Increase Animals 758921911/modmain.lua>)
- [modworldgenmain.lua](<../../Increase Animals 758921911/modworldgenmain.lua>)
- [scripts/map/layouts/juicyberryfarm.lua](<../../Increase Animals 758921911/scripts/map/layouts/juicyberryfarm.lua>)
- [scripts/map/layouts/layouts.lua](<../../Increase Animals 758921911/scripts/map/layouts/layouts.lua>)
- [scripts/map/layouts/PigGuardsWithChest12.lua](<../../Increase Animals 758921911/scripts/map/layouts/PigGuardsWithChest12.lua>)
- [scripts/map/layouts/PigGuardsWithChest4.lua](<../../Increase Animals 758921911/scripts/map/layouts/PigGuardsWithChest4.lua>)
- [scripts/map/layouts/PigGuardsWithChest7.lua](<../../Increase Animals 758921911/scripts/map/layouts/PigGuardsWithChest7.lua>)
- [scripts/map/layouts/TrapSummer.lua](<../../Increase Animals 758921911/scripts/map/layouts/TrapSummer.lua>)
- [scripts/map/layouts/TrapWinter.lua](<../../Increase Animals 758921911/scripts/map/layouts/TrapWinter.lua>)
- [scripts/map/layouts/TrapWinterDec.lua](<../../Increase Animals 758921911/scripts/map/layouts/TrapWinterDec.lua>)
- [scripts/map/static_layouts/pigguards2.lua](<../../Increase Animals 758921911/scripts/map/static_layouts/pigguards2.lua>)
- [scripts/map/static_layouts/pigguards_b2.lua](<../../Increase Animals 758921911/scripts/map/static_layouts/pigguards_b2.lua>)
- [scripts/map/static_layouts/pigguards_easy2.lua](<../../Increase Animals 758921911/scripts/map/static_layouts/pigguards_easy2.lua>)
- [scripts/scenarios/chest_totalrandom.lua](<../../Increase Animals 758921911/scripts/scenarios/chest_totalrandom.lua>)


## Erneute Prüfung: Registrierung gegenüber Generierung

Beide Worldgenmods ändern Daten während modworldgenmain. AddRoomPreInit verändert existierende Roomdefinition; erzeugt keine neue fehlende Roomregistry. Level/Tasksetänderung, Layouttabelle und Roomdichte sind separate Eingriffe. Increase Animals lädt zusätzliche Layoutmodule; Advanced World Generation verändert Tasksetzusammenstellung. Reihenfolge und Namescollision mit anderen Mods beeinflussen resultierende Daten.

Der heutige Taskkonstruktor normalisiert skalare Locks/Keys zu Tabellen. AddModTask prüft vorhandene Namen; für eigene Tasks konfliktfreie IDs verwenden. Default-Foresttaskset enthält Starttasks, optionale Tasks, notwendige Prefabs und Setpieces: bloß Tasks ersetzen kann einen gültigen Start oder notwendige Ressourcen verlieren. Dichtegewichte sind keine garantierten absoluten Stückzahlen. Native Graph-/Layoutplatzierung und statistische Häufigkeit bleiben über mehrere Seeds zu prüfen; keine bestehende Welt wird durch den Hook rückwirkend neu generiert.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
