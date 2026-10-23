# 16 – Katalog aller Workspace-Mods

Alle 26 Verzeichnisse mit modinfo.lua wurden inventarisiert. Metadaten, Einstiegscode und thematisch relevante Module wurden gelesen; komplexe Mechanismen wurden gezielt bis zu ihren beteiligten Komponenten verfolgt. Vollständige statische Prüfung aller Zeilen und Ingame-Abnahme jeder Mod wurden nicht durchgeführt. Der Katalog unterscheidet erkennbare WIP-/Variantenstände; eine fehlende WIP-Markierung beweist keine Laufzeitkompatibilität.

Lua-Dateizahlen umfassen auch modinfo, Hilfsdateien und mögliche Altdateien. Flags stammen aus literalen Zuweisungen; dynamische oder auskommentierte Werte müssen im tatsächlichen Ladeumfeld geprüft werden. Statische Altlasten sind Hinweise für einen neuen Audit, keine eigenmächtigen Änderungen vorhandener Mods.

## Advanced World Generation (without infuse!) 756647525

**Einordnung:** Worldgen-Mod. **Version:** `"2.3.61"`. **Lua-Dateien:** 3. **client_only_mod:** `false`; **all_clients_require_mod:** `false`.

Gezielte Worldgenanpassungen und Tasksetauswahl ohne Infuse. TaskSet-Hooks und modworldgenmain als Beispiel; alte kommentierte Tasklisten nicht ungeprüft übernehmen.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Advanced World Generation (without infuse!) 756647525/modinfo.lua>)
- [modmain.lua](<../Advanced World Generation (without infuse!) 756647525/modmain.lua>)
- [modworldgenmain.lua — AddTaskSetPreInitAny](<../Advanced World Generation (without infuse!) 756647525/modworldgenmain.lua>) (indexierte Einstiegsstelle: Zeile 26)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddTaskSetPreInitAny`.

## Adventure Mode 1847959350

**Einordnung:** umfangreiche Mod. **Version:** `"0.9971"`. **Lua-Dateien:** 56. **client_only_mod:** `false`; **all_clients_require_mod:** `true`.

Abenteuerwelten, Lobby-/Charakterauswahl und Zwischensequenzen; abhängig von Teleportato. Beispiel für Worldnet-Netstrings, Player-Netvars, Rooms/Tasks/Layouts und verteiltes Setup. Kein isolierter Baukasten ohne die Abhängigkeit.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Adventure Mode 1847959350/modinfo.lua>)
- [modmain.lua — AddUserCommand](<../Adventure Mode 1847959350/modmain.lua>) (indexierte Einstiegsstelle: Zeile 117)
- [modworldgenmain.lua — AddCustomizationPrefab](<../Adventure Mode 1847959350/modworldgenmain.lua>) (indexierte Einstiegsstelle: Zeile 169)
- [scripts/components/maxlightspawner.lua — OnSave](<../Adventure Mode 1847959350/scripts/components/maxlightspawner.lua>) (indexierte Einstiegsstelle: Zeile 16)
- [scripts/components/maxwelltalker.lua](<../Adventure Mode 1847959350/scripts/components/maxwelltalker.lua>)
- [scripts/prefabs/diviningrodstart.lua — OnSave](<../Adventure Mode 1847959350/scripts/prefabs/diviningrodstart.lua>) (indexierte Einstiegsstelle: Zeile 36)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddClassPostConstruct`, `AddPlayerPostInit`, `AddPrefabPostInit`, `AddRoomPreInit`, `AddTaskPreInit`.

## Auto Actions (Serp) 732459815

**Einordnung:** Clientmod. **Version:** `"1.1.66"`. **Lua-Dateien:** 4. **client_only_mod:** `true`; **all_clients_require_mod:** `false`.

