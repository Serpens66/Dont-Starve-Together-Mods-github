
-------------------------------
-- If you want a different formula for health calculation, you can adjust the function below.
-- Make sure to do a backup of this modified file, because every mod-update will overwrite your customized customsettings.lua file!

TUNING.AUTOHEALTHMOD = 
{
    CUSTOMHEALTH_FN = function(NumPlayer,OnePlayerValue,SixPlayerValue,prefab,name,adjust_with_mob_prefab)
        -- NumPlayer is the number of players currently on the server
        -- OnePlayerValue and SixPlayerValue are based on the modsetting. On Quicksetting="normal" they will be equal to DSValue and DSTValue you can see in the valuelist in modmain.lua
        -- prefab and name are for advanced functions, see my prefabnamelist in modmain.lua to see prefab=name pairs.
        -- in case adjust_with_mob_prefab is not nil, then adjust_with_mob_prefab is the prefab you find in prefabnamelist (eg. "merm"), to which also the name belongs. And prefab is in this case eg "mermguard" which is not in the prefabnamelist but uses the same ratio like merm. 
        
        return OnePlayerValue + (NumPlayer-1)*((SixPlayerValue-OnePlayerValue)/5) -- this is the formula I currently use. you can replace this with whatever you like
        
    end 
}





