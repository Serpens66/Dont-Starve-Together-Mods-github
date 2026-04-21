if not (GLOBAL.TheNet:GetIsServer() or GLOBAL.TheNet:IsDedicated()) then 
	return
end


modimport("customsettings")

GLOBAL.TUNING.SPIDER_DROPPER_HEALTH = 400 -- in spider.lua the dropper uses the tuning value of spider_warrior -> make it independend

-- Add prefab-name into prefabnamelist and name-values into namevalueslist
-- if TUNING value is based on the prefab like MINOTAUR_HEALTH or MINOTAUR[HEALTH], you are done.
-- if TUNING value is based on that name, put the name below into tuninghealth_basedonname_names list.
-- if TUNING value is neither the prefab nor the name (eg. deciduoustree uses the TUNING DECIDUOUS_CHOPS_MONSTER), put prefab-tuning into tuninghealth_special
-- if you have several mobs, eg. Warg which should the same setting/health, but have different prefabs, add each prefab, but with the same name (and if health is based on name, put it into tuninghealth_basedonname_names, see Warg as example)
-- if you want several mobs to use the same scaling, like buzzard and mutatedbuzzard_gestalt (all using the buzzard scaling), then use adjust_ents_with_same_ratio
-- if you want other TUNING values (not mobs!), like phase-health or boosts be adjusted by the same scaling, use adjust_TUNING_with_same_ratio list
-- shadow_rook, klaus and other who have different phases while still having the same prefab get a list assigned to the prefab.
-- bosses and other mobs that only spawn for the fight and are problematic when they change health during fight can be put into "no_ents_health_change_prefabs" so they do not change health during a fight when a player joins/leaves. But for most "phase change on health change" live health changes work fine without triggering a phase change. But eg. crabking was to complicated otherwise.
-- Luckily the DST devs meanwhile use "healthtrigger" for new mobs which should have different phases based on health. This uses percentage instead of hardcoded health values, which makes everything much easier.
local prefabnamelist = {minotaur='AncGuardian', archive_centipede='Ancient_Sentrypede', antlion='Antlion', bearger='Bearger', mutatedbearger='Bearger_Armored', beefalo='Beefalo', beeguard='Beeguard', beequeen='Beequeen',
 lunarthrall_plant='Brightshade', lunarthrall_plant_vine_end='Brightshade_Vine', buzzard='Buzzard', alterguardian_phase1="Celestial_Champion1", alterguardian_phase2="Celestial_Champion2", alterguardian_phase3="Celestial_Champion3",
 alterguardian_phase1_lunarrift='Celestial_Revenant', alterguardian_phase4_lunarrift='Celestial_Scion', knight='Clockworks', knight_nightmare='Clockworks', bishop='Clockworks', bishop_nightmare='Clockworks', rook='Clockworks', rook_nightmare='Clockworks',
 crabking='Crabking', crabking_claw='Crabking_Claw', deer='Deer', deer_red='DeerGem', deer_blue='DeerGem', deerclops='Deerclops', mutateddeerclops='Deerclops_Crystal', dragonfly='Dragonfly', eyeofterror="Eye_of_Terror",
 eyeofterror_mini="Eye_of_Terror_Mini", twinofterror1="Eye_of_Terror_Twin1", twinofterror2="Eye_of_Terror_Twin2", spat='Ewecus', fused_shadeling='Fused_Shadeling', sharkboi='Frostjaw', gelblob="Icker", gnarwail='Gnarwail', grassgator="Grassgator", shadowthrall_hands="InkBlight_Jitters",shadowthrall_horns="InkBlight_Rasp",shadowthrall_mouth="InkBlight_Rictus",shadowthrall_wings="InkBlight_Shriek",
 klaus={'Klaus1','Klaus2'}, koalefant_summer='Koalefant', koalefant_winter='Koalefant', krampus='Krampus', lavae='Lavae', lordfruitfly='Lord_Fruit_Flies', ruinsnightmare='Lurking_Nightmare', malbatross='Malbatross', otter="Marotter", merm='Merm', moose='Moose', 
 mossling='Mosling', mushgnome='Mush_Gnome',  daywalker="Nightmare_Werepig", daywalker2="Nightmare_Werepig", chest_mimic_revealed="Ornery_Chest", pigguard='Pig_Guard', deciduoustree='Poisonedtree', powder_monkey='Powder_Monkey', prime_mate='Prime_Mate', rabbitking_passive='Rabbitking', rabbitking_aggressive='Rabbitking', rabbitking_lucky='Rabbitking', rabbitkingminion_bunnyman="Royal_Rabbit_Enforcer", rocky='RLobster', shark='Rockjaw', fruitdragon='Saladmander', waterplant='Sea_Weed', 
 shadow_bishop={'Shadow_Bishop1','Shadow_Bishop2','Shadow_Bishop3'}, shadow_knight={'Shadow_Knight1','Shadow_Knight2','Shadow_Knight3'},
 shadow_rook={'Shadow_Rook1','Shadow_Rook2','Shadow_Rook3'}, eyeturret='Shootius', stalker_atrium='Skeleton_A', stalker='Skeleton',
 stalker_forest='Skeleton', slurtle='Slurtle', spider_dropper='Spider_dropper', spider_healer='Spider_healer', spider_hider='Spider_hider', spider_spitter='Spider_spitter', spider_warrior='Spider_warrior', spiderqueen='Spiderqueen',
 tallbird='Tallbird', teenbird='Teenbird', tentacle_pillar='Tentacle_pillar', wagdrone_rolling='Terramite', toadstool='Toadstool', toadstool_dark='ToadstoolMisery', leif='Treeguard',
 lightninggoat='Voaltgoat', walrus='Walrus', wagboss_robot='W.A.R.B.O.T.', warg='Warg', claywarg='Warg', gingerbreadwarg='Warg', mutatedwarg='Warg_Possessed', pigman='Werepig', worm='Worm', worm_boss='Great_Depths_Worm'}
 
