name = "Automatic Health Adjust"
description = "This mod automatically adjusts the health of mobs depending on the number of active players.\n\nDefault is DS values for 1 player, and DST values for 6 players." 
author = "Serpens"
forumthread = ""

version = "1.1074"
api_version = 10

dst_compatible = true

client_only_mod = false
all_clients_require_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- how to add new mobs?
-- In case the mob has no special forms with different HP and the HP value in tuning lua looks like [prefab]_HEALTH, all you need is to add a (self chosen) name and the value range (1 player,6player) below and do the same in modmain. That's all.
-- If it has different forms it is more complicated, see examples like shadow clockworks or klaus and explanation on top of modmain.lua

local nameslist = {'AncGuardian', 'Ancient_Sentrypede', 'Ancient_Guard_Tower', 'Antlion', 'Bearger', 'Bearger_Armored', 'Beefalo', 'Beeguard', 'Beequeen', 'Blighted_Great_Depths_Worm', 'Blighted_Hound_Batilisk', 'Blighted_Rock_Master', 'Brightshade', 'Brightshade_Vine', 'Bunnyman', 'Buzzard', 'Celestial_Champion1', 'Celestial_Champion2', 
 'Celestial_Champion3', 'Celestial_Revenant', 'Celestial_Scion', 'Clockworks', 'Crabking', 'Crabking_Claw', 'Deer', 'DeerGem', 'Deerclops', 'Deerclops_Crystal', 'Dragonfly', 'Eye_of_Terror', 'Eye_of_Terror_Mini', 'Eye_of_Terror_Twin1', 'Eye_of_Terror_Twin2', 
 'Ewecus', 'Fused_Shadeling', 'Frostjaw', 'Gnarwail', "Grassgator", 'Hound_Batilisk', 'Icker', 'InkBlight_Jitters', 'InkBlight_Rasp', 'InkBlight_Rictus', 'InkBlight_Shriek', 'Klaus1', 'Klaus2', 'Koalefant', 'Krampus', 'Lavae', 'Lord_Fruit_Flies', 'Lurking_Nightmare'; 'Malbatross', 'Marotter', 'Merm', 'Moose', 'Mosling', 'Mush_Gnome', 'Nightmare_Werepig', 'Ornery_Chest', 'Pig_Guard', 'Pig', 'Poisonedtree', 'Powder_Monkey', 'Prime_Mate', 
 'Rabbitking', 'Royal_Rabbit_Enforcer', 'RLobster', 'Rock_Master', 'Rockjaw', 'Saladmander', 'Sea_Weed', 'Shadow_Bishop1',  'Shadow_Bishop2', 'Shadow_Bishop3', 'Shadow_Knight1', 'Shadow_Knight2', 'Shadow_Knight3', 'Shadow_Rook1', 
 'Shadow_Rook2', 'Shadow_Rook3', 'Shootius', 'Shrouded_Queen', 'Skeleton_A', 'Skeleton', 'Slurtle', 'Spider_dropper', 'Spider_healer', 'Spider_hider', 'Spider_spitter', 'Spider_warrior', 
 'Spiderqueen', 'Tallbird', 'Teenbird', 'Tentacle_pillar', 'Terramite', 'Toadstool', 'ToadstoolMisery', 'Treeguard', 'Umbral_Abomination',  'Voaltgoat', 'Walrus', 'W.A.R.B.O.T.', 'Warg', 'Warg_Possessed', 'Werepig', 'Worm', 'Great_Depths_Worm'}
