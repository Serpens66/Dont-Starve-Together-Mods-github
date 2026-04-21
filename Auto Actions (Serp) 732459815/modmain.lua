
if GetModConfigData("ClientDidEnable")==true then -- client_only mods bei mir können auch andere clients beeinflussen, wenn ich host ohne caves bin. daher nun eine extra setting die default unwahr ist und nur ich true gesetzt habe
    -- vllt hilfts doch nicht, aber mal probieren... https://forums.kleientertainment.com/forums/topic/111728-why-does-a-client_only-mod-at-host-affects-other-clients/?tab=comments#comment-1259732
    Assets = {
        Asset("IMAGE", "images/newframe.tex"),
        Asset("ATLAS", "images/newframe.xml"),
        Asset("IMAGE","images/icons/ae_crafttools.tex"),
        Asset("ATLAS", "images/icons/ae_crafttools.xml"),
        Asset("IMAGE","images/icons/ae_boomcritters.tex"),
        Asset("ATLAS", "images/icons/ae_boomcritters.xml"),
        Asset("IMAGE","images/icons/ae_equipweapon.tex"),
        Asset("ATLAS", "images/icons/ae_equipweapon.xml"),
        Asset("IMAGE","images/icons/ae_lightindark.tex"),
        Asset("ATLAS", "images/icons/ae_lightindark.xml"),
        Asset("IMAGE","images/icons/ae_refuelfires.tex"),
        Asset("ATLAS", "images/icons/ae_refuelfires.xml"),
        Asset("IMAGE","images/icons/ae_repairwalls.tex"),
        Asset("ATLAS", "images/icons/ae_repairwalls.xml"),
        Asset("IMAGE","images/icons/ae_replanttrees.tex"),
        Asset("ATLAS", "images/icons/ae_replanttrees.xml"),
        Asset("IMAGE","images/icons/ae_enablemod.tex"),
        Asset("ATLAS", "images/icons/ae_enablemod.xml"),
        Asset("IMAGE","images/icons/ae_alwaysignoresaps.tex"),
        Asset("ATLAS", "images/icons/ae_alwaysignoresaps.xml")
    }

    local require = GLOBAL.require
    local pcall = GLOBAL.pcall
    local ACTIONS = GLOBAL.ACTIONS
    local BufferedAction = GLOBAL.BufferedAction
    local EQUIPSLOTS = GLOBAL.EQUIPSLOTS

    local FindEntity = GLOBAL.FindEntity

    local TheInput = GLOBAL.TheInput
    local AllRecipes = GLOBAL.AllRecipes

    local GetTime = GLOBAL.GetTime


    local delayUnequipASecond = 0

    local Backup_GetActionButtonAction

    local AASC = GLOBAL.require("widgets/aas_new")


    local function IMS( plyctrl )
        return plyctrl.ismastersim
    end


    local actsToUse = {ACTIONS.NET,ACTIONS.DIG,ACTIONS.CHOP,ACTIONS.MINE}
    local toolsForActionsGold = {MINE = "goldenpickaxe",DIG = "goldenshovel",CHOP = "goldenaxe"}
    local toolsForActions = {MINE = "pickaxe",DIG = "shovel",CHOP = "axe",HAMMER="hammer"}

    -- Custom Settings --

    local ae_enablemod = GetModConfigData("ae_enablemod") == 1 or false
    local ae_ignoreRestrictions = GetModConfigData("autoequipignorerestrictions") or 1
    local ae_weapons = GetModConfigData("ae_equipweapon") or 1
    local ae_huntwithboomerang = GetModConfigData("ae_boomcritters") or 0
    local ae_givelight = GetModConfigData("ae_lightindark") or 0

    local aa_useEconomicMode = true
    local aa_canCraftToolsWithMouse = true
    local aa_canCraftToolsAutomatically = GetModConfigData("ae_crafttools") > 0 or false
    local aa_useGoldenTools = GetModConfigData("ae_crafttools") > 1 or false

    local aa_ignoreTraps = false --GetModConfigData("autoequipignoretraps") and GetModConfigData("autoequipignoretraps") > 0 or false
    local aa_reactiveTraps = false --GetModConfigData("autoequipreactivatetraps") and GetModConfigData("autoequipreactivatetraps") > 0 or false
    local aa_replantTrees = GetModConfigData("ae_replanttrees") and GetModConfigData("ae_replanttrees") > 0 or false

    local aa_refuelfires = GetModConfigData("ae_refuelfires") or false
    local aa_repairwalls = GetModConfigData("ae_repairwalls") and GetModConfigData("ae_repairwalls") > 0 or false

    local aa_completelyignore = GetModConfigData("ae_alwaysignoresaps") and GetModConfigData("ae_alwaysignoresaps") > 0 or false

    local letsDoDebug = false

    -- Functions --

    local aa_canPickupToolsAutomatically = true





    local aa_seedTypes = {deciduoustree = "acorn",evergreen = "pinecone", evergreen_sparse = "pinecone", twiggytree = "twiggy_nut"}
    local aa_saplingTypes = {"pinecone_sapling","acorn_sapling","twiggy_nut_sapling"}

    local forceResetTrap
    local forceUnequipTool
    local forcePlantSapling

    local forcePlantSaplingPlacer

    local ToggleModEnabled





    local function DoEquip( inst, tool )
        if( inst == nil or inst.components == nil or inst.components.playercontroller == nil or tool == nil ) then return end
        
        local plcotrl = inst.components.playercontroller
        if( plcotrl and plcotrl.inst and plcotrl.inst.replica and plcotrl.inst.replica.inventory ) then -- plcotrl.autoequip_lastequipped ~= nil
            if letsDoDebug then print("- Equipping tool/weapon:",tool) end
            delayUnequipASecond = GetTime()+0.25
            inst.replica.inventory:UseItemFromInvTile(tool)
            --inst.replica.inventory:ControllerUseItemOnSelfFromInvTile(tool)
        else
            if letsDoDebug then print("Tried to equip, but failed.") end
        end
    end

    local function DoUnequip( plcotrl, force )
        if( plcotrl and plcotrl.inst and plcotrl.inst.replica and plcotrl.inst.replica.inventory ) then -- plcotrl.autoequip_lastequipped ~= nil
            if letsDoDebug then print("- Unequipping tool/weapon") end
            plcotrl.inst.replica.inventory:UseItemFromInvTile(plcotrl.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS))
        end
    end

    local function GetInventory( inst )
        return ( inst.components and inst.components.playercontroller and inst.components.inventory ) or ( inst.replica and inst.replica.inventory )
    end

    local function CustomFindItem( inst, inv, check )
        local items = inv and inv.GetItems and inv:GetItems() or inv.itemslots or nil
        if not inst or not inv or not check or not items then if letsDoDebug then print("Something went wrong with the inventory...") end return nil end
        
        local zeItem = nil
        
        for k,v in pairs(items) do
            if check(v) then
                zeItem = v
            end
        end
        
        if inv.GetOverflowContainer and inv:GetOverflowContainer() ~= nil then
            items = inv:GetOverflowContainer() and inv:GetOverflowContainer().GetItems and inv:GetOverflowContainer():GetItems() or inv:GetOverflowContainer().slots or nil
            if items then
                for k,v in pairs(items) do
                    if check(v) then
                        zeItem = v
                    end
                end
            end
        end
        
        if( inst.replica and inst.replica.inventory and inst.replica.inventory.GetEquippedItem and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) and check(inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)) ) then
            zeItem = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        end
        
        return zeItem
    end

    local function CustomFindItems( inst, inv, check )
        if not inst or not inv or not check or ( ( not inv.GetItems or not inv:GetItems() ) and not inv.itemslots ) then if letsDoDebug then print("Something went wrong with the inventory...") end return nil end
        local items = inv.GetItems and inv:GetItems() or inv.itemslots
        local zeItem = {}
        
        for k,v in pairs(items) do
            if check(v) then
                table.insert(zeItem,v)
            end
        end
        
        if inv and inv.GetOverflowContainer then
            items = ( inv:GetOverflowContainer() and inv:GetOverflowContainer().GetItems and inv:GetOverflowContainer():GetItems() ) or ( inv:GetOverflowContainer() and inv:GetOverflowContainer().slots ) or nil
            if items then
                for k,v in pairs(items) do
                    if check(v) then
                        table.insert(zeItem,v)
                    end
                end
            end
        end
        
        return zeItem
    end

    local function FindTool(inst, inventory, action, checkbp )
        return ( inventory and ( inventory.GetItems or inventory.itemslots ) and CustomFindItem( inst, inventory, function(item)
            return item:HasTag(action.id.."_tool") and ( not checkbp or ( checkbp and checkbp(item) ) )
        end) ) or ( inventory and inventory.FindItem and inventory:FindItem(function(item)
            return item:HasTag(action.id.."_tool") and ( not checkbp or ( checkbp and checkbp(item) ) )
        end) ) or ( inventory and inventory.GetOverflowContainer and inventory:GetOverflowContainer() and ( inventory:GetOverflowContainer().GetItems or inventory:GetOverflowContainer().itemslots ) and CustomFindItem( inst, inventory:GetOverflowContainer(), function(item)
            return item:HasTag(action.id.."_tool") and ( not checkbp or ( checkbp and checkbp(item) ) )
        end) ) or nil
    end

    local function DoMatch( tab, value )
        for k,v in pairs(tab) do
            if( v and value and v == value ) then return true end
        end
        return false
    end
    local function DoMatchString( tab, value )
        for k,v in pairs(tab) do
            if( string.lower(v) == string.lower(value) ) then return true end
        end
        return false
    end
    local restrictedPrefabs = {
        "berrybush", "berrybush2", "grass", "depleted_grass", "sapling","acorn_sapling", "pinecone_sapling", "twiggy_nut_sapling", "blue_mushroom", "green_mushroom", "red_mushroom", "berrybush_juicy",
        "rabbithole","molehill",
        "bambootree", "bamboo", "depleted_bambootree", "bush_vine", "crabhole",
        "trap_tooth", "twiggytree"
    }

    local function FindWorkableEntity(inst, action, radius, ignoreRestriction, usecustomexception)
        --print("finding...")
        -- return (entitiy.prefab ~= "berrybush" and entitiy.prefab ~= "berrybush2" and entitiy.prefab ~= "grass" and entitiy.prefab ~= "rabbithole" and entitiy.prefab ~= "crabhole" and entitiy.prefab ~= "sapling" and entitiy.prefab ~= "bambootree" and entitiy.prefab ~= "bamboo" and entitiy.prefab ~= "depleted_bambootree" and entitiy.prefab ~= "bush_vine" and not useRestriction )
        if not usecustomexception then
            return GLOBAL.FindEntity(inst, radius, function( entitiy )
                return ( not ignoreRestriction and not DoMatchString(restrictedPrefabs,entitiy.prefab) or ignoreRestriction )
            end, {action.id.."_workable"}, TARGET_EXCLUDE_TAGS)
        elseif usecustomexception and type(usecustomexception) == "table" then
            return GLOBAL.FindEntity(inst, radius, function( entitiy )
                return ( not ignoreRestriction and not DoMatchString(restrictedPrefabs,entitiy.prefab) or ignoreRestriction )
            end, {}, TARGET_EXCLUDE_TAGS, usecustomexception)
        end
    end

    local function CanAndWhichToolToMake( inst, tool_id, isOverwritting )
        if not inst.replica or not inst.replica.builder or not inst.replica.builder.CanBuild or not inst.replica.builder.MakeRecipeFromMenu then return false end
        
        local toolToMake
        
        if( not isOverwritting and not aa_useGoldenTools or isOverwritting and aa_useGoldenTools ) then
            if toolsForActionsGold[tool_id] and inst.replica.builder:KnowsRecipe(toolsForActionsGold[tool_id]) and inst.replica.builder:CanBuild(toolsForActionsGold[tool_id]) then
                toolToMake = toolsForActionsGold[tool_id]
            end
            if toolsForActions[tool_id] and inst.replica.builder:KnowsRecipe(toolsForActions[tool_id]) and inst.replica.builder:CanBuild(toolsForActions[tool_id]) then
                toolToMake = toolsForActions[tool_id]
            end
        else
            if toolsForActions[tool_id] and inst.replica.builder:KnowsRecipe(toolsForActions[tool_id]) and inst.replica.builder:CanBuild(toolsForActions[tool_id]) then
                toolToMake = toolsForActions[tool_id]
            end
            if toolsForActionsGold[tool_id] and inst.replica.builder:KnowsRecipe(toolsForActionsGold[tool_id]) and inst.replica.builder:CanBuild(toolsForActionsGold[tool_id]) then
                toolToMake = toolsForActionsGold[tool_id]
            end
        end
        
        return toolToMake ~= nil, toolToMake or nil
    end

    local function GetAction(inst, target, action, ignorecontrol, searchTarget)
        --print(inst,target,target and target.inst or "error",target and target.components or "error comp",action.id)
        local lrecipe = nil
        local tool
        local thecraftingact
        tool = FindTool(inst,GetInventory(inst), action)
        if not tool and aa_canCraftToolsWithMouse and toolsForActions[action.id] then
            local canCraft, whichCraft = CanAndWhichToolToMake(inst,action.id, ( ignorecontrol ~= nil and ignorecontrol ) or ( ignorecontrol == nil and TheInput:IsControlPressed(41) ) or false)
            --inst.replica.builder:MakeRecipeFromMenu(AllRecipes[toolsForActions[action.id]])
            if canCraft and whichCraft then
                tool = "craft"
                lrecipe = whichCraft
                thecraftingact = toolsForActions[action.id]
            end
        end
        --print("Finding a tool...", tool or "N/A")
        if not tool then
            return
        elseif type(tool) == "string" then
            tool = nil
        end
        if action == ACTIONS.NET and (not target.components.health or target.components.health:IsDead()) then return end
        if not target:HasTag((action.id).."_workable") then return end --if not target.components.workable and not target.components.hackable then return end
        
        -- if( target.components.hackable and ( ( action == ACTIONS.HACK and not target.components.hackable:IsActionValid(action,false) ) or ( action ~= ACTIONS.HACK and target.components.workable.action ~= action ) ) ) then return end
        -- if( not target:HasTag(action.id.."_workable") ) then return end
        
        local laction = BufferedAction(inst, (not lrecipe and target or nil), action, tool,nil, lrecipe)
        if( lrecipe ) then
            laction.action = ACTIONS.BUILD
            laction.GetActionString = function()
                return "(Craft "..(thecraftingact == lrecipe and "" or "golden " )..thecraftingact..")"
            end
            laction.mod_name = "a-a"
        else
            laction.autoequip = true
        end
        return laction
    end

    local weaponsByPriority = {
        nightsword = 5,
        cutlass = 6,
        ruins_bat = 12,
        spear_obsidian = 13,
        tentaclespike = 14,
        nightstick = 15,
        batbat = 16,
        spear_wathgrithr = 17,
        spear = 18,
        spear_poison = 19,
        peg_leg = 20,
        trident = 21,

        machete = 42, goldenmachete = 42.1, obsidianmachete = 42.2,
        multitool_axe_pickaxe = 43,
        axe = 44, goldenaxe = 44.1,
        pickaxe = 44.2, goldenpickaxe = 44.3,
        hammer = 44.4, pitchfork = 44.5, shovel = 44.6, goldenshovel = 44.7,
        lucy = 46
    }
    -- lighter = 45, but let's not include it, we aren't that sinister

    local rangedWeaponsByPriority = {
        boomerang = 1
    }

    local hasPreferedWeapon = nil
    local function IsRangedWeapon( weap ) return ( weap and weap.replica and weap.replica._ and weap.replica._.inventoryitem and weap.replica._.inventoryitem.classified and weap.replica._.inventoryitem.classified.attackrange and weap.replica._.inventoryitem.classified.attackrange:value() > 0 ) or false end
    -- Used percent - ThePlayer.replica.inventory:GetItems()[2].replica._.inventoryitem.classified.percentused:value()
    local function GetBestWeapon(inst, canBeRanged, ishunting)
        if letsDoDebug then print("- Start finding best weapon -") end
        local bestweapon = GetInventory(inst):GetEquippedItem(EQUIPSLOTS.HANDS)
        local isranged
        -- do not replace a ranged weapon
        if bestweapon then return bestweapon end
        
        if hasPreferedWeapon and hasPreferedWeapon ~= "" then
        
            local customweapon = GetInventory(inst).FindItem and GetInventory(inst):FindItem(function(item)
                return item.prefab == hasPreferedWeapon
            end) or CustomFindItem(inst, GetInventory(inst), function(item)
                return item.prefab == hasPreferedWeapon
            end)
            
            if customweapon then
                return customweapon, false
            end
        
        end
        
        local weapons = GetInventory(inst).FindItems and GetInventory(inst):FindItems(function(item)
                return item:HasTag("weapon") and ( item.prefab ~= "lighter" )
            end) or CustomFindItems(inst, GetInventory(inst), function(item)
                return item:HasTag("weapon") and ( item.prefab ~= "lighter" )
            end)
        if weapons then
            local highest = 100000
            for k,v in pairs(weapons) do
                if v and ( IsRangedWeapon(v) and canBeRanged or not IsRangedWeapon(v) ) then
                    if not bestweapon or ( weaponsByPriority and weaponsByPriority[v.prefab] and weaponsByPriority[v.prefab] < highest ) then
                        -- print("switching to "..v.prefab)
                        bestweapon = v
                        if( weaponsByPriority and weaponsByPriority[v.prefab] and weaponsByPriority[v.prefab] ) then highest = weaponsByPriority[v.prefab] end
                        if letsDoDebug then print("Found acceptable weapon", v or "N/A") end
                    elseif not bestweapon or ( rangedWeaponsByPriority and rangedWeaponsByPriority[v.prefab] and rangedWeaponsByPriority[v.prefab] < highest ) then
                        -- print("switching to "..v.prefab)
                        isranged = true
                        bestweapon = v
                        if( rangedWeaponsByPriority and rangedWeaponsByPriority[v.prefab] and rangedWeaponsByPriority[v.prefab] ) then highest = rangedWeaponsByPriority[v.prefab] end
                        if letsDoDebug then print("Found acceptable weapon", v or "N/A") end
                    end
                    if( ae_huntwithboomerang and ae_huntwithboomerang > 0 and ishunting and ( canBeRanged and rangedWeaponsByPriority and rangedWeaponsByPriority[v.prefab] or not canBeRanged ) ) then
                        isranged = true
                        bestweapon = v
                        break
                    end
                end
            end
        end
        return bestweapon, isranged or false
    end

    local function AutoEquipItem(playercontroller, bufferedaction, isranged)
        if not bufferedaction then return end
        if not bufferedaction.invobject then return end
        if not playercontroller.autoequip_lastequipped and not isranged then
            playercontroller.autoequip_lastequipped = GetInventory(playercontroller.inst):GetEquippedItem(EQUIPSLOTS.HANDS)
            if not playercontroller.autoequip_lastequipped then playercontroller.autoequip_lastequipped = "empty" end
        end
        
        DoEquip(playercontroller.inst,bufferedaction.invobject)
        -- playercontroller.GetInventory(inst):Equip(bufferedaction.invobject)
    end

    local function DoAutoEquipItem( playercontroller, tool, deta )
        if letsDoDebug then print("Forcing equip of: ",playercontroller,tool,deta) end
        if deta ~= nil then
            local tempAction = BufferedAction(playercontroller.inst, playercontroller.inst, ACTIONS.EQUIP, tool)
            table.insert(tempAction.onsuccess,deta);
            AutoEquipItem(playercontroller, tempAction, false)
        else
            local tempAction = BufferedAction(playercontroller.inst, playercontroller.inst, ACTIONS.EQUIP, tool)
            AutoEquipItem(playercontroller, tempAction, false)
        end
    end

    local function AutoEquipBestWeapon(playercontroller, target, isForced, bufferedaction)
        local bestweapon
        local isranged
        if( target ) then
            if( target:HasTag("hostile") or target:HasTag("monster") or target:HasTag("largecreature") ) then
                bestweapon, isranged = GetBestWeapon(playercontroller.inst, false)
            elseif( target:HasTag("insect") or target:HasTag("smallcreature") or target:HasTag("flying") ) then
                bestweapon, isranged = GetBestWeapon(playercontroller.inst, true, true )
            else
                bestweapon, isranged = GetBestWeapon(playercontroller.inst, false)
            end
        else
            bestweapon, isranged = GetBestWeapon(playercontroller.inst, false)
        end
        if letsDoDebug then print("Found a best weapon", bestweapon or "N/A") end
        if not bestweapon or bestweapon == GetInventory(playercontroller.inst):GetEquippedItem(EQUIPSLOTS.HANDS) then return end
        bufferedaction.invobject = bestweapon
        AutoEquipItem(playercontroller, bufferedaction, isranged)
    end

    local tookLightOut = nil
    local firstCheckedForDarkness = nil
    local function CheckIfInDarkness( inst )
        if( not firstCheckedForDarkness ) then
            if letsDoDebug then print("Oh, it's dark...") end
            firstCheckedForDarkness = GetTime()
        elseif( firstCheckedForDarkness and GetTime() > (firstCheckedForDarkness+2) ) then
            if letsDoDebug then print("That's it, I'm equipping light!") end
            firstCheckedForDarkness = nil
            
            local possibleLights = CustomFindItem(inst, GetInventory(inst), function(item) return item:HasTag("lighter") end) -- For now, just use whatever can be found
            if( possibleLights ) then
                if possibleLights then
                    if letsDoDebug then print("Equipping a light-source!") print(possibleLights) end
                    DoEquip(inst,possibleLights)
                else
                    if letsDoDebug then print("No lights found! Something went wrong...") end
                end
            else
                if( ae_givelight > 1 ) then
                    if letsDoDebug then print("No lights found, but attempting to craft a light.") end
                    if( inst.replica and inst.replica.builder and inst.replica.builder.CanBuild and inst.replica.builder.MakeRecipeFromMenu and inst.replica.builder:CanBuild("torch") ) then
                        inst.replica.builder:MakeRecipeFromMenu(AllRecipes["torch"])
                    end
                else
                    if letsDoDebug then print("No lights found.") end
                end
            end
            -- Tag is "lighter"
        end
    end

    local CreateEntity = GLOBAL.CreateEntity

    local function UpdateTreePlacer( info, doremove )
        if(doremove and forcePlantSaplingPlacer) then
            forcePlantSaplingPlacer:Remove()
            return false
        end
        
        if(forcePlantSaplingPlacer and forcePlantSaplingPlacer:IsValid()) then
            forcePlantSaplingPlacer.Transform:SetPosition(info[2].x,info[2].y,info[2].z)
        else
            forcePlantSaplingPlacer = CreateEntity()
            
            local seedType = aa_seedTypes[info[1]]

            forcePlantSaplingPlacer:AddTag("FX")
            forcePlantSaplingPlacer.entity:SetCanSleep(false)
            forcePlantSaplingPlacer.persists = false

            forcePlantSaplingPlacer.entity:AddTransform()
            forcePlantSaplingPlacer.entity:AddAnimState()
            forcePlantSaplingPlacer.AnimState:SetBank(seedType)
            forcePlantSaplingPlacer.AnimState:SetBuild(seedType)
            forcePlantSaplingPlacer.AnimState:PlayAnimation("idle_planted", true)
            forcePlantSaplingPlacer.AnimState:SetLightOverride(1)
            
            forcePlantSaplingPlacer.AnimState:SetAddColour(.25, .25, .25, 0)
            
            if(forcePlantSaplingPlacer and forcePlantSaplingPlacer:IsValid()) then
                forcePlantSaplingPlacer.Transform:SetPosition(info[2].x,info[2].y,info[2].z)
            end
        end
    end

    -- attached to playercontroller.OnUpdate
    local function OnUpdate(playercontroller, dt,...)
        if not playercontroller:IsEnabled() then return end
        if ae_givelight and ae_givelight > 0 then
            if GLOBAL.TheWorld.state.isnight and not GLOBAL.TheWorld.state.isfullmoon and playercontroller.inst.LightWatcher and not playercontroller.inst.LightWatcher:IsInLight() then CheckIfInDarkness(playercontroller.inst) elseif(  not (GLOBAL.TheWorld.state.isnight and not GLOBAL.TheWorld.state.isfullmoon and playercontroller.inst.LightWatcher and not playercontroller.inst.LightWatcher:IsInLight()) and firstCheckedForDarkness ) then firstCheckedForDarkness = nil end
        end
        if( ( IMS(playercontroller) and not playercontroller.inst.sg:HasStateTag("idle") ) or ( not IMS(playercontroller) and not playercontroller.inst:HasTag("idle") ) ) then return end
        if TheInput:IsControlPressed(GLOBAL.CONTROL_PRIMARY) then return end
        if TheInput:IsControlPressed(GLOBAL.CONTROL_SECONDARY) then return end
        if TheInput:IsControlPressed(GLOBAL.CONTROL_ACTION) then return end
        if TheInput:IsControlPressed(GLOBAL.CONTROL_ATTACK) then return end
        if( ( IMS(playercontroller) and playercontroller.inst.sg:HasStateTag("working") ) or ( not IMS(playercontroller) and playercontroller.inst:HasTag("working") ) ) then return end
        if( ( IMS(playercontroller) and playercontroller.inst.sg:HasStateTag("doing") ) or ( not IMS(playercontroller) and playercontroller.inst:HasTag("doing") ) ) then return end
        if( ( IMS(playercontroller) and playercontroller.inst.sg:HasStateTag("attack") ) or ( not IMS(playercontroller) and playercontroller.inst:HasTag("attack") ) ) then return end
        if playercontroller.inst.replica.combat.target ~= nil then return end
        -- print("switch to previous equipped item")
        
        if( forcePlantSapling ) then forcePlantSapling = nil UpdateTreePlacer(nil,true) if letsDoDebug then print("Resetting tree sapling data!") end end
        if( forceResetTrap ) then forceResetTrap = nil if letsDoDebug then print("Resetting trap data!") end end
        if( forcePlantSaplingPlacer ) then UpdateTreePlacer(nil,true) end
        
        if not playercontroller.autoequip_lastequipped then return end
        
        if( playercontroller.autoequip_lastequipped and GetTime() < delayUnequipASecond ) then return end
        if type(playercontroller.autoequip_lastequipped) == "string" then -- and not GetInventory(playercontroller.inst):IsFull()
            --playercontroller.inst.components.locomotor:PushAction(BufferedAction(playercontroller.inst, nil, ACTIONS.UNEQUIP, GetInventory(playercontroller.inst):GetEquippedItem(EQUIPSLOTS.HANDS)), true)
            DoUnequip(playercontroller)
            playercontroller.inst.autoequip_prioNextTarget = nil
        elseif type(playercontroller.autoequip_lastequipped) == "table" then
            --playercontroller.inst.components.locomotor:PushAction(BufferedAction(playercontroller.inst, nil, ACTIONS.EQUIP, playercontroller.autoequip_lastequipped), true)
            DoEquip(playercontroller.inst,playercontroller.autoequip_lastequipped)
            playercontroller.inst.autoequip_prioNextTarget = nil
        end
        -- playercontroller.GetInventory(inst):Equip(playercontroller.autoequip_lastequipped)
        playercontroller.autoequip_lastequipped = nil
        --forceNextAction = false
        playercontroller.inst.autoequip_prioNextTarget = nil
        playercontroller.inst.autoequip_prioNextAct = nil
    end

    local function GenerateNewBufferedAction( playercontroller, doforce, ignore_targets, musthave, donthave )
        local successflag, retvalue = pcall(Backup_GetActionButtonAction, playercontroller, doforce or nil, ignore_targets or nil, musthave or nil, donthave or nil)
        if( not successflag ) then
            if letsDoDebug then print("Something went wrong...", retvalue) end
            return nil
        else
            return retvalue
        end
    end

    local alreadyCheckedMods = {}
    local function CustomCheckForMod( lemodname )
        if letsDoDebug then print("Checking for mod:",lemodname) end

        if( alreadyCheckedMods[lemodname] ~= nil ) then
            
            return alreadyCheckedMods[lemodname]
        elseif( alreadyCheckedMods[lemodname] == nil ) then
            local KnownModIndex = KnownModIndex or GLOBAL.KnownModIndex
            alreadyCheckedMods[lemodname] = ( ( KnownModIndex:GetModActualName(lemodname) and true ) or false )
            
            return alreadyCheckedMods[lemodname]
        end
        
        return false
    end

    local RPC = GLOBAL.RPC
    local SendRPCToServer = GLOBAL.SendRPCToServer

    local function DoCustomModifications( buffered, playercontroller, ignore )
        if not buffered or not buffered.action or not buffered.target or not buffered.target.prefab then if letsDoDebug then print("Eh, not all needed info was here", buffered,buffered.action,buffered.target,buffered.target.prefab) end return end
        if letsDoDebug then print("= Doing custom modifications:", buffered,buffered.action,buffered.target,buffered.target.prefab) end
        if( buffered.target.prefab == "trap_teeth" and buffered.action == ACTIONS.PICKUP ) then
            if( buffered.target:HasTag("minesprung") ) then
                buffered.action = ACTIONS.RESETMINE
                local position = TheInput:GetWorldPosition()
                local controlmods = playercontroller:EncodeControlMods()
                buffered.preview_cb = function()
                    SendRPCToServer(RPC.RightClick, buffered.action.code, position.x, position.z, buffered.target, false, controlmods, nil, buffered.action.mod_name)
                end
                
                playercontroller:DoAction(buffered)
                
                return "end"
            elseif( not buffered.target:HasTag("minesprung") and not ignore and aa_ignoreTraps ) then
                if letsDoDebug then print("Finding new buffer...") end
                local x, y, z = playercontroller.inst.Transform:GetWorldPosition()
                local ignoreTraps = TheSim:FindEntities(x, y, z, 8, nil, {"trapsprung","minesprung"}, {"trap"})
                return GenerateNewBufferedAction(playercontroller, nil, ignoreTraps)
            end
        elseif( buffered.target.prefab == "trap" and buffered.action == ACTIONS.PICKUP and not ignore and aa_ignoreTraps ) then
            if letsDoDebug then print("Finding new buffer...") end
            local x, y, z = playercontroller.inst.Transform:GetWorldPosition()
            local ignoreTraps = TheSim:FindEntities(x, y, z, 8, nil, {"trapsprung","minesprung"}, {"trap"})
            return GenerateNewBufferedAction(playercontroller, nil, ignoreTraps)
            
        elseif( buffered.action == ACTIONS.PICK and ( (buffered.target.prefab == "grass") or (buffered.target.prefab == "sapling") or (buffered.target.prefab == "reeds") ) and CustomCheckForMod("Scythestest") and not ignore ) then
            if letsDoDebug then print("Finding new buffer...") end
            
            local tool
            if( inst.replica and inst.replica.inventory and inst.replica.inventory.GetEquippedItem and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ) then
                tool = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            elseif( inst.components and inst.components.inventory ) then
                tool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            end
            if ( not tool or ( tool and not tool:HasTag("mower") ) ) and ( inst.components and inst.components.playercontroller ) then
                
                local thetool = CustomFindItem(inst, GetInventory(inst), function(itm) return itm:HasTag("mower") end)
                if thetool then
                    if letsDoDebug then print("Force equipping sychte") end
                    
                    DoAutoEquipItem(inst.components.playercontroller, thetool, doonsuccess )
                    buffered.invobject = thetool
                    return buffered
                end
            else
                if letsDoDebug then print("Already has sychte equipped") end
            end
            
        elseif( buffered.target.prefab and table.contains(aa_saplingTypes,buffered.target.prefab) and buffered.action == ACTIONS.DIG and not ignore and aa_completelyignore ) then
            return false
        end
        return buffered
    end

    local lastActionDone

    local doTimeDelay = 0
    local doNext = 0
    local forceNextAction = false
    -- attached to playercontroller.GetActionButtonAction
    local function GetActionButtonAction(playercontroller, forced, bufferedaction,...)
        if not playercontroller or not playercontroller:IsEnabled() then return end
        --print("start action 2")
        
        if( doTimeDelay and doTimeDelay > GetTime() ) then
            return
        elseif( doTimeDelay and doTimeDelay <= GetTime() ) then
            doTimeDelay = nil
        end
        
        --if doNext > 0 then doNext = doNext-1 return end
        
        if( playercontroller:IsDoingOrWorking() ) then if letsDoDebug then print("[Is working!]") end return end
        
        --print(forceUnequipTool, lastActionDone, forceUnequipTool and lastActionDone and forceUnequipTool == lastActionDone or nil )
        if( forceUnequipTool and lastActionDone and forceUnequipTool == lastActionDone ) then
            DoUnequip(playercontroller)
            forceUnequipTool = nil
        end
        
        lastActionDone = bufferedaction and bufferedaction.action or nil
        
        if( forcePlantSapling and aa_replantTrees ) then
            if letsDoDebug then print("Doing plant") end
            if( forcePlantSapling[1] and forcePlantSapling[2] and ( not forcePlantSapling[3] or forcePlantSapling[3] and not forcePlantSapling[3]:IsValid() ) and aa_seedTypes and aa_seedTypes[forcePlantSapling[1]] and GetInventory(playercontroller.inst) and CustomFindItem(playercontroller.inst, GetInventory(playercontroller.inst), function(itm) return itm.prefab and itm.prefab == aa_seedTypes[forcePlantSapling[1]] end) ~= nil ) then
                UpdateTreePlacer(forcePlantSapling)
                
                local seedType = aa_seedTypes[forcePlantSapling[1]]
                local seed = CustomFindItem(playercontroller.inst, GetInventory(playercontroller.inst), function(itm) return itm.prefab and itm.prefab == seedType end)
                if( GLOBAL.TheWorld.Map:CanDeployPlantAtPoint(forcePlantSapling[2], seed) ) then
                    if letsDoDebug then print("Planting plant") end
                    local pos = forcePlantSapling[2]
                    if( IMS(playercontroller) ) then
                        local act = BufferedAction( playercontroller.inst, nil, ACTIONS.DEPLOY, seed, pos, nil )
                        playercontroller.inst.components.locomotor:PushAction(act,true)
                    else
                        local act = BufferedAction( playercontroller.inst, nil, ACTIONS.DEPLOY, seed, pos, nil )
                        act.preview_cb = function()
                            --SendRPCToServer(RPC.RightClick, act.action.code, pos.x, pos.z, act.target, false, controlmods, nil, act.action.mod_name)
                            SendRPCToServer(RPC.ControllerActionButtonDeploy, seed, pos.x, pos.z)
                        end
                        playercontroller:DoAction(act)
                    end
                    
                    forcePlantSapling = nil
                    UpdateTreePlacer(nil,true)
                    doTimeDelay = GetTime() + 0.75
                    return
                else
                    if letsDoDebug then print("Searching for pickup for plant") end
                    local pos = forcePlantSapling[2]
                    
                    local ents = GLOBAL.TheSim:FindEntities(pos.x, pos.y, pos.z, {"_inventoryitem"})
                    if ents and ents[1] ~= nil then
                        if letsDoDebug then print("Found, now running") end
                        return GenerateNewBufferedAction(playercontroller, ents[1])
                    end
                end
            elseif( not forcePlantSapling[1] or not forcePlantSapling[2] ) then
                forcePlantSapling = nil
                UpdateTreePlacer(nil,true)
            end
        elseif( forceResetTrap and aa_reactiveTraps ) then
            -- trapsprung
            if letsDoDebug then print("Doing re-trap") end
            if( forceResetTrap[1] and forceResetTrap[2] and GetInventory(playercontroller.inst) and CustomFindItem(playercontroller.inst, GetInventory(playercontroller.inst), function(itm) return itm.prefab and itm.prefab == forceResetTrap[1] end) ~= nil ) then
                local seed = CustomFindItem(playercontroller.inst, GetInventory(playercontroller.inst), function(itm) return itm.prefab and itm.prefab == forceResetTrap[1] end)
                if( seed ) then
                    if letsDoDebug then print("Resetting trap") end
                    local pos = forceResetTrap[2]
                    if( IMS(playercontroller) ) then
                        local act = BufferedAction( playercontroller.inst, nil, ACTIONS.DROP, seed, pos, nil )
                        playercontroller.inst.components.locomotor:PushAction(act,true)
                    else
                        local act = BufferedAction( playercontroller.inst, nil, ACTIONS.DROP, seed, pos, nil )
                        act.preview_cb = function()
                            SendRPCToServer(RPC.DropItemFromInvTile, seed, true)
                        end
                        playercontroller:DoAction(act)
                    end
                    
                    forceResetTrap = nil
                    doTimeDelay = GetTime() + 0.75
                    return
                end
            elseif( not forceResetTrap[1] or not forceResetTrap[2] ) then
                forceResetTrap = nil
            end
        end
        
        if( bufferedaction and bufferedaction.action and bufferedaction.action.id and bufferedaction.action == ACTIONS.CATCH ) then
            if letsDoDebug then print("No matter what, always catch before anything else!") end
            return bufferedaction
        end
        
        --print("start action 3")
        if letsDoDebug then print("\n------------------------------------------------------") end
        if letsDoDebug then print("Starting to find action!") end
        if letsDoDebug then print("Starting with tool/weapon:",playercontroller.inst.replica and playercontroller.inst.replica.inventory and playercontroller.inst.replica.inventory.GetEquippedItem and playercontroller.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or "None") end
        
        local shouldIgnoreRestrictions = ae_ignoreRestrictions and ae_ignoreRestrictions > 0 and playercontroller:IsControlPressed(41)
        
        if letsDoDebug then print("Pre-Buffered info:",bufferedaction or "N/A") end
        
        
        if bufferedaction ~= nil then bufferedaction = DoCustomModifications(bufferedaction,playercontroller,shouldIgnoreRestrictions) end
        if type(bufferedaction) == "string" and bufferedaction == "end" then return end
        
        if letsDoDebug then print("Post-Buffered info:",bufferedaction or "N/A") end
        
        --[[
        if( playercontroller.inst and playercontroller.inst and playercontroller.inst.autoequip_prioNextTarget ~= nil and playercontroller.inst.autoequip_prioNextAct ~= nil and playercontroller.inst.autoequip_prioNextAct.id ~= nil ) then
            if letsDoDebug then print("Oh? Found info:", playercontroller.inst.autoequip_prioNextTarget or "N/A",playercontroller.inst.autoequip_prioNextAct and playercontroller.inst.autoequip_prioNextAct.id or "N/A", playercontroller.inst.autoequip_prioNextTarget.HasTag or "Can't use HasTag", (playercontroller.inst.autoequip_prioNextAct.id or "na").."_workable") end
            if( playercontroller.inst.autoequip_prioNextTarget:HasTag((playercontroller.inst.autoequip_prioNextAct.id or "na").."_workable") ) then
                if letsDoDebug then print("Doing pre-prepared action") end
                --return bufferedaction
                
                if( playercontroller.inst.replica and playercontroller.inst.replica.inventory and playercontroller.inst.replica.inventory.GetEquippedItem and ( not playercontroller.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or ( playercontroller.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) and not playercontroller.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS):HasTag((playercontroller.inst.autoequip_prioNextAct.id or "na").."_tool") ) ) ) then
                    local theTool = FindTool(playercontroller.inst,GetInventory(playercontroller.inst), playercontroller.inst.autoequip_prioNextAct)
                    if( theTool ~= nil ) then
                        if letsDoDebug then print("But ehhh... You don't have the right tool yet... Let me help.") end
                        DoEquip(playercontroller.inst,theTool)
                        doNext = 4;
                        return
                    else
                        playercontroller.inst.autoequip_prioNextTarget = nil
                        playercontroller.inst.autoequip_prioNextAct = nil
                        if( forceNextAction ) then DoUnequip(playercontroller) forceNextAction = false end
                        if letsDoDebug then print("But ehhh... You don't have the right tool yet, and you don't even have that kind of tool... ABANDON SHIP!!!") end
                        return
                    end
                end
                if( bufferedaction and bufferedaction.action and bufferedaction.target and bufferedaction.action.id and bufferedaction.action.id == playercontroller.inst.autoequip_prioNextAct.id and bufferedaction.target == playercontroller.inst.autoequip_prioNextTarget ) then
                    return bufferedaction
                else
                    return BufferedAction(playercontroller.inst, playercontroller.inst.autoequip_prioNextTarget, playercontroller.inst.autoequip_prioNextAct)
                end
            else
                playercontroller.inst.autoequip_prioNextTarget = nil
                playercontroller.inst.autoequip_prioNextAct = nil
                if( forceNextAction ) then
                    DoUnequip(playercontroller)
                    forceNextAction = false
                end
                return
            end
        end]]
        
        if letsDoDebug then print("[Trying to find a new action]") end
        
        local tool
        local target
        
        
        local shouldMakeToolLater
        local shouldGetToolLater

        if letsDoDebug then print("Doing economic mode") end

        local foundSomething
        local canUseActions = {}
        local toolsOfActions = {}
        local actionOfChoice
        
        for k, v in pairs(actsToUse) do
            if v and v.id then
                local letool
                
                if( v == ACTIONS.CHOP ) then
                    letool = FindTool(playercontroller.inst,GetInventory(playercontroller.inst), ACTIONS.CHOP, function(itm) return ( itm.prefab and itm.prefab == "lucy" ) end)
                end
                
                if not letool then letool = FindTool(playercontroller.inst,GetInventory(playercontroller.inst), v) end
                
                if letool then
                    table.insert(canUseActions, (v.id).."_workable")
                    toolsOfActions[(v.id).."_workable"] = letool
                    foundSomething = true
                elseif GLOBAL.FindEntity(playercontroller.inst, 8, function( entitiy ) return true end, {"weapon",(v.id).."_tool"}, TARGET_EXCLUDE_TAGS) then
                    --inst.replica.builder:MakeRecipeFromMenu(AllRecipes["torch"])
                    table.insert(canUseActions, (v.id).."_workable")
                    local canCraft, makeCraft = CanAndWhichToolToMake(playercontroller.inst,v.id)
                    toolsOfActions[(v.id).."_workable"] = "pickup"
                    foundSomething = true
                    if letsDoDebug then print("Can pick-up tool") end
                elseif aa_canCraftToolsAutomatically and CanAndWhichToolToMake(playercontroller.inst,v.id) then
                    --inst.replica.builder:MakeRecipeFromMenu(AllRecipes["torch"])
                    table.insert(canUseActions, (v.id).."_workable")
                    local canCraft, makeCraft = CanAndWhichToolToMake(playercontroller.inst,v.id)
                    toolsOfActions[(v.id).."_workable"] = "craft"
                    foundSomething = true
                    if letsDoDebug then print("Can make a tool") end
                end
            end
        end
        
        if foundSomething then
        
            --if letsDoDebug then print("Search gave:") end
            for k,v in pairs(canUseActions) do
                --if letsDoDebug then print("-",v) end
            end
            --if letsDoDebug then print("And tools:") end
            for k,v in pairs(canUseActions) do
                --if letsDoDebug then print("-",k,v) end
            end
            
            target = FindWorkableEntity(playercontroller.inst, nil, playercontroller.directwalking and 3 or 6, shouldIgnoreRestrictions, canUseActions)
            if target and target ~= nil then
                for k, v in pairs(actsToUse) do
                    local leid = v.id
                    if( target and target:HasTag(leid.."_workable") and toolsOfActions[leid.."_workable"] ~= nil ) then
                        if aa_canPickupToolsAutomatically and type(toolsOfActions[leid.."_workable"]) == "string" and toolsOfActions[leid.."_workable"] == "pickup" then
                            --local canCraft, doCraft = CanAndWhichToolToMake(playercontroller.inst,leid)
                            --if canCraft and doCraft then
                            --	playercontroller.inst.replica.builder:MakeRecipeFromMenu(AllRecipes[doCraft])
                            --end
                            --return
                            shouldGetToolLater = leid
                        elseif aa_canCraftToolsAutomatically and type(toolsOfActions[leid.."_workable"]) == "string" and toolsOfActions[leid.."_workable"] == "craft" then
                            --local canCraft, doCraft = CanAndWhichToolToMake(playercontroller.inst,leid)
                            --if canCraft and doCraft then
                            --	playercontroller.inst.replica.builder:MakeRecipeFromMenu(AllRecipes[doCraft])
                            --end
                            --return
                            shouldMakeToolLater = leid
                        elseif toolsOfActions[leid.."_workable"] and type(toolsOfActions[leid.."_workable"]) ~= "string" then
                            tool = toolsOfActions[leid.."_workable"]
                            actionOfChoice = v
                        end
                    end
                end
                
                if target and tool and actionOfChoice then
                    playercontroller.inst.autoequip_actiontodo = actionOfChoice
                end
            end
        
        else
        
            --print("Found nothing...")
        
        end
        
        if letsDoDebug then print("Economic mode ending") end
        
        if letsDoDebug then print("Result:",target or "n/a",tool or "n/a", target and bufferedaction and bufferedaction.target and bufferedaction.target == target or "n/a" ) end
        
        if( target and shouldMakeToolLater ) then
            if( bufferedaction and bufferedaction.target ) then
                if playercontroller.inst:GetDistanceSqToInst(bufferedaction.target) > playercontroller.inst:GetDistanceSqToInst(target) then
                    local canCraft, doCraft = CanAndWhichToolToMake(playercontroller.inst,shouldMakeToolLater)
                    if canCraft and doCraft then
                        playercontroller.inst.replica.builder:MakeRecipeFromMenu(AllRecipes[doCraft])
                    end
                    return
                end
            else
                local canCraft, doCraft = CanAndWhichToolToMake(playercontroller.inst,shouldMakeToolLater)
                if canCraft and doCraft then
                    playercontroller.inst.replica.builder:MakeRecipeFromMenu(AllRecipes[doCraft])
                end
                return
            end
        elseif( target and shouldGetToolLater ) then
            local closestTool = GLOBAL.FindEntity(playercontroller.inst, 8, function( entitiy ) return true end, {"weapon",shouldGetToolLater.."_tool"}, TARGET_EXCLUDE_TAGS)
            if closestTool then
                local pos = closestTool:GetPosition()
                if( bufferedaction and bufferedaction.target ) then
                    if playercontroller.inst:GetDistanceSqToInst(bufferedaction.target) > playercontroller.inst:GetDistanceSqToInst(target) then
                        return GenerateNewBufferedAction(playercontroller, closestTool)
                    end
                else
                    return GenerateNewBufferedAction(playercontroller, closestTool)
                end
            end
        end
        
        if tool and target and ( not bufferedaction or ( bufferedaction and bufferedaction.target ~= target ) ) then
        
            if letsDoDebug then print("Possible new action: ",target,tool) end
        
            if bufferedaction and bufferedaction.target and bufferedaction.action then
                if playercontroller.inst:GetDistanceSqToInst(bufferedaction.target) < playercontroller.inst:GetDistanceSqToInst(target) then
                    if letsDoDebug then print("Doing action 1") end
                    playercontroller.inst.autoequip_prioNextTarget = bufferedaction.target
                    playercontroller.inst.autoequip_prioNextAct = bufferedaction.action
                    doTimeDelay = GetTime()+0.25
                    return bufferedaction
                else
                    if letsDoDebug then print("Another action",tostring(tool), tostring(target), "is closer") end
                end
            else
                if letsDoDebug then print("Doing new action", tostring(tool), tostring(target)) end
            end
        
            if not playercontroller.autoequip_lastequipped then
                playercontroller.autoequip_lastequipped = GetInventory(playercontroller.inst):GetEquippedItem(EQUIPSLOTS.HANDS)
                if not playercontroller.autoequip_lastequipped then playercontroller.autoequip_lastequipped = "empty" end
            end
            
            --playercontroller.inst.components.locomotor:PushAction(BufferedAction(playercontroller.inst, target, playercontroller.inst.autoequip_actiontodo, tool), true)
            
            local newAction = BufferedAction(playercontroller.inst, target, ACTIONS.WALKTO)
            
            if( playercontroller.inst.autoequip_actiontodo and GetInventory(playercontroller.inst):GetEquippedItem(EQUIPSLOTS.HANDS) and type(GetInventory(playercontroller.inst):GetEquippedItem(EQUIPSLOTS.HANDS)) == "table" and GetInventory(playercontroller.inst):GetEquippedItem(EQUIPSLOTS.HANDS):HasTag((playercontroller.inst.autoequip_actiontodo.id).."_tool") ) then
                if letsDoDebug then print("Well... you already have the needed tool, so get started.") end
                playercontroller.inst.autoequip_prioNextTarget = target
                playercontroller.inst.autoequip_prioNextAct = playercontroller.inst.autoequip_actiontodo
                doNext = 4
            else
                --playercontroller.inst.components.locomotor:PushAction(BufferedAction(playercontroller.inst, nil, ACTIONS.EQUIP, tool), true)
                DoEquip(playercontroller.inst,tool)
                playercontroller.inst.autoequip_prioNextTarget = target
                playercontroller.inst.autoequip_prioNextAct = playercontroller.inst.autoequip_actiontodo
                if( playercontroller.inst.autoequip_prioNextAct.id == "DIG" or playercontroller.inst.autoequip_prioNextAct.id == "dig" ) then
                    forceUnequipTool = playercontroller.inst.autoequip_prioNextAct
                    if target and target.GetPosition and target.prefab and aa_seedTypes and aa_seedTypes[target.prefab] and aa_replantTrees then
                        local thepos = target:GetPosition()
                        if thepos then
                            forcePlantSapling = {
                                target.prefab,
                                thepos,
                                target
                            }
                            if letsDoDebug then print("SEED-TYPE:", target.prefab) end
                            forceNextAction = {"unequip"}
                            --forceNextAction = {"tree_root"}
                        else
                            forceNextAction = {"unequip"}
                        end
                    else
                        forceNextAction = {"tree"}
                    end
                end
                if letsDoDebug then print("Equipped tool, now we just have to use it next.", ACTIONS.EQUIP, tool) end
                doTimeDelay = GetTime()+0.25
            end
            
            return newAction

        else
        
            --if bufferedaction then if letsDoDebug then print("Doing another action") end doTimeDelay = GetTime()+1 return bufferedaction end
            if bufferedaction then
                if letsDoDebug then print("Doing another action") end
                if bufferedaction and bufferedaction.target and bufferedaction.action then
                    if aa_replantTrees and bufferedaction.action == ACTIONS.DIG and bufferedaction.target.GetPosition and bufferedaction.target.prefab and aa_seedTypes and aa_seedTypes[bufferedaction.target.prefab] then
                        local thepos = bufferedaction.target:GetPosition()
                        if thepos then
                            forcePlantSapling = {
                                bufferedaction.target.prefab,
                                thepos,
                                target
                            }
                            UpdateTreePlacer(forcePlantSapling)
                            
                            if letsDoDebug then print("SEED-TYPE:", bufferedaction.target.prefab) end
                        end
                    elseif bufferedaction.action == ACTIONS.CHECKTRAP and bufferedaction.target.GetPosition and bufferedaction.target.prefab and aa_reactiveTraps then
                        local thepos = bufferedaction.target:GetPosition()
                        if thepos then
                            forceResetTrap = {
                                bufferedaction.target.prefab,
                                thepos
                            }
                            doTimeDelay = GetTime() + 0.75
                        end
                    end
                end
                    
                return bufferedaction
            end
        
            --[[
            if playercontroller.autoequip_lastequipped then
                -- playercontroller.inst.components.locomotor:PushAction(BufferedAction(playercontroller.inst, nil, ACTIONS.EQUIP, playercontroller.autoequip_lastequipped), true)
                if type(layercontroller.autoequip_lastequipped) == "string" and not GetInventory(playercontroller.inst):IsFull() then
                    --playercontroller.inst.components.locomotor:PushAction(BufferedAction(playercontroller.inst, nil, ACTIONS.UNEQUIP, GetInventory(playercontroller.inst):GetEquippedItem(EQUIPSLOTS.HANDS)), true)
                    DoUnequip(playercontroller)
                    playercontroller.inst.autoequip_prioNextTarget = nil
                elseif type(layercontroller.autoequip_lastequipped) == "table" then
                    --playercontroller.inst.components.locomotor:PushAction(BufferedAction(playercontroller.inst, nil, ACTIONS.EQUIP, playercontroller.autoequip_lastequipped), true)
                    DoEquip(playercontroller.inst,playercontroller.autoequip_lastequipped)
                    playercontroller.inst.autoequip_prioNextTarget = nil
                end
                playercontroller.autoequip_lastequipped = nil
            end
            ]]
        end
    end

    local typies = {
        "doer",
        "target",
        "initialtargetowner",
        "action",
        "invobject",
        "doerownsobject",
        "pos",
        "rotation",
        "onsuccess",
        "onfail",
        "recipe",
        "options",
        "distance",
        "forced",
        "autoequipped",
        "skin"
    }

    local function DoAction(playercontroller, bufferedaction,...)
        if not bufferedaction then return end
        if not bufferedaction.action then return end
        if bufferedaction.action == ACTIONS.ATTACK and ae_weapons and ae_weapons > 0 then
            AutoEquipBestWeapon(playercontroller, bufferedaction.target or nil, TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_ATTACK), bufferedaction)
            return
        end
        
        if letsDoDebug then
            print("\n-------------------------------------\n",playercontroller,bufferedaction,bufferedaction.action.id)
            for k,v in pairs(bufferedaction) do
                print("-",k,v)
            end
        end
        
        if bufferedaction.action == ACTIONS.BUILD and bufferedaction.mod_name and bufferedaction.mod_name == "a-a" then
            local inst = playercontroller.inst
            if inst.replica and inst.replica.builder and inst.replica.builder.CanBuild and inst.replica.builder.MakeRecipeFromMenu and inst.replica.builder:KnowsRecipe(bufferedaction.recipe) and inst.replica.builder:CanBuild(bufferedaction.recipe) then
                inst.replica.builder:MakeRecipeFromMenu(AllRecipes[bufferedaction.recipe])
                return
            end
        end
        
        if bufferedaction.action == ACTIONS.REPAIR and bufferedaction.mod_name and bufferedaction.mod_name == "a-a" then
            if not playercontroller.ismastersim then
                local position = playercontroller.inst:GetPosition()
                local mouseover = bufferedaction.target
                local controlmods = playercontroller:EncodeControlMods()
                if playercontroller:CanLocomote() then
                    if letsDoDebug then print("Ran shit") end
                    bufferedaction.mod_name = ""
                    bufferedaction.preview_cb = function()
                        --SendRPCToServer(RPC.RightClick, bufferedaction.action.code, position.x, position.z, mouseover, isreleased, controlmods, nil, bufferedaction.action.mod_name)
                        SendRPCToServer(RPC.ControllerUseItemOnSceneFromInvTile, bufferedaction.action.code, bufferedaction.invobject, bufferedaction.target, nil)
                    end
                    
                    
                    --SendRPCToServer(RPC.ControllerUseItemOnSceneFromInvTile, bufferedaction.action.code, bufferedaction.invobject, bufferedaction.target, bufferedaction.action.mod_name)
                    -- DoAction(playercontroller,bufferedaction)
                    --playercontroller:DoAction(bufferedaction)
                    return bufferedaction
                end
            end
        end
        
        if ( bufferedaction.action == ACTIONS.ADDFUEL or bufferedaction.action == ACTIONS.ADDWETFUEL ) and bufferedaction.mod_name and bufferedaction.mod_name == "a-a" then
            if not playercontroller.ismastersim then
                local position = playercontroller.inst:GetPosition()
                local mouseover = bufferedaction.target
                local controlmods = playercontroller:EncodeControlMods()
                if playercontroller:CanLocomote() then
                    if letsDoDebug then print("Ran shit") end
                    bufferedaction.mod_name = ""
                    bufferedaction.preview_cb = function()
                        --SendRPCToServer(RPC.RightClick, bufferedaction.action.code, position.x, position.z, mouseover, isreleased, controlmods, nil, bufferedaction.action.mod_name)
                        SendRPCToServer(RPC.ControllerUseItemOnSceneFromInvTile, bufferedaction.action.code, bufferedaction.invobject, bufferedaction.target, nil)
                    end
                    
                    
                    --SendRPCToServer(RPC.ControllerUseItemOnSceneFromInvTile, bufferedaction.action.code, bufferedaction.invobject, bufferedaction.target, bufferedaction.action.mod_name)
                    -- DoAction(playercontroller,bufferedaction)
                    --playercontroller:DoAction(bufferedaction)
                    return bufferedaction
                end
            end
        end
        
        if bufferedaction.action == ACTIONS.COOK and bufferedaction.mod_name and bufferedaction.mod_name == "a-a" then
            if not playercontroller.ismastersim then
                local position = playercontroller.inst:GetPosition()
                local mouseover = bufferedaction.target
                local controlmods = playercontroller:EncodeControlMods()
                if playercontroller:CanLocomote() then
                    if letsDoDebug then print("Ran shit") end
                    bufferedaction.mod_name = ""
                    bufferedaction.preview_cb = function()
                        --SendRPCToServer(RPC.RightClick, bufferedaction.action.code, position.x, position.z, mouseover, isreleased, controlmods, nil, bufferedaction.action.mod_name)
                        SendRPCToServer(RPC.ControllerUseItemOnSceneFromInvTile, bufferedaction.action.code, bufferedaction.invobject, bufferedaction.target, nil)
                    end
                    
                    
                    --SendRPCToServer(RPC.ControllerUseItemOnSceneFromInvTile, bufferedaction.action.code, bufferedaction.invobject, bufferedaction.target, bufferedaction.action.mod_name)
                    -- DoAction(playercontroller,bufferedaction)
                    --playercontroller:DoAction(bufferedaction)
                    return bufferedaction
                end
            end
        end
        
        if not bufferedaction.autoequip then return end
        if not bufferedaction.invobject then return end
        if playercontroller.inst and GetInventory and GetInventory(playercontroller.inst) and GetInventory(playercontroller.inst).GetEquippedItem and GetInventory(playercontroller.inst):GetEquippedItem(EQUIPSLOTS.HANDS) and GetInventory(playercontroller.inst):GetEquippedItem(EQUIPSLOTS.HANDS) == bufferedaction.invobject then return end
        AutoEquipItem(playercontroller, bufferedaction)
    end

    -- attached to playercontroller.DoAttackButton
    local function DoAttackButton(playercontroller,retarget)
        local isForced = TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_ATTACK)
        local target = playercontroller:GetAttackTarget(isForced, retarget, retarget ~= self:GetCombatTarget())
        if target and playercontroller.inst.replica.combat.target ~= target and ae_weapons and ae_weapons > 0 then
            local bufferedaction = BufferedAction(playercontroller.inst, target, ACTIONS.ATTACK)
            AutoEquipBestWeapon(playercontroller, target, isForced, bufferedaction)
            playercontroller.inst.components.locomotor:PushAction(bufferedaction, true)
        end
    end

    -- attached to playercontroller.GetClickActions
    local function GetClickActions(playeractionpicker,position, target, actions)
        if not target then return actions end
        if not actions then return actions end
        if TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then return actions end
        local action
        -- print("Getting info...",target,actions)
        for k,v in ipairs(actions) do
            if v.action == ACTIONS.ATTACK then
                action = GetAction(playeractionpicker.inst, target, ACTIONS.NET)
            end
            if not action and v.action == ACTIONS.ATTACK then
                action = GetAction(playeractionpicker.inst, target, ACTIONS.NET)
            end
            if not action and (v.action == ACTIONS.LOOKAT or v.action == ACTIONS.WALKTO) then
                --print("Check for chop")
                --print("Checking...",playeractionpicker.inst, target, ACTIONS.CHOP)
                action = GetAction(playeractionpicker.inst, target, ACTIONS.CHOP)
            end
            if not action and (v.action == ACTIONS.LOOKAT or v.action == ACTIONS.WALKTO) then
                action = GetAction(playeractionpicker.inst, target, ACTIONS.MINE)
            end
            if not action and (v.action == ACTIONS.LOOKAT or v.action == ACTIONS.WALKTO) and ACTIONS.HACK then
                action = GetAction(playeractionpicker.inst, target, ACTIONS.HACK)
            end
            if action then
                actions[k] = action
                action = nil
            end
        end
        
        --print("End result:", action, actions)
        return actions
    end

    local function CanRepairWall( inst, target )
        if( not inst or not target or not GetInventory(inst) ) then return false end
        if( target and target.replica and target.replica._ and target.replica._.health and target.replica._.health._isnotfull and target.replica._.health._isnotfull.value and target.replica._.health._isnotfull:value() ~= true ) then return false end
        
        --local mat = ( target:HasTag("moonrock") and "moonrock" ) or ( target:HasTag("ruins") and "ruins" ) or ( target:HasTag("stone") and "stone" ) or ( target:HasTag("wood") and "wood" ) or ( target:HasTag("grass") and "grass" ) or nil
        local mat = ( target:HasTag("moonrock") and "moonrock" ) or ( target:HasTag("ruins") and "ruins" ) or ( target:HasTag("stone") and "stone" ) or ( target:HasTag("wood") and "wood" ) or ( target:HasTag("grass") and "hay" ) or nil
        if not mat then return false end
        
        local wallitem = CustomFindItem(inst, GetInventory(inst), function(itm) return itm.prefab and itm.prefab == ("wall_"..mat.."_item") end)
        if not wallitem then return false end
        
        
        return wallitem
    end

    local function CanFeedFire( inst, target )
        if( not inst or not target or not GetInventory(inst) or ( not aa_refuelfires or aa_refuelfires < 1 ) ) then return false end
        
        local settin = aa_refuelfires
        
        local preferred = {
            "log",
            "charcoal",
            "twigs",
            "cutgrass"
        }
        
        local fuelitem
        
        fuelitem = CustomFindItem(inst, GetInventory(inst), function(itm)
            return itm.HasTag and itm:HasTag("BURNABLE_fuel") and itm.prefab and itm.prefab == (preferred and preferred[settin] or "NA")
        end)
        
        if not fuelitem then
            fuelitem = CustomFindItem(inst, GetInventory(inst), function(itm)
                return itm.HasTag and itm:HasTag("BURNABLE_fuel") and itm.prefab and ( itm.prefab == "log"  )
            end)
        end
        
        if not fuelitem then
            fuelitem = CustomFindItem(inst, GetInventory(inst), function(itm)
                return itm.HasTag and itm:HasTag("BURNABLE_fuel") and itm.prefab and ( itm.prefab == "charcoal" )
            end)
        end
        
        if not fuelitem then
            fuelitem = CustomFindItem(inst, GetInventory(inst), function(itm)
                return itm.HasTag and itm:HasTag("BURNABLE_fuel") and itm.prefab and ( itm.prefab == "twigs" )
            end)
        end
        
        if not fuelitem then
            fuelitem = CustomFindItem(inst, GetInventory(inst), function(itm)
                return itm.HasTag and itm:HasTag("BURNABLE_fuel") and itm.prefab and ( itm.prefab == "cutgrass" )
            end)
        end
        
        if not fuelitem then
            fuelitem = CustomFindItem(inst, GetInventory(inst), function(itm)
                return itm.HasTag and itm:HasTag("BURNABLE_fuel")
            end)
        end
        
        if not fuelitem then return false end
        
        
        return fuelitem
    end

    -- attached to playercontroller.GetRightClickActions
    local function GetRightClickActions(playeractionpicker, position, target, actions)
        if not target then return actions end
        if not actions then return actions end
        if TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then return actions end
        
        local forceToFront = TheInput:IsControlPressed(41)
        
        local action
        for k,v in ipairs(actions) do
            if( ( v.action == ACTIONS.LOOKAT or v.action == ACTIONS.WALKTO or v.action == ACTIONS.PICK ) or forceToFront ) then
                action = GetAction(playeractionpicker.inst, target, ACTIONS.DIG, true)
            end
            if not action and ( target:HasTag("wall") and CanRepairWall(playeractionpicker.inst,target) and aa_repairwalls ) then
                action = BufferedAction(playeractionpicker.inst, target, ACTIONS.REPAIR, CanRepairWall(playeractionpicker.inst,target))
                action.mod_name = "a-a"
                --[[
                action.preview_cb = function()
                    SendRPCToServer(RPC.ControllerUseItemOnSceneFromInvTile, action.action.code, action.invobject, action.target, action.action.mod_name)
                end]]
            end
            if not action and ( target:HasTag("campfire") and CanFeedFire(playeractionpicker.inst,target) and ( aa_refuelfires and aa_refuelfires > 0 ) ) and not forceToFront then
                local available_fuel = CanFeedFire(playeractionpicker.inst,target)
                
                if available_fuel and available_fuel.replica and available_fuel.replica._ and available_fuel.replica._.inventoryitem and available_fuel.replica._.inventoryitem._iswet and available_fuel.replica._.inventoryitem._iswet:value() == true then
                    action = BufferedAction(playeractionpicker.inst, target, ACTIONS.ADDWETFUEL, available_fuel)
                    action.GetActionString = function()
                        return "Add Wet Fuel("..(available_fuel and available_fuel.name or "ERROR")..")"
                    end
                else
                    action = BufferedAction(playeractionpicker.inst, target, ACTIONS.ADDFUEL, available_fuel)
                    action.GetActionString = function()
                        return "Add Fuel("..(available_fuel and available_fuel.name or "ERROR")..")"
                    end
                end
                action.mod_name = "a-a"
                --[[
                action.preview_cb = function()
                    SendRPCToServer(RPC.ControllerUseItemOnSceneFromInvTile, action.action.code, action.invobject, action.target, action.action.mod_name)
                end]]
            end
            
            -- print("Debugging: "..tostring(not action).." "..tostring( target:HasTag("cookable") ).." - "..tostring( GLOBAL.FindEntity(playeractionpicker.inst, 6, function( ent ) return ent.HasTag and ent:HasTag("cooker") end, {}, TARGET_EXCLUDE_TAGS) ))
            --[[
            if not action and ( target:HasTag("cookable") and GLOBAL.FindEntity(playeractionpicker.inst, 6, function( ent ) return ent.HasTag and ent:HasTag("cooker") end, {}, TARGET_EXCLUDE_TAGS) ) then
                local available_fire = GLOBAL.FindEntity(playeractionpicker.inst, 6, function( ent2 ) return ent2.HasTag and ent2:HasTag("cooker") end, {}, TARGET_EXCLUDE_TAGS)
                
                if( available_fire ) then
                    action = BufferedAction(playeractionpicker.inst, available_fire, ACTIONS.COOK, target)
                    action.GetActionString = function()
                        return "Cook "..(target and target.name or "ERROR")
                    end
                    action.mod_name = "a-a"
                end
            end
            ]]
            if not action and ( ( v.action == ACTIONS.LOOKAT or v.action == ACTIONS.WALKTO or v.action == ACTIONS.PICK ) or forceToFront ) then
                action = GetAction(playeractionpicker.inst, target, ACTIONS.HAMMER, true)
            end
            if action then
                actions[k] = action
                action = nil
            end
        end
        
        return actions
    end

    --[[
    local function OnPlayerLoaded( ply )

        ply:DoTaskInTime( 1, function()
        
            print("Loading player...")

            ply:ListenForEvent("finishedwork", function(inst, data)
                if( data and data.action and data.action == ACTIONS.DIG and TheInput:IsControlPressed(GLOBAL.CONTROL_ACTION) ) then
                    inst:DoTaskInTime( 0, function()
                        if inst.components.playercontroller.autoequip_lastequipped then
                            -- inst.components.locomotor:PushAction(BufferedAction(inst, nil, ACTIONS.EQUIP, inst.components.playercontroller.autoequip_lastequipped), true)
                            if type(inst.components.playercontroller.autoequip_lastequipped) == "string" and not GetInventory(inst):IsFull() then
                                inst.components.locomotor:PushAction(BufferedAction(inst, nil, ACTIONS.UNEQUIP, GetInventory(inst):GetEquippedItem(EQUIPSLOTS.HANDS)), true)
                            elseif type(inst.components.playercontroller.autoequip_lastequipped) == "table" then
                                inst.components.locomotor:PushAction(BufferedAction(inst, nil, ACTIONS.EQUIP, inst.components.playercontroller.autoequip_lastequipped), true)
                            end
                            inst.components.playercontroller.autoequip_lastequipped = nil
                        end
                    end)
                end
            end)
            
            print("Player fully setup!")
        
        end)
    end

    AddPlayerPostInit(OnPlayerLoaded)
    ]]

    local originalFunctions = {}
    local originalFunctionsPicker = {}

    local function addPlayeractionpicker( inst )
        if inst.inst==GLOBAL.ThePlayer then
            local controller = inst
            
            originalFunctionsPicker.GetLeftClickActions = controller.GetLeftClickActions;
            originalFunctionsPicker.GetRightClickActions = controller.GetRightClickActions;

            controller.GetLeftClickActions = function(self, position, target,...)
                local actions = originalFunctionsPicker.GetLeftClickActions(self,position,target,...)
                local successflag, retvalue = pcall(GetClickActions, self, position, target, actions)
                if not successflag then
                    if letsDoDebug then print(retvalue) end
                    return actions
                else
                    return retvalue
                end
            end

            controller.GetRightClickActions = function(self, position, target,...)
                local actions = originalFunctionsPicker.GetRightClickActions(self,position,target,...)
                local successflag, retvalue = pcall(GetRightClickActions, self, position, target, actions)
                if not successflag then
                    if letsDoDebug then print(retvalue) end
                    return actions
                else
                    return retvalue
                end
            end
        end
    end
    AddClassPostConstruct("components/playeractionpicker", addPlayeractionpicker)

    local shouldToggleEnabled = nil
    local function addPlayerController( inst )
        if inst.inst==GLOBAL.ThePlayer then
            local controller = inst

            originalFunctions.OnUpdate = controller.OnUpdate;
            originalFunctions.GetActionButtonAction = controller.GetActionButtonAction;
            originalFunctions.DoAction = controller.DoAction;
            originalFunctions.DoAttackButton = controller.DoAttackButton;

            -- Ooooooo

            controller.OnUpdate = function(salf, dt,...)
                originalFunctions.OnUpdate(salf,dt,...)
                if(shouldToggleEnabled ~= nil) then
                    ToggleModEnabled(salf,shouldToggleEnabled);
                    shouldToggleEnabled=nil;
                    return;
                end
                if(ae_enablemod) then
                    local successflag, retvalue = pcall(OnUpdate, salf, dt,...)
                    if not successflag then
                        if letsDoDebug then print(retvalue) end
                    end
                end
            end

            controller.GetActionButtonAction = function(salf,forced,...)
                --print("Action button")
                local bufferedaction = originalFunctions.GetActionButtonAction(salf,forced or salf.autoequip_prioNextTarget or nil,...)
                local successflag, retvalue = pcall(GetActionButtonAction, salf, forced or salf.autoequip_prioNextTarget or nil, bufferedaction,...)
                if not successflag then
                    if letsDoDebug then print("Ran default ABA with: ",bufferedaction) end
                    return bufferedaction
                else
                    if letsDoDebug then print("Ran custom ABA with: ",retvalue) end
                    return retvalue
                end
            end

            controller.DoAction = function(salf, bufferedaction,...)
                --print("Action")
                local successflag, retvalue = pcall(DoAction, salf, bufferedaction,...)
                if( successflag and retvalue ) then
                    if letsDoDebug then print("Worked, sending:", retvalue) end
                    if( retvalue and type(retvalue) == "string" and retvalue == "empty" ) then
                        return originalFunctions.DoAction(salf,nil,...)
                    else
                        return originalFunctions.DoAction(salf,retvalue,...)
                    end
                else
                    if letsDoDebug then print("Failed") end
                    return originalFunctions.DoAction(salf,bufferedaction,...)
                end
            end

            controller.DoAttackButton = function(salf,...)
                local successflag, retvalue = pcall(DoAttackButton, salf,...)
                if not successflag then
                    if letsDoDebug then print(retvalue) end
                end
                return originalFunctions.DoAttackButton(salf,...)
            end
        end
    end
    AddClassPostConstruct("components/playercontroller", addPlayerController)

    function ToggleModEnabled( controller, state )

        local playctrl = controller.inst.components.playercontroller
        local playpick = controller.inst.components.playeractionpicker

        if(state == true) then
        
            playctrl.GetActionButtonAction = function(salf,forced,...)
                --print("Action button")
                local bufferedaction = originalFunctions.GetActionButtonAction(salf,forced or salf.autoequip_prioNextTarget or nil,...)
                local successflag, retvalue = pcall(GetActionButtonAction, salf, forced or salf.autoequip_prioNextTarget or nil, bufferedaction,...)
                if not successflag then
                    -- print(retvalue)
                    return bufferedaction
                else
                    return retvalue
                end
            end

            playctrl.DoAction = function(salf, bufferedaction,...)
                --print("Action")
                local successflag, retvalue = pcall(DoAction, salf, bufferedaction,...)
                if( successflag and retvalue ) then
                    if letsDoDebug then print("Worked, sending:", retvalue) end
                    if( retvalue and type(retvalue) == "string" and retvalue == "empty" ) then
                        return originalFunctions.DoAction(salf,nil,...)
                    else
                        return originalFunctions.DoAction(salf,retvalue,...)
                    end
                else
                    if letsDoDebug then print("Failed") end
                    return originalFunctions.DoAction(salf,bufferedaction,...)
                end
            end

            playctrl.DoAttackButton = function(salf,...)
                local successflag, retvalue = pcall(DoAttackButton, salf,...)
                if not successflag then
                    if letsDoDebug then print(retvalue) end
                end
                return originalFunctions.DoAttackButton(salf,...)
            end
            
            playpick.GetLeftClickActions = function(self, position, target,...)
                local actions = originalFunctionsPicker.GetLeftClickActions(self,position,target,...)
                local successflag, retvalue = pcall(GetClickActions, self, position, target, actions)
                if not successflag then
                    if letsDoDebug then print(retvalue) end
                    return actions
                else
                    return retvalue
                end
            end

            playpick.GetRightClickActions = function(self, position, target,...)
                local actions = originalFunctionsPicker.GetRightClickActions(self,position,target,...)
                local successflag, retvalue = pcall(GetRightClickActions, self, position, target, actions)
                if not successflag then
                    if letsDoDebug then print(retvalue) end
                    return actions
                else
                    return retvalue
                end
            end
        
        else
        
            playctrl.GetActionButtonAction = originalFunctions.GetActionButtonAction

            playctrl.DoAction = originalFunctions.DoAction

            playctrl.DoAttackButton = originalFunctions.DoAttackButton
            
            playpick.GetLeftClickActions = originalFunctionsPicker.GetLeftClickActions

            playpick.GetRightClickActions = originalFunctionsPicker.GetRightClickActions
        
        end

    end

    -- Activation thingies

    --[[
    local function LoadScript(filename)
        local fn = GLOBAL.loadfile("scripts/"..filename..".lua")
        if not fn then return end
        local successflag, retvalue = GLOBAL.pcall(fn)
        if successflag then
            GLOBAL.GetPlayer().SoundEmitter:PlaySound("dontstarve/HUD/collect_newitem")
        else
            print(retvalue)
        end
    end

    local function OnSimPostInit(player)
        LoadScript("auto_equip")
    end

    AddSimPostInit(OnSimPostInit)

    ]]

    -- require "auto_equip";

    -- local pcontoller = require "components/playeractionpicker";



    local function GetPickupAction(target, tool)
        if target:HasTag("smolder") then
            return ACTIONS.SMOTHER
        elseif tool ~= nil then
            for k, v in pairs(GLOBAL and GLOBAL.TOOLACTIONS or {}) do
                if target:HasTag(k.."_workable") then
                    if tool:HasTag(k.."_tool") then
                        return ACTIONS[k]
                    end
                    break
                end
            end
        end
        if target:HasTag("trapsprung") then
            return ACTIONS.CHECKTRAP
        elseif target:HasTag("inactive") then
            return ACTIONS.ACTIVATE
        elseif target.replica.inventoryitem ~= nil and
            target.replica.inventoryitem:CanBePickedUp() and
            not (target:HasTag("catchable") or target:HasTag("fire")) then
            return ACTIONS.PICKUP 
        elseif target:HasTag("pickable") and not target:HasTag("fire") then
            return ACTIONS.PICK 
        elseif target:HasTag("harvestable") then
            return ACTIONS.HARVEST
        elseif target:HasTag("readyforharvest") or
            (target:HasTag("notreadyforharvest") and target:HasTag("withered")) then
            return ACTIONS.HARVEST
        elseif target:HasTag("dried") and not target:HasTag("burnt") then
            return ACTIONS.HARVEST
        elseif target:HasTag("donecooking") and not target:HasTag("burnt") then
            return ACTIONS.HARVEST
        elseif tool ~= nil and tool:HasTag("unsaddler") and target:HasTag("saddled") and (not target.replica.health or not target.replica.health:IsDead()) then
            return ACTIONS.UNSADDLE
        elseif tool ~= nil and tool:HasTag("brush") and target:HasTag("brushable") and (not target.replica.health or not target.replica.health:IsDead()) then
            return ACTIONS.BRUSH
        end
        --no action found
    end

    local TARGET_EXCLUDE_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }
    local PICKUP_TARGET_EXCLUDE_TAGS = { "catchable" }
    local HAUNT_TARGET_EXCLUDE_TAGS = { "haunted", "catchable" }
    for i, v in ipairs(TARGET_EXCLUDE_TAGS) do
        table.insert(PICKUP_TARGET_EXCLUDE_TAGS, v)
        table.insert(HAUNT_TARGET_EXCLUDE_TAGS, v)
    end

    local CanEntitySeeTarget = GLOBAL.CanEntitySeeTarget

    Backup_GetActionButtonAction = function(self, force_target, ignore_targets, musthave, donthave)
        --Don't want to spam the action button before the server actually starts the buffered action
        --Also check if playercontroller is enabled
        --Also check if force_target is still valid
        if (not self.ismastersim and (self.remote_controls[CONTROL_ACTION] or 0) > 0) or
            not self:IsEnabled() or
            (force_target ~= nil and (not force_target.entity:IsVisible() or force_target:HasTag("INLIMBO") or force_target:HasTag("NOCLICK"))) then
            --"DECOR" should never change, should be safe to skip that check
            return

        elseif self.actionbuttonoverride ~= nil then
            local buffaction, usedefault = self.actionbuttonoverride(self.inst, force_target)
            if not usedefault or buffaction ~= nil then
                return buffaction
            end

        elseif not self:IsDoingOrWorking() then
            local force_target_distsq = force_target ~= nil and self.inst:GetDistanceSqToInst(force_target) or nil

            if self.inst:HasTag("playerghost") then
                --haunt
                if force_target == nil then
                    local target = FindEntity(self.inst, self.directwalking and 3 or 6, ValidateHaunt, nil, HAUNT_TARGET_EXCLUDE_TAGS)
                    if CanEntitySeeTarget(self.inst, target) then
                        return BufferedAction(self.inst, target, ACTIONS.HAUNT)
                    end
                elseif force_target_distsq <= (self.directwalking and 9 or 36) and
                    not (force_target:HasTag("haunted") or force_target:HasTag("catchable")) and
                    ValidateHaunt(force_target) then
                    return BufferedAction(self.inst, force_target, ACTIONS.HAUNT)
                end
                return
            end

            local tool = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            --bug catching (has to go before combat)
            if tool ~= nil and tool:HasTag(ACTIONS.NET.id.."_tool") then
                if force_target == nil then
                    local target = FindEntity(self.inst, 5, ValidateBugNet, { "_health", ACTIONS.NET.id.."_workable" }, TARGET_EXCLUDE_TAGS)
                    if CanEntitySeeTarget(self.inst, target) then
                        return BufferedAction(self.inst, target, ACTIONS.NET, tool)
                    end
                elseif force_target_distsq <= 25 and
                    force_target.replica.health ~= nil and
                    ValidateBugNet(force_target) and
                    force_target:HasTag(ACTIONS.NET.id.."_workable") then
                    return BufferedAction(self.inst, force_target, ACTIONS.NET, tool)
                end
            end

            --catching
            if self.inst:HasTag("cancatch") then
                if force_target == nil then
                    local target = FindEntity(self.inst, 10, nil, { "catchable" }, TARGET_EXCLUDE_TAGS)
                    if CanEntitySeeTarget(self.inst, target) then
                        return BufferedAction(self.inst, target, ACTIONS.CATCH)
                    end
                elseif force_target_distsq <= 100 and
                    force_target:HasTag("catchable") then
                    return BufferedAction(self.inst, force_target, ACTIONS.CATCH)
                end
            end

            --unstick
            if force_target == nil then
                local target = FindEntity(self.inst, self.directwalking and 3 or 6, nil, { "pinned" }, TARGET_EXCLUDE_TAGS)
                if CanEntitySeeTarget(self.inst, target) then
                    return BufferedAction(self.inst, target, ACTIONS.UNPIN)
                end
            elseif force_target_distsq <= (self.directwalking and 9 or 36) and
                force_target:HasTag("pinned") then
                return BufferedAction(self.inst, force_target, ACTIONS.UNPIN)
            end

            --misc: pickup, tool work, smother
            if force_target == nil then
                local pickup_tags =
                {
                    "_inventoryitem",
                    "pickable",
                    "donecooking",
                    "readyforharvest",
                    "notreadyforharvest",
                    "harvestable",
                    "trapsprung",
                    "dried",
                    "inactive",
                    "smolder",
                    "saddled",
                    "brushable",
                }
                if tool ~= nil then
                    for k, v in pairs(TOOLACTIONS) do
                        if tool:HasTag(k.."_tool") then
                            table.insert(pickup_tags, k.."_workable")
                        end
                    end
                end
                local x, y, z = self.inst.Transform:GetWorldPosition()
                
                local exclude = PICKUP_TARGET_EXCLUDE_TAGS
                if donthave and type(donthave) == "table" then
                    for k,v in pairs(donthave) do
                        table.insert(exclude,v)
                    end
                end
                
                local ents = TheSim:FindEntities(x, y, z, self.directwalking and 3 or 6, musthave or nil, exclude, pickup_tags)
                for i, v in ipairs(ents) do
                    if v ~= self.inst and v.entity:IsVisible() and CanEntitySeeTarget(self.inst, v) and ( ignore_targets == nil or ( ignore_targets ~= nil and not DoMatch(ignore_targets, v) ) ) then
                        local action = GetPickupAction(v, tool)
                        if action ~= nil then
                            return BufferedAction(self.inst, v, action, action ~= ACTIONS.SMOTHER and tool or nil)
                        end
                    end
                end
            elseif force_target_distsq <= (self.directwalking and 9 or 36) then
                local action = GetPickupAction(force_target, tool)
                if action ~= nil then
                    return BufferedAction(self.inst, force_target, action, action ~= ACTIONS.SMOTHER and tool or nil)
                end
            end
        end
    end

    local STARTSCALE = 0.25
    local NORMSCALE = 1
    local controls = nil

    local KEYBOARDTOGGLEKEY = GetModConfigData("autoequipopeningamesettings") or "C"
    if type(KEYBOARDTOGGLEKEY) == "string" then
        KEYBOARDTOGGLEKEY = KEYBOARDTOGGLEKEY:lower():byte()
    end

    local function IsDefaultScreen()
        return GLOBAL.TheFrontEnd:GetActiveScreen().name:find("HUD") ~= nil
            and not(GLOBAL.ThePlayer.HUD:IsControllerCraftingOpen() or GLOBAL.ThePlayer.HUD:IsControllerInventoryOpen())
    end

    local function ShowSettingsMenu( controls )
        if type(GLOBAL.ThePlayer) ~= "table" or type(GLOBAL.ThePlayer.HUD) ~= "table" then return end
        if not IsDefaultScreen() then return end
        
        GLOBAL.TheFrontEnd:PushScreen(AASC(controls))
    end

    local function HideGestureWheel(delay_focus_loss)
        if type(GLOBAL.ThePlayer) ~= "table" or type(GLOBAL.ThePlayer.HUD) ~= "table" then return end
        
        if delay_focus_loss and controls.aas.activegesture then
            --delay a little on controllers to prevent canceling the emote by moving
            GLOBAL.ThePlayer:DoTaskInTime(0.5, function() SetModHUDFocus("AAS", false) end)
        else
            SetModHUDFocus("AAS", false)
        end
        
        controls.aas:Hide()
        controls.aas.inst.UITransform:SetScale(STARTSCALE, STARTSCALE, 1)
        
        if not IsDefaultScreen() then return end
        
        if controls.aas.activegesture then
            GLOBAL.TheNet:SendSlashCmdToServer(controls.aas.activegesture, true)
        end
    end

    local function UpdateSettings()

        if(ae_enablemod ~= (GetModConfigData("ae_enablemod") == 1 or false)) then
            ae_enablemod = (GetModConfigData("ae_enablemod") == 1 or false);
            shouldToggleEnabled = (GetModConfigData("ae_enablemod") == 1 or false);
        end
        ae_ignoreRestrictions = GetModConfigData("autoequipignorerestrictions") or 1
        ae_weapons = GetModConfigData("ae_equipweapon") or 1
        ae_huntwithboomerang = GetModConfigData("ae_boomcritters") or 0
        ae_givelight = GetModConfigData("ae_lightindark") or 0

        aa_canCraftToolsAutomatically = GetModConfigData("ae_crafttools") > 0 or false
        aa_useGoldenTools = GetModConfigData("ae_crafttools") > 1 or false

        aa_ignoreTraps = false --GetModConfigData("autoequipignoretraps") and GetModConfigData("autoequipignoretraps") > 0 or false
        aa_reactiveTraps = false --GetModConfigData("autoequipreactivatetraps") and GetModConfigData("autoequipreactivatetraps") > 0 or false
        aa_replantTrees = GetModConfigData("ae_replanttrees") and GetModConfigData("ae_replanttrees") > 0 or false
        
        aa_refuelfires = GetModConfigData("ae_refuelfires") or false
        aa_repairwalls = GetModConfigData("ae_repairwalls") and GetModConfigData("ae_repairwalls") > 0 or false
        
        aa_completelyignore = GetModConfigData("ae_alwaysignoresaps") and GetModConfigData("ae_alwaysignoresaps") > 0 or false
        
        print("Settings have been updated!")
    end

    local handlers_applied = false
    local function AddAASettings( self )
        controls = self -- this just makes controls available in the rest of the modmain's functions
        inst = GLOBAL.ThePlayer
        --[[
        controls.aas = controls:AddChild(AAS(controls))
        local screenwidth, screenheight = GLOBAL.TheSim:GetScreenSize()
        centerx = screenwidth/2
        centery = screenheight/2
        controls.aas:SetPosition(centerx, centery, 0)
        controls.aas.inst.UITransform:SetScale(STARTSCALE, STARTSCALE, 1)
        controls.aas:Hide()
        ]]
        
        if not handlers_applied then
            -- Keyboard controls
            GLOBAL.TheInput:AddKeyDownHandler(KEYBOARDTOGGLEKEY, function()
                if TheInput and TheInput.IsControlPressed and TheInput:IsControlPressed(41) then
                    local bestweapon = GetInventory(inst):GetEquippedItem(EQUIPSLOTS.HANDS)
                    if( bestweapon and ( not hasPreferedWeapon or hasPreferedWeapon ~= bestweapon.prefab ) ) then
                        hasPreferedWeapon = bestweapon.prefab
                        inst.components.talker:Say("I'll use this "..tostring(bestweapon.name or "N/A").." as my primary weapon.")
                    elseif( bestweapon and hasPreferedWeapon and hasPreferedWeapon == bestweapon.prefab ) then
                        hasPreferedWeapon = nil
                        inst.components.talker:Say("I'll now use whatever strongest, standard weapon that I have.")
                    end
                else
                    ShowSettingsMenu(controls)
                end
            end)
            --GLOBAL.TheInput:AddKeyUpHandler(KEYBOARDTOGGLEKEY, HideGestureWheel)
            
            -- Controller controls
            -- This is pressing the left stick in
            -- CONTROL_MENU_MISC_3 is the same thing as CONTROL_OPEN_DEBUG_MENU
            -- CONTROL_MENU_MISC_4 is the right stick click
            --[[
            GLOBAL.TheInput:AddControlHandler(GLOBAL.CONTROL_MENU_MISC_3, function(down)
                if down then
                    ShowGestureWheel(controls)
                else
                    --HideGestureWheel(true)
                end
            end)
            ]]
            handlers_applied = true
        end
        
        local OldOnUpdate = controls.OnUpdate
        local function OnUpdate(...)
            OldOnUpdate(...)
            if controls.updatesettings then
                controls.updatesettings = false
                UpdateSettings()
            end
        end
        controls.OnUpdate = OnUpdate
        
    end


    AddClassPostConstruct( "widgets/controls", AddAASettings )
end