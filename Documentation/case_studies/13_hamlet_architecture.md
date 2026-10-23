# HamletHouseWIP – Architektur, vorhandene Teile und Lücken

**Prüfart:** statische Ablaufanalyse; Architektur und wesentliche Pfade beschrieben; offene Spezialverträge unten. Keine Ingame-Funktionszusage. Alle Verzeichnisse: `DSTHamletHouseWIP`.

## Einstieg und Abhängigkeiten

README und modmain-TODOs kennzeichnen einen unfertigen Innenraumport. Vorhanden sind interiorspawner, door, renovator, roombuilder, Fix-/Dekorationsprefabs sowie Builder-/Placer-/Map-/Weather- und Kameraänderungen. [DSTHamletHouseWIP/modmain.lua — GetInteriorSpawner](<../../DSTHamletHouseWIP/modmain.lua>) (Zeile 189) exportiert Zugriff auf den Spawner. Das ist kein in Vanilla vorhandener allgemeiner DST-Innenraumvertrag.

## Initialisierung, Interaktion und Serverwirkung

Forest erhält serverseitig interiorspawner. Gebäude erstellt Räume; Türcomponent verbindet Zugang, USEDOOR führt serverseitig Activate aus. Eigene wilson/wilson_client-Stategraphstates unterscheiden PerformBufferedAction und Preview. RoomBuilder/Renovator erzeugen/ändern Einrichtung über eigene Actions. Builder- und Placerwrapper berücksichtigen Innenraumkoordinaten, Boden und Kollisionsprüfung. Weather-/Frog-/Rain-/VFX-Wrapper versuchen Außenwetter im Innenraum auszunehmen.

## Replikation, UI, Speicherung und Wiederherstellung

Player.HH_House setzt IsInsideHouse, waterproofness-/birdspawn-Modifier und Kameranetvar. Player-OnSave/OnLoad speichert dieses Flag und wendet es wieder an. door/interiorspawner besitzen eigene Speicherlogik für Räume/Türen/Entities; ihre Daten müssen zusammen mit Worldsave und Referenz-PostPass geladen werden. Ein boolesches Spielerflag beweist keine gültige Tür/Position nach Reconnect. Camera/VFX sind clientseitige Wirkung; Climate/Sicherheit/Buildpermission serverseitig.

## Cleanup und Lebensdauer

Vorhandene Schutzlogik unterbindet Hausbrand, solange Spieler innen sind. Zerstörung eines Hauses muss alle Bewohner, Raumobjekte, Türen, Kamera- und Wettereffekte bereinigen. Teleport außerhalb der Tür kann das Eintritts-/Austrittsprotokoll umgehen. Diese Pfade sind im TODOstand ausdrücklich noch problematisch.

## Aktuelle Vanilla-Kette

[components/builder.lua — DoBuild](<../../../_scripts/scripts_02_10_2026/scripts/components/builder.lua>) (Zeile 657) → [components/placer.lua — OnUpdate](<../../../_scripts/scripts_02_10_2026/scripts/components/placer.lua>) (Zeile 403) → [componentactions.lua — SCENE](<../../../_scripts/scripts_02_10_2026/scripts/componentactions.lua>) (Zeile 132) → [stategraphs/SGwilson_client.lua — PerformPreviewBufferedAction](<../../../_scripts/scripts_02_10_2026/scripts/stategraphs/SGwilson_client.lua>) (Zeile 728) → [entityscript.lua — LoadPostPass](<../../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>) (Zeile 1939); [components/moisture.lua — waterproofnessmodifiers](<../../../_scripts/scripts_02_10_2026/scripts/components/moisture.lua>) (Zeile 45) / [components/birdattractor.lua — spawnmodifier](<../../../_scripts/scripts_02_10_2026/scripts/components/birdattractor.lua>) (Zeile 7). Es existiert kein Vanilla-Beleg, der den gesamten portierten Spawner als multiplayerfähig bestätigt.

## Altlasten und konkrete Prüfgrenze