local namevalueslist = {AncGuardian={2500, 10000}, Ancient_Sentrypede={600, 1200}, Antlion={3000, 6000}, Bearger={3000, 6000}, Bearger_Armored={4000, 8000}, Beefalo={500, 1000}, Beeguard={100, 180},
 Beequeen={3000, 22500}, Brightshade={500, 1000}, Brightshade_Vine={100, 200}, Buzzard={125, 250}, Celestial_Champion1={2000, 10000}, Celestial_Champion2={2600, 13000}, Celestial_Champion3={2800, 14000},
 Celestial_Revenant={2000,8000}, Celestial_Scion={3500,16000}, Clockworks={300, 900}, Crabking={3000, 12000}, Crabking_Claw={100, 500}, Deer={350, 700}, DeerGem={750, 1500}, Deerclops={2000, 4000}, Deerclops_Crystal={3000,6000}, Dragonfly={3500, 27500}, 
 Eye_of_Terror={2000,5000}, Eye_of_Terror_Mini={150,200}, Eye_of_Terror_Twin1={4000,10000}, Eye_of_Terror_Twin2={4000,10000}, Ewecus={400, 800}, Fused_Shadeling={625, 1250}, Frostjaw={4000, 8000}, Gnarwail={500, 1000}, Grassgator={500, 1000}, Icker={300, 600}, InkBlight_Jitters={500, 1000}, InkBlight_Rasp={600, 1200}, InkBlight_Rictus={400, 800}, InkBlight_Shriek={400, 800}, Klaus1={2000, 10000}, Klaus2={5440, 27440}, Koalefant={500, 1000},
 Krampus={200, 300}, Lavae={250, 500}, Lord_Fruit_Flies={900, 1500}, Lurking_Nightmare={400, 850}, Malbatross={1500, 5000}, Marotter={175, 350}, Merm={250, 500}, Moose={3000, 6000}, Mosling={350, 525}, Mush_Gnome={300, 600}, Nightmare_Werepig={2000,10000}, Ornery_Chest={400,950},
 Pig_Guard={300, 600}, Poisonedtree={12, 18}, Powder_Monkey={100, 200}, Prime_Mate={200, 350}, Rabbitking={800, 2000}, Royal_Rabbit_Enforcer={150, 400},  RLobster={1500, 3000}, Rockjaw={500, 1000}, Saladmander={450, 900}, Sea_Weed={250, 500}, Shadow_Bishop1={250, 800},
 Shadow_Bishop2={800, 2500}, Shadow_Bishop3={2500, 7500}, Shadow_Knight1={300, 900}, Shadow_Knight2={900, 2700}, Shadow_Knight3={2700, 8100}, Shadow_Rook1={350, 1000},
 Shadow_Rook2={1000, 4000}, Shadow_Rook3={4000, 10000}, Shootius={1500, 3000}, Skeleton_A={6000, 16000}, Skeleton={2000, 4000}, Slurtle={600, 1200},
 Spider_dropper={200, 400}, Spider_healer={200, 400}, Spider_hider={150, 225}, Spider_spitter={175, 350}, Spider_warrior={200, 400}, Spiderqueen={1250, 2500}, Tallbird={400, 800}, Teenbird={300, 600}, Tentacle_pillar={500, 750}, Terramite={140, 280},
 Toadstool={7500, 52500}, ToadstoolMisery={11111, 99999}, Treeguard={2000, 3000}, Voaltgoat={350, 700}, Walrus={150, 300}, ['W.A.R.B.O.T.']={4500, 22500}, Warg={600, 1800}, Warg_Possessed={1500, 3000},  Werepig={350, 525}, Worm={450, 900}, Great_Depths_Worm={1500, 5000},}