Automatisierte Spieleraktionen. playeractionpicker/playercontroller-Wrapper zeigen Cliententscheidungen und Originalaufrufe. Große Datei mit historischen und auskommentierten Blöcken; Texttreffer eines Hooks sind kein Nachweis seiner Ausführung.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Auto Actions (Serp) 732459815/modinfo.lua>)
- [modmain.lua — AddTag](<../Auto Actions (Serp) 732459815/modmain.lua>) (indexierte Einstiegsstelle: Zeile 465)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddClassPostConstruct`, `AddPlayerPostInit`.

## Automatic Health Adjust 764204839

**Einordnung:** Servermod. **Version:** `"1.1073"`. **Lua-Dateien:** 3. **client_only_mod:** `false`; **all_clients_require_mod:** `false`.

Skaliert Gegnerleben nach Spielern; Spawn-/Leave-Events, verzögerte Neuberechnung und health.save_maxhealth. SetMaxHealth kann aktuelle Gesundheit verändern; Sondergegner wie Crab King separat prüfen.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Automatic Health Adjust 764204839/modinfo.lua>)
- [modmain.lua — AddPrefabPostInit](<../Automatic Health Adjust 764204839/modmain.lua>) (indexierte Einstiegsstelle: Zeile 345)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddComponentPostInit`, `AddPrefabPostInit`.

## Breakable Ice 385979230

**Einordnung:** ältere Mod. **Version:** `"1.0.01"`. **Lua-Dateien:** 10. **client_only_mod:** `false`; **all_clients_require_mod:** `false`.

Zerbrechliches Eis/Pond-Erweiterung und crystallizable-Component. Save/Load-Wrapper als Lernstelle. In modmain ist ein OnLoad(data)-Wrapper sichtbar, während aktuelles Prefab-OnLoad(inst,data) erhält: Signatur vor Wiederverwendung korrigiert auditieren, kein bestätigter Laufzeitfehler.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Breakable Ice 385979230/modinfo.lua>)
- [modmain.lua — AddDescriptors](<../Breakable Ice 385979230/modmain.lua>) (indexierte Einstiegsstelle: Zeile 20)
- [data/prefabs/pond.lua — AddComponent](<../Breakable Ice 385979230/data/prefabs/pond.lua>) (indexierte Einstiegsstelle: Zeile 117)
- [scripts/components/crystallizable.lua — AddTemperature](<../Breakable Ice 385979230/scripts/components/crystallizable.lua>) (indexierte Einstiegsstelle: Zeile 149)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddPrefabPostInit`.

## DST-Evolving-Maxwell-Shadows_mithunger

**Einordnung:** Variantenstand. **Version:** `"1.000"`. **Lua-Dateien:** 8. **client_only_mod:** `nicht literal gefunden`; **all_clients_require_mod:** `true`.

Hungerbezogene Variante der Maxwell-Schattenmod. Components, Inventare und Schattenzustände vergleichen; kein unabhängiger Nachweis einer neueren stabilen Fassung.

Einstieg und Beispieldateien:

- [modinfo.lua](<../DST-Evolving-Maxwell-Shadows_mithunger/modinfo.lua>)
- [modmain.lua — AddRecipe](<../DST-Evolving-Maxwell-Shadows_mithunger/modmain.lua>) (indexierte Einstiegsstelle: Zeile 139)
- [scripts/components/shadowtoggleable.lua — AddTag](<../DST-Evolving-Maxwell-Shadows_mithunger/scripts/components/shadowtoggleable.lua>) (indexierte Einstiegsstelle: Zeile 3)
- [scripts/prefabs/journalpage.lua — AddTransform](<../DST-Evolving-Maxwell-Shadows_mithunger/scripts/prefabs/journalpage.lua>) (indexierte Einstiegsstelle: Zeile 9)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddComponentAction`, `AddComponentPostInit`, `AddPrefabPostInit`, `AddPrefabPostInitAny`, `AddRecipe`, `AddStategraphActionHandler`, `AddStategraphPostInit`.

## DSTHamletHouseWIP

**Einordnung:** WIP. **Version:** `"1.0"`. **Lua-Dateien:** 56. **client_only_mod:** `false`; **all_clients_require_mod:** `true`.

Innenräume und Haus-/Türsystem, interiorspawner und Builder-/Weather-Eingriffe. README bezeichnet das Projekt als unfertig und nennt Multiplayer/Höhlen als offen. Nicht als getestete DST-Architektur übernehmen.

Einstieg und Beispieldateien:

