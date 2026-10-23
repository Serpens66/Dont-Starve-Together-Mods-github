# 22 – Auditnachweise zur Vertiefung

Stand 03.10.2026. Der vollständige ZIPvergleich wurde erneut ausgeführt: 4.044 Dateien identisch, keine fehlenden/geänderten/zusätzlichen Dateien; Archiv-SHA-256 `f8d7cff2e9f86cdab3de08c6e750ecec2986c9bc95b364724f4c77244a798bf1`. [Manifest](SOURCE_MANIFEST.json) enthält API-, Quellenhash-, Inventar-, Vorlagen- und Abdeckungsdaten. Die Quellenzeile ist ein Navigationsanker; Symbolvorkommen allein ist kein Beweis des ganzen Vertrags. [Bisheriger Audit](17_Vanilla_Audit.md) bleibt der Grundstock.

## Feature-Audits und Entscheidungen

| Feature | Definition → Aufrufer/Initialisierung → Zuständigkeit/Save | Schluss für die Beispiele |
|---|---|---|
| Ernährung | edible/GetHealth/GetHunger/GetSanity → eater/Eat → custom_stats_mod_fn vor DoDelta, oneat danach, foodmemory/RememberFood am Ende | aktuelle Wirkung im Callback, Historie im Event; drei Rückgabewerte bewahren |
| Foodmemory | RememberFood/GetBaseFood/GetFoodMultiplier → eater/Eat → Componenttasks/OnSave/OnLoad/OnRemove | gewürzte Basisnamen und Restzeit statt Offlinewallclock; eigene Queue klar abweichend |
| Container | treasurechest/MakeChest → containers/widgetsetup → container_replica/container_classified → container/OnSave/OnLoad mit SpawnSaveRecord | eigene Parameterkopie auf allen Peers; Slotpersistenz nicht doppeln |
| Abbau | workable/WorkedBy → HAMMER → Callback OnWork/OnFinish im Prefab | Inhalte vor Remove ablegen; Instanzzähler statt Dateilokale |
| Haltbarkeit | finiteuses/SetPercent, armor/SetCondition, fueled/SetPercent, perishable/SetPercent → Reparaturaction; OnSave/OnLoad je Component, Stackable/Get/Put | Maxima und aktuelle Werte unterscheiden; Clamping/Callbacks nicht umgehen |
| Ausrüstung | Inventory/Equip/Unequip → Equippable/Equip/Unequip → SourceModifierList/SetModifier/RemoveModifier → Combat/GetDamage | Quelle inst plus eigener Key; Eigencleanup, nach Load Equip ableiten |
| Speed | Locomotor/SetExternalSpeedMultiplier/RemoveExternalSpeedMultiplier → Laufgeschwindigkeit/Playerclassified | anderer Argumentvertrag und Prediction; kein ungeprüfter Equip-Speedbonus |
| Datenabfrage | networkclientrpc/AddModRPCHandler/SendModRPCToServer → serverseitiger Handler → Component/Replica → net_string/Dirty → Controls/Button | begrenzte rein numerische Anfrage; Serverposition/Radius; öffentliche Antwort und Sequenzprüfung |
| Private Hint | player_common/SetClassifiedTarget → player_classified → ShowMe-Dirty/HoverText | private Classifiedzuständigkeit nicht mit Player-Netstring verwechseln |
| Worldgen | mods/CreateEnvironment und map/lockandkey → AddRoom/AddTask/AddTaskSetPreInit → Level/ChooseTasks → GraphNode/ConvertGround → ObjectLayout/LayoutForDefinition/Convert | eigenen Room/Task registrieren; LOCKS.NONE im Standardtask ein Einzelwert |
| Layouts | map/layouts/SimpleBase → StaticLayout.Get → LayoutForDefinition/Deepcopy → ConvertLayoutToEntitylist → ReserveAndPlaceLayout | vorhandener Layoutname, keine Platzierungsgarantie für jeden Seed |
| Weltoption | Modworldgenmain auch im Runtime-Ladepfad → Customize/GetWorldSettingsFromLevelSettings → Gamelogic/Pre vor Spawnworld, SetPersistData, Post danach | UI und Runtime getrennt implementieren; Pre ohne TheWorld |
| Timer | Timer/StartTimer/OnSave/OnLoad/LongUpdate/OnRemove → Worldsettingsutil/Pickable-PreLoad → worldsettingstimer | eigenes Beispiel hat einen eigenen persistierten Task; relative Restzeitregel ausdrücklich beschrieben |
| Migration | EntityScript/GetSaveRecord/SetPersistData/LoadPostPass → Inventory/Follower/Teleporter → neue Worldentities | GUIDreferenzen nicht als weltübergreifend dauerhafte IDs behandeln |
| Assets | Asset/Prefabregistrierung → Bildatlasresolver/AnimState-Namen; lokale image_build/zipanim/export/buildanimation-Kette gelesen | Quell-ZIP und kompilierte Anim-ZIP unterscheiden; Toolinterpreter/Outputpfade prüfen |

## Erneute fachliche Prüfung der sechs bisherigen Vorlagen

| Vorlage | Nachvollzogener Vertrag | Grenze/Test |
|---|---|---|
| 01 Prefabtweak | PrefabPostInit nach Prefabkonstruktion; weapon:SetDamage auf Master | späterer Hook kann überschreiben; Reconnect/Configwechsel |
| 02 Item | Speerbank/swap_build, SetPristine vor Clientreturn, Weapon/Finiteuses/Equippable, Recipe2 | Asset-/Equip-/Verbrauchstest bleibt offen |
| 03 Networkcomponent | net_ushort vor SetPristine, AddReplicableComponent, Owner-GUID-/GrandOwner-/Cooldowncheck, Saveversion | Owneränderung/RPCflut/Migration und late join testen |
| 04 Action | SCENE-Modcomponentactions, Clienttags, beide SGs, Distanz-/Alivecheck serverseitig, Markpersistenz | Actionunterbrechung/Clientsammlung und verspätete Tags testen |
| 05 ClientUI | Controls.topleft_root, Text, Dedicatedguard, passive Clickability | HUDskalierung/Screenfokus/Controller prüfen |
| 06 Worldgen | BGForest RoomPreInit, Gewichtsfaktor, bestehende Definition | Gewichte sind keine absolute Dichte; nur Neugenerierung |

## Grenzen des Audits

Die 236 Workspace-Lua-Dateien sind inventarisiert und unverändert gehasht. Fallstudien verfolgen die beschriebenen wesentlichen Pfade, nicht jede kommentierte historische Alternative oder jede Fremdmodintegration. Komplexe Sonderboss-, Innenraum-, Weltreset-, Automations- und Anzeigeverträge bleiben einzeln bezeichnete B/H/WIP-Grenzen. Native Netzwerkbudgets, Binaryassets, Engine-Resetatomarität und Profilkosten können nicht aus Lua-Signaturen bewiesen werden. Diese Grenze wird nicht mit erfundenen Laufzeitergebnissen gefüllt.

Für Updates: ZIP erneut vergleichen; geänderte Manifestquellen ermitteln; Definition **und alle relevanten Aufrufer** lesen; betroffene Fallstudien/Beispiele aktualisieren; statisch prüfen; anschließend den jeweiligen offenen Ingame-Testplan abarbeiten. SHA-256 nur nach erneutem Audit aktualisieren, nicht zum Wegdrücken einer Warnung.


## Ergänzende Vertragsprüfung vom 03.10.2026

[Aufgabenindex](25_Aufgabenindex.md) verbindet Vorhaben, Quellen und Vorlagen. [Prüfgrenzen](24_Statische_Vertragspruefung.md), [API-Quellenketten](26_Quellenketten_API.md), [Reviewmatrix aller 26 Mods](REVIEW_MATRIX.json) und [isolierte Tests](tests/README.md) unterscheiden Inventar, Quellverträge, Logikergebnisse und offene Engineabnahme.