local tuninghealth_basedonname_names = {"Koalefant","Pig_Guard","Werepig","Warg","Rabbitking"} -- if TUNING value is based on that name
 -- a list of prefab -> tuningkey and name -> tuningkey for mobs whose tuning key is not simply their prefab or name plus HEALTH
local tuninghealth_special = {lightninggoat="LIGHTNING_GOAT_HEALTH",deciduoustree="DECIDUOUS_CHOPS_MONSTER",DeerGem="DEER_GEMMED_HEALTH",
    twinofterror1="TWIN1_HEALTH",twinofterror2="TWIN2_HEALTH",bishop_nightmare="BISHOP_HEALTH",rook_nightmare="ROOK_HEALTH",knight_nightmare="KNIGHT_HEALTH",
    stalker_forest="STALKER_HEALTH",lunarthrall_plant_vine_end="LUNARTHRALL_PLANT_VINE_HEALTH",mutateddeerclops="MUTATED_DEERCLOPS_HEALTH",
    mutatedbearger="MUTATED_BEARGER_HEALTH",mutatedwarg="MUTATED_WARG_HEALTH",daywalker2="DAYWALKER_HEALTH",rabbitkingminion_bunnyman="RABBITKING_ABILITY_SUMMON_HP",
    chest_mimic_revealed="CHEST_MIMIC_HEALTH",}
local no_ents_health_change_prefabs = {"crabking","crabking_claw","crabking_mob","crabking_mob_knight"} -- for these prefabs we wont change the current/max health for existing entities, because it would be too complicated/would mess other things up. important for crabking/crabking_claw
  -- for prefabs in the list "no_ents_health_change_prefabs" we should check the lua file and check if they correctly use the save maxhealth on load, or if it is overwritten. Eg. Crabking executes in OnLoadPostPass socketitem() which sets the maxhealth based on an not yet updated TUNING value, which results in vanilla health when you exit and start the game again, while crabking is active (for other ents this is fixed via the Ents health changes)
  -- that is why we edit the OnLoadPostPass for crabking below, to use the saved maxhealth instead
-- the TUNING things in "adjust_TUNING_with_same_ratio" dont have their own setting, and we want to adjust them the same ratio like mob health
-- DONT add HEALTH from other mobs here, just things like different phase/Boosts and stuff like this
-- If you want to change the health from other mobs with the same ratio which are not listed in prefabnamelist, then add them to adjust_ents_with_same_ratio list instead
local adjust_TUNING_with_same_ratio = {
  alterguardian_phase2={"ALTERGUARDIAN_PHASE2_MAXHEALTH"}, -- has 2 different max hp. in modsettings we change STARTHEALTH value, but we will also change MAXHEALTH with the same ratio.
  alterguardian_phase3={"ALTERGUARDIAN_PHASE3_MAXHEALTH"},
  alterguardian_phase1={"ALTERGUARDIAN_PHASE1_SHIELDTRIGGER"}, -- ALTERGUARDIAN_PHASE1_SHIELDTRIGGER is the damage to take before using shield, its an absolute value -.- so we have to adjust it too
  crabking={"CRABKING_HEALTH_BONUS","CRABKING_REGEN","CRABKING_REGEN_BUFF","CRABKING_FREEZE_THRESHOLD",  -- adjust crabking related mobs/values with the same ratio like crabking itself
      "CRABKING_MOB_HEALTH","CRABKING_MOB_HEALTH_BONUS_MAXGEM","CRABKING_MOB_KNIGHT_HEALTH","CRABKING_ICEWALL_HEALTH",
      "CRABKING_ICEWALL_HEALTH_BONUS","CRABKING_ICEWALL_HEALTH_BONUS_MAXGEM"}, -- no_ents_health_change_prefabs , so no need to add to adjust_ents_with_same_ratio
  crabking_claw={"CRABKING_CLAW_HEALTH_BOOST","CRABKING_CLAW_HEALTH_BOOST_MAXGEM"},
  stalker_atrium={"STALKER_ATRIUM_PHASE2_HEALTH"}, -- also adjust STALKER_ATRIUM_PHASE2_HEALTH , because dst devs hardcoded this value instead of using healthrigger-precentage -.-
  merm={"MERM_HEALTH_REGEN_AMOUNT","MERM_HEALTH_KINGBONUS","MERM_GUARD_HEALTH","PUNY_MERM_HEALTH","MERM_LUNAR_GUARD_EXTRA_HEALTH","MERM_LUNAR_EXTRA_HEALTH"}, -- are here and not in adjust_ents_with_same_ratio, because the health of merms is calculated in UpdateDamageAndHealth , which we also call later.
}
local call_inst_fn_for_ents = {mermguard="UpdateDamageAndHealth",merm_lunar="UpdateDamageAndHealth", -- UpdateDamageAndHealth does not adjust current health, but is ok, since they regenerate
  mermguard_lunar="UpdateDamageAndHealth",merm_shadow="UpdateDamageAndHealth",mermguard_shadow="UpdateDamageAndHealth",
}

