# 18 – Internetquellen, Aktualität und Widersprüche

Recherche: 03.10.2026. Die aktuellen lokalen Scripts sind die maßgebliche Implementierungsquelle. Die folgenden Internetquellen ergänzen Begriffe, Werkzeuge und Veröffentlichung. Eigene Zusammenfassungen ersetzen weder Quellenprüfung noch Rechte an fremden Assets.

| Quelle | Zugriff und Einordnung | Nutzen |
|---|---|---|
| [Klei: Modding Don't Starve and Don't Starve Together](https://support.klei.com/hc/en-us/articles/360029555992-Modding-Don-t-Starve-and-Don-t-Starve-Together) | Offizielle Supportseite, direkt gelesen; angezeigtes Update 15.07.2026 | Modding-Möglichkeiten, Mod Tools und Veröffentlichungsanforderungen. Keine vollständige technische DST-API. |
| [Klei ds_mod_tools](https://github.com/kleientertainment/ds_mod_tools) | Offizielles Repository, README gelesen | SCML-Workflow und Toolquellen; historische Python-2.7-/Linux-/macOS-Annahmen nicht als Windows-Einrichtungsanweisung übernehmen. |
| [Lua 5.1 Reference Manual](https://www.lua.org/manual/5.1/manual.html) | Originaldokumentation, direkt gelesen | Sprachsemantik, Metatables, setfenv, Module und Standardbibliothek. Die DST-Engine stellt zusätzliche Globals bereit. |
| [rezecib: Getting started with modding DST](https://kleiforums.com/forums/topic/47353-guide-getting-started-with-modding-dst-and-some-general-tips-for-ds-as-well/) | Historischer Klei-Forenbeitrag; direkter Aufruf blockiert, Inhalt über Suchindex gelesen | Überblick über Components/Replicas, Erweiterungspunkte und RPC. Technische Details gegen aktuellen Snapshot prüfen. |
| [Wonderlarr: New recipe system functions](https://kleiforums.com/forums/topic/140881-documentation-new-recipe-system-functions-other-info/) | Beitrag von 2022, beschreibt auch Update von 2024; Suchindex gelesen | Neue Rezeptfilter und AddRecipe2. Aktuelle Sonderfälle stehen in modutil.lua/recipe.lua. |
| [Tutorial: DST's new craft menu](https://kleiforums.com/forums/topic/147251-tutorialcomplete-tutorial-for-dsts-new-craft-menu/) | Klei-Forum, indexierter Text gelesen | UI-/Rezeptüberblick; eine Parameterbeschreibung nennt tech als String, was keine korrekte Vorgabe für die aktuelle TECH-Tabelle ist. |
| [Kzisor: Before beginning](https://kleiforums.com/forums/topic/50574-guide-modding-practices-before-beginning/) und [Introduction to modding](https://kleiforums.com/forums/topic/50773-guide-modding-practices-introduction-to-modding/) | Historische Beiträge von 2015; Suchindex gelesen | Orientierung zur Mod-Struktur; keine Aktualitätsgarantie für API oder Multiplayer. |
| [Linux: autocompiler and necessary tools](https://kleiforums.com/forums/topic/167818-guide-how-to-get-autocompiler-and-nescessary-tools-for-modding-dont-starve-together-on-linux/) | Suchindex als ergänzender Fund; keine lokale Linux-Prüfung | Verweist auf Exportordner und Klei-Werkzeuge. Für diesen Windows-Workspace nicht als geprüfte Installation verwendet. |

## Aufgelöste Widersprüche

- Ältere Beispiele verwenden Recipe/AddRecipe/AddRecipeTab. Sie sind im aktuellen modutil.lua noch enthalten, geben aber Deprecated-Warnungen aus. Neue Beispiele verwenden AddRecipe2.
- Aussagen, Stategraphs seien ausschließlich serverseitig, reichen für DST nicht: `SGwilson_client.lua` verarbeitet vorhergesagte Spieleraktionen.
- Recipe2 erwartet Techdaten als Tabelle, beispielsweise `TECH.NONE`. Ein Tutorialbegriff „String“ ersetzt diesen Vertrag nicht.
- MODS als automatisch ergänzter Filter hat Ausnahmen, unter anderem nounlock. Filter nicht pauschal doppelt ergänzen.
- Kommentare vorhandener Mods, ein RoomPreInit könne einen unbekannten Room neu erstellen, werden durch die aktuelle Room-Ladekette nicht bestätigt.
- Python-Versionen aus dem historischen Klei-Toolrepository beschreiben dessen damalige Umgebung. Sie belegen nicht, dass das installierte Windows-Tool mit dem vorhandenen Python 3 gestartet werden kann.

Belege für diese technischen Punkte stehen in [Ladeumgebungen](02_Ladeumgebungen_Hooks.md), [Crafting](07_Crafting_Kochen.md), [Actions](08_Actions_Stategraphs.md), [Weltgenerierung](10_Weltgenerierung.md) und [Assets](12_Assets_Animation_Audio.md).

## Quellenpflege

Internetbeiträge können verschwinden, gesperrt sein oder ihren Inhalt ändern. Hier sind Links, Zugriffsmethode und Aussagegrenzen dokumentiert; vollständige fremde Tutorials wurden nicht kopiert. Foren-Direktzugriff wurde nicht als erfolgreich ausgewiesen. Für konkrete neue Features zuerst lokale Implementierung prüfen, danach zusätzliche themenspezifische Primärquellen recherchieren. Ein Suchindexauszug ist kein Beleg für nicht sichtbare Anhänge oder weiterführende Antworten.


## Vertiefung 03.10.2026

Erneut online gelesen: [Kleis ds_mod_tools](https://github.com/kleientertainment/ds_mod_tools) und [Lua 5.1 Reference Manual](https://www.lua.org/manual/5.1/manual.html). Lokale Mod-Tools-Implementierungen image_build/zipanim/export/buildanimation liefern die konkrete installierte CLIkette; ihre Definitionen sind direkt im [Assetkapitel](12_Assets_Animation_Audio.md) verlinkt. Keine externen Tutorials ersetzt kopiert. Erweiterte Vanilla-/Modbelege stehen in den Fallstudien, [Auditnachweisen](22_Vertiefungs_Audits.md) und dem [Manifest](SOURCE_MANIFEST.json). Toolinterpreter-/Binär-/FMODfähigkeit blieb ungeprüft; statische Existenz ist kein erfolgreicher Export.


## Erneute Internetrecherche 03.10.2026

| Primärquelle | Abruf / Version | Konkreter Bezug und Grenze |
|---|---|---|
| [Klei ds_mod_tools](https://github.com/kleientertainment/ds_mod_tools) | 03.10.2026, master-README; kein unveränderlicher Commitpin | Historische SCML-/Autocompileroberflächen und Plattformabhängigkeiten; nicht automatisch identisch zur lokal gehashten Steaminstallation |
| [image_build.py Originalquelle](https://raw.githubusercontent.com/kleientertainment/ds_mod_tools/master/pkg/cmn/mod_tools/compiler_scripts/image_build.py) | 03.10.2026, master-Datei | Aktive process_file_to_atlas gegenüber anderem ExportImage-Helfer; Outputpfad/CWD/Atlasformat. Lokale Werkzeugquelle zusätzlich im Manifest gehasht |
| [Lua-5.1-Manual](https://www.lua.org/manual/5.1/manual.html) | 03.10.2026, Sprachversion 5.1 | Funktionsumgebungen, lokale Closures, Wahrheit und Operatorrangfolge; Sprachfälle zusätzlich mit vorhandenem 5.1-Interpreter reproduziert |
| [Introduction to replicas](https://forums.kleientertainment.com/forums/topic/106889-introduction-to-replicas/) | 03.10.2026, Direktabruf 403/Tool-Internal-Error | Volltext nicht verfügbar. Keine daraus ungeprüft übernommenen technischen Garantien; aktuelle entityreplica/EntityScript/modutil sind der konkrete Beleg |
| [Musicmod-Tutorial](https://forums.kleientertainment.com/forums/topic/131653-tutorial-updated-updated-guide-on-how-to-create-music-mods-with-or-without-thescrapskleis-templates/) | 03.10.2026, Direktabruf 403/Tool-Internal-Error | Keine bestätigte FMOD-/Bankversionsanleitung aus dem Volltext. Lokale Designer-/Studioversionen nur Inventar, kein Exporttest |

Recherchetreffer zu anderen Klei-Spielen (z.B. Griftlands-Audio) liefern keinen DST-Bankvertrag. Ältere Communitybeiträge sind Suchhilfen; Replikation, RPC, Prediction und Worldgen werden anhand aktueller eigener Spielscripts belegt. Unzugängliche Primärbeiträge werden nicht durch vermeintlich gleichwertige Suchsnippets ersetzt.