- [modinfo.lua](<../DSTHamletHouseWIP/modinfo.lua>)
- [modmain.lua — AddComponentPostInit](<../DSTHamletHouseWIP/modmain.lua>) (indexierte Einstiegsstelle: Zeile 120)
- [scripts/components/door.lua — OnSave](<../DSTHamletHouseWIP/scripts/components/door.lua>) (indexierte Einstiegsstelle: Zeile 119)
- [scripts/components/fixable.lua — AddTag](<../DSTHamletHouseWIP/scripts/components/fixable.lua>) (indexierte Einstiegsstelle: Zeile 5)
- [scripts/components/interiorspawner.lua — AddWall](<../DSTHamletHouseWIP/scripts/components/interiorspawner.lua>) (indexierte Einstiegsstelle: Zeile 187)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddClassPostConstruct`, `AddComponentAction`, `AddComponentPostInit`, `AddPlayerPostInit`, `AddPrefabPostInit`, `AddRecipe`, `AddStategraphActionHandler`.

## Evolving Maxwell Shadows 1868560353

**Einordnung:** Hauptstand im Workspace. **Version:** `"1.005"`. **Lua-Dateien:** 8. **client_only_mod:** `nicht literal gefunden`; **all_clients_require_mod:** `true`.

Schatten mit Inventar, Ausrüstung und erweiterten Zuständen. containers.params, Entity-Components, Task-/Save-Daten und Stategraphänderungen sind relevante Lernstellen. Nur statisch untersucht, nicht als aktuell funktionsfähig zertifiziert.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Evolving Maxwell Shadows 1868560353/modinfo.lua>)
- [modmain.lua — AddRecipe](<../Evolving Maxwell Shadows 1868560353/modmain.lua>) (indexierte Einstiegsstelle: Zeile 122)
- [scripts/components/shadowtoggleable.lua — AddTag](<../Evolving Maxwell Shadows 1868560353/scripts/components/shadowtoggleable.lua>) (indexierte Einstiegsstelle: Zeile 3)
- [scripts/prefabs/journalpage.lua — AddTransform](<../Evolving Maxwell Shadows 1868560353/scripts/prefabs/journalpage.lua>) (indexierte Einstiegsstelle: Zeile 9)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddComponentAction`, `AddComponentPostInit`, `AddPrefabPostInit`, `AddPrefabPostInitAny`, `AddRecipe`, `AddStategraphActionHandler`, `AddStategraphPostInit`.

## Evolving Maxwell Shadows 1868560353_vormultitools

**Einordnung:** historische Variante. **Version:** `"0.9989"`. **Lua-Dateien:** 8. **client_only_mod:** `nicht literal gefunden`; **all_clients_require_mod:** `true`.

Stand vor Multitooländerungen. Gut für gezielten Versionsvergleich; nicht parallel zur Hauptvariante aktivieren, weil Namen und Eingriffe überlappen.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Evolving Maxwell Shadows 1868560353_vormultitools/modinfo.lua>)
- [modmain.lua — AddRecipe](<../Evolving Maxwell Shadows 1868560353_vormultitools/modmain.lua>) (indexierte Einstiegsstelle: Zeile 119)
- [scripts/components/shadowtoggleable.lua — AddTag](<../Evolving Maxwell Shadows 1868560353_vormultitools/scripts/components/shadowtoggleable.lua>) (indexierte Einstiegsstelle: Zeile 3)
- [scripts/prefabs/journalpage.lua — AddTransform](<../Evolving Maxwell Shadows 1868560353_vormultitools/scripts/prefabs/journalpage.lua>) (indexierte Einstiegsstelle: Zeile 9)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddComponentAction`, `AddComponentPostInit`, `AddPrefabPostInit`, `AddPrefabPostInitAny`, `AddRecipe`, `AddStategraphActionHandler`, `AddStategraphPostInit`.

## FinderMod 786654500

**Einordnung:** Gameplay/UI-Mod. **Version:** `'1.14'`. **Lua-Dateien:** 2. **client_only_mod:** `false`; **all_clients_require_mod:** `true`.

Sucht Gegenstände in Behältern. Client-UI plus serverseitiger RPC und net_entity-Felder. Serverabfragen und Sichtbarkeit müssen zum Datenbedarf passen; Begrenzung/Eigentum separat prüfen.

Einstieg und Beispieldateien:

- [modinfo.lua](<../FinderMod 786654500/modinfo.lua>)
- [modmain.lua — AddTag](<../FinderMod 786654500/modmain.lua>) (indexierte Einstiegsstelle: Zeile 118)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddClassPostConstruct`, `AddModRPCHandler`, `AddPlayerPostInit`.

