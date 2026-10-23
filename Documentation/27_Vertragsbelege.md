# Konkrete Definitionsbelege der erneuten Prüfung

Dieses Register ergänzt die lesbaren Fallstudien. Signatur/Zeile/Excerpt werden gegen aktiven Code geprüft; Kommentare und Strings sind keine Definitionen. Lexikalische Definition ist noch kein vollständiger Kontrollfluss- oder Enginebeweis. Quellenstand/Hashes im [Manifest](SOURCE_MANIFEST.json), Abläufe in [Quellenketten](26_Quellenketten_API.md) und [Fallstudien](case_studies/README.md).

| Ursprung | Quelle und Zeile | Signatur |
|---|---|---|
| vanilla | [mods.lua](<../../_scripts/scripts_02_10_2026/scripts/mods.lua>), 297 | `CreateEnvironment(modname, isworldgen, isfrontend)` |
| vanilla | [mods.lua](<../../_scripts/scripts_02_10_2026/scripts/mods.lua>), 589 | `ModWrangler:InitializeModMain(modname, env, mainfile, safe)` |
| vanilla | [mods.lua](<../../_scripts/scripts_02_10_2026/scripts/mods.lua>), 677 | `ModWrangler:RegisterPrefabs()` |
| vanilla | [mainfunctions.lua](<../../_scripts/scripts_02_10_2026/scripts/mainfunctions.lua>), 145 | `LoadPrefabFile(filename, async_batch_validation, search_asset_first_path)` |
| vanilla | [entityscript.lua](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>), 610 | `EntityScript:AddComponent(name)` |
| vanilla | [entityscript.lua](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>), 648 | `EntityScript:RemoveComponent(name)` |
| vanilla | [entityscript.lua](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>), 1939 | `EntityScript:LoadPostPass(newents, savedata)` |
| vanilla | [entityscript.lua](<../../_scripts/scripts_02_10_2026/scripts/entityscript.lua>), 1954 | `EntityScript:SetPersistData(data, newents)` |
| vanilla | [entityreplica.lua](<../../_scripts/scripts_02_10_2026/scripts/entityreplica.lua>), 98 | `AddReplicableComponent(name)` |
| vanilla | [networkclientrpc.lua](<../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>), 1834 | `AddModRPCHandler(namespace, name, fn)` |
| vanilla | [networkclientrpc.lua](<../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>), 1851 | `AddClientModRPCHandler(namespace, name, fn)` |
| vanilla | [networkclientrpc.lua](<../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>), 1866 | `AddShardModRPCHandler(namespace, name, fn)` |
| vanilla | [networkclientrpc.lua](<../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>), 1881 | `SendModRPCToServer(id_table, ...)` |
| vanilla | [networkclientrpc.lua](<../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>), 1886 | `SendModRPCToClient(id_table, ...)` |
| vanilla | [networkclientrpc.lua](<../../_scripts/scripts_02_10_2026/scripts/networkclientrpc.lua>), 1891 | `SendModRPCToShard(id_table, ...)` |
| vanilla | [components/health.lua](<../../_scripts/scripts_02_10_2026/scripts/components/health.lua>), 154 | `Health:OnSave()` |
| vanilla | [components/health.lua](<../../_scripts/scripts_02_10_2026/scripts/components/health.lua>), 163 | `Health:OnLoad(data)` |
| vanilla | [components/health.lua](<../../_scripts/scripts_02_10_2026/scripts/components/health.lua>), 503 | `Health:SetMaxHealth(amount)` |
| vanilla | [components/health.lua](<../../_scripts/scripts_02_10_2026/scripts/components/health.lua>), 550 | `Health:SetPercent(percent, overtime, cause)` |
| vanilla | [components/container.lua](<../../_scripts/scripts_02_10_2026/scripts/components/container.lua>), 979 | `Container:OnSave()` |
| vanilla | [components/container.lua](<../../_scripts/scripts_02_10_2026/scripts/components/container.lua>), 996 | `Container:OnLoad(data, newents)` |
| vanilla | [components/eater.lua](<../../_scripts/scripts_02_10_2026/scripts/components/eater.lua>), 230 | `Eater:Eat(food, feeder)` |
| vanilla | [components/foodmemory.lua](<../../_scripts/scripts_02_10_2026/scripts/components/foodmemory.lua>), 32 | `FoodMemory:RememberFood(prefab)` |
| vanilla | [components/foodmemory.lua](<../../_scripts/scripts_02_10_2026/scripts/components/foodmemory.lua>), 58 | `FoodMemory:OnSave()` |
| vanilla | [components/foodmemory.lua](<../../_scripts/scripts_02_10_2026/scripts/components/foodmemory.lua>), 68 | `FoodMemory:OnLoad(data)` |
| vanilla | [components/perishable.lua](<../../_scripts/scripts_02_10_2026/scripts/components/perishable.lua>), 60 | `Update(inst, dt)` |
| vanilla | [components/combat.lua](<../../_scripts/scripts_02_10_2026/scripts/components/combat.lua>), 846 | `Combat:CalcDamage(target, weapon, multiplier)` |
| vanilla | [components/temperature.lua](<../../_scripts/scripts_02_10_2026/scripts/components/temperature.lua>), 254 | `Temperature:GetInsulation()` |
| vanilla | [components/timer.lua](<../../_scripts/scripts_02_10_2026/scripts/components/timer.lua>), 95 | `Timer:GetTimeLeft(name)` |
| vanilla | [components/timer.lua](<../../_scripts/scripts_02_10_2026/scripts/components/timer.lua>), 122 | `Timer:OnSave()` |
| vanilla | [components/timer.lua](<../../_scripts/scripts_02_10_2026/scripts/components/timer.lua>), 135 | `Timer:OnLoad(data)` |
| vanilla | [components/timer.lua](<../../_scripts/scripts_02_10_2026/scripts/components/timer.lua>), 144 | `Timer:LongUpdate(dt)` |
| vanilla | [components/skinner.lua](<../../_scripts/scripts_02_10_2026/scripts/components/skinner.lua>), 11 | `SetSkinsOnAnim(anim_state, prefab, base_skin, clothing_names, monkey_curse, skintype, default_build)` |
| vanilla | [components/skinner.lua](<../../_scripts/scripts_02_10_2026/scripts/components/skinner.lua>), 569 | `Skinner:SetSkinName(skin_name, skip_beard_setup, skip_skins_set)` |
| vanilla | [components/skinner.lua](<../../_scripts/scripts_02_10_2026/scripts/components/skinner.lua>), 803 | `Skinner:OnSave()` |
| vanilla | [components/skinner.lua](<../../_scripts/scripts_02_10_2026/scripts/components/skinner.lua>), 814 | `Skinner:OnLoad(data)` |
| vanilla | [prefabs/pond.lua](<../../_scripts/scripts_02_10_2026/scripts/prefabs/pond.lua>), 189 | `OnSave(inst, data)` |
| vanilla | [prefabs/pond.lua](<../../_scripts/scripts_02_10_2026/scripts/prefabs/pond.lua>), 194 | `OnLoad(inst, data)` |
| vanilla | [map/tasks.lua](<../../_scripts/scripts_02_10_2026/scripts/map/tasks.lua>), 62 | `AddModTask(mod, name, data)` |
| vanilla | [simutil.lua](<../../_scripts/scripts_02_10_2026/scripts/simutil.lua>), 658 | `RegisterInventoryItemAtlas(atlas, imagename)` |
| vanilla | [simutil.lua](<../../_scripts/scripts_02_10_2026/scripts/simutil.lua>), 687 | `GetInventoryItemAtlas(imagename, no_fallback)` |
| vanilla | [components/crop.lua](<../../_scripts/scripts_02_10_2026/scripts/components/crop.lua>), 205 | `Crop:Harvest(harvester)` |
| vanilla | [components/explosive.lua](<../../_scripts/scripts_02_10_2026/scripts/components/explosive.lua>), 27 | `Explosive:OnBurnt()` |
| workspace | [Food Queue 2843201996/scripts/components/_foodbuffer.lua](<../Food Queue 2843201996/scripts/components/_foodbuffer.lua>), 34 | `FoodBuffer:GetBaseFood(food)` |
| workspace | [Food Queue 2843201996/scripts/components/_foodbuffer.lua](<../Food Queue 2843201996/scripts/components/_foodbuffer.lua>), 94 | `FoodBuffer:AddToBuffer(food)` |
| workspace | [Food Queue 2843201996/scripts/components/_foodbuffer.lua](<../Food Queue 2843201996/scripts/components/_foodbuffer.lua>), 110 | `FoodBuffer:OnSave()` |
| workspace | [Food Queue 2843201996/scripts/components/_foodbuffer.lua](<../Food Queue 2843201996/scripts/components/_foodbuffer.lua>), 116 | `FoodBuffer:OnLoad(data)` |
| workspace | [Food Queue 2843201996/scripts/components/_foodbuffer_replica.lua](<../Food Queue 2843201996/scripts/components/_foodbuffer_replica.lua>), 10 | `FoodBuffer:SetBuffer(buffer)` |
| workspace | [Trash Can 1879090052/scripts/prefabs/trashcan.lua](<../Trash Can 1879090052/scripts/prefabs/trashcan.lua>), 28 | `onhammered(inst, worker)` |
| workspace | [Trash Can 1879090052/scripts/prefabs/trashcan.lua](<../Trash Can 1879090052/scripts/prefabs/trashcan.lua>), 40 | `onhit(inst, worker)` |
| workspace | [Trash Can 1879090052/scripts/prefabs/trashcan.lua](<../Trash Can 1879090052/scripts/prefabs/trashcan.lua>), 77 | `OnActivate(inst)` |
| workspace | [Repair Combine 767776640/scripts/components/combinerepairable.lua](<../Repair Combine 767776640/scripts/components/combinerepairable.lua>), 13 | `CombineRepairable:Repair(doer, repair_item)` |
| workspace | [FinderMod 786654500/modmain.lua](<../FinderMod 786654500/modmain.lua>), 97 | `ServerRPCFunction(owner,prefab,source,unhighlighten,highlighten)` |
| workspace | [FinderMod 786654500/modmain.lua](<../FinderMod 786654500/modmain.lua>), 203 | `RegisterListeners(inst)` |
| workspace | [Evolving Maxwell Shadows 1868560353/modmain.lua](<../Evolving Maxwell Shadows 1868560353/modmain.lua>), 1137 | `GetActionForShadowTarget(inst,target,leader,doableactionlist)` |
| workspace | [Evolving Maxwell Shadows 1868560353/modmain.lua](<../Evolving Maxwell Shadows 1868560353/modmain.lua>), 1354 | `FindEntityToWorkAction(inst)` |
| workspace | [Evolving Maxwell Shadows 1868560353/scripts/BM_helpers.lua](<../Evolving Maxwell Shadows 1868560353/scripts/BM_helpers.lua>), 211 | `ContainerShouldAcceptItem(self,item, slot)` |
| workspace | [Evolving Maxwell Shadows 1868560353/scripts/BM_helpers.lua](<../Evolving Maxwell Shadows 1868560353/scripts/BM_helpers.lua>), 423 | `EquipNewEquip(inst,searchequipslot,actionlist,force)` |
| workspace | [Home Base Bonus 738448215/modmain.lua](<../Home Base Bonus 738448215/modmain.lua>), 120 | `AddAbsorb(self, key, mod)` |
| workspace | [Home Base Bonus 738448215/modmain.lua](<../Home Base Bonus 738448215/modmain.lua>), 127 | `RemoveAbsorb(self, key)` |
| workspace | [Home Base Bonus 738448215/modmain.lua](<../Home Base Bonus 738448215/modmain.lua>), 160 | `GetDamageModifier(self)` |
| workspace | [Home Base Bonus 738448215/modmain.lua](<../Home Base Bonus 738448215/modmain.lua>), 279 | `CheckBase(inst,xyztile)` |
| workspace | [Home Base Bonus 738448215/modmain.lua](<../Home Base Bonus 738448215/modmain.lua>), 655 | `UpdateHomeBaseData(inst)` |
| workspace | [Auto Actions (Serp) 732459815/modmain.lua](<../Auto Actions (Serp) 732459815/modmain.lua>), 251 | `GetAction(inst, target, action, ignorecontrol, searchTarget)` |
| workspace | [Auto Actions (Serp) 732459815/modmain.lua](<../Auto Actions (Serp) 732459815/modmain.lua>), 485 | `OnUpdate(playercontroller, dt,...)` |
| workspace | [Auto Actions (Serp) 732459815/modmain.lua](<../Auto Actions (Serp) 732459815/modmain.lua>), 1123 | `DoAttackButton(playercontroller,retarget)` |
| workspace | [Auto Actions (Serp) 732459815/modmain.lua](<../Auto Actions (Serp) 732459815/modmain.lua>), 1839 | `OnUpdate(...)` |
| workspace | [Show Me (Serp) 732456848/modmain.lua](<../Show Me (Serp) 732456848/modmain.lua>), 813 | `GetPerishTime(inst,c)` |
| workspace | [Show Me (Serp) 732456848/modmain.lua](<../Show Me (Serp) 732456848/modmain.lua>), 902 | `CalcDamage(self, weapon)` |
| workspace | [Show Me (Serp) 732456848/modmain.lua](<../Show Me (Serp) 732456848/modmain.lua>), 990 | `IsAdmin(viewer)` |
| workspace | [Show Me (Serp) 732456848/modmain.lua](<../Show Me (Serp) 732456848/modmain.lua>), 1041 | `GetTestString(item,viewer)` |
| workspace | [Teleportato 756229217/scripts/components/worldjump.lua](<../Teleportato 756229217/scripts/components/worldjump.lua>), 12 | `OnPlayerSpawn(world, player)` |
| workspace | [Teleportato 756229217/scripts/components/worldjump.lua](<../Teleportato 756229217/scripts/components/worldjump.lua>), 189 | `WorldJump:LoadPlayerData()` |
| workspace | [Teleportato 756229217/scripts/components/worldjump.lua](<../Teleportato 756229217/scripts/components/worldjump.lua>), 210 | `WorldJump:SavePlayerData(pl)` |
| workspace | [Teleportato 756229217/scripts/components/worldjump.lua](<../Teleportato 756229217/scripts/components/worldjump.lua>), 322 | `WorldJump:DoJump(keepage,keepinventory,keeprecipes)` |
| workspace | [Adventure Mode 1847959350/scripts/components/maxlightspawner.lua](<../Adventure Mode 1847959350/scripts/components/maxlightspawner.lua>), 16 | `MaxLightSpawner:OnSave()` |
| workspace | [Adventure Mode 1847959350/scripts/components/maxlightspawner.lua](<../Adventure Mode 1847959350/scripts/components/maxlightspawner.lua>), 34 | `MaxLightSpawner:LoadPostPass(newents, savedata)` |
| workspace | [Adventure Mode 1847959350/scripts/components/maxlightspawner.lua](<../Adventure Mode 1847959350/scripts/components/maxlightspawner.lua>), 55 | `MaxLightSpawner:SpawnAllLights()` |
| workspace | [Adventure Mode 1847959350/scripts/components/maxwelltalker.lua](<../Adventure Mode 1847959350/scripts/components/maxwelltalker.lua>), 13 | `MaxwellTalker:StopTalking()` |
| workspace | [Adventure Mode 1847959350/modworldgenmain.lua](<../Adventure Mode 1847959350/modworldgenmain.lua>), 227 | `AlwaysTinyCave(tasksetdata)` |
| workspace | [Adventure Mode 1847959350/modworldgenmain.lua](<../Adventure Mode 1847959350/modworldgenmain.lua>), 252 | `AdventurePortalWorld(tasksetdata)` |
| workspace | [Adventure Mode 1847959350/modworldgenmain.lua](<../Adventure Mode 1847959350/modworldgenmain.lua>), 689 | `AdventureDarkness(tasksetdata)` |
| workspace | [Adventure Mode 1847959350/modworldgenmain.lua](<../Adventure Mode 1847959350/modworldgenmain.lua>), 777 | `AdventureMaxwellHome(tasksetdata)` |
| workspace | [DSTHamletHouseWIP/scripts/components/interiorspawner.lua](<../DSTHamletHouseWIP/scripts/components/interiorspawner.lua>), 267 | `InteriorSpawner:ExecuteTeleport(doer, destination, direction)` |
| workspace | [DSTHamletHouseWIP/scripts/components/interiorspawner.lua](<../DSTHamletHouseWIP/scripts/components/interiorspawner.lua>), 1330 | `InteriorSpawner:OnSave()` |
| workspace | [DSTHamletHouseWIP/scripts/components/interiorspawner.lua](<../DSTHamletHouseWIP/scripts/components/interiorspawner.lua>), 1438 | `InteriorSpawner:OnLoad(data)` |
| workspace | [DSTHamletHouseWIP/scripts/components/interiorspawner.lua](<../DSTHamletHouseWIP/scripts/components/interiorspawner.lua>), 1504 | `InteriorSpawner:LoadPostPass(ents, data)` |
| workspace | [DSTHamletHouseWIP/scripts/components/door.lua](<../DSTHamletHouseWIP/scripts/components/door.lua>), 24 | `Door:UpdateTargetOffset()` |
| workspace | [DSTHamletHouseWIP/scripts/components/door.lua](<../DSTHamletHouseWIP/scripts/components/door.lua>), 119 | `Door:OnSave()` |
| workspace | [DSTHamletHouseWIP/scripts/components/door.lua](<../DSTHamletHouseWIP/scripts/components/door.lua>), 158 | `Door:OnLoad(data)` |
| workspace | [DSTHamletHouseWIP/scripts/components/door.lua](<../DSTHamletHouseWIP/scripts/components/door.lua>), 206 | `Door:LoadPostPass(newents, savedata)` |
| workspace | [Automatic Health Adjust 764204839/modmain.lua](<../Automatic Health Adjust 764204839/modmain.lua>), 84 | `AdjustHealthEnt(names,prefab,inst,settings,ratio_from_prefab)` |
| workspace | [Automatic Health Adjust 764204839/modmain.lua](<../Automatic Health Adjust 764204839/modmain.lua>), 156 | `DoHealthChange(world,player,testnumplayer)` |
| workspace | [Automatic Health Adjust 764204839/modmain.lua](<../Automatic Health Adjust 764204839/modmain.lua>), 340 | `DoHealthChangeSoon(world,player)` |
| workspace | [More Worldsettings 2838382897/scripts/moresettings_helpers.lua](<../More Worldsettings 2838382897/scripts/moresettings_helpers.lua>), 73 | `GetFittingImage(name)` |
| workspace | [More Farm Harvest 736398747/modmain.lua](<../More Farm Harvest 736398747/modmain.lua>), 5 | `CropPostInit(self)` |
| workspace | [Physics-Based Spacing 2840497376/modmain.lua](<../Physics-Based Spacing 2840497376/modmain.lua>), 7 | `GetFabRad(fab)` |
| workspace | [Random DayDuskNight Events 2842755452/scripts/components/rememberstuff.lua](<../Random DayDuskNight Events 2842755452/scripts/components/rememberstuff.lua>), 17 | `RememberStuff:OnSave()` |
| workspace | [Random DayDuskNight Events 2842755452/scripts/components/rememberstuff.lua](<../Random DayDuskNight Events 2842755452/scripts/components/rememberstuff.lua>), 60 | `RememberStuff:LoadPostPass(newents, data)` |
| workspace | [Scythe 733887349/scripts/prefabs/scythe.lua](<../Scythe 733887349/scripts/prefabs/scythe.lua>), 14 | `OnEquip(inst, owner)` |
| workspace | [Scythe 733887349/scripts/prefabs/scythe.lua](<../Scythe 733887349/scripts/prefabs/scythe.lua>), 25 | `OnUnequip(inst, owner)` |
| workspace | [Breakable Ice 385979230/data/prefabs/pond.lua](<../Breakable Ice 385979230/data/prefabs/pond.lua>), 42 | `CalculateGrowth(inst)` |
| workspace | [Breakable Ice 385979230/data/prefabs/pond.lua](<../Breakable Ice 385979230/data/prefabs/pond.lua>), 317 | `inst.OnLoad(data)` |
| workspace | [Breakable Ice 385979230/scripts/components/crystallizable.lua](<../Breakable Ice 385979230/scripts/components/crystallizable.lua>), 363 | `Crystallizable:OnSave()` |
| workspace | [Breakable Ice 385979230/scripts/components/crystallizable.lua](<../Breakable Ice 385979230/scripts/components/crystallizable.lua>), 399 | `Crystallizable:OnLoad(data)` |