-- DS and DST values, same order as the names above! (can not use "pairs" within modinfo, so we have two lists and will use #nameslist)
local valuelist = {{2500, 10000}, {600, 1200}, {2000, 6000}, {3000, 6000}, {3000, 6000}, {4000, 8000}, {500, 1000}, {100, 180}, {3000, 22500}, {2000, 6000}, {1000, 3000}, {1650, 5000}, {500, 1000}, {100, 200}, {200, 400}, {125, 250}, {2000, 10000}, {2600, 13000}, 
 {2800, 14000}, {2000,8000}, {3500,16000}, {300, 900}, {3000, 12000}, {100, 500}, {350, 700}, {750, 1500}, {2000, 4000}, {3000, 6000}, {3500, 27500}, {2000,5000}, {150,200}, {4000,10000}, {4000,10000}, 
 {400, 800}, {625, 1250}, {4000, 8000}, {500, 1000}, {500, 1000}, {500, 1500}, {300, 600}, {500, 1000}, {600, 1200}, {400, 800}, {400, 800}, {2000, 10000}, {5488, 27440}, {500, 1000}, {200, 300}, {250, 500}, {900, 1500}, {400, 850}, {1500, 5000}, {175, 350}, {250, 500}, {3000, 6000}, {350, 525}, {300, 600}, {2000,10000}, {400,950}, {300, 600}, {250, 500}, {12, 18}, {100, 200}, {200, 350},
 {800, 2000}, {150, 400},{1500, 3000}, {1400, 4000}, {500, 1000}, {450, 900}, {250, 500}, {250, 800}, {800, 2500}, {2500, 7500}, {300, 900}, {900, 2700}, {2700, 8100}, {350, 1000}, 
 {1000, 4000}, {4000, 10000}, {1000, 3000}, {3700, 18500}, {6000, 16000}, {2000, 4000}, {600, 1200}, {200, 400}, {200, 400}, {150, 225}, {175, 350}, {200, 400}, 
 {1250, 2500}, {400, 800}, {300, 600}, {500, 750}, {140, 280}, {7500, 52500}, {11111, 99999}, {2000, 3000}, {3500, 16000}, {350, 700}, {150, 300}, {4500, 22500}, {600, 1800}, {1500, 3000}, {350, 525}, {450, 900}, {1500, 5000},}

-- when adding new options in configs, do not forget to adjust the code on the bottom, adjust the numbers! "configs[i*2-1+x]" while x is the number of options currently set in configs. two places were you have to adjust it
configs = {
    {
        name = "mode",
        label = "QuickSet",
		hover = "If this is enabled, all the following settings do nothing\n",
        options = {
            {description = "Disabled", data = 1,hover = "Use the settings defined below."},
            {description = "Easy", data = 2,hover = "DS*0.5 values for 1 player, average of DS and DST for 6 players"},
            {description = "Normal", data = 3,hover = "DS values for 1 player, DST values for 6 players."},
            {description = "Hard", data = 4,hover = "Average of DS and DST for 1 player, DST*1.5 for 6 players."},
            {description = "Very Hard", data = 5,hover = "DST for 1 player, DST*2 for 6 players."},
        },
        default = 1, 
    },
    {
        name = "max",
        label = "Max",
		hover = "The max number of players the mod should calculate with\neg when you play with 5 players, but want max health values for max of 3 players.\nIf Min is higher than Max, both will be disabled.",
        options = {
            {description = "Disabled", data = 0,hover = "Default"},
            {description = "1", data = 1,hover = "\n"},
            {description = "2", data = 2,hover = "\n"},
            {description = "3", data = 3,hover = "\n"},
            {description = "4", data = 4,hover = "\n"},
            {description = "5", data = 5,hover = "\n"},
            {description = "6", data = 6,hover = "\n"},
            {description = "7", data = 7,hover = "\n"},
            {description = "8", data = 8,hover = "\n"},
            {description = "9", data = 9,hover = "\n"},
            {description = "10", data = 10,hover = "\n"},
            {description = "15", data = 15,hover = "\n"},
            {description = "20", data = 20,hover = "\n"},
            {description = "25", data = 25,hover = "\n"},
            {description = "30", data = 30,hover = "\n"},
        },
        default = 0, 
    },
    {
        name = "min",
        label = "Min",
		hover = "The min number of players the mod should calculate with\neg when you play with 2 players, but want max health values for min of 4 players.\nIf Min is higher than Max, both will be disabled.",
        options = {
            {description = "Disabled", data = 0,hover = "Default"},
            {description = "1", data = 1,hover = "\n"},
            {description = "2", data = 2,hover = "\n"},
            {description = "3", data = 3,hover = "\n"},
            {description = "4", data = 4,hover = "\n"},
            {description = "5", data = 5,hover = "\n"},
            {description = "6", data = 6,hover = "\n"},
            {description = "7", data = 7,hover = "\n"},
            {description = "8", data = 8,hover = "\n"},
            {description = "9", data = 9,hover = "\n"},
            {description = "10", data = 10,hover = "\n"},
            {description = "15", data = 15,hover = "\n"},
            {description = "20", data = 20,hover = "\n"},
            {description = "25", data = 25,hover = "\n"},
            {description = "30", data = 30,hover = "\n"},
        },
        default = 0, 
    },
    {
        name = "nulloption",
        label = "Change formula in files --------------------",
		hover = "If you want to change the health formula, go to mod folder and adjust customsettings.lua! (steamapps_workshop_content_322330_764204839)",
        options = {
            {description = "--------", data = 1},
        },
        default = 1, 
    },
}
for i=1,#nameslist do -- there is no pairs in modinfo available -.-    
    configs[i*2-1+4] = {
        name = nameslist[i].."1",
        label = nameslist[i].." 1 Player",
        hover = "Set the health the "..nameslist[i].." should have when 1 player is active.\nFor 2,3,4 and 5 players,\nthe health will be something between 1 and 6 players.",
        options = {
            {description = valuelist[i][1]*0.5, data = valuelist[i][1]*0.5,hover="\n"},
            {description = valuelist[i][1].." (DS)", data = valuelist[i][1],hover="Default"},
            {description = (valuelist[i][2] + valuelist[i][1])/2, data = (valuelist[i][2] + valuelist[i][1])/2,hover="\n"},
            {description = valuelist[i][2].." (DST)", data = valuelist[i][2],hover="\n"},
            {description = valuelist[i][2]*1.5, data = valuelist[i][2]*1.5,hover="\n"},
            {description = valuelist[i][2]*2, data = valuelist[i][2]*2,hover="\n"},
        },
        default = valuelist[i][1],
    }
    configs[i*2+4] = {
        name = nameslist[i].."6",
        label = nameslist[i].." 6 Player",
        hover = "Set the health the "..nameslist[i].." should have when 6 players are active.\nFor 2,3,4 and 5 players,\nthe health will be something between 1 and 6 players.",
        options = {
            {description = valuelist[i][1]*0.5, data = valuelist[i][1]*0.5,hover="\n"},
            {description = valuelist[i][1].." (DS)", data = valuelist[i][1],hover="Default"},
            {description = (valuelist[i][2] + valuelist[i][1])/2, data = (valuelist[i][2] + valuelist[i][1])/2,hover="\n"},
            {description = valuelist[i][2].." (DST)", data = valuelist[i][2],hover="\n"},
            {description = valuelist[i][2]*1.5, data = valuelist[i][2]*1.5,hover="\n"},
            {description = valuelist[i][2]*2, data = valuelist[i][2]*2,hover="\n"},
        },
        default = valuelist[i][2],
    }
end    

configuration_options = previous_configuration or old_config or configs or {}