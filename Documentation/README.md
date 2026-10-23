# Don't Starve Together: Modding-Nachschlagewerk

Stand: **03.10.2026**. Sprache: Deutsch; Lua-Bezeichner entsprechen dem Spielcode.

Diese Sammlung verbindet aktuelle Vanilla-Verträge mit eigenen, kommentierten Beispielen und der Auswertung aller 26 Mod-Verzeichnisse dieses Workspace. Sie dient als Arbeitsgrundlage für neue Mods und für die Pflege bestehender Mods. Die 13 Vorlagen sind eigenständige Mod-Verzeichnisse unter [templates](templates/README.md).

## Belastbarkeit und Einstieg

Das installierte `scripts.zip` und `_scripts/scripts_02_10_2026` wurden vollständig inhaltsbezogen verglichen: **4.044 Dateien, keine fehlende Datei, keine SHA-256-Abweichung**. Details, Audit-Ketten und Grenzen stehen im [Vanilla-Audit](17_Vanilla_Audit.md). Lua-seitig sichtbare Engine-Aufrufe sind belegt; der interne C++-Code des Spiels ist hier nicht verfügbar. Unbekannte interne Verträge werden nicht erfunden.

**45 Lua-Dateien bestehen die Lua-5.1-Syntaxprüfung mit -p außerhalb der Sandbox: 42 Vorlagendateien, zwei abgegrenzte Fragmente und eine Testdatei. Zusätzlich bestehen 22 isolierte Lua-Logiktests und sechs Prüfer-Tests. Ingame- und Netzwerkprüfungen stehen aus.** Eine Syntaxprüfung beweist weder korrekte Assets noch funktionierende Replikation. Der genaue Abschlussstatus steht in [VALIDATION](VALIDATION.md).

Bei einer neuen Mod-Idee zuerst das nächstliegende Vanilla-Prefab finden, dessen Components und Aufrufer verfolgen und erst danach einen Erweiterungspunkt auswählen. Diese Dokumentation ersetzt den featurebezogenen Vanilla-Audit aus der Workspace-`AGENTS.md` nicht, insbesondere nach Spielupdates.

## Kapitel

| Kapitel | Inhalt |
|---|---|
| [01 Grundlagen](01_Grundlagen.md) | Pfade, Werkzeuge, Lua und Mod-Struktur |
| [02 Ladeumgebungen und Hooks](02_Ladeumgebungen_Hooks.md) | GLOBAL, modimport, require, Timing und Wrapper |
| [03 Prefabs und Components](03_Prefabs_Components.md) | Konstruktion, Tags, Replica und Lebenszyklus |
| [04 Multiplayer](04_Multiplayer.md) | Server, Netvars, RPC, Classifieds und Shards |
| [05 Persistenz](05_Persistenz.md) | Save/Load, Referenzen, PostPass und Migration |
| [06 Gegenstände und Gebäude](06_Gegenstaende_Gebaeude_Container.md) | Ausrüstung, Werkzeuge, Placer und Container |
| [07 Crafting und Kochen](07_Crafting_Kochen.md) | AddRecipe2, Filter, Zutaten und Kochrezepte |
| [08 Actions und Stategraphs](08_Actions_Stategraphs.md) | Client-Auswahl, Prediction und serverseitige Wirkung |
| [09 Brains und Charaktere](09_Brains_Charaktere.md) | Verhalten, Player-Factory und Charakter-Inhalte |
| [10 Weltgenerierung](10_Weltgenerierung.md) | Rooms, Tasks, Layouts, Einstellungen und Tiles |
| [11 UI und Sprache](11_UI_Eingabe_Localisierung.md) | Widgets, Eingabe, Controller und STRINGS |
| [12 Assets](12_Assets_Animation_Audio.md) | Bildpipeline, Bank/Build, Symbole und Audio |
| [13 Debugging und Qualität](13_Debugging_Tests_Performance.md) | Konsole, Logs, Tests, Performance und Konflikte |
| [14 Workshop und Wartung](14_Workshop_Wartung.md) | Installation, Veröffentlichung und Update-Ablauf |
| [15 API-Register](15_API_Register.md) | Aus modutil.lua extrahierte Signaturen und Kontexte |
| [16 Workspace-Mods](16_Workspace_Mods.md) | Alle Mods, Lernbeispiele und konkrete Altlasten |
| [17 Vanilla-Audit](17_Vanilla_Audit.md) | Quellenketten und geprüfte Verträge |
| [18 Internetquellen](18_Quellen.md) | Quellenwert, Aktualität und Widersprüche |
| [19 Checklisten](19_Checklisten.md) | Umsetzung, Diagnose und Freigabe |
| [20 Einstieg für spätere Projekte](20_Projektworkflow.md) | Gezielte Suche, Entscheidungsmatrix und kompakte Vertragsnotizen |