local adjust_ents_with_same_ratio = {
  -- mutatedbearger={ratio_from_prefab="bearger",TUNING="MUTATED_BEARGER_HEALTH"},
  mutatedbuzzard_gestalt={ratio_from_prefab="buzzard",TUNING="MUTATEDBUZZARD_HEALTH"},
}

local function adjcurhealth(inst,percentage)
  inst.components.health:SetPercent(percentage)
  local nachher = inst.components.health.currenthealth
end

local function AdjustHealthEnt(names,prefab,inst,settings,ratio_from_prefab)
  local name = nil
  local vorher = 0 -- debug
  local nachher = 0 -- debug
  local altmax = 0
  local percentbefore = 1
  local adjusthealth = true -- in some special cases this will be set to false
  
  if (type(names) == "string") then -- most of the times a string, but eg for klaus a table
    name = names
  else -- table
    local level = nil
    if (prefab=="shadow_bishop" or prefab=="shadow_knight" or prefab=="shadow_rook") then
      level = inst.level or 1
    elseif prefab=="klaus" then
      if not inst.enraged then
        level = 1
      else
        level = 2
      end
    end
    if level~=nil then
      name = names[level] -- use the correct setting for the level of shadow (assumes the level starts from 1)
    else -- fallback
      name = names[1]
      print("Automatic Health Adjust: Error level is nil for prefab:"..prefab..", names:"..tostring(names))
    end
  end
  
  local setting1 = settings[name].setting1
  local setting6 = settings[name].setting6
  local newmax = settings[name].newmax
  
  -- if we want to use the same ratio for several prefabs: adjust_ents_with_same_ratio
  if ratio_from_prefab~=nil and adjust_ents_with_same_ratio[prefab].newmax~=nil then -- in this case the prefab is eg. mutatedbuzzard_gestalt and ratio_from_prefab == buzzard and the name is Buzzard (which means settings belongs to Buzzard), while mutatedbuzzard_gestalt does not exist in prefabnamelist
    newmax = adjust_ents_with_same_ratio[prefab].newmax
  end
  
  if prefab=="pigman" and not (inst.components.werebeast and inst.components.werebeast:IsInWereState()) then 
      adjusthealth = false -- for pigmans only change health if they are werebeast
  elseif prefab == "deciduoustree" and inst.target_leaf_state=="poison" and inst.components.workable and newmax ~= inst.components.workable.maxwork then
      if inst.components.workable.maxwork<0 then
          inst.components.workable.maxwork = inst.components.workable.workleft -- set a maxleft, so next time the tree won't regenerate every time player join/leave
      end -- downside of setting a max is, that if tree transforms back to normal, the new workleft cant be more than our set maxwork. But I think this is ok...
      percentbefore = inst.components.workable.workleft / inst.components.workable.maxwork
      inst.components.workable:SetMaxWork(newmax)
      inst.components.workable:SetWorkLeft(math.ceil(newmax*percentbefore))
      adjusthealth = false -- already adjusted
  elseif prefab=="leif" then -- treeguard only needs to call his scale function. there it will change health depending on its scale and new TUNING value
      inst:SetLeifScale(inst._scale or 1)
      adjusthealth = false -- already adjusted
  end
  
  if adjusthealth and inst.components.health and newmax ~= inst.components.health:GetMaxWithPenalty() then -- every else prefab
      vorher = inst.components.health.currenthealth
      altmax = inst.components.health.maxhealth
      percentbefore = inst.components.health:GetPercent() -- self.currenthealth / self.maxhealth
      
      -- Health realtime adjustments with same ratio of things related to the mob
      if (prefab=="alterguardian_phase2" or prefab=="alterguardian_phase3") and inst.unloadedhealthmultiplier~=nil then
          newmax = newmax * inst.unloadedhealthmultiplier -- multiply thew newmax (which is based on STARTHEALTH) with the new HP multiplier
      end
      
      inst.components.health:SetMaxHealth(newmax)
      -- inst:DoTaskInTime(1, adjcurhealth, percentbefore) -- short delay, to hoepfully fix the bug that full hp mobs loose current health
      inst.components.health:SetPercent(percentbefore)
      nachher = inst.components.health.currenthealth
  end
end



