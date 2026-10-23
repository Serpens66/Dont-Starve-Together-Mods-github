# 21 – Abdeckung und verbleibende Verträge

Bewertung beschreibt die **Dokumentation**, nicht die Funktionsfähigkeit der Mod. A = wesentlicher Ablauf einschließlich Einstieg, Interaktion, Server-/Clientzuständigkeit, Save/Load und Cleanup beschrieben. B = Architektur und zentrale Pfade beschrieben; komplexe Spezialpfade ausdrücklich offen. H = historische Besonderheiten; WIP = nachweislich unfertiger Architekturstand. Kombinationen bleiben bewusst sichtbar. Inventarisierte 236 Lua-Dateien sind kein Nachweis, dass jede Zeile oder Enginefunktion voll auditiert wurde.

| Modverzeichnis | Abdeckung | Erklärung | Laufzeit |
|---|---|---|---|
| Advanced World Generation (without infuse!) 756647525 | A | [Fallstudie](case_studies/09_world_generation.md) | offen |
| Adventure Mode 1847959350 | B | [Fallstudie](case_studies/12_adventure.md) | offen |
| Auto Actions (Serp) 732459815 | B | [Fallstudie](case_studies/07_auto_actions.md) | offen |
| Automatic Health Adjust 764204839 | B | [Fallstudie](case_studies/21_health.md) | offen |
| Breakable Ice 385979230 | H/B | [Fallstudie](case_studies/22_ice.md) | offen |
| DST-Evolving-Maxwell-Shadows_mithunger | B/H | [Fallstudie](case_studies/05_maxwell.md) | offen |
| DSTHamletHouseWIP | WIP/B | [Fallstudie](case_studies/13_hamlet_architecture.md) | offen |
| Evolving Maxwell Shadows 1868560353 | B/H | [Fallstudie](case_studies/05_maxwell.md) | offen |
| Evolving Maxwell Shadows 1868560353_vormultitools | B/H | [Fallstudie](case_studies/05_maxwell.md) | offen |
| FinderMod 786654500 | A | [Fallstudie](case_studies/04_finder.md) | offen |
| Food Queue 2843201996 | A | [Fallstudie](case_studies/01_food_queue.md) | offen |
| FoodMemory Everyone 2839957838 | A | [Fallstudie](case_studies/15_foodmemory.md) | offen |
| Home Base Bonus 738448215 | B | [Fallstudie](case_studies/06_homebase.md) | offen |
| Increase Animals 758921911 | A | [Fallstudie](case_studies/09_world_generation.md) | offen |
| More Explosive Range 763290344 | A | [Fallstudie](case_studies/16_explosive.md) | offen |
| More Farm Harvest 736398747 | A | [Fallstudie](case_studies/17_farm.md) | offen |
| More Worldsettings 2838382897 | A | [Fallstudie](case_studies/10_more_worldsettings.md) | offen |
| Physics-Based Spacing 2840497376 | A | [Fallstudie](case_studies/18_spacing.md) | offen |
| Random DayDuskNight Events 2842755452 | A | [Fallstudie](case_studies/19_random_clock.md) | offen |
| Repair Combine 767776640 | A | [Fallstudie](case_studies/03_repair_combine.md) | offen |
| Scythe 733887349 | A | [Fallstudie](case_studies/20_scythe.md) | offen |
| Show Me (Serp) 732456848 | B | [Fallstudie](case_studies/08_show_me.md) | offen |
| Skins 733791077 | H/B | [Fallstudie](case_studies/14_skins_architecture.md) | offen |
| Skins Project (API) 733788733 | H/B | [Fallstudie](case_studies/14_skins_architecture.md) | offen |
| Teleportato 756229217 | B | [Fallstudie](case_studies/11_teleportato.md) | offen |
| Trash Can 1879090052 | A | [Fallstudie](case_studies/02_trash_can.md) | offen |

## Entscheidung für ein neues Projekt

Für Container, Ernährung, Ausrüstung, Abfrage-UI, Rooms/Tasks und timergebundene Weltoptionen gibt es [eigenständige Vorlagen](templates/README.md). Sie liefern eng begrenzte vollständige Lua-Pfade und offene Testprotokolle. Für Maxwell-Joberweiterungen, allgemeine Automation, exakte Sonderanzeigen, Innenräume und Weltreset liegt die Entscheidungskette in den jeweiligen Fallstudien; daraus folgt keine ungeprüfte universelle Vorlage.