## Food Queue 2843201996

**Einordnung:** Gameplay/UI-Mod. **Version:** `"1.0.25"`. **Lua-Dateien:** 5. **client_only_mod:** `false`; **all_clients_require_mod:** `true`.

Eigener _foodbuffer mit Save-Daten, sechs replizierten Strings und UI. Kompaktes reales Component-/Replica-Beispiel. Insight-Anbindung ist eine zusätzliche Integration, kein Vanilla-Vertrag.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Food Queue 2843201996/modinfo.lua>)
- [modmain.lua — AddReplicableComponent](<../Food Queue 2843201996/modmain.lua>) (indexierte Einstiegsstelle: Zeile 2)
- [scripts/components/_foodbuffer.lua — AddToBuffer](<../Food Queue 2843201996/scripts/components/_foodbuffer.lua>) (indexierte Einstiegsstelle: Zeile 94)
- [scripts/components/_foodbuffer_replica.lua — net_string](<../Food Queue 2843201996/scripts/components/_foodbuffer_replica.lua>) (indexierte Einstiegsstelle: Zeile 6)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddClassPostConstruct`, `AddPlayerPostInit`, `AddReplicableComponent`.

## FoodMemory Everyone 2839957838

**Einordnung:** Gameplay-Mod. **Version:** `"1.0.11"`. **Lua-Dateien:** 2. **client_only_mod:** `nicht literal gefunden`; **all_clients_require_mod:** `true`.

Warlys Nahrungsmemory für weitere Spieler. Player-/Component-Hooks und optionale Oberfläche. Der Ausdruck not inst.components ~= nil in modmain ist wegen Operatorrangfolge kein verständlicher Komponenten-Existenztest; bei Wiederverwendung sauber prüfen.

Einstieg und Beispieldateien:

- [modinfo.lua](<../FoodMemory Everyone 2839957838/modinfo.lua>)
- [modmain.lua — AddPlayerPostInit](<../FoodMemory Everyone 2839957838/modmain.lua>) (indexierte Einstiegsstelle: Zeile 108)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddPlayerPostInit`.

## Home Base Bonus 738448215

**Einordnung:** umfangreiche Mod. **Version:** `"1.1.802"`. **Lua-Dateien:** 4. **client_only_mod:** `false`; **all_clients_require_mod:** `true`.

Boni in erkannten Basen: Entitysuche, Bau-/Bodenkriterien, Player-Effekte, Netvars und HUD. Suchintervalle, Radius und Clientdatenmenge sind hier besonders relevant.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Home Base Bonus 738448215/modinfo.lua>)
- [modmain.lua — AddPlayerPostInit](<../Home Base Bonus 738448215/modmain.lua>) (indexierte Einstiegsstelle: Zeile 83)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddClassPostConstruct`, `AddComponentPostInit`, `AddModRPCHandler`, `AddPlayerPostInit`, `AddPrefabPostInit`.

## Increase Animals 758921911

**Einordnung:** Worldgen-Mod. **Version:** `"0.8.92"`. **Lua-Dateien:** 15. **client_only_mod:** `false`; **all_clients_require_mod:** `false`.

Ändert Tierverteilung in Rooms und Layouts. Gewicht und Dichte unterscheiden. RoomPreInit-Kommentare anhand aktueller ModRoom-Kette prüfen; fehlende Rooms werden nicht automatisch angelegt.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Increase Animals 758921911/modinfo.lua>)
- [modmain.lua](<../Increase Animals 758921911/modmain.lua>)
- [modworldgenmain.lua — AddAnimaltoWorldGeneration](<../Increase Animals 758921911/modworldgenmain.lua>) (indexierte Einstiegsstelle: Zeile 122)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddRoomPreInit`, `AddTaskSetPreInitAny`.

## More Explosive Range 763290344