## Arbeitsablauf für neue Mods

**Für zukünftige Arbeit mit Codex:** zuerst [Projektworkflow](20_Projektworkflow.md) lesen. Dort sind die minimale Lesereihenfolge, Suchbefehle und passende Beispiele je Vorhaben zusammengefasst. Diese Sammlung ergänzt die Workspace-Anweisungen; sie ersetzt sie nicht.

1. Ziel, Mod-Typ, betroffene Prefabs und benötigte Client-Daten festlegen.
2. Spielarchiv prüfen; den zuständigen Vanilla-Ablauf von Definition bis Aufrufer untersuchen.
3. Ein passendes [Workspace-Beispiel](16_Workspace_Mods.md) lesen und dessen historische Besonderheiten beachten.
4. Eine passende Vorlage in einen **neuen** Mod-Ordner kopieren. Die Ordner unter Documentation werden nicht automatisch im Spiel aktiviert.
5. Namen mit eigenem Präfix versehen; Metadaten, Konfiguration und Datenspeicherung definieren.
6. Kleine Änderungen implementieren, Syntax prüfen und die vorgesehenen Laufzeitfälle ausführen.
7. Host und separaten Client prüfen; bei Gameplay-Mods zusätzlich Dedicated Server und relevante Höhlenwechsel.
8. Erst nach belegten Ergebnissen veröffentlichen; geprüften Spielstand und mögliche Konflikte festhalten.

## Themenregister

- `AddPrefabPostInit`, `AddComponentPostInit`, `AddClassPostConstruct`: Kapitel 02 und 15.
- `SetPristine`, `ismastersim`, `AddReplicableComponent`: Kapitel 03 und 04.
- `net_bool`, `net_ushortint`, Dirty-Events, `GetModRPC`: Kapitel 04.
- `OnSave`, `OnLoad`, `LoadPostPass`, GUID, `newents`: Kapitel 05.
- `equippable`, `finiteuses`, `inventoryitem`, `WidgetSetup`: Kapitel 06.
- `AddRecipe2`, `TECH`, Filter, `AddCookerRecipe`: Kapitel 07.
- `AddAction`, `AddComponentAction`, `wilson_client`: Kapitel 08.
- `PriorityNode`, `BufferedAction`, `MakePlayerCharacter`: Kapitel 09.
- `AddRoomPreInit`, `AddTaskSetPreInit`, `StaticLayout`: Kapitel 10.
- `STRINGS`, `Text`, `OnControl`, HUD: Kapitel 11.
- Atlas, TEX, SCML, `swap_object`, SoundEmitter: Kapitel 12.
- `c_spawn`, `c_give`, `c_save`, Syntaxcompiler, Testmatrix: Kapitel 13.

## Pflege und maschinelle Hilfen

[tools/verify_reference.py](tools/verify_reference.py) prüft Dateien, CRLF/UTF-8, lokale Links, API-Signaturen und sämtliche Lua-Vorlagen. [tools/audit_scripts.py](tools/audit_scripts.py) vergleicht das Archiv erneut mit dem Snapshot, ohne Dateien zu entpacken oder zu ändern. [SOURCE_MANIFEST.json](SOURCE_MANIFEST.json) erfasst den Quellenstand und Hashes der für diese Sammlung herangezogenen Dateien.

Verlinkte Vanilla-Dateien liegen außerhalb des Repositorys im benachbarten `_scripts`-Ordner. Auf einem anderen Rechner sind diese Links erst nach Wiederherstellung dieser Struktur verfügbar.


## Vertiefung anhand der vorhandenen Mods