**Vorhanden:** Raum-/Tür-/Einrichtungs- und Kameraansätze, Persistenzhooks. **Historisch:** portierte Innenraumphysik und Legacyrecipetabs, Upvalue-/Mapersetzungen. **Fehlend/offen:** durchgängige Clientreplikation aller Raumdaten, Caveeinbindung, teleportunabhängige Innenzustandserkennung, sichere Mehrspielerzerstörung, aktuelles Crafting/Controllerverhalten. SCENE-Sammlung greift auf inst.components.door.hidden zu; auf einem Client ohne diese Gameplaycomponent ist das kein gültiges Replikationsmodell. Player-HH_House benutzt servercomponents ohne durchgängige Clientguards. Diese Grenzen erfordern eine eigene Architekturentscheidung, keine ungeprüfte universaltemplate.

## Szenarien für die spätere Laufzeitabnahme

Spätere WIP-Tests: zwei Bewohner, Türwechsel bei Lag, Logout innen/außen, Save/Load in zwei Räumen, Wortox/Consoleteleport, Hausbrand/Abbau und geschlossene Tür. Client-Placer und Crafting ohne Freecrafting. Cave/Forestmigration und Camerareset. Jeder Fehler ist getrennt von der portierten DS-Historie zu protokollieren.

Alle Szenarien sind **offen**. Für Dedicated-Server, separaten Client, Reconnect und Shardwechsel gelten zusätzlich die [allgemeinen Checklisten](../19_Checklisten.md). Statische Symbol-/Hashprüfung ersetzt diese Abnahme nicht. [Katalog](../16_Workspace_Mods.md) · [Abdeckungsmatrix](../21_Abdeckungsmatrix.md) · [Projektworkflow](../20_Projektworkflow.md).


## Dateiregister: DSTHamletHouseWIP

Dieses Register enthält **inventarisierte** Lua-Dateien; es ist Navigation und kein zusätzlicher Nachweis eines vollständigen Audits jeder Datei. Der oben erklärte Ablauf bezeichnet die untersuchten Mechanismen.

