# 15 – API-Register aus modutil.lua

93 tatsächlich definierte Funktionswrapper im geprüften Snapshot. Signaturen sind aus der Quelle extrahiert; Parameterbezeichnungen werden nicht durch vermutete komfortablere Signaturen ersetzt.

Main bedeutet Registrierung im Spiel-Mod-Lader, nicht automatisch Serverausführung. Die Hookfunktion kann auf Clients aufgerufen werden; Gameplay braucht einen Mastersim-Guard. Worldgen-Verfügbarkeit folgt dem frühen Return in InsertPostInitFunctions. Einige gemeinsame APIs sind dort registrierbar, ihre Runtime-Callbacks werden jedoch erst im Spiel ausgeführt.

Frontend ist ein zusätzlicher Parameter des Laders, kein pauschaler Ausschluss aller Main-Wrapper: sofern das Frontend-Environment nicht als Worldgen erstellt wird, passiert es ebenfalls den Main-Teil. „Nur Main“ in der Tabelle bedeutet deshalb „nicht im Worldgen-Environment“. Es garantiert weder vorhandene Gameplay-Entities im Frontend noch die Ausführung dort registrierter Spielhooks. ReloadFrontEndAssets hat dagegen einen eigenen isfrontend-Guard.

Die Tabelle enthält Registrierungskontext und Anwendungsfall. Für vollständige Datenstrukturen und Spezial-APIs zusätzlich die delegierte Implementierung prüfen. Callbackverträge der sechs Vorlagen sind im [Audit](17_Vanilla_Audit.md) verfolgt.

