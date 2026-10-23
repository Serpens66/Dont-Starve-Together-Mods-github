# Aufgabenindex für neue Projekte

Zuerst [Projektworkflow](20_Projektworkflow.md), danach passende Quellenkette und Vorlage lesen. Der Name einer Funktion ersetzt keine Prüfung ihrer aktuellen Aufrufer.

| Aufgabe | Erklärung / Fallstudie | Ausgangsvorlage | Wesentlicher Audit |
|---|---|---|---|
| Prefab konfigurieren | [Hooks](02_Ladeumgebungen_Hooks.md), [Health](case_studies/21_health.md) | [01](templates/01_prefab_tweak/README.md) | Rolle, Maxwert, gespeicherter Zustand |
| Eigenes Item | [Gegenstände](06_Gegenstaende_Gebaeude_Container.md), [Sense](case_studies/20_scythe.md) | [02](templates/02_item/README.md) | Bank/Build, finiteuses, Equip/Rezept |
| Zähler replizieren | [Multiplayer](04_Multiplayer.md), [RPCkette](26_Quellenketten_API.md#replicas-und-rpcs) | [03](templates/03_network_component/README.md) | Netkonstruktion, Dirty, Eigentümer |
| Rechtsklickaktion | [Actions](08_Actions_Stategraphs.md), [Repair](case_studies/03_repair_combine.md) | [04](templates/04_action/README.md) | Componentaction, beide SGs, Servervalidierung |
| Lokales HUD | [UI](11_UI_Eingabe_Localisierung.md) | [05](templates/05_client_ui/README.md) | Owner, Input/Controller, Cleanup |
| Biomdichte | [Worldgen](10_Weltgenerierung.md), [Worldgenmods](case_studies/09_world_generation.md) | [06](templates/06_worldgen/README.md) | Room, Gebiet, Seed, Generierungszeitpunkt |
| Lagergebäude | [Trash Can](case_studies/02_trash_can.md), [Container](23_Praxismechanismen.md) | [07](templates/07_container_building/README.md) | Slots, Replicaui, Hammer, Contentreferenzen |
| Ernährungshistorie | [Food Queue](case_studies/01_food_queue.md), [Foodmemory](case_studies/15_foodmemory.md) | [08](templates/08_food_history/README.md) | eater-Order, Spices/Stackeat/Buff/Load |
| Ausrüstungsbonus | [Homebase](case_studies/06_homebase.md), [Modifier](23_Praxismechanismen.md) | [09](templates/09_source_bonus/README.md) | Quelle/Key, Kombination, Mount/Unequip |
| Serverdaten anzeigen | [Finder](case_studies/04_finder.md), [Show Me](case_studies/08_show_me.md) | [10](templates/10_query_ui/README.md) | Scope/Berechtigung, Budget, stale Reply |
| Room/Task | [Worldgen](10_Weltgenerierung.md), [Adventure](case_studies/12_adventure.md) | [11](templates/11_room_task/README.md) | Locks/Keys, Layout, Taskset |
| Runtimeweltoption | [More Worldsettings](case_studies/10_more_worldsettings.md), [Clock](case_studies/19_random_clock.md) | [12](templates/12_world_option/README.md) | Pre/Post, Restzeit, Pause/LongUpdate |
| Companionarbeit | [Maxwell](case_studies/05_maxwell.md) | gezielter Entwurf | tatsächliches Prefab, Brainzweig/SG, Slots |
| Automatisierung | [Auto Actions](case_studies/07_auto_actions.md) | gezielter Entwurf | Input/Preview/RPC, Equipmentrace/Abbruch |
| Welt-/Kapitelreset | [Teleportato](case_studies/11_teleportato.md), [Adventure](case_studies/12_adventure.md) | keine universelle Vorlage | externe Shards, bestätigter Save, idempotenter Restore |
| Innenräume | [Hamlet](case_studies/13_hamlet_architecture.md) | keine universelle Vorlage | Registry/GUID, Transition/Kamera, MPgeometrie |
| Charakterkosmetik | [Skins](case_studies/14_skins_architecture.md), [Assets](12_Assets_Animation_Audio.md) | gezielter Skinneraudit | skinmode/clothing/ownership, Formen/Load |
| Saison/Eis | [Ice](case_studies/22_ice.md) | neue Phasencomponent | Pond/Fishable/Kollision, Restzeit/Präzedenz |

## Vertragsnotiz pro Feature

Festhalten: Rollen; Originaldefinition und Aufrufer; vor/nach Pristine; Datenbesitzer/Transport; Benutzereingabeprüfung; Originalwerte bzw. versionierte Primärdaten; Restoreorder/Referenzen; Cleanup; Wrapperkonflikte; statische und ausgeführte Tests. Nach Update neue Belege prüfen.

[Tests](tests/README.md), [Prüfgrenzen](24_Statische_Vertragspruefung.md), [Manifest](SOURCE_MANIFEST.json) und [Reviewmatrix](REVIEW_MATRIX.json) helfen gezielt suchen. Sie sind kein pauschales Gütesiegel.

## Zusätzliche Projektwege

| Aufgabe | Erklärung | Praktischer Ausgangspunkt | Noch nötiger projektspezifischer Audit |
|---|---|---|---|
| Neue Crockpot-Speise | [28](28_Kochinhalte.md) | [13](templates/13_cooked_food/README.md) | Rezeptüberschneidung, Kocher, Produkt-/Topf-/Cookbookgrafik |
| Passive Kreatur | [29](29_Kreaturen_Charaktere_Lebenszyklus.md) | [Brainfragment](examples/creature_brain.lua) | vollständiger eigener Konstruktor, SGfelder/Clips, Verhalten |
| Eigener Charakter | [29](29_Kreaturen_Charaktere_Lebenszyklus.md) | [Callbackfragment](examples/character_callbacks.lua) | Auswahl/Assets, tatsächliche Fähigkeit, Ghost-/Moduspersistenz |
| Private Playerdaten | [30](30_Multiplayer_Lebenszyklen.md) | konkrete Vanilla-Classifieds | gültiger Owner, Zielzuordnung, Attach/Detach, Reconnect |
| Predicted Action | [30](30_Multiplayer_Lebenszyklen.md), [08](08_Actions_Stategraphs.md) | [04](templates/04_action/README.md) | Predicting/Nonpredicting, Servervalidierung, Abbruch |
| Persistenter Playerwert über Höhlen | [30](30_Multiplayer_Lebenszyklen.md), [05](05_Persistenz.md) | eigene gespeicherte Component | Session statt World-GUIDs; OnDespawn vor Serialize |

Die [Abdeckungsstufen](21_Abdeckungsmatrix.md) trennen Beispiel, Ablauf, Projekt-Audit und offenen Vertrag.
