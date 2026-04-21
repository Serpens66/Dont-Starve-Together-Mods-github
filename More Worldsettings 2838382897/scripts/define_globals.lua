local _G = GLOBAL

if _G.MORESET_MOD == nil then
    _G.MORESET_MOD = {}
end

-- atlases be found at Don't Starve Together\data\images and Don't Starve Together\data\databundle\images
_G.MORESET_MOD.atlas_to_search = {"images/customisation.xml","images/worldsettings_customization.xml","images/worldgen_customization.xml","images/inventoryimages.xml","images/inventoryimages1.xml","images/inventoryimages2.xml","images/inventoryimages3.xml"}


_G.TUNING.BANANABUSH_REGROW_TIME = _G.TUNING.TOTAL_DAY_TIME -- add a new tunging value for bananabush, cause in prefab it uses TUNING.TOTAL_DAY_TIME


_G.MORESET_MOD.tuning_names = {}
_G.MORESET_MOD.tuning_names._REGROW_TIME = {} -- the key is the appendix of the tuning value we search for
-- _G.MORESET_MOD.tuning_names._GROW_TIME = {} -- does not work for most things yet because of this: https://forums.kleientertainment.com/klei-bug-tracker/dont-starve-together/local-variables-eg-in-evergreenslua-r36251/ as soon as this is fixed it will automatically start working... but maybe better add those manually, because they are too different and we dont want all of them and we may not want to reduce time of tall stage...

_G.MORESET_MOD.PrefabTuningTansl = {} -- manuall add prefabs here who has no prefab_REGROW_TIME value, but a different naming (code in modmain finds them and prints it to logfile)
_G.MORESET_MOD.PrefabTuningTansl["berrybush"] = "berry"
_G.MORESET_MOD.PrefabTuningTansl["berrybush_juicy"] = "berry_juicy"
_G.MORESET_MOD.PrefabTuningTansl["marsh_bush"] = "marshbush"
_G.MORESET_MOD.PrefabTuningTansl["sapling_moon"] = "sapling"
_G.MORESET_MOD.PrefabTuningTansl["oasis_cactus"] = "cactus"
_G.MORESET_MOD.PrefabTuningTansl["berrybush2"] = "berry"
_G.MORESET_MOD.PrefabTuningTansl["bullkelp_plant"] = "bullkelp"
_G.MORESET_MOD.PrefabTuningTansl["monkeytail"] = "reeds" -- but has own MONKEYTAIL_CYCLES...
_G.MORESET_MOD.PrefabTuningTansl["flower_cave_double"] = "flower_cave"
_G.MORESET_MOD.PrefabTuningTansl["flower_cave_triple"] = "flower_cave"

-- my mod searches in aboves atlas_to_search by default.  steamapps\common\Don't Starve Together\data\images and steamapps\common\Don't Starve Together\data\databundle\images
 -- manuall add tuning_names here, which need a different naming or atlas than atlas_to_search for image.tex , see logfile for sth like this "More Worldsetings mod: No Image found for" OR "WARNING! Could not find region 'bullkelp.tex' from atlas 'images/customisation.xml'. Is the region specified in the atlas?"
-- you can let atlas be nil if it is in atlas_to_search
_G.MORESET_MOD.TuningImageTansl = {}
_G.MORESET_MOD.TuningImageTansl["berry"] = {atlas=nil,imagename="berrybush"}
_G.MORESET_MOD.TuningImageTansl["berry_juicy"] = {atlas=nil,imagename="berries_juicy"}
_G.MORESET_MOD.TuningImageTansl["marshbush"] = {atlas=nil,imagename="marsh_bush"}
_G.MORESET_MOD.TuningImageTansl["bullkelp"] = {atlas=nil,imagename="ocean_bullkelp"}
_G.MORESET_MOD.TuningImageTansl["grassgekko"] = {atlas=nil,imagename="grassgekkos"}
_G.MORESET_MOD.TuningImageTansl["wormlight_plant"] = {atlas=nil,imagename="wormlights"}
_G.MORESET_MOD.TuningImageTansl["oceanvine"] = {atlas=nil,imagename="regrowth"} -- use regrowth, no fitting image found in any atlas
_G.MORESET_MOD.TuningImageTansl["teenbird"] = {atlas=nil,imagename="tallbirds"}
_G.MORESET_MOD.TuningImageTansl["livingtree_young"] = {atlas=nil,imagename="regrowth"} -- use regrowth, no fitting image found in any atlas
_G.MORESET_MOD.TuningImageTansl["twiggy_tree"] = {atlas=nil,imagename="twiggytrees"}
_G.MORESET_MOD.TuningImageTansl["oceantreenut"] = {atlas=nil,imagename="regrowth"} -- use regrowth, no fitting image found in any atlas
_G.MORESET_MOD.TuningImageTansl["cave_banana"] = {atlas=nil,imagename="banana"}
_G.MORESET_MOD.TuningImageTansl["marbleshrub"] = {atlas=nil,imagename="regrowth"} -- use regrowth, no fitting image found in any atlas. the marble seed is not affected by this
_G.MORESET_MOD.TuningImageTansl["deciduous"] = {atlas=nil,imagename="deciduoustree"}
_G.MORESET_MOD.TuningImageTansl["babybeefalo"] = {atlas=nil,imagename="beefalo"}
_G.MORESET_MOD.TuningImageTansl["mushroomfarm_full"] = {atlas=nil,imagename="mushrooms"}
_G.MORESET_MOD.TuningImageTansl["bananabush"] = {atlas=nil,imagename="banana"}

_G.MORESET_MOD.TuningImageTansl["onion"] = {atlas=nil,imagename="quagmire_onion"}
_G.MORESET_MOD.TuningImageTansl["tomato"] = {atlas=nil,imagename="quagmire_tomato"}
_G.MORESET_MOD.TuningImageTansl["weed_firenettle"] = {atlas=nil,imagename="firenettles"}
_G.MORESET_MOD.TuningImageTansl["weed_forgetmelots"] = {atlas=nil,imagename="forgetmelots"}
_G.MORESET_MOD.TuningImageTansl["weed_ivy"] = {atlas=nil,imagename="regrowth"} -- has no image, because it has no product
_G.MORESET_MOD.TuningImageTansl["weed_tillweed"] = {atlas=nil,imagename="tillweed"}
_G.MORESET_MOD.TuningImageTansl["randomseed"] = {atlas=nil,imagename="seeds"}

 
_G.MORESET_MOD.AddNoSettingFor = {} -- manual add tunings that we dont want to add to settings. eg. no one cares for winter_tree (christmas)