local function DoHealthChange(world,player,testnumplayer)
    local NumPlayer = #GLOBAL.AllPlayers -- only the players from the world were player spawned/left. So if one player is in cave and one at overworld, both worlds will have the values for 1 player.
    if testnumplayer~=nil then
        NumPlayer = testnumplayer -- testing
    end
    if NumPlayer == nil or NumPlayer==0 then
        return -- this wont happen , except the empty server continues
    end

    local maxplayers = GetModConfigData("max")
    local minplayers = GetModConfigData("min")
    if maxplayers>0 and minplayers > maxplayers then -- disable both, if min is higher than max, while "0" means "disabled"
        minplayers = 0
        maxplayers = 0 
    end
    if minplayers>0 and NumPlayer < minplayers then
        NumPlayer = minplayers
    end
    if maxplayers>0 and NumPlayer > maxplayers then
        NumPlayer = maxplayers
    end
    local newmax = 99 -- just a random number
    local setting1 = 0
    local setting6 = 0
    local quickset_mode = GetModConfigData("mode")
    local tuningkey

    local settings = {}
    for prefab,names in pairs(prefabnamelist) do -- change Tuning value, so new enemies will have this HP
      if (type(names) == "string") then -- most of the times a string, but eg for klaus a table
          names = {names}
      end
      for _,name in ipairs(names) do
        if quickset_mode==2 then -- easy
            setting1 = namevalueslist[name][1] * 0.5
            setting6 = (namevalueslist[name][2] + namevalueslist[name][1])/2
        elseif quickset_mode==3 then -- normal
            setting1 = namevalueslist[name][1]
            setting6 = namevalueslist[name][2]
        elseif quickset_mode==4 then -- hard
            setting1 = (namevalueslist[name][2] + namevalueslist[name][1])/2
            setting6 = namevalueslist[name][2] * 1.5
        elseif quickset_mode==5 then -- very hard
            setting1 = namevalueslist[name][2]
            setting6 = namevalueslist[name][2] * 2
        else -- quickset_mode==1 or any other value
            setting1 = GetModConfigData(name.."1") -- if mode == 1
            setting6 = GetModConfigData(name.."6") -- if mode == 1
        end
        newmax = GLOBAL.TUNING.AUTOHEALTHMOD.CUSTOMHEALTH_FN(NumPlayer,setting1,setting6,prefab,name) -- setting1 + (NumPlayer-1)*((setting6-setting1)/5)
        settings[name] = {prefab=prefab,setting1=setting1,setting6=setting6,newmax=newmax}
      end
    end
    
    
    for prefab,names in pairs(prefabnamelist) do -- change Tuning value, so new enemies will have this HP
        if (type(names) == "string") then -- most of the times a string, but eg for klaus a table
            names = {names}
        end
        for _,name in ipairs(names) do
            setting1 = settings[name].setting1 
            setting6 = settings[name].setting6 
            newmax = settings[name].newmax 
            
            tuningkey = tuninghealth_special[prefab]
            if tuningkey==nil then
                tuningkey = tuninghealth_special[name]
            end
            if tuningkey~=nil then
                if type(tuningkey)=="string" then
                    settings[name].oldTuning = GLOBAL.TUNING[string.upper(tuningkey)]
                    GLOBAL.TUNING[string.upper(tuningkey)] = newmax
                elseif type(tuningkey)=="table" then  -- eg. {gnarwail={GNARWAIL="HEALTH"}} (this example is not in tuninghealth_special, because this tuning is based on prefab)
                    key,value = next(tuningkey)
                    if GLOBAL.TUNING[string.upper(key)]~=nil then
                        settings[name].oldTuning = GLOBAL.TUNING[string.upper(key)][string.upper(value)]
                        GLOBAL.TUNING[string.upper(key)][string.upper(value)] = newmax
                    else
                        print("Automatic Health Adjust: Error, invalid key -"..tostring(key).."- for prefab:"..prefab..", name:"..tostring(name))
                    end
                else
                    print("Automatic Health Adjust: Error, invalid tuningkey -"..tostring(tuningkey).."- for prefab:"..prefab..", name:"..tostring(name))
                end
            elseif table.contains(tuninghealth_basedonname_names,name) then -- check this before we do check prefab_HEALTH, (eg. if there would be a pigman_health entry, we still want to change Werepig)
                if GLOBAL.TUNING[string.upper(name).."_HEALTH"]~=nil then
                    settings[name].oldTuning = GLOBAL.TUNING[string.upper(name).."_HEALTH"]
                    GLOBAL.TUNING[string.upper(name).."_HEALTH"] = newmax
                elseif GLOBAL.TUNING[string.upper(name)]~=nil and GLOBAL.TUNING[string.upper(name)]["HEALTH"]~=nil then
                    settings[name].oldTuning = GLOBAL.TUNING[string.upper(name)]["HEALTH"]
                    GLOBAL.TUNING[string.upper(name)]["HEALTH"] = newmax
                else
                    print("Automatic Health Adjust: Error, no default TUNING entry for prefab:"..prefab..", name:"..tostring(name))
                end
            elseif prefab=="shadow_bishop" or prefab=="shadow_knight" or prefab=="shadow_rook" then    
                level = GLOBAL.tonumber(string.sub(name,-1)) -- get last character of name, it is the level
                settings[name].oldTuning = GLOBAL.TUNING[string.upper(prefab)]["HEALTH"][level]
                GLOBAL.TUNING[string.upper(prefab)]["HEALTH"][level] = newmax
            elseif prefab=="klaus" then
                if name=="Klaus1" then -- Klaus2: do nothing, because only a not enraged tuning value exists and if it is not spawned yet, it is no enraged, so only set it for not enraged (if there is one already spawned and enraged, it will be fixed with the next code that loops through all ents)
                    settings[name].oldTuning = GLOBAL.TUNING[string.upper(prefab).."_HEALTH"]
                    GLOBAL.TUNING[string.upper(prefab).."_HEALTH"] = newmax
                end
            elseif prefab=="alterguardian_phase2" or prefab=="alterguardian_phase3" then -- has 2 different max hp. in modsettings we change STARTHEALTH value, but we will also change MAXHEALTH with the same ratio.
                settings[name].oldTuning = GLOBAL.TUNING[string.upper(prefab).."_STARTHEALTH"]
                GLOBAL.TUNING[string.upper(prefab).."_STARTHEALTH"] = newmax
            else -- every other normal case
                if GLOBAL.TUNING[string.upper(prefab).."_HEALTH"]~=nil then
                    settings[name].oldTuning = GLOBAL.TUNING[string.upper(prefab).."_HEALTH"]
                    GLOBAL.TUNING[string.upper(prefab).."_HEALTH"] = newmax
                elseif GLOBAL.TUNING[string.upper(prefab)]~=nil and GLOBAL.TUNING[string.upper(prefab)]["HEALTH"]~=nil then
                    settings[name].oldTuning = GLOBAL.TUNING[string.upper(prefab)]["HEALTH"]
                    GLOBAL.TUNING[string.upper(prefab)]["HEALTH"] = newmax
                else
                    print("Automatic Health Adjust: Warning, no default TUNING entry for prefab:"..prefab..", name:"..tostring(name).." , will try name.")
                    if GLOBAL.TUNING[string.upper(name).."_HEALTH"]~=nil then
                        settings[name].oldTuning = GLOBAL.TUNING[string.upper(name).."_HEALTH"]
                        GLOBAL.TUNING[string.upper(name).."_HEALTH"] = newmax
                    elseif GLOBAL.TUNING[string.upper(name)]~=nil and GLOBAL.TUNING[string.upper(name)]["HEALTH"]~=nil then
                        settings[name].oldTuning = GLOBAL.TUNING[string.upper(name)]["HEALTH"]
                        GLOBAL.TUNING[string.upper(name)]["HEALTH"] = newmax
                    else
                        print("Automatic Health Adjust: Error2, no default TUNING entry for prefab:"..prefab..", name:"..tostring(name))
                    end
                end
            end
            
            -- Health tuning adjustments with same ratio of things related to the mob, eg. health_boost from crabking, or hardcoded STALKER_ATRIUM_PHASE2_HEALTH from stalker...
            if settings[name].oldTuning~=nil then
              if adjust_TUNING_with_same_ratio[prefab]~=nil then
                for t_i,tuning_name in ipairs(adjust_TUNING_with_same_ratio[prefab]) do
                  if GLOBAL.TUNING[tuning_name]~=nil then
                    local sixplayer = GLOBAL.TUNING[tuning_name] / (settings[name].oldTuning/setting6) -- get the same ratio like set for health, so we need no config value for the boost/bonus
                    local oneplayer = GLOBAL.TUNING[tuning_name] / (settings[name].oldTuning/setting1)
                    GLOBAL.TUNING[tuning_name] = GLOBAL.TUNING.AUTOHEALTHMOD.CUSTOMHEALTH_FN(NumPlayer,oneplayer,sixplayer,prefab,name) -- oneplayer + (NumPlayer-1)*((sixplayer-oneplayer)/5)
                  else
                    print("Automatic Health Adjust: Error , trying to adjust TUNING value "..tostring(tuning_name)..", but it does not exist? May need fixing")
                  end
                end
              end
              -- adjust TUNING from other ents with same ratio
              for other_prefab,info in pairs(adjust_ents_with_same_ratio) do
                if prefabnamelist[other_prefab]==nil and info.ratio_from_prefab==prefab then
                  local tuning_name = info.TUNING
                  if GLOBAL.TUNING[tuning_name]~=nil then
                    info.OldTUNINGValue = GLOBAL.TUNING[tuning_name]
                    local sixplayer = GLOBAL.TUNING[tuning_name] / (settings[name].oldTuning/setting6) -- get the same ratio like set for health, so we need no config value for the boost/bonus
                    local oneplayer = GLOBAL.TUNING[tuning_name] / (settings[name].oldTuning/setting1)
                    GLOBAL.TUNING[tuning_name] = GLOBAL.TUNING.AUTOHEALTHMOD.CUSTOMHEALTH_FN(NumPlayer,oneplayer,sixplayer,ratio_from_prefab,name,prefab) -- oneplayer + (NumPlayer-1)*((sixplayer-oneplayer)/5)
                    info.newmax = GLOBAL.TUNING[tuning_name]
                  else
                    print("Automatic Health Adjust: Error2 , trying to adjust TUNING value "..tostring(tuning_name)..", but it does not exist? May need fixing")
                  end
                end
              end
                
            end
        end
    end
    for k,inst in pairs(GLOBAL.Ents) do -- also change current and max hp from all already exisiting entities
        prefab = inst.prefab
        if prefab~=nil and not table.contains(no_ents_health_change_prefabs,prefab) then -- we dont change current health of a currently active crabking, because we would need to copy the formula, which would break if the devs change their code. Instead, players should re-activate the crabking if they want to update his health. 
          names = prefabnamelist[prefab]
          local ratio_from_prefab = nil
          if names==nil and adjust_ents_with_same_ratio[prefab]~=nil and adjust_ents_with_same_ratio[prefab].ratio_from_prefab~=nil then -- if there is no setting for this, but a adjust_ents_with_same_ratio
            ratio_from_prefab = adjust_ents_with_same_ratio[prefab].ratio_from_prefab
            names = prefabnamelist[ratio_from_prefab]
          end
          if names ~= nil then
            AdjustHealthEnt(names,prefab,inst,settings,ratio_from_prefab)
          end
          if call_inst_fn_for_ents[prefab]~=nil then
            if type(inst[call_inst_fn_for_ents[prefab]])=="function" then
              inst[call_inst_fn_for_ents[prefab]](inst) -- eg. for merms inst.UpdateDamageAndHealth to adjust max health based on new TUNING values
            end
          end
        end
    end    