| Signatur | Registrierungskontext | Verwendung / Callback | Quelle |
|---|---|---|---|
| `ReloadFrontEndAssets()` | nur Frontend | env.FrontEndAssets erneut laden; nur Frontend. | [modutil.lua:187](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `ReloadPreloadAssets()` | Main/Frontend, nicht Worldgen | env.PreloadAssets vorladen; nicht Worldgen. | [modutil.lua:203](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddCustomizeGroup(category, name, text, desc, atlas, order)` | Main/Worldgen | Weltoptionengruppe/-eintrag über map/customize ändern; Datenvertrag dort prüfen. | [modutil.lua:212](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `RemoveCustomizeGroup(category, name)` | Main/Worldgen | Weltoptionengruppe/-eintrag über map/customize ändern; Datenvertrag dort prüfen. | [modutil.lua:217](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddCustomizeItem(category, group, name, itemsettings)` | Main/Worldgen | Weltoptionengruppe/-eintrag über map/customize ändern; Datenvertrag dort prüfen. | [modutil.lua:222](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `RemoveCustomizeItem(category, name)` | Main/Worldgen | Weltoptionengruppe/-eintrag über map/customize ändern; Datenvertrag dort prüfen. | [modutil.lua:227](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `GetCustomizeDescription(description)` | Main/Worldgen | Beschreibung einer Weltoption abfragen. | [modutil.lua:232](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddLevelPreInit(levelid, fn)` | Main/Worldgen | Leveldaten vor Verarbeitung ändern; fn(level). | [modutil.lua:238](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddLevelPreInitAny(fn)` | Main/Worldgen | Alle Leveldaten vor Verarbeitung ändern; fn(level). | [modutil.lua:246](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddTaskSetPreInit(tasksetname, fn)` | Main/Worldgen | Bestimmtes Taskset ändern; fn(taskset). | [modutil.lua:251](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddTaskSetPreInitAny(fn)` | Main/Worldgen | Alle Tasksets ändern; fn(taskset). | [modutil.lua:259](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddTaskPreInit(taskname, fn)` | Main/Worldgen | Vorhandene Taskdefinition ändern; fn(task). | [modutil.lua:267](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddRoomPreInit(roomname, fn)` | Main/Worldgen | Vorhandene Roomkopie ändern; fn(room); legt fehlende Rooms nicht an. | [modutil.lua:275](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddLocation(arg1, ...)` | Main/Worldgen | Locationdefinition über AddModLocation registrieren. | [modutil.lua:283](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddLevel(arg1, arg2, ...)` | Main/Worldgen | Leveldefinition registrieren; UpgradeModLevelFromV1toV2 wird angewendet. | [modutil.lua:287](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddTaskSet(arg1, ...)` | Main/Worldgen | Taskset über AddModTaskSet registrieren. | [modutil.lua:294](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddTask(arg1, ...)` | Main/Worldgen | Neue Taskdefinition über AddModTask registrieren. | [modutil.lua:298](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddRoom(arg1, ...)` | Main/Worldgen | Neue Roomdefinition über AddModRoom registrieren. | [modutil.lua:302](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddStartLocation(arg1, ...)` | Main/Worldgen | Startlocation über AddModStartLocation registrieren. | [modutil.lua:306](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddGameMode(game_mode, game_mode_text)` | Main/Worldgen | Nur Warnung: entfernt. game_modes in modinfo.lua verwenden. | [modutil.lua:311](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `GetModConfigData(optionname, get_local_config)` | Main/Worldgen | Option lesen, optional lokale statt Serverkonfiguration. | [modutil.lua:329](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddGamePostInit(fn)` | Main/Worldgen | Game-PostInit registrieren; nicht mit Prefab-PostInit verwechseln. | [modutil.lua:335](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddSimPostInit(fn)` | Main/Worldgen | Sim-PostInit registrieren; spätes Setup, kein periodischer Tick. | [modutil.lua:341](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddGlobalClassPostConstruct(package, classname, fn)` | Main/Worldgen | Konstruktor einer benannten globalen Klasse erweitern; fn(self, ...). | [modutil.lua:346](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddClassPostConstruct(package, fn)` | Main/Worldgen | Konstruktor der von require(package) gelieferten Klasse erweitern; fn(self, ...). | [modutil.lua:351](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `RegisterTileRange(range_name, range_start, range_end)` | Main/Worldgen | TileManager-Wrapper; Registry/Renderingdaten ändern. Neuer Tile benötigt zusätzlichen Asset-/Save-Audit. | [modutil.lua:357](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddTile(tile_name, tile_range, tile_data, ground_tile_def, minimap_tile_def, turf_def)` | Main/Worldgen | TileManager-Wrapper; Registry/Renderingdaten ändern. Neuer Tile benötigt zusätzlichen Asset-/Save-Audit. | [modutil.lua:364](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `ChangeTileRenderOrder(tile_id, target_tile_id, moveafter)` | Main/Worldgen | TileManager-Wrapper; Registry/Renderingdaten ändern. Neuer Tile benötigt zusätzlichen Asset-/Save-Audit. | [modutil.lua:378](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `SetTileProperty(tile_id, propertyname, value)` | Main/Worldgen | TileManager-Wrapper; Registry/Renderingdaten ändern. Neuer Tile benötigt zusätzlichen Asset-/Save-Audit. | [modutil.lua:385](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `ChangeMiniMapTileRenderOrder(tile_id, target_tile_id, moveafter)` | Main/Worldgen | TileManager-Wrapper; Registry/Renderingdaten ändern. Neuer Tile benötigt zusätzlichen Asset-/Save-Audit. | [modutil.lua:392](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `SetMiniMapTileProperty(tile_id, propertyname, value)` | Main/Worldgen | TileManager-Wrapper; Registry/Renderingdaten ändern. Neuer Tile benötigt zusätzlichen Asset-/Save-Audit. | [modutil.lua:399](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddFalloffTexture(falloff_id, falloff_def)` | Main/Worldgen | TileManager-Wrapper; Registry/Renderingdaten ändern. Neuer Tile benötigt zusätzlichen Asset-/Save-Audit. | [modutil.lua:406](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `ChangeFalloffRenderOrder(falloff_id, falloff_id_id, moveafter)` | Main/Worldgen | TileManager-Wrapper; Registry/Renderingdaten ändern. Neuer Tile benötigt zusätzlichen Asset-/Save-Audit. | [modutil.lua:413](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `SetFalloffProperty(falloff_id, propertyname, value)` | Main/Worldgen | TileManager-Wrapper; Registry/Renderingdaten ändern. Neuer Tile benötigt zusätzlichen Asset-/Save-Audit. | [modutil.lua:420](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddAction(id, str, fn)` | nur Main | Action samt modbezogener Codezuordnung registrieren; fn(bufferedaction); liefert Action. | [modutil.lua:442](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddComponentAction(actiontype, component, fn)` | nur Main | Action-Sammlung für Component und Actiontyp registrieren; Callbacksignatur hängt vom Typ ab. | [modutil.lua:478](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddPopup(id)` | nur Main | Popup-ID/-Objekt mit modbezogener Codezuordnung registrieren; Spezial-API, weiterer Consumer-Audit nötig. | [modutil.lua:483](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddMinimapAtlas(atlaspath)` | nur Main | Atlas zum späteren Laden registrieren; Icon zusätzlich im Prefab setzen. | [modutil.lua:512](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddStategraphActionHandler(stategraph, handler)` | nur Main | ActionHandler zur benannten Stategraphdefinition ergänzen. | [modutil.lua:518](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddStategraphState(stategraph, state)` | nur Main | State zur benannten Stategraphdefinition ergänzen. | [modutil.lua:527](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddStategraphEvent(stategraph, event)` | nur Main | EventHandler zur benannten Stategraphdefinition ergänzen. | [modutil.lua:536](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddModShadersInit(fn)` | nur Main | Shadercallback registrieren; Renderer-Consumer zusätzlich auditieren. | [modutil.lua:545](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddModShadersSortAndEnable(fn)` | nur Main | Shadercallback registrieren; Renderer-Consumer zusätzlich auditieren. | [modutil.lua:551](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddStategraphPostInit(stategraph, fn)` | nur Main | Fertige Stategraphdefinition ändern; fn(sg). | [modutil.lua:557](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddComponentPostInit(component, fn)` | nur Main | Nach Componentkonstruktor; fn(component, inst), vor weiterem Prefabsetup. | [modutil.lua:567](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddPrefabPostInitAny(fn)` | nur Main | Nach jedem Prefabkonstruktor; fn(inst); Filter und Aufwand beachten. | [modutil.lua:580](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddPlayerPostInit(fn)` | nur Main | Any-Prefab-Hook mit player-Tagfilter; fn(inst). | [modutil.lua:586](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddPrefabPostInit(prefab, fn)` | nur Main | Nach Prefabkonstruktor; fn(inst); Mastersim im Callback prüfen. | [modutil.lua:593](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddRecipePostInitAny(fn)` | nur Main | Alle Rezepte ändern; fn(recipe), auch bestehende. | [modutil.lua:602](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddRecipePostInit(recipename, fn)` | nur Main | Rezept ändern; fn(recipe); vorhandene Rezepte sofort bearbeiten. | [modutil.lua:613](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddBrainPostInit(brain, fn)` | nur Main | Brain nach dessen Initialisierung erweitern; fn(brain). | [modutil.lua:627](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddIngredientValues(names, tags, cancook, candry)` | nur Main | Kochtags für Zutaten registrieren; cancook/candry beeinflussen Varianten. | [modutil.lua:636](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddCookerRecipe(cooker, recipe)` | nur Main | Kochrezept für Cooker registrieren; Rezeptdaten und test(cooker,names,tags). | [modutil.lua:643](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddModCharacter(name, gender, modes)` | nur Main | Charakter registrieren; ersetzt nicht Prefab, Assets, Portraits und Strings. | [modutil.lua:655](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `RemoveDefaultCharacter(name)` | nur Main | Standardcharakter aus Auswahl entfernen. | [modutil.lua:660](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddPrototyperDef(prototyper_prefab, data)` | nur Main | Crafting-Prototyperdaten registrieren. | [modutil.lua:666](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddRecipeFilter(filter_def, index)` | nur Main | Filterdefinition registrieren; optionale Einfügeposition. | [modutil.lua:674](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddRecipeToFilter(recipe_name, filter_name)` | nur Main | Rezeptname in Filter ergänzen. | [modutil.lua:713](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `RemoveRecipeFromFilter(recipe_name, filter_name)` | nur Main | Rezeptname aus Filter entfernen. | [modutil.lua:722](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddRecipe2(name, ingredients, tech, config, filters)` | nur Main | Aktuelles Craftingrezept, TECH-Tabelle und config; liefert Rezept, ergänzt Defaultfilter. | [modutil.lua:732](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddCharacterRecipe(name, ingredients, tech, config, extra_filters)` | nur Main | Charakter-/Skillgebundenes Rezept und optionale Zusatzfilter. | [modutil.lua:758](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddDeconstructRecipe(name, return_ingredients)` | nur Main | Rückbauzutaten registrieren. | [modutil.lua:784](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddRecipe(arg1, ...)` | nur Main | Legacyrezept; Deprecated-Warnung. Neue Mods: AddRecipe2. | [modutil.lua:794](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `Recipe(...)` | nur Main | Legacyalias mit Warnung; delegiert an AddRecipe. | [modutil.lua:818](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddRecipeTab(rec_str, rec_sort, rec_atlas, rec_icon, rec_owner_tag, rec_crafting_station)` | nur Main | Historischer Tab; Deprecated-Warnung. Neue Mods: Filter. | [modutil.lua:823](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `LoadPOFile(path, lang)` | nur Main | PO-Datei durch LanguageTranslator laden; Pfad-/Sprachzuordnung beachten. | [modutil.lua:836](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `RemapSoundEvent(name, new_name)` | nur Main | Soundevent auf anderes Event umleiten; Engine-Wrapper. | [modutil.lua:842](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `RemoveRemapSoundEvent(name)` | nur Main | Soundevent-Umleitung entfernen. | [modutil.lua:847](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddReplicableComponent(name)` | nur Main | Replica-Komponentenname registrieren; eigene Datei name_replica.lua erforderlich. | [modutil.lua:852](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddModRPCHandler(namespace, name, fn)` | nur Main | Client→Server registrieren; fn(player, ...). | [modutil.lua:857](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddClientModRPCHandler(namespace, name, fn)` | nur Main | Server→Client registrieren; fn(...). | [modutil.lua:862](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddShardModRPCHandler(namespace, name, fn)` | nur Main | Shard→Shard registrieren; fn(sender_shard, ...). | [modutil.lua:867](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `GetModRPCHandler(namespace, name)` | nur Main | Registrierten Serverhandler abfragen; keine RPC-ID. | [modutil.lua:872](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `GetClientModRPCHandler(namespace, name)` | nur Main | Registrierten Clienthandler abfragen; keine RPC-ID. | [modutil.lua:877](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `GetShardModRPCHandler(namespace, name)` | nur Main | Registrierten Shardhandler abfragen; keine RPC-ID. | [modutil.lua:882](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `SendModRPCToServer(id_table, ...)` | nur Main | Mit ID-Tabelle zum Server senden; Argumente durch nativen Transport. | [modutil.lua:887](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `SendModRPCToClient(id_table, ...)` | nur Main | Mit ID-Tabelle zu Clients senden; Empfängerargumente nach networkclientrpc/native API prüfen. | [modutil.lua:892](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `SendModRPCToShard(id_table, ...)` | nur Main | Mit ID-Tabelle zu Shards senden; Empfängerargumente nach networkclientrpc/native API prüfen. | [modutil.lua:897](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `GetModRPC(namespace, name)` | nur Main | ID-Tabelle für Server-RPC abfragen. | [modutil.lua:906](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `GetClientModRPC(namespace, name)` | nur Main | ID-Tabelle für Client-RPC abfragen. | [modutil.lua:910](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `GetShardModRPC(namespace, name)` | nur Main | ID-Tabelle für Shard-RPC abfragen. | [modutil.lua:914](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `SetModHUDFocus(focusid, hasfocus)` | nur Main | Fokus für Mod/focusid setzen; benötigt ThePlayer.HUD. | [modutil.lua:919](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddUserCommand(command_name, data)` | nur Main | Benutzerkommando über AddModUserCommand registrieren; Datenvertrag zusätzlich prüfen. | [modutil.lua:928](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddVoteCommand(command_name, init_options_fn, process_result_fn, vote_timeout)` | nur Main | Abstimmung mit Init-/Resultcallback registrieren; Defaulttimeout 15. | [modutil.lua:933](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `ExcludeClothingSymbolForModCharacter(name, symbol)` | nur Main | Bekleidungssymbol bei Modcharakter ausschließen. | [modutil.lua:942](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `RegisterInventoryItemAtlas(atlas, prefabname)` | nur Main | Inventarbildnamen einem Atlas zuordnen; vorzugsweise Prefabname als Bildname. | [modutil.lua:954](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `RegisterScrapbookIconAtlas(atlas, tex)` | nur Main | Scrapbook-TEX einem Atlas zuordnen. | [modutil.lua:959](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `RegisterSkilltreeBGForCharacter(atlas, charactername)` | nur Main | Skilltree-Hintergrundatlas für charactername_background.tex registrieren. | [modutil.lua:964](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `RegisterSkilltreeIconsAtlas(atlas, tex)` | nur Main | Skilltree-Icon-TEX einem Atlas zuordnen. | [modutil.lua:969](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `AddLoadingTip(stringtable, id, tipstring, controltipdata)` | nur Main | Text/ID und optional Steuerungshinweis registrieren; eindeutige ID. | [modutil.lua:975](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `RemoveLoadingTip(stringtable, id)` | nur Main | Text/ID und zugehörige Steuerungsdaten entfernen. | [modutil.lua:990](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `SetLoadingTipCategoryWeights(weighttable, weightdata)` | nur Main | Übergebene Kategoriengewichte in Zieltabelle übernehmen. | [modutil.lua:1002](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |
| `SetLoadingTipCategoryIcon(category, categoryatlas, categoryicon)` | nur Main | Atlas/Icon einer Ladetippkategorie setzen. | [modutil.lua:1008](<../../_scripts/scripts_02_10_2026/scripts/modutil.lua>) |

## Weitere Exporte und Grenzen

`Prefab`, `Asset` und `Ingredient` werden direkt aus dem Spiel exportiert; sie sind keine hier neu definierten Wrapper. `modassert` und `moderror` werden ebenfalls zugewiesen. `ReleaseID`, `CurrentRelease`, die postinitfns/postinitdata-Tabellen sowie die Legacytabellen MOD_RPC/CLIENT_MOD_RPC/SHARD_MOD_RPC sind keine PostInit-Funktionen. GetModRPC/GetClientModRPC/GetShardModRPC sind für neue RPC-Zugriffe vorgesehen.

Native Engine-Methoden, jede Component-Methode und alle Globals sind bewusst kein Teil dieses Mod-Hook-Registers. Sie sind unter ihrem jeweiligen Thema belegt. AddGameMode ist zwar vorhanden, hat aber keine Registrierungswirkung mehr. Deprecated bedeutet bei den alten Recipe-APIs nicht, dass sie aus diesem Snapshot entfernt wären.


## Ergänzende Vertragsprüfung vom 03.10.2026

[Aufgabenindex](25_Aufgabenindex.md) verbindet Vorhaben, Quellen und Vorlagen. [Prüfgrenzen](24_Statische_Vertragspruefung.md), [API-Quellenketten](26_Quellenketten_API.md), [Reviewmatrix aller 26 Mods](REVIEW_MATRIX.json) und [isolierte Tests](tests/README.md) unterscheiden Inventar, Quellverträge, Logikergebnisse und offene Engineabnahme.

Die praktischen Aufrufer-/Lebenszyklusverbindungen für AddCookerRecipe, AddIngredientValues und AddModCharacter stehen in [Kapitel 28](28_Kochinhalte.md) und [Kapitel 29](29_Kreaturen_Charaktere_Lebenszyklus.md); Classified-/Prediction-/Sessionverträge in [30](30_Multiplayer_Lebenszyklen.md). Das API-Register bleibt auf seine 93 tatsächlich vorhandenen Mod-Hooks begrenzt.
