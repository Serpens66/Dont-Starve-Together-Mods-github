-- ######################################################################################
-- ###  for customization
-- ###  dont forget to backup this file also outside of the mod folder
-- ###  because every mod-update will resett this file!
-- ######################################################################################
_T = GLOBAL.TUNING

-- for dig and pick and harvest (every action mentioned in "always"), everthing that is not within the never/always list, will only be target if both, maxwell and shadow have the tool equipped.
_T.BM_AllowedAction = {
    never = {
        [GLOBAL.ACTIONS.MINE] = {prefabs={"cave_entrance"},tags={}},
        [GLOBAL.ACTIONS.CHOP] = {prefabs={},tags={}},
        [GLOBAL.ACTIONS.DIG] = {prefabs={"rabbithole"},tags={"mushroom","sign","farm_plant"}}, -- never ever dig these up. Barren/Withered/Diseased or just planted things are already excluded in modcode
        [GLOBAL.ACTIONS.PICK] = {prefabs={"mandrake_planted","atrium_gate","moonbase","sculptingtable","statueglommer","telebase_gemsocket"},tags={"flower","weed"}},   
        [GLOBAL.ACTIONS.PICKUP] = {prefabs={"waxwelljournal","pumpkin_lantern","powcake"},tags={"tool","light","trap","mine","explosive"}}, -- will only pick up stuff that has canbepickedup and cangoincontainer true
        [GLOBAL.ACTIONS.HARVEST] = {prefabs={},tags={}},
    },
    always = { -- everything chopable/mineable/pickupable is automatically in this list (so will be always worked on if the shadow has the equipment, at least as long here is no entry for these actions)
        [GLOBAL.ACTIONS.DIG] = {prefabs={"molehill","farm_soil_debris"},tags={"stump","grave"}}, -- always dig these if shadow has a shovel.  Everything else which is not in this or NoDig list, will be dig up if also maxwell has a shovel
        [GLOBAL.ACTIONS.PICK] = {prefabs={"sapling","sapling_moon","grass","reeds","tumbleweed","bullkelp_plant","rock_avocado_bush","tallbirdnest"},tags={}}, -- everything which product can spoil is not in this list
        [GLOBAL.ACTIONS.HARVEST] = {prefabs={},tags={"withered"}},
    }
}


 -- some specific items that are not hardcoded (like tools+pickables for worker and weapon/armor for duelist and nightmarefuel)
_T.BM_AllowedItemsInContainer = {
    workerequip = {prefabs={"grass_umbrella","umbrella"},tags={"light","lighter"}}, -- allowed in container and will be equipped -- will be equipped automatically if no other action can be done
    duelistequip = {prefabs={},tags={}},
    workerNoequip = {prefabs={},tags={}}, -- allowed in contaier, but wont be equipped
    duelistNoequip = {prefabs={},tags={}},
}


_T.SHADOWWAXWELL_DAMAGE = 20 -- duelist damage without any weapon
_T.BM_stayitemprefab = "journalpage" -- the prefab of the item which makes shadows stay at their position, if it is in their container.