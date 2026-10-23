# Room und Task mit Vanilla-Layout

Eigenständiger Modordner: den gesamten Inhalt dieses Ordners einschließlich `scripts` in einen neuen lokalen Modordner kopieren; nicht nur modmain in eine andere Vorlage einfügen. Vanilla-Assets benötigen keine eigenen Exporte. Die Beispieldateien haben eindeutige Namen. Vor Integration Namen, Konfiguration, Ladeordnung und gleichzeitige andere Hooks prüfen.

## Dateien und Zuständigkeit

- `modinfo.lua`
- `modmain.lua`
- `modworldgenmain.lua`

## Funktionsweise und Grenzen

Nur bei Generierung des Forest-Tasksets default kommt ein zusätzlicher Task hinzu. Der Room verteilt Gras/Blumen und fordert ein SimpleBase-Layout an. Dichte und Gewichte sind verschiedene Größen; countstaticlayouts benutzt den Layout-Konverter. Kein Umbau bestehender Saves, kein garantierter Startplatz und keine Höhlenänderung. Für Adventure/tasksetclassic registriert dieser Hook nichts. Locks/Keys sind im Vanilla-Forest-Muster gewählt; daraus folgt keine Garantie für beliebige fremde Progressionsgraphen.

## Quellenkette des statischen Audits

[modutil.lua — env.AddRoom = function](<../../../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 302) → [map/rooms.lua — AddModRoom](<../../../../_scripts/scripts_02_10_2026/scripts/map/rooms.lua>) (Zeile 27); [map/tasks/dst_tasks_forestworld.lua — Make a pick](<../../../../_scripts/scripts_02_10_2026/scripts/map/tasks/dst_tasks_forestworld.lua>) (Zeile 8); [map/tasksets/forest.lua — AddTaskSet("default"](<../../../../_scripts/scripts_02_10_2026/scripts/map/tasksets/forest.lua>) (Zeile 2) → [map/level.lua — ChooseTasks](<../../../../_scripts/scripts_02_10_2026/scripts/map/level.lua>) (Zeile 89) → [map/graphnode.lua — countstaticlayouts](<../../../../_scripts/scripts_02_10_2026/scripts/map/graphnode.lua>) (Zeile 259) → [map/object_layout.lua — local function Convert(](<../../../../_scripts/scripts_02_10_2026/scripts/map/object_layout.lua>) (Zeile 509) → [map/layouts.lua — SimpleBase](<../../../../_scripts/scripts_02_10_2026/scripts/map/layouts.lua>) (Zeile 253).

## Testprotokoll – offen, keine Spielinstanz gestartet

1. Mindestens drei neue Forest-default-Welten mit verschiedenen Seeds erzeugen; task/room/layout in Worldgen-Log und Karte suchen. Layoutplatzierung kann scheitern und muss am Log beurteilt werden.
2. Clientbeitritt und Dedicated-Generierung prüfen; kein Runtime-Hook erforderlich.
3. Bestehenden Save laden: kein neuer Room erwartet. Save/Load und Reconnect erhalten generierte Objekte über normale Persistenz.
4. Höhlen und alternative Tasksets unverändert; Shardwechsel testet nur bestehende Weltobjekte, keine erneute Generierung.

Syntaxprüfung mit `luac5.1.exe -p` prüft weder Engine-Globals noch Assets, Prediction oder Multiplayer. Ergebnisse stehen im [Prüfbericht](../../VALIDATION.md). Für ein neues Projekt außerdem den [Workflow](../../20_Projektworkflow.md) und die [Checklisten](../../19_Checklisten.md) verwenden.


## Erneute statische Prüfung

Ladeumgebung, Registrierungen, Vanilla-Aufrufer, Rollen, Speicherung und Cleanup erneut geprüft. [Vorlagenmatrix](../../24_Statische_Vertragspruefung.md#zwölf-vorlagen-geprüfte-schnittstellen) benennt Sonderfälle und Grenzen. [Isolierte Tests](../../tests/README.md) gelten nur für die dort genannten Logikpfade, keine Laufzeitabnahme dieser Mod.
