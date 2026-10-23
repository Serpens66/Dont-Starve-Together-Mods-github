# 23 – Praktische Mechanismen aus den Workspace-Mods

Dieses Kapitel verbindet die Grundlagen mit den konkreten Fallstudien. Für ein neues Feature zuerst passenden Abschnitt/Fallstudie wählen, dann die [Auditkette](22_Vertiefungs_Audits.md) und Vorlage lesen. Änderungen am bestehenden Mod folgen dem [Projektworkflow](20_Projektworkflow.md).

## Ernährung: Wirkung, Verlauf und Anzeige

[components/eater.lua — function Eater:Eat](<../../_scripts/scripts_02_10_2026/scripts/components/eater.lua>) (Zeile 230) prüft Essbarkeit, bestimmt Stackfaktor, liest foodmemory-Multiplikator und edible-Deltas, wendet Charakterabsorption und custom_stats_mod_fn an, verändert Stats, sendet oneat, informiert Lebensmittel/entfernt es und merkt zuletzt foodmemory. Deshalb darf ein oneat-Listener die Queue fürs nächste Essen ändern, aber die schon erfolgte Mahlzeit nicht über einen nachträglich geänderten Faktor "korrigieren". Das würde Caps, negative Effekte, Feeder und OnEaten-Sonderwirkungen umgehen.

Foodmemory setzt wiederholungsabhängige Faktoren pro Basisgericht und einen neu gestarteten Ablauf. [components/foodmemory.lua — GetBaseFood](<../../_scripts/scripts_02_10_2026/scripts/components/foodmemory.lua>) (Zeile 28) normalisiert Spicedfood; eine FIFO-/MRU-Queue ist semantisch anders. Für jede Mechanik festlegen: zählt erfolgloses Essen? Potion? Favorit? Grundstat oder tatsächliches Delta? Stack ganz essen? Neue Modbeschreibung muss diese Fragen beantworten. [Food Queue](case_studies/01_food_queue.md), [FoodMemory Everyone](case_studies/15_foodmemory.md), [eigenes Beispiel](templates/08_food_history/README.md).

## Haltbarkeit und echte Aufwertung

| System | Normaler Setter | Savegröße | Besonderheit |
|---|---|---|---|
| finiteuses | SetUses/SetPercent | verbleibende Uses | Ende kann Entity entfernen; Actions können verschiedene Nutzungskosten haben |
| armor | SetCondition/SetPercent | condition | maxcondition separat; Clamp und onfinished/Remove |
| fueled | DoDelta/SetPercent | fuel | depleted/sectioncallbacks und Verbrauchstask |
| perishable | SetPercent | time/paused | perishtime versus perishremainingtime, Verderbtask |

Belege: [components/finiteuses.lua — OnSave](<../../_scripts/scripts_02_10_2026/scripts/components/finiteuses.lua>) (Zeile 48), [components/armor.lua — SetCondition](<../../_scripts/scripts_02_10_2026/scripts/components/armor.lua>) (Zeile 90), [components/fueled.lua — OnSave](<../../_scripts/scripts_02_10_2026/scripts/components/fueled.lua>) (Zeile 133), [components/perishable.lua — OnSave](<../../_scripts/scripts_02_10_2026/scripts/components/perishable.lua>) (Zeile 331). Reparatur verändert aktuellen Vorrat; Upgrade verändert eine persistente Eigenschaft, aus der Maxima erneut abgeleitet werden. Für neue Upgradeitems Schema und Level speichern, Maxima vor Restwertwiederherstellung setzen, beim Configwechsel bewusst Prozent oder absolute Menge erhalten. Nicht nur ein Maximalfeld hochsetzen und danach auf Vanilla-Load hoffen.

[components/stackable.lua — function Stackable:Get](<../../_scripts/scripts_02_10_2026/scripts/components/stackable.lua>) (Zeile 109) spawnt eine neue Entity und übernimmt ausgewählte Zustände, darunter perishremainingtime. Eine eigene Upgradecomponent muss Split/Mergefähigkeit oder Stackable-Ausschluss definieren. [Repair Combine](case_studies/03_repair_combine.md) zeigt warum gefüllte Stacks und Overmax zusätzliche Verträge brauchen.

## Quellen und Rückbau von Boni

[util/sourcemodifierlist.lua — SetModifier](<../../_scripts/scripts_02_10_2026/scripts/util/sourcemodifierlist.lua>) (Zeile 64) arbeitet pro source und key. Standardaggregator multipliziert; additive/boolean Varianten werden ausdrücklich im Konstruktor gewählt. Entityquelle erhält onremove-Bereinigung. Stringquelle braucht expliziten Rückbau. `SetModifier(source, modifier, key)` unterscheidet sich von `locomotor:SetExternalSpeedMultiplier(source, key, multiplier)`. `RemoveModifier(source)` entfernt alle Schlüssel dieser Quelle; mit Key nur den eigenen Eintrag entfernen. Kein globales Reset, das andere Mods löscht.