**Einordnung:** kleine Servermod. **Version:** `"1.03"`. **Lua-Dateien:** 2. **client_only_mod:** `false`; **all_clients_require_mod:** `false`.

Component-PostInit verändert Explosionsradius/Schaden. Kleines Beispiel für unmittelbare Feldänderungen; Prefab-Code kann später erneut konfigurieren.

Einstieg und Beispieldateien:

- [modinfo.lua](<../More Explosive Range 763290344/modinfo.lua>)
- [modmain.lua — AddPrefabPostInit](<../More Explosive Range 763290344/modmain.lua>) (indexierte Einstiegsstelle: Zeile 5)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddPrefabPostInit`.

## More Farm Harvest 736398747

**Einordnung:** ältere Servermod. **Version:** `"1.0.0"`. **Lua-Dateien:** 2. **client_only_mod:** `nicht literal gefunden`; **all_clients_require_mod:** `false`.

Wrapper für crop:Harvest und zusätzliche Ernte. Originalrückgaben und verzögerte Wirkung nachvollziehen. crop ist nicht gleich moderner farmplant/farm_crop; neue Pflanzen gesondert auditieren.

Einstieg und Beispieldateien:

- [modinfo.lua](<../More Farm Harvest 736398747/modinfo.lua>)
- [modmain.lua — AddComponentPostInit](<../More Farm Harvest 736398747/modmain.lua>) (indexierte Einstiegsstelle: Zeile 48)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddComponentPostInit`.

## More Worldsettings 2838382897

**Einordnung:** Worldgen/Runtime-Mod. **Version:** `"1.029"`. **Lua-Dateien:** 7. **client_only_mod:** `false`; **all_clients_require_mod:** `false`.

Zusätzliche Welteinstellungen, Customize-Registrierung und WorldSettings-PreLoad-Helfer. Zeigt den Unterschied zwischen UIoption und tatsächlicher Runtimewirkung. Upvalue-Helfer und generische Modulnamen sind konfliktanfällige Integrationsstellen.

Einstieg und Beispieldateien:

- [modinfo.lua](<../More Worldsettings 2838382897/modinfo.lua>)
- [modmain.lua — AddPrefabPostInitAny](<../More Worldsettings 2838382897/modmain.lua>) (indexierte Einstiegsstelle: Zeile 25)
- [modworldgenmain.lua — AddCustomizeGroup](<../More Worldsettings 2838382897/modworldgenmain.lua>) (indexierte Einstiegsstelle: Zeile 114)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddClassPostConstruct`, `AddPrefabPostInit`, `AddPrefabPostInitAny`.

## Physics-Based Spacing 2840497376

**Einordnung:** Gameplaymod. **Version:** `"1.01"`. **Lua-Dateien:** 2. **client_only_mod:** `nicht literal gefunden`; **all_clients_require_mod:** `true`.

Ermittelt Platzbedarf über temporär erzeugte Prefabs und ändert Rezeptabstände. Cache und sofortiges Remove sind relevant; SpawnPrefab kann trotz Remove Hooks/Seiteneffekte auslösen.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Physics-Based Spacing 2840497376/modinfo.lua>)
- [modmain.lua — AddPrefabPostInit](<../Physics-Based Spacing 2840497376/modmain.lua>) (indexierte Einstiegsstelle: Zeile 21)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddPrefabPostInit`.

## Random DayDuskNight Events 2842755452

**Einordnung:** Servermod. **Version:** `"1.02"`. **Lua-Dateien:** 4. **client_only_mod:** `false`; **all_clients_require_mod:** `false`.

