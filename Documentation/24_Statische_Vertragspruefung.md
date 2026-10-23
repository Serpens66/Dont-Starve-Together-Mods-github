# Statische Vertragsprüfung und verbleibende Abnahme

Stand 03.10.2026: 4.044 Archivdateien erneut identisch. Änderungen dieser Überarbeitung betreffen ausschließlich Documentation. Keine Spielinstanz gestartet.

<a id="zwölf-vorlagen-geprüfte-schnittstellen"></a>

## Vorlagen: geprüfte Schnittstellen

| Vorlage | Geprüfter Vertrag und Sonderfall |
|---|---|
| 01 prefab_tweak | Modumgebung/Config, PrefabPostInit, Health-Maxwechsel mit Prozentbewahrung; positive Unendlichkeit jetzt abgewiesen |
| 02 item | Prefabloader unter Spielglobals, Speerbank/Build/Swap, Pristine vor Servercomponents, Rezept/finiteuses |
| 03 network_component | Replicaregistrierung vor Instanziierung, Netushort vor Pristine, Dirtylistener, Load schreibt Replica; RPC prüft echte Entity/GUID/GrandOwner und Budget |
| 04 action | gemeinsame Action/Componentaction/beide SGs; serverseitige Distanz und Gesundheit; Preview autorisiert keine Wirkung |
| 05 client_ui | Controlsowner/Topleftroot/Widgetentity-Cleanup, Dedicatedguard; Callback behält Modumgebung |
| 06 worldgen | Worldgenumgebung, Roomhook bestehender Dichte, keine Runtime-Terrainänderung; positive Unendlichkeit jetzt abgewiesen |
| 07 container_building | gemeinsame Slots, Replica-WidgetSetup, Servercontainer, Placer, Hammerdrop, Content-SaveRecords; keine vollständige aktuelle Treasurechest-Kopie mit Upgrades/Burn/Skins |
| 08 food_history | eater-Customfn vor Deltas, oneat danach; positive Wirkung, MRU3, validierter Save; nach Remove deaktiviert auch eine in fremdem Wrapper behaltene Closure |
| 09 source_bonus | Quelle/Key für Speed/Damage, Equip und gezielter Unequip; abgeleitete Modifier nicht als Primärdaten speichern |
| 10 query_ui | servereigener Spielerparameter, begrenzte Sequenz/Radius/Cooldown, Replicaantwort; Update verwendet jetzt GLOBAL.tonumber |
| 11 room_task | registrierter Room/Task, aktuelle Locks/Keys, Vanilla-Layout, default-Foresttaskset; keine allgemeine Höhlenvorlage |
| 12 world_option | Customize in Worldgen/Runtime, Pre-/Postoverride, servereigener Timer, Restzeitfraction bei Änderung; kein allgemeiner LongUpdate-/Offlineprogressersatz |
| 13 cooked_food | getrennte Kocher-/Produktregistrierung, explizite Weight/Priority, Topf-/Boden-/Cookbookgrafik, Frische-/Stewerpersistenz; eigener Filter gegen unbeabsichtigte Gewürzverarbeitung |

Die [Vorlagen](templates/README.md) enthalten Einbau und konkrete Laufzeitfälle. [Vertiefungsaudits](22_Vertiefungs_Audits.md) und [API-Quellenketten](26_Quellenketten_API.md) verfolgen Initialisierung, Aufrufer, Rollen, Speicherung und Cleanup. Diese Prüfung beweist keine native Animation, tatsächlich ausgelöste Dirtyevents oder Engine-Actionerfolge.

## Was die Prüfungen beweisen

- Archivvergleich: Snapshot entspricht dem installierten Archiv, nicht automatisch dem weltweit neuesten Build.
- Hash: bezeichnete Datei blieb gleich; kein Beweis eines verstandenen Ablaufs.
- Symbol-Link: Textstelle außerhalb von Kommentaren vorhanden; kann Aufrufer sein, kein Definitionsbeweis.
- Manifestbeleg: genaue Zeile/Excerpt; bei kind=definition lexikalisch erkannte Funktionsdefinition. Kommentar und String zählen nicht. Anonyme Hooks sind kein erfundener benannter Funktionsvertrag.
- Abhängigkeit: literale require-/PrefabFiles-/eigene AddComponent-/Replica-Ziele vorhanden. Dynamische Namen, bedingte Registrierung, externe Mods und native Suchpfade getrennt behandeln.
- Assetprüfung: deklarierte literalische Pfade im Mod oder installierten Archiv und Atlasregionen vorhanden. Keine Rendering-/Bankkompatibilitätsfreigabe.
- Lua -p: erfolgreiche Compilerstarts und Parses separat gezählt; keine Bytecodes geschrieben.
- Isolierte Tests: tatsächliche eigene Logik mit kleinen Stubs ausgeführt, keine DST-/Netzwerkemulation.

Der [Referenzprüfer](tools/verify_reference.py) trennt Dokumentationsfehler, Syntaxfehler und Infrastrukturfehler. Mit --skip-lua wird kein Syntaxerfolg ausgegeben. Fehlender Compiler/Startfehler lässt andere Ergebnisse sichtbar; frühere Erfolge bleiben gezählt, Gesamt-Syntaxerfolg bleibt false. Exit 0 eines rein statischen Laufs ist keine Gesamtfreigabe.

## Erneute Modzuordnung und offene Verträge

Alle 26 Verzeichnisse wurden erneut auf aktive Einstiege, Registrierungen und Fallstudienzuordnung gesichtet. [REVIEW_MATRIX](REVIEW_MATRIX.json) benennt die Prüftiefe. Einstiegscan ist vom tiefen Featureaudit zu unterscheiden. Auskommentierte Loader, unbenutzte Cachevariablen und externe GemCorefunktionen sind keine aktuellen eigenen Vanilla-Verträge.

Die vertieften Fälle erklären konkrete Risiken: Maxwell Legacybrain/Containerguids; Homebase unterschiedliche Rechnungen; Auto Actions Preview/Retarget; Show Me veraltete Schätzwerte; Health Form/Wake/Save; Teleportato Transferphasen; Adventure Dialog/Lightcleanup; Hamlet fehlender MP-Innenraumvertrag; Skins heutiger Skinner; Ice Sprach-/Restzeitfehler. Bestehende Mods bleiben unverändert.

Host, separater Client, Dedicated, Save/Load, Reconnect, Shards sowie Action/UI/Assets bleiben offen. Ergebnisse pro Projekt mit Rolle, Scriptstand, Modliste, Eingabe, erwartetem und tatsächlichem Zustand festhalten. Keine vorhandene Mod wird dadurch als voll funktionsfähig zertifiziert.

Die neuen ausgewählten Featureketten und Fragmente sind zusätzlich in [31](31_Praxis_Auditnachweise.md) abgegrenzt. Der historische Anchor für die erste Zwölf-Vorlagen-Matrix bleibt erhalten, damit vorhandene Links gültig sind.