end



GLOBAL.TUNING.AUTOHEALTHMOD.DoHealthChange = DoHealthChange -- for testing or manual triggering it with console
-- eg: TUNING.AUTOHEALTHMOD.DoHealthChange(TheWorld,ThePlayer,2)

local function DoHealthChangeSoon(world,player)
    world:DoTaskInTime(1, DoHealthChange, player) -- use DoTaskInTime to maybe kind of prevent a race condition problem when multiple players join at once (so all joining players are already joined when the first executes this function)
end


AddPrefabPostInit("world", function(world)
    world:ListenForEvent("ms_playerspawn", DoHealthChangeSoon) -- is only called in the specific world the player spawns. So if he spawns at overworld, it is not called for caves.
    world:ListenForEvent("ms_playerleft", DoHealthChangeSoon)
    -- world:ListenForEvent("playerexited",function() print("hier player LEFT") end) -- none of these leave events is fired BEFORE the player is gone... so when host leaves server, the function is NOT called, leading to wrong current health when starting the game again, cause maxhealth is not saved.
    -- world:ListenForEvent("playerdeactivated",function() print("hier player deaktiviert") end)
    
    -- these functions are called before leaving:
    -- world:ListenForEvent("ms_playerdespawn",function() print("hier ms_playerdespawn aufgerunfen");end)
    -- world:ListenForEvent("ms_playerdisconnected",function() print("hier ms_playerdisconnected aufgerunfen");end)
    -- ms_playerjoined
    
    
    -- local function CheckAndSave(inst)
        -- if inst.migration then
        -- ...
        -- end
    -- end
    -- inst:ListenForEvent("onremove", CheckAndSave)
    
end)