Equipcallback erfolgt innerhalb Inventory:Equip, bevor jede nachfolgende Slot-/Eventphase abgeschlossen ist. Die übergebenen Argumente inst,owner benutzen, statt schon endgültige Equiptabellen vorauszusetzen. [Bonusvorlage](templates/09_source_bonus/README.md) speichert keinen derived Modifier; Equip rekonstruiert ihn. [Home Base](case_studies/06_homebase.md) erläutert Umweltcache und die abweichende Semantik historischer Bonuslisten.

## Container: vier zusammengehörige Verträge

1. Gemeinsame Widgetparameter und Tags vor Clientreturn; eigene Deepcopy statt Mutation der Vanillatabelle.
2. Servercomponent akzeptiert/verschiebt echte Entities; Itemtest und Mengenbeschränkung gehören hierher.
3. Replica/Classified transportiert Slot-/Öffnungszustand; UI darf keine nicht replizierten Serverfields lesen.
4. OnSave/OnLoad speichert SaveRecords und Referenzen; Abbau/Brand legt Inhalte ab, bevor Entity entfernt wird.

[components/container.lua — OnSave](<../../_scripts/scripts_02_10_2026/scripts/components/container.lua>) (Zeile 979) / [components/container.lua — OnLoad](<../../_scripts/scripts_02_10_2026/scripts/components/container.lua>) (Zeile 996), [components/container_replica.lua — container_classified](<../../_scripts/scripts_02_10_2026/scripts/components/container_replica.lua>) (Zeile 23). Besondere Filter, Equip-Overflow, Maschinenbutton oder vernichtende Verarbeitung benötigen eigene Zusatztests. [Trash Can](case_studies/02_trash_can.md), [Maxwell](case_studies/05_maxwell.md), [Gebäudevorlage](templates/07_container_building/README.md).

## Datenabhängige UI und Spielerautomatisierung

UI ist eine Ansicht des bekannten Zustands. Für eine Anfrage erlaubte Daten, Serverbudget, Ziel-/Owner-/Entfernungsprüfung, Antwortzuordnung und Cleanup festlegen. Eine Client-Pause zwischen RPCs schützt den Server nicht vor manuell gesendeten Anfragen. Öffentliche netvars und owner-targeted Classified unterscheiden sich in der Verteilung; die bloße Anzeige nur bei ThePlayer erzeugt keine Privatheit. Serverantworten müssen verspätete oder entfernte Ziele verkraften. [Finder](case_studies/04_finder.md), [Show Me](case_studies/08_show_me.md), [validiertes Beispiel](templates/10_query_ui/README.md).

Automatisierung wählt Vanilla-BufferedActions und gibt sie dem Controller. Actionpicker liefert Kandidaten, Prediction zeigt Versuch, Server führt zulässige Action aus. Ein lokaler Boolean darf nicht serverseitige Prüfung ersetzen. Eigene dauernde OnUpdate-Suchen benötigen Budget, Zielinvalidierung, Abbruch und fokussierte Eingaben. [Auto Actions](case_studies/07_auto_actions.md) dokumentiert den Original-/Fallbackpfad; kein universeller automatischer Spieler wird als geprüfte Vorlage angeboten.

## Weltoptionen, Layouts und persistenter Wechsel

Option → gespeicherter Override → Pre/Post/Sync → konkrete Component/Tuningwirkung ist eine vollständige Kette. Pre existiert vor TheWorld; Post liegt nach Weltpersistenz, vor der restlichen Entitypopulation. Laufende Timer müssen ausdrücklich angepasst oder bewusst nur für den nächsten Zyklus verändert werden. [More Worldsettings](case_studies/10_more_worldsettings.md), [Timerbeispiel](templates/12_world_option/README.md).

Roomgewichte bestimmen relative Auswahl, distributepercent die Gesamtdichte. Tasks organisieren Roomwahl und Graphprogression; Layoutnamen werden über mehrere Layoutregister aufgelöst, tiefkopiert und reserviert. Ein angeforderter count ist keine Zusicherung, dass jedes Layout in jedem Seed Platz findet. [Worldgen](case_studies/09_world_generation.md), [Room/Taskbeispiel](templates/11_room_task/README.md).

Migration in einen bestehenden Shard, Save/Load derselben Welt und Reset in eine neue Welt sind verschiedene Datenverträge. [components/teleporter.lua — LoadPostPass](<../../_scripts/scripts_02_10_2026/scripts/components/teleporter.lua>) (Zeile 410) löst Partnerreferenzen über newents der geladenen Welt. Weltübergreifend GUIDs/Positionen/Einmalflags blind zu kopieren ist kein Ersatz dafür. [Teleportato](case_studies/11_teleportato.md) erklärt das zusätzliche Übergabeprotokoll; [Adventure](case_studies/12_adventure.md) dessen Kapitel- und Callbackabhängigkeiten. Eine produktive Resetlösung braucht nachgewiesene Idempotenz und Crash-/Shardantwortstrategie.