Ändert Tagesabschnitte zufällig und speichert Auswahl über rememberstuff. cycleschanged/ms_setclocksegs und Clock-Upvaluezugriff nachvollziehen; internen Upvaluevertrag bei Updates erneut prüfen. Forest-spezifischer Einstieg.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Random DayDuskNight Events 2842755452/modinfo.lua>)
- [modmain.lua — AddComponentPostInit](<../Random DayDuskNight Events 2842755452/modmain.lua>) (indexierte Einstiegsstelle: Zeile 14)
- [scripts/components/rememberstuff.lua — OnSave](<../Random DayDuskNight Events 2842755452/scripts/components/rememberstuff.lua>) (indexierte Einstiegsstelle: Zeile 17)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddClassPostConstruct`, `AddComponentPostInit`, `AddPrefabPostInit`.

## Repair Combine 767776640

**Einordnung:** Action-Mod. **Version:** `"1.091"`. **Lua-Dateien:** 3. **client_only_mod:** `false`; **all_clients_require_mod:** `true`.

Kombiniert/Repariert Gegenstände über USEITEM-Action und beide Spielerstategraphs. Konkretes Muster für Auswahl → State → Serverwirkung. Durability-/Save-Wrapper und lokale Datenvariablen vor Wiederverwendung prüfen.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Repair Combine 767776640/modinfo.lua>)
- [modmain.lua — AddComponent](<../Repair Combine 767776640/modmain.lua>) (indexierte Einstiegsstelle: Zeile 19)
- [scripts/components/combinerepairable.lua — AddTag](<../Repair Combine 767776640/scripts/components/combinerepairable.lua>) (indexierte Einstiegsstelle: Zeile 4)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddComponentAction`, `AddComponentPostInit`, `AddPrefabPostInitAny`, `AddStategraphActionHandler`.

## Scythe 733887349

**Einordnung:** ältere Inhaltsmod. **Version:** `"1.0.3"`. **Lua-Dateien:** 4. **client_only_mod:** `false`; **all_clients_require_mod:** `true`.

Neue Sense, Erntebeschleunigung, Equip-Tags und eigene Assets. Verwendet altes Recipe. Im Prefab steht Clientreturn vor SetPristine; entspricht nicht dem aktuellen Vanilla-Speer-Muster und sollte nicht kopiert werden.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Scythe 733887349/modinfo.lua>)
- [modmain.lua](<../Scythe 733887349/modmain.lua>)
- [scripts/prefabs/scythe.lua — AddTag](<../Scythe 733887349/scripts/prefabs/scythe.lua>) (indexierte Einstiegsstelle: Zeile 16)
- [scripts/prefabs/scythe_golden.lua — AddTag](<../Scythe 733887349/scripts/prefabs/scythe_golden.lua>) (indexierte Einstiegsstelle: Zeile 16)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): keine dieser Hooknamen gefunden.

## Show Me (Serp) 732456848

**Einordnung:** umfangreiche Gameplay/UI-Mod. **Version:** `"0.3534"`. **Lua-Dateien:** 2. **client_only_mod:** `false`; **all_clients_require_mod:** `true`.

Zusätzliche Objektinformationen über RPC und Inspectable-/Description-Erweiterungen. Nützlich für Informationsfluss und Wrapper; sehr große Datei mit historischen Sonderfällen, kein universelles Metadaten-API.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Show Me (Serp) 732456848/modinfo.lua>)
- [modmain.lua — AddTag](<../Show Me (Serp) 732456848/modmain.lua>) (indexierte Einstiegsstelle: Zeile 88)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddClassPostConstruct`, `AddComponentPostInit`, `AddModRPCHandler`, `AddPlayerPostInit`, `AddPrefabPostInit`.

## Skins 733791077

**Einordnung:** Erweiterungsmod. **Version:** `"1.0.1"`. **Lua-Dateien:** 2. **client_only_mod:** `nicht literal gefunden`; **all_clients_require_mod:** `true`.

Registriert Charakteraussehensvarianten über SkinsProject.AddSkin, sofern das globale API existiert. Benötigt Skins Project; rawget-Prüfung installiert keine Abhängigkeit.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Skins 733791077/modinfo.lua>)
- [modmain.lua — AddSkin](<../Skins 733791077/modmain.lua>) (indexierte Einstiegsstelle: Zeile 60)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): keine dieser Hooknamen gefunden.

## Skins Project (API) 733788733

**Einordnung:** historische API-Mod. **Version:** `"1.1.11"`. **Lua-Dateien:** 3. **client_only_mod:** `nicht literal gefunden`; **all_clients_require_mod:** `true`.

Globales SkinsProject-API und generic_switch-Prefab. Legacy-RecipeTab und gemeinsame globale Namen; neue Aussehenssysteme gegen aktuelle Vanilla- und Rechteverträge prüfen.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Skins Project (API) 733788733/modinfo.lua>)
- [modmain.lua — AddRecipeTab](<../Skins Project (API) 733788733/modmain.lua>) (indexierte Einstiegsstelle: Zeile 18)
- [scripts/prefabs/generic_switch.lua — AddTransform](<../Skins Project (API) 733788733/scripts/prefabs/generic_switch.lua>) (indexierte Einstiegsstelle: Zeile 24)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddRecipe`.