- [modinfo.lua](<../../DSTHamletHouseWIP/modinfo.lua>)
- [modmain.lua](<../../DSTHamletHouseWIP/modmain.lua>)
- [scripts/camera_tweak.lua](<../../DSTHamletHouseWIP/scripts/camera_tweak.lua>)
- [scripts/components/door.lua](<../../DSTHamletHouseWIP/scripts/components/door.lua>)
- [scripts/components/fixable.lua](<../../DSTHamletHouseWIP/scripts/components/fixable.lua>)
- [scripts/components/interiorspawner.lua](<../../DSTHamletHouseWIP/scripts/components/interiorspawner.lua>)
- [scripts/components/pocket.lua](<../../DSTHamletHouseWIP/scripts/components/pocket.lua>)
- [scripts/components/renovator.lua](<../../DSTHamletHouseWIP/scripts/components/renovator.lua>)
- [scripts/components/roombuilder.lua](<../../DSTHamletHouseWIP/scripts/components/roombuilder.lua>)
- [scripts/components/roomdemolisher.lua](<../../DSTHamletHouseWIP/scripts/components/roomdemolisher.lua>)
- [scripts/components/shelfer.lua](<../../DSTHamletHouseWIP/scripts/components/shelfer.lua>)
- [scripts/components/vineable.lua](<../../DSTHamletHouseWIP/scripts/components/vineable.lua>)
- [scripts/decorecipes.lua](<../../DSTHamletHouseWIP/scripts/decorecipes.lua>)
- [scripts/prefabs/construction_permit.lua](<../../DSTHamletHouseWIP/scripts/prefabs/construction_permit.lua>)
- [scripts/prefabs/deco.lua](<../../DSTHamletHouseWIP/scripts/prefabs/deco.lua>)
- [scripts/prefabs/deco_academy.lua](<../../DSTHamletHouseWIP/scripts/prefabs/deco_academy.lua>)
- [scripts/prefabs/deco_antiquities.lua](<../../DSTHamletHouseWIP/scripts/prefabs/deco_antiquities.lua>)
- [scripts/prefabs/deco_chair.lua](<../../DSTHamletHouseWIP/scripts/prefabs/deco_chair.lua>)
- [scripts/prefabs/deco_florist.lua](<../../DSTHamletHouseWIP/scripts/prefabs/deco_florist.lua>)
- [scripts/prefabs/deco_lamp.lua](<../../DSTHamletHouseWIP/scripts/prefabs/deco_lamp.lua>)
- [scripts/prefabs/deco_lightglow.lua](<../../DSTHamletHouseWIP/scripts/prefabs/deco_lightglow.lua>)
- [scripts/prefabs/deco_placers.lua](<../../DSTHamletHouseWIP/scripts/prefabs/deco_placers.lua>)
- [scripts/prefabs/deco_plantholder.lua](<../../DSTHamletHouseWIP/scripts/prefabs/deco_plantholder.lua>)
- [scripts/prefabs/deco_roomglow.lua](<../../DSTHamletHouseWIP/scripts/prefabs/deco_roomglow.lua>)
- [scripts/prefabs/deco_ruins_fountain.lua](<../../DSTHamletHouseWIP/scripts/prefabs/deco_ruins_fountain.lua>)
- [scripts/prefabs/deco_swinging_light.lua](<../../DSTHamletHouseWIP/scripts/prefabs/deco_swinging_light.lua>)
- [scripts/prefabs/deco_table.lua](<../../DSTHamletHouseWIP/scripts/prefabs/deco_table.lua>)
- [scripts/prefabs/deco_util.lua](<../../DSTHamletHouseWIP/scripts/prefabs/deco_util.lua>)
- [scripts/prefabs/deco_wall_ornament.lua](<../../DSTHamletHouseWIP/scripts/prefabs/deco_wall_ornament.lua>)
- [scripts/prefabs/demolition_permit.lua](<../../DSTHamletHouseWIP/scripts/prefabs/demolition_permit.lua>)
- [scripts/prefabs/exterior_texture_packages.lua](<../../DSTHamletHouseWIP/scripts/prefabs/exterior_texture_packages.lua>)
- [scripts/prefabs/generic_door.lua](<../../DSTHamletHouseWIP/scripts/prefabs/generic_door.lua>)
- [scripts/prefabs/generic_interior.lua](<../../DSTHamletHouseWIP/scripts/prefabs/generic_interior.lua>)
- [scripts/prefabs/generic_interior_art.lua](<../../DSTHamletHouseWIP/scripts/prefabs/generic_interior_art.lua>)
- [scripts/prefabs/generic_wall_back.lua](<../../DSTHamletHouseWIP/scripts/prefabs/generic_wall_back.lua>)
- [scripts/prefabs/generic_wall_side.lua](<../../DSTHamletHouseWIP/scripts/prefabs/generic_wall_side.lua>)
- [scripts/prefabs/house_door.lua](<../../DSTHamletHouseWIP/scripts/prefabs/house_door.lua>)
- [scripts/prefabs/housefloor.lua](<../../DSTHamletHouseWIP/scripts/prefabs/housefloor.lua>)
- [scripts/prefabs/housewall.lua](<../../DSTHamletHouseWIP/scripts/prefabs/housewall.lua>)
- [scripts/prefabs/interior_texture_packages.lua](<../../DSTHamletHouseWIP/scripts/prefabs/interior_texture_packages.lua>)
- [scripts/prefabs/invis_lightningrod.lua](<../../DSTHamletHouseWIP/scripts/prefabs/invis_lightningrod.lua>)
- [scripts/prefabs/playerhouse_city.lua](<../../DSTHamletHouseWIP/scripts/prefabs/playerhouse_city.lua>)
- [scripts/prefabs/playerhouse_city_floor.lua](<../../DSTHamletHouseWIP/scripts/prefabs/playerhouse_city_floor.lua>)
- [scripts/prefabs/playerhouse_city_interior.lua](<../../DSTHamletHouseWIP/scripts/prefabs/playerhouse_city_interior.lua>)
- [scripts/prefabs/prop_door.lua](<../../DSTHamletHouseWIP/scripts/prefabs/prop_door.lua>)
- [scripts/prefabs/reconstruction_project.lua](<../../DSTHamletHouseWIP/scripts/prefabs/reconstruction_project.lua>)
- [scripts/prefabs/renovation_poof_fx.lua](<../../DSTHamletHouseWIP/scripts/prefabs/renovation_poof_fx.lua>)
- [scripts/prefabs/rug.lua](<../../DSTHamletHouseWIP/scripts/prefabs/rug.lua>)
- [scripts/prefabs/shelf.lua](<../../DSTHamletHouseWIP/scripts/prefabs/shelf.lua>)
- [scripts/prefabs/shelf_slot.lua](<../../DSTHamletHouseWIP/scripts/prefabs/shelf_slot.lua>)
- [scripts/prefabs/test_interior_art.lua](<../../DSTHamletHouseWIP/scripts/prefabs/test_interior_art.lua>)
- [scripts/prefabs/wall_interior.lua](<../../DSTHamletHouseWIP/scripts/prefabs/wall_interior.lua>)
- [scripts/prefabs/wallblockobject.lua](<../../DSTHamletHouseWIP/scripts/prefabs/wallblockobject.lua>)
- [scripts/shelfercode.lua](<../../DSTHamletHouseWIP/scripts/shelfercode.lua>)
- [scripts/upvaluehacker.lua](<../../DSTHamletHouseWIP/scripts/upvaluehacker.lua>)
- [strings.lua](<../../DSTHamletHouseWIP/strings.lua>)