| Wissensdefizit | Jetzt vorhanden | Verbleibende Grenze und nächster Nachweis |
|---|---|---|
| Nahrungswirkung und Queue | Eat-Reihenfolge, Foodmemory, eigener persistenter Callback | Fremde Ernährungssysteme: kombinierte Ladeordnungen und Charaktertests |
| Haltbarkeit/Aufwertung | Vier unterschiedliche Setter-/Saveformen, Verbrauch/Stacks | Fremde Items/Referenzen und Replica-Maximalgrößen pro Prefab auditieren |
| Bonuscleanup | Entityquelle/Schlüssel und eigenes Equipbeispiel | Prediction bei Speed, Sonderdamage/Reittier separat |
| Daten-UI | validierte begrenzte Anfrage, Sequenzantwort, Classifiedvergleich | Privatdaten owner-targeted; Controllerfocus/Latenztests |
| Worldgen | Dichte/Gewichte/Layoutreservierung und eigener Task | Native Platzierung, alle Seeds/Tasksets keine statische Garantie |
| Weltoptionen | UI → Overrides → Timer; Restzeitmigration | Offlinezeit/Fast-forward und fremde Worldsettingstimer separat |
| Persistenter Weltreset | Sammeln → Shards → PersistentString → Spawn/Load | Engineatomarität, Crash-/Disconnect-/Doppelantwortschutz und externes GEM API |
| Innenräume/Skins | vorhandene/historische/fehlende Funktionen getrennt | fehlende vollständige Multiplayer-/Reconnectarchitektur nicht durch Prosa ersetzbar |
| Assets/Audio | lokale Werkzeugkette und Registrierung | Binäre Kompilierung, FMOD-Kompatibilität und visueller/auditiver Exporttest offen |

[Katalog](16_Workspace_Mods.md) · [Auditnachweise](22_Vertiefungs_Audits.md) · [Projektworkflow](20_Projektworkflow.md).


## Ergänzende Vertragsprüfung vom 03.10.2026

[Aufgabenindex](25_Aufgabenindex.md) verbindet Vorhaben, Quellen und Vorlagen. [Prüfgrenzen](24_Statische_Vertragspruefung.md), [API-Quellenketten](26_Quellenketten_API.md), [Reviewmatrix aller 26 Mods](REVIEW_MATRIX.json) und [isolierte Tests](tests/README.md) unterscheiden Inventar, Quellverträge, Logikergebnisse und offene Engineabnahme.

## Vier getrennte Abdeckungsdimensionen für neue Mods

„Ablauf beschrieben“ gilt ausschließlich für den benannten untersuchten Pfad. Es bedeutet keine vollständige Funktionsgarantie für jede Erweiterung oder alle 26 Mods.

| Projektmechanismus | Praktisches Beispiel vorhanden | Ablauf vollständig beschrieben | Projektbezogener Audit erforderlich | Offener Vertrag |
|---|---|---|---|---|
| Item/Container/Bonus/Ernährung | Eigenständige Vorlagen 02/07/09/08 | jeweiliger begrenzter Vorlagenpfad und Fallstudien | Zielprefab, Fremdmodifier und Charakterkombinationen | Engine-/MP-/Saveprüfungen |
| Crockpot-Speise | [Vorlage 13](templates/13_cooked_food/README.md) | [28](28_Kochinhalte.md): regulärer Koch-/Produktlebenszyklus | andere Rezepte/Kocher/Gewürze, eigene Assets | Cookbook/Frische/Clientdarstellung im Spiel |
| Passive Kreatur | [Brainfragment](examples/creature_brain.lua), keine komplette Mod | [29](29_Kreaturen_Charaktere_Lebenszyklus.md): ausgewählter Rabbit-Lebenszyklus | eigener SG-/Component-/Assetumfang | Navigation/Netzsicht/Corpse/Traptests |
| Charakter | [Callbackfragment](examples/character_callbacks.lua), keine fertigen Assets | [29](29_Kreaturen_Charaktere_Lebenszyklus.md): Factory, Spawn, Ghost, Restore | Fähigkeit, Graphik, Auswahl, Sondermodi/Skilltrees | native Session-/Skin-/Predictioninternals |
| Öffentliches UI/RPC | Vorlage 10 | Abfragevalidierung, öffentliche Antwort, Cleanup | Datenzugriff, Budget, Controllerfokus | Latenz/Client-/Dedicatedtests |
| Classified/Privatdaten | aktuelle Vanilla-Beispiele, keine universelle Modvorlage | [30](30_Multiplayer_Lebenszyklen.md): ausgewählte Player-/Equipment-Lifecycle | eigene Owner-/Ziel-/Speicherkette | native Zustellung und tatsächlicher Datenschutztest |
| Prediction/Session/Migration | Action-/Component-Vorlagen als begrenzter Einstieg | [30](30_Multiplayer_Lebenszyklen.md): Lua-Flüsse und Fehlerpfad | konkrete Actions/Daten/Shardkonfiguration | Enginekorrektur, Crash-/Transportatomarität |

Die Modbewertungen A/B/H/WIP werden durch diese zusätzliche Mechanismusmatrix nicht pauschal hochgestuft. [Auditregister](31_Praxis_Auditnachweise.md) und [Prüfstatus](VALIDATION.md) nennen die tatsächliche neue Prüftiefe.