## Teleportato 756229217

**Einordnung:** umfangreiche Basis-/Worldgenmod. **Version:** `"1.284"`. **Lua-Dateien:** 18. **client_only_mod:** `false`; **all_clients_require_mod:** `true`.

Weltwechsel, Worldjump-Component, Save-/Sessiondaten, Shardkommunikation und Worldgen. Besonders relevant für Adventure Mode; eigener komplexer Migrationsablauf, kein allgemeines Copy/Paste-Muster. Nicht auf Laufzeit geprüft.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Teleportato 756229217/modinfo.lua>)
- [modmain.lua — OnSave](<../Teleportato 756229217/modmain.lua>) (indexierte Einstiegsstelle: Zeile 19)
- [modworldgenmain.lua — Add_IIBE_Mask](<../Teleportato 756229217/modworldgenmain.lua>) (indexierte Einstiegsstelle: Zeile 859)
- [scripts/components/adv_startstuff.lua — OnLoad](<../Teleportato 756229217/scripts/components/adv_startstuff.lua>) (indexierte Einstiegsstelle: Zeile 4)
- [scripts/components/adventurejump.lua — OnLoad](<../Teleportato 756229217/scripts/components/adventurejump.lua>) (indexierte Einstiegsstelle: Zeile 61)
- [scripts/components/shard_teleplayersave.lua — net_bool](<../Teleportato 756229217/scripts/components/shard_teleplayersave.lua>) (indexierte Einstiegsstelle: Zeile 25)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddClassPostConstruct`, `AddModRPCHandler`, `AddPlayerPostInit`, `AddPrefabPostInit`, `AddPrefabPostInitAny`, `AddRecipe2`, `AddRoomPreInit`.

## Trash Can 1879090052

**Einordnung:** Gebäude-/Containermod. **Version:** `"2.325"`. **Lua-Dateien:** 3. **client_only_mod:** `false`; **all_clients_require_mod:** `true`.

Mülleimer mit von treasurechest kopierten Containerparametern und eigener Prefabdatei. Legacy-AddRecipe; in modmain erscheint trashcantex ohne Punkt sowie local assets statt global Assets. Statische Verdachtsstellen, tatsächliches Assetladen pro Prefab separat prüfen.

Einstieg und Beispieldateien:

- [modinfo.lua](<../Trash Can 1879090052/modinfo.lua>)
- [modmain.lua — AddMinimapAtlas](<../Trash Can 1879090052/modmain.lua>) (indexierte Einstiegsstelle: Zeile 15)
- [scripts/prefabs/trashcan.lua — AddTransform](<../Trash Can 1879090052/scripts/prefabs/trashcan.lua>) (indexierte Einstiegsstelle: Zeile 183)

**Indexierte Hooknamen** (einschließlich möglicher Kommentar-/Altcode-Treffer): `AddRecipe`.


## Vertiefte Ablaufbeschreibungen

Zu jedem oben inventarisierten Verzeichnis gibt es jetzt eine Zuordnung in der [Abdeckungsmatrix](21_Abdeckungsmatrix.md) und im [Fallstudienregister](case_studies/README.md). Die Matrix trennt beschriebenen Hauptablauf von offenen Spezialverträgen und historischen/WIP-Ständen. Der Katalog bleibt ein Einstieg, nicht das komplette Begründungsdokument.


## Ergänzende Vertragsprüfung vom 03.10.2026

[Aufgabenindex](25_Aufgabenindex.md) verbindet Vorhaben, Quellen und Vorlagen. [Prüfgrenzen](24_Statische_Vertragspruefung.md), [API-Quellenketten](26_Quellenketten_API.md), [Reviewmatrix aller 26 Mods](REVIEW_MATRIX.json) und [isolierte Tests](tests/README.md) unterscheiden Inventar, Quellverträge, Logikergebnisse und offene Engineabnahme.