for prefab,name in pairs(prefabnamelist) do -- to solve the wrong current health problem, we also have to save maxhealth for all those prefabs
    AddPrefabPostInit(prefab,function(inst)
        if inst.components.health~=nil then
            inst.components.health.save_maxhealth = true -- meanwhile the devs added this value, so instead of wrting my own OnSave, we can simply set this to true.
        end
    end)
end
for prefab,info in pairs(adjust_ents_with_same_ratio) do -- to solve the wrong current health problem, we also have to save maxhealth for all those prefabs
    AddPrefabPostInit(prefab,function(inst)
        if inst.components.health~=nil then
            inst.components.health.save_maxhealth = true -- meanwhile the devs added this value, so instead of wrting my own OnSave, we can simply set this to true.
        end
    end)
end




-- vanilla OnLoadPostPass does recalcualte the maxhealth, although we want to be sure to use the maxhealth we saved thanks to save_maxhealth
-- only needed for prefabs within no_ents_health_change_prefabs and only if they set the maxhealth on load
-- In theory this should work fine but:
 -- 1) not 100% sure if it can happen that saved_maxhealth will be 200.000 (because vanilla code does set it to this value several times...)
 -- and 2) also in vanilla something sets the currenthealth to maxhealth after OnLoadPostPass, so the SetPercent in my and the vanilla function does not help and the crabking will have maxhealth on load always.
 -- because of these 2 problems, I will outcomment this code == not use it, because users should simply leave the screen and activate crabking again, this prevents all problems. The vanilla code is just terrible to mod.
