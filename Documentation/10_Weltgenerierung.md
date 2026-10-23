# 10 — Weltgenerierung, Layouts und Einstellungen

## Aufbau und Hook-Kette

| Ebene | Aufgabe |
|---|---|
| Level | Standort, Overrides und ausgewählter Taskset |
| Taskset | Pflicht-/Optionstasks, Setpieces und Startregeln |
| Task | Zusammengehörige Räume und Progressionsanforderungen |
| Room | Boden, Tags und Inhalt eines Kartenbereichs |
| Layout / StaticLayout | Konkrete Gruppe von Objekten beziehungsweise Tiles |
| GraphNode | Räumliche Verteilung des Inhalts |

Level.ChooseTasks holt den Taskset, wendet TaskSetPreInit und Any an, überträgt Daten, wendet LevelPreInit an und verarbeitet Tasks. ApplyModsToTasks ruft TaskPreInit auf. Story.GetRoom kopiert die Raumdefinition und wendet RoomPreInit auf die Kopie an. Ein Hook wird dadurch nur für einen tatsächlich verwendeten Raum relevant.

Belege: [map/level.lua — function Level:ChooseTasks](<../../_scripts/scripts_02_10_2026/scripts/map/level.lua>) (Zeile 89), [map/level.lua — function Level:ApplyModsToTasks](<../../_scripts/scripts_02_10_2026/scripts/map/level.lua>) (Zeile 43), [map/storygen.lua — function Story:GetRoom](<../../_scripts/scripts_02_10_2026/scripts/map/storygen.lua>) (Zeile 107), [map/storygen.lua — function Story:ModRoom](<../../_scripts/scripts_02_10_2026/scripts/map/storygen.lua>) (Zeile 98).

## Rooms erweitern

`AddRoomPreInit("BGForest", fn)` ändert einen bestehenden Raum. Eine unbekannte Room-ID erzeugt dadurch keinen neuen Raum. Neue Räume mit AddRoom registrieren und über Tasks/Tasksets tatsächlich einbinden. Direkter Zugriff auf terrain.rooms ist aktuell als veraltet markiert.

Die [Worldgen-Vorlage](templates/06_worldgen/README.md) erhöht das numerische flower-Gewicht in BGForest. Sie verändert weder lebende Entities noch bestehende Karten und greift nicht auf TheWorld zu.

Belege: [modutil.lua — env.AddRoomPreInit](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 275), [map/rooms.lua — function AddModRoom](<../../_scripts/scripts_02_10_2026/scripts/map/rooms.lua>) (Zeile 27), [map/terrain.lua — Accessing 'terrain.rooms' directly](<../../_scripts/scripts_02_10_2026/scripts/map/terrain.lua>) (Zeile 169), [map/rooms/forest/terrain_forest.lua — AddRoom("BGForest"](<../../_scripts/scripts_02_10_2026/scripts/map/rooms/forest/terrain_forest.lua>) (Zeile 27).

## Gewichte sind keine absoluten Prozentwerte

`contents.distributepercent` bestimmt, ob ein geeigneter Verteilungspunkt belegt wird. `contents.distributeprefabs` enthält Gewichte für die folgende Auswahl. GraphNode prüft distributepercent und ruft pickspawnprefab mit dem Gewichtsverzeichnis auf.

Ein doppeltes flower-Gewicht bedeutet daher nicht automatisch doppelt so viele Blumen im gesamten Spiel. Andere Gewichte, Raumanzahl, Terrainfilter, Substitutionen und Spawnpunkte beeinflussen die Ausgabe. Höhere Gewichte können andere Inhalte verdrängen. `countprefabs` und `countstaticlayouts` haben andere Aufgaben; vorhandene Funktionen als Werte nicht blind mit Zahlen multiplizieren.

Beleg: [map/graphnode.lua — self.data.terrain_contents.distributepercent](<../../_scripts/scripts_02_10_2026/scripts/map/graphnode.lua>) (Zeile 449), [Increase Animals 758921911/modworldgenmain.lua — AddRoomPreInit(roomstr](<../Increase Animals 758921911/modworldgenmain.lua>) (Zeile 157).

## Tasks, Progression und Setpieces

Tasksets unterscheiden forest/cave und besondere Modi. Optionale Tasks, Starttasks und benötigte Prefabs müssen erreichbar bleiben. Locks und Keys modellieren Progression; einen Task aus einem historischen DS-Szenario nicht lediglich anhand seines Namens in DST aufnehmen.

Die Advanced-World-Generation-Mod enthält ausdrücklich auskommentierte Versuche und manuell ausgewählte historische Tasks. Adventure Mode und Teleportato zeigen umfangreiche Setpiece-/Weltwechselketten mit gegenseitiger Abhängigkeit. Sie eignen sich zum Studium, nicht als kleine Standard-Worldgen-Vorlage.

Belege: [map/level.lua — function Level:ChooseTasks](<../../_scripts/scripts_02_10_2026/scripts/map/level.lua>) (Zeile 89), [Advanced World Generation: historischer Kommentar zu Tasks](<../Advanced World Generation (without infuse!) 756647525/modworldgenmain.lua>) (Zeile 49), [Adventure Mode 1847959350/scripts/tasksroomslayouts.lua — AddRoomPreInit("MaxHome"](<../Adventure Mode 1847959350/scripts/tasksroomslayouts.lua>) (Zeile 50).

## Tiled und Layouts

StaticLayout lädt exportierte Lua-Layouts, überträgt Tile-Indizes auf WORLD_TILES und liest Objekt-/Propertydaten. Layouts bekommen einen eindeutigen Registrierungsnamen und werden über Room-/Task-/Setpiece-Daten platziert. Terrain-, Größen- und Ausrichtungsregeln an einem passenden bestehenden Layout prüfen. Die Tiled-Quelldatei und den daraus erzeugten Lua-Stand gemeinsam pflegen.

Beleg: [map/static_layout.lua — local function ConvertStaticLayoutToLayout](<../../_scripts/scripts_02_10_2026/scripts/map/static_layout.lua>) (Zeile 40). Der Audit umfasst den Loader-Einstieg; ein neues komplexes Layout benötigt zusätzlich seine konkreten Platzierungsverbraucher.

## Weltoptionen und Runtime-Anpassung

`AddCustomizeGroup` und `AddCustomizeItem` registrieren Oberfläche und Optionen. Das alleine implementiert keine Wirkung. Die gewählten Werte müssen über Overrides/TUNING oder passenden Runtime-Code verarbeitet werden. Worldgen-Änderungen wirken bei Erzeugung; reine Runtime-Einstellungen können je nach Mechanik auch nachträglich wirken.

worldsettingsutil zeigt Timer-Integration für angepasste Spawn-/Regenerationszeiten. More Worldsettings kombiniert Optionsregistrierung, Übersetzungen und Runtime-/PreLoad-Anpassung. Eine TUNING-Änderung aktualisiert bereits laufende Timer nicht automatisch.

Belege: [modutil.lua — env.AddCustomizeItem](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 222), [worldsettingsutil.lua — local function MakeStartTimerFunction](<../../_scripts/scripts_02_10_2026/scripts/worldsettingsutil.lua>) (Zeile 15), [More Worldsettings 2838382897/modmain.lua — WorldSettings_Pickable_PreLoad](<../More Worldsettings 2838382897/modmain.lua>) (Zeile 48).

## Neue Bodentypen

AddTile, RegisterTileRange und Renderordnungsfunktionen delegieren an TileManager. Neue Tiles brauchen kollisionsfreie IDs, Render-/Minimapdaten und passende Turf-/Weltgenerierungsintegration. Diese Sammlung inventarisiert die Schnittstellen; sie enthält keinen pauschal fertigen neuen Tile. Vor Umsetzung TileManager und alle benötigten Verbraucher auditieren.

Beleg: [modutil.lua — env.AddTile](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) (Zeile 364).

## Prüfung

Mehrere neue forest-Welten mit Default und geändertem Faktor erzeugen, Room-Hook-Ausführung im Worldgen-Log bestätigen, Verteilung und Erreichbarkeit vergleichen. Höhlen separat erzeugen; dort soll die Forest-Vorlage keinen Treffer haben. Bestehende Welten müssen beim Laden unverändert bleiben. Keine feste Blumenanzahl aus einem einzelnen Seed ableiten.


## Vertiefung mit Workspace-Beispielen

Die dazugehörigen konkreten Abläufe, Daten-/Cleanupentscheidungen und Altlasten sind im [Praxismechanismen-Kapitel](23_Praxismechanismen.md) erklärt. Über die [Abdeckungsmatrix](21_Abdeckungsmatrix.md) zu passenden Fallstudien und eigenständigen Vorlagen navigieren; Grenzen komplexer Systeme stehen ausdrücklich dort.