- [Abdeckungsmatrix aller 26 Modverzeichnisse](21_Abdeckungsmatrix.md): Umfang und Grenzen pro Mod.
- [Praxismechanismen](23_Praxismechanismen.md): Ernährung, Haltbarkeit/Upgrades, Quellenboni, Container, Daten-UI, Automation und Weltwechsel.
- [Neue Auditnachweise](22_Vertiefungs_Audits.md): Definitionen/Aufrufer, Entscheidungen und erneute Prüfung bisheriger Beispiele.
- [Fallstudienregister](case_studies/README.md): konkrete Abläufe und Altlasten.
- [13 eigenständige Vorlagen](templates/README.md): sechs Grundlagen-, sechs vertiefte Beispiele und eine Kochvorlage.

Für ein späteres Projekt: zuerst Abdeckungsmatrix und passende Fallstudie lesen, dann die Quellenkette im aktuellen Scriptstand erneut verfolgen, passende Vorlage kopieren und ihren Testplan konkretisieren. B/H/WIP-Grenzen sind gezielte neue Auditaufträge, keine bestätigten universellen Schnittstellen. [Projektworkflow](20_Projektworkflow.md) verbindet diese Schritte.


## Ergänzende Vertragsprüfung vom 03.10.2026

[Aufgabenindex](25_Aufgabenindex.md) verbindet Vorhaben, Quellen und Vorlagen. [Prüfgrenzen](24_Statische_Vertragspruefung.md), [API-Quellenketten](26_Quellenketten_API.md), [Reviewmatrix aller 26 Mods](REVIEW_MATRIX.json) und [isolierte Tests](tests/README.md) unterscheiden Inventar, Quellverträge, Logikergebnisse und offene Engineabnahme.


## Neue Navigation und Belege

- [Aufgabenindex](25_Aufgabenindex.md): passende Kapitel, Fälle und Vorlagen je Vorhaben.
- [Prüfgrenzen und Vorlagenmatrix](24_Statische_Vertragspruefung.md): was belegt ist und was offen bleibt.
- [API-Quellenketten](26_Quellenketten_API.md): Closureumgebung, Netaufbau, RPC und Restoreorder.
- [Konkrete Definitionsbelege](27_Vertragsbelege.md): maschinell kontrollierte Zeilen und Signaturen.
- [Assetbericht](ASSET_CHECK_RESULTS.json): tatsächliche Pfade/Regionen und ZIP-Mitglieder.
- [Isolierte Tests](tests/README.md): eigene Logik ohne Spielstart.

## Weitere Projektwege: Kochen, Kreaturen, Charaktere und Multiplayer

| Kapitel | Praktischer Nutzen |
|---|---|
| [28 Kochinhalte](28_Kochinhalte.md) | Eigenes Produkt von Registrierung über Frische/Topfsymbol bis Save/Load, Ernte und Cookbook; Gewürzstation abgrenzen |
| [29 Kreaturen und Charaktere](29_Kreaturen_Charaktere_Lebenszyklus.md) | Rabbit-/Wilson-Vergleich, Brain/SG, Schlaf/Tod, Charactercallbacks, Erstspawn und Ghost |
| [30 Multiplayer-Lebenszyklen](30_Multiplayer_Lebenszyklen.md) | Classified/Owner/Attach, initiale Anzeige, Prediction an/aus, Session und Shardmigration |
| [31 Praxis-Auditnachweise](31_Praxis_Auditnachweise.md) | Definitionen, Aufrufer, Zuständigkeiten, Restore/Cleanup und konkrete Grenzen |

[Vorlage 13](templates/13_cooked_food/README.md) ist ein eigenständiges Kochbeispiel; [Brain-/Charactercallback-Fragmente](examples/README.md) benötigen vollständige eigene Projekte und Assets. Die [Abdeckungsdimensionen](21_Abdeckungsmatrix.md) verhindern, dass eine Ablaufbeschreibung als universelle oder bereits im Spiel geprüfte Lösung verstanden wird.

Für die üblichen beschriebenen Mechanismen kann ein neuer Chat mit dieser Sammlung zielgerichtet arbeiten. Eigene Charaktergrafiken, neue Boss-/Skilltree-Systeme, private Datenverträge und native Enginefragen bleiben konkrete Projektarbeit. Der neue Feature-Audit und die tatsächlich nötigen Spieltests entfallen durch die Sammlung nicht.