-- AddPrefabPostInit("crabking",function(inst)
  -- local Old_OnLoadPostPass = inst.OnLoadPostPass
  -- local function New_OnLoadPostPass(inst, newents, data,...)
    -- local saved_maxhealth = inst.components.health~=nil and inst.components.health.maxhealth or nil
    -- local ret = Old_OnLoadPostPass(inst, newents, data,...)
    -- if saved_maxhealth~=nil then
      -- inst.components.health:SetMaxHealth(saved_maxhealth)
      -- if data.healthpercent~=nil then
        -- inst.components.health:SetPercent(data.healthpercent)
      -- end
    -- end
    -- return ret
  -- end
  -- inst.OnLoadPostPass = New_OnLoadPostPass
-- end)


-- old save maxhealth code
-- AddComponentPostInit("health",function(comp) -- to solve the wrong current health problem, we also have to save maxhealth
    -- if comp.inst and comp.inst.prefab and GLOBAL.table.containskey(prefabnamelist, comp.inst.prefab) then -- only change component of these prefabs we do maxhealth change
    -- for whatever reason, most things do not have a prefab here...
        
        -- local _OnSave = comp.OnSave
        -- local function OnSave()
            -- local data = {maxhealth = comp.maxhealth}
            -- local olddata = _OnSave(comp)
            -- local newdata = GLOBAL.MergeMaps(data,olddata) -- merge the old and the new data
            -- return newdata
        -- end
        -- comp.OnSave = OnSave
        
        -- local _OnLoad = comp.OnLoad
        -- local function OnLoad(comp,data)
            -- if data then
                -- if data.maxhealth then
                    -- comp.maxhealth = data.maxhealth
                -- end
            -- end
            -- _OnLoad(comp,data) -- call the old function now
        -- end
        -- comp.OnLoad = OnLoad
    -- end
    
-- end)

------------------------------------

-- make spider_dropper independend of spider_warrior health
AddPrefabPostInit("spider_dropper",function(inst)
    inst.components.health:SetMaxHealth(TUNING.SPIDER_DROPPER_HEALTH)
end)

-- ## special code for alterguardian_phase2/3 to remember if it was unloaded or not (and therefore has higher maxhealth or not)
for _,prefab in ipairs({"alterguardian_phase2","alterguardian_phase3"}) do
    AddPrefabPostInit(prefab,function(inst)
        
        local _OnSave = inst.OnSave
        local function OnSave(inst,data,...)
            local ret = nil
            if _OnSave~=nil then
                ret = _OnSave(inst,data,...) -- call the previous
            end
            data.unloadedhealthmultiplier = inst.unloadedhealthmultiplier
            return ret
        end
        inst.OnSave = OnSave
        
        local _OnLoad = inst.OnLoad
        local function OnLoad(inst,data,...)
            local ret = nil
            if _OnLoad~=nil then
                ret = _OnLoad(inst,data,...) -- call the previous
            end
            if data then
                if data.unloadedhealthmultiplier then
                    inst.unloadedhealthmultiplier = data.unloadedhealthmultiplier
                end
            end
            return ret
        end
        inst.OnLoad = OnLoad
        
        
        local _OnEntityWake = inst.OnEntityWake
        local function OnEntityWake(inst,...)
            if _OnEntityWake~=nil then
                _OnEntityWake(inst,...)
            end
            local currentmax = inst~=nil and inst.components~=nil and inst.components.health~=nil and inst.components.health.maxhealth or nil -- maxhealth was likely changed in OnEntityWake
            if currentmax~=nil then
                local prefab = inst.prefab
                if prefab~=nil and currentmax > GLOBAL.TUNING[string.upper(prefab).."_STARTHEALTH"] then
                    inst.unloadedhealthmultiplier = currentmax / GLOBAL.TUNING[string.upper(prefab).."_STARTHEALTH"]
                end
            end
        end
        inst.OnEntityWake = OnEntityWake
    end)
end


-- in nightmarecreature.lua the devs have the glorious idea to save the health values in a local variable, that is filled BEFORE any mod is loaded -.-
-- Thats why adjusting the TUNING health value alone does not help in this case ... we have to repeat the assign of SetMaxHealth, now with the new TUNING value, instead of the value saved in that local data variable -.-
for _,prefab in ipairs({"crawlingnightmare","nightmarebeak","ruinsnightmare"}) do
  AddPrefabPostInit(prefab,function(inst)
    local newhealth = TUNING[string.upper(prefab).."_HEALTH"]
    if newhealth==nil then
      if prefab=="crawlingnightmare" then -- of course these two have special tuning names -.-
        newhealth = TUNING.CRAWLINGHORROR_HEALTH
      elseif prefab=="nightmarebeak" then
        newhealth = TUNING.TERRORBEAK_HEALTH
      end
    end
    if newhealth~=nil then
      inst.components.health:SetMaxHealth(newhealth)
    end
  end)
end