## Erneute Prüfung: Door und Interior-Savegraph

[`DSTHamletHouseWIP/scripts/components/door.lua`](<../../DSTHamletHouseWIP/scripts/components/door.lua>) speichert IDs, Interiornamen, Ausrichtung und Disablegründe. Activate meldet usedoor und delegiert an Interiorspawner. Nicht alle Zielkoordinaten/Offsets werden gespeichert; UpdateTargetOffset setzt die lokale Zielentity nil, Lookup ist auskommentiert. Eigener LoadPostPass ist leer; die Registry muss Entityzuordnung leisten.

[`DSTHamletHouseWIP/scripts/components/interiorspawner.lua`](<../../DSTHamletHouseWIP/scripts/components/interiorspawner.lua>) speichert Room-/Door-Metadaten, nächste Interior-ID, Playerhomes, Innenraumstatus, Objekt-GUIDs und Wall/Floor-GUIDs. OnLoad baut Tabellen, PostPass löst newents und Objektzugehörigkeit/Doors auf. Fehlende Objekte sind eigene Fehlerfälle; direkte wallobject.GUID/floorobject.GUID im Save verlangen gültige Entities. Auskommentierte Pathfinding-/Setupaufrufe sind keine aktive Rekonstruktion.

ExecuteTeleport versetzt Entity, Follower und ausgewählte Inventar-/Ausrüstungsbegleiter innerhalb derselben Welt. Das ist kein Shardwechsel und kein privates Mapinstanzsystem. FadeInFinished aktiviert Controller und stellt zuvor abgelegten Healthzustand wieder her. Kamera/Wetter/Builder/Placer enthalten Portreste und unvollständige Pfade. Tür-/Renovateactions ersetzen kein fertiges Clientprotokoll für Registry, Geometrie und Kollision.

Für neue Innenräume: außen → gesperrte Transition → serverseitige Interior-ID → bestätigte Clientdaten → Kamera/Controller aktiv; Abbruch kehrt zum konsistenten Zustand zurück. Load benötigt stabile IDs und Regeln für fehlende Wand/Boden, abgebautes Haus und ausgeloggten Besitzer. Lua-Lektüre kann den vorliegenden WIP-Port erklären, aber den fehlenden aktuellen Multiplayer-Innenraumvertrag nicht zur Funktionsfreigabe machen.


Konkrete zusätzliche Funktionsdefinitionen: [Vertragsbelege](../27_Vertragsbelege.md). Die [Reviewmatrix](../REVIEW_MATRIX.json) trennt Einstiegssichtung und ausgewählte vertiefte Abläufe; weitere Featureänderungen benötigen einen eigenen aktuellen Audit.
