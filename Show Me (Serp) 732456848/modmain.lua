local _G = GLOBAL
local easing = GLOBAL.require("easing")

--nice round function
local round2=function(num, idp)
	return _G.tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

Assets =
{
	Asset("ATLAS", "images/iteminfo_images.xml"),
	Asset("IMAGE", "images/iteminfo_images.tex"),
}

if modinfo then
	print("ShowMe version:",modinfo.version)
end

local GetGlobal=function(gname,default)
	local res=_G.rawget(_G,gname)
	if res == nil and default ~= nil then
		_G.rawset(_G,gname,default)
		return default
	end
	return res
end

--Locals (Add compatibility with any other mineable mods).
local mods = GetGlobal("mods",{})

local GetTime = _G.GetTime
local TheNet = _G.TheNet
local SERVER_SIDE = TheNet:GetIsServer()
local CLIENT_SIDE =	 TheNet:GetIsClient() or (SERVER_SIDE and not TheNet:IsDedicated())

local tonumber = _G.tonumber
local food_order = tonumber(GetModConfigData("food_order",true)) or 0
if food_order == 0 then
	food_order = tonumber(GetModConfigData("food_order")) or 0
end
--TUNING.SHOWME_FOOD_ORDER = food_order --для Tell Me
local food_style = tonumber(GetModConfigData("food_style",true)) or 0
if food_style == 0 then
	food_style = tonumber(GetModConfigData("food_style")) or 0
end
--TUNING.SHOWME_FOOD_STYLE = food_style

local food_estimation = tonumber(GetModConfigData("food_estimation",true)) or -1
if food_estimation == -1 then
	food_estimation = tonumber(GetModConfigData("food_estimation")) or 0
end

local display_units = tonumber(GetModConfigData("units_ingredients",true)) or 0
if display_units == 0 then
	display_units = tonumber(GetModConfigData("units_ingredients")) or 0
end

local showuses_item = tonumber(GetModConfigData("showuses_item",true)) or 0
if showuses_item == 0 then
	showuses_item = tonumber(GetModConfigData("showuses_item")) or 0
end

local showuses_other = tonumber(GetModConfigData("showuses_other",true)) or 0
if showuses_other == 0 then
	showuses_other = tonumber(GetModConfigData("showuses_other")) or 0
end

local show_worldstatus = tonumber(GetModConfigData("show_worldstatus",true)) or 0
if show_worldstatus == 0 then
	show_worldstatus = tonumber(GetModConfigData("show_worldstatus")) or 0
end

local show_creature_speed = tonumber(GetModConfigData("show_creature_speed",true)) or 0
if show_creature_speed == 0 then
	show_creature_speed = tonumber(GetModConfigData("show_creature_speed")) or 0
end

local show_foodstats_multiplier = tonumber(GetModConfigData("show_foodstats_multiplier",true)) or 0
if show_foodstats_multiplier == 0 then
	show_foodstats_multiplier = tonumber(GetModConfigData("show_foodstats_multiplier")) or 0
end

local function ToggleShowUnits(player)
    if player:HasTag("ShowUnits") then
        player:RemoveTag("ShowUnits")  -- for clients the last tooltip seems to be chached. so units are active and you hover over eg twigs you see inedible. now you deactivate unis and when hovering over the same twigs you will see still units. After hovering over another item in inventory, it will be resettet und the units are gone
        -- print("ShowUnits Tag removed")
    else
        player:AddTag("ShowUnits")
        -- print("ShowUnits Tag added")
	end
end

AddModRPCHandler("ShowMe", "ShowMe_ShowUnitshandler", function(player)
	if player then
        ToggleShowUnits(player)
    end
end)

--- Press "F1" to show recipe units
GLOBAL.TheInput:AddKeyDownHandler(GetModConfigData("keybind"), function()
	local player = GLOBAL.ThePlayer
    if not player or player.HUD:IsConsoleScreenOpen() or player.HUD:IsChatInputScreenOpen() then
		return
	end
	if GLOBAL.TheNet:GetIsServer() then -- Server-side
		ToggleShowUnits(player)
	else -- Client-side
		local RPC = GetModRPC("ShowMe", "ShowMe_ShowUnitshandler") 
        SendModRPCToServer(RPC)
	end
end)

--Название на английском, краткая сетевая строка-алиас (для пересылки).
--Если алиас начинается с маленькой буквы, то он обязан быть длиной в 1 букву. Если с большой, то 2 (вторая буква может быть любого регистра).
local MY_STRINGS =
{ 
	{ armor = "Armor:" }, --A
	{ aggro = "Aggression:" }, --B
	{ cookpot = "Probably it will be" }, --C (Crock Pot)
	{ dmg = "Damage:" }, --D
	{ electric = "Electric:" }, --E --electric power
	{ food = "Food:"},
	{ S2="Now it's the summer," }, --G
	{ health= "Health:" }, --H --for food
	{ warm = "Insulation:" }, --I --winter insulation
	{ kill = "Kill:" }, --J	 --for Canibalism 18 mod
	{ kills = "Kills:" }, --K  --for Canibalism 18 mod
	{ loyal = "Loyality:" }, --L  --pigman and bunnyman
	{ S4="Now it's the autumn," }, --M
	{ remaining_days = "Remaining days" }, --N
	{ owner = "Owner:" }, --O --support of various mods
	{ perish = "Spoil in" }, --P -- Spoil in N days.
	{ hunger= "Hunger:" }, --Q
	{ range = "Range:" }, --R  --for range weapon or for mobs
	{ sanity= "Sanity:" }, --S
	{ thickness = "Thickness:" }, --T
	{ units_of = "units of" }, --U
	{ resist = "Resistance:" }, --V --against sleep darts, ice staff etc
	{ waterproof = "Waterproof:" }, --W
	{ heal = "Heal:" }, --X
	{ fishes = "Fishes:" }, --Y	 --in a pond
	{ fish = "Fish:" }, --Z
	{ sec= "Seconds:" },  --for cooking in Crock Pot
	{ love = "Love:" }, 
	{ summer = "Summer:" }, --summer insulation
	{ absorb = "Absorb:" },
	{ S3="Now it's the spring," }, --
	{ is_admin = "This is the ADMIN!\nHe is out of the game\nso don't touch him." },
	{ temperature = "t" },
	{ hp= "HP:" }, --for characters
	{ armor_character = "Armor:" },
	{ sanity_character = "Sanity:" }, --S	
	{ fuel = "Fuel:" }, --F --for firepit
	{ speed = "Speed:" }, 
	{ uses_of = "uses of" },
	{ obedience = "Obedience:" },
	{ S1="Now it's the winter," }, 
	{ dmg_character = "Damage:" }, 
	{ power="Power:"},--usually means strengths of weapon but not physical damage
    {creature_speed="Speed:" },
    {precipitationrate="GlobalRain:" },
    {moisturerate="Rain:" },
    {wetness="GlobalWetness:" },
    {nothing="" },
    {bucktime="Bucktime:"},
    {buckdelay="Buckdelay:"},
    {beefalohealth="Mount HP:"},
    {beefstrength = 'Mount Strength:' },
    { stale = "Stale in" }, --P -- Stale in N days.
    { explosive_damage = "Explosive Damage" },
    { explosive_range = "Explosive Range" },
    
    
    { cooldown="Cooldown:"},
	{ domest = "Tamed:" }, -- "Domestication:"
	{ will_die = "Will die in" }, --will die in N days (saying about pet or animal).
	{ will_dry = "Will dry in" },
	{ dmg_bonus = "Damage bonus:" }, -- Damage: +X (means damage modifier, not base damage)
	{ crop = "" }, --Not used. It's just a key for info type. Info - "Product: percent"
	{ grow_in = "Grow in" }, --About grass etc
	{ perish_product = "" }, --Just a key for info type. Info - "Product: time in days"
	{ just_time = "" }, --Just a key for info type. Info - [time]
	--Thirst mod
	{ water = "Water:" },
	{ salt = "Salt:" },
	{ sip = "A sip:" },
	{ watergainspeed = "Water gain speed:" },
	{ water_poisoned = "Is poisoned!" },
	
	{ timer = "Timer" },
	{ trade_gold = 'Gold tribute:' },
	{ trade_rock = 'Rock tribute:' },
	{ durability = 'Durability:' },
	{ strength = 'Strength:' },
	{ aoe = "AoE:" },
    
    { food_temperature = '' },
	{growable='' },
	
	{sanityaura='Sanity Aura:' },
	{fresh='Fresh in'}, --Fresh in N days (with mod Better Ice Box)
	{frigde='frigde'}, --For icebox etc
	{food_memory='Memory'},
	{buff=''},
	{effectiveness='Effectiveness:'},
	{force='Force:'},
	{repairer='Repair:'},             
}

SHOWME_STRINGS = {
	loyal = "forever", --for very loyal pigman with loyalty over 9000
	of = " of ", -- X of Y (reserved)
	units_1 = "1 unit of ",
	units_many = " units of ",
	uses_1 = "1 use of ",
	uses_many = " uses of ", --X uses of Y, where X > 1
	days = " days", --Spoil in N days.
    temperature = "Temperature", -- used at least in food info
	paused = 'Paused',
	already_fresh = 'Maximum freshness',
	cheat_fresh = 'Cheat mod detected',
	onpickup = ' on pick up', --for flowers                      
}

FOOD_TAGS = {}

MY_DATA = {}
for i,v in ipairs(MY_STRINGS) do
	for k,str in pairs(v) do --одна пара
		MY_DATA[k] = {
			desc = str,
			id = i,
			sym = string.char(i+64), -- A+
			fn = nil, --Function to return the proper string. By default: desc + " " + param1
			percent = nil, --To add "%" at the end of the number
		}
		v.key = k --Записываем ключ в отдельную переменную. Вообще это ужасный костыль, лучше не трогать теперь.
		break
	end
end


local function DefaultDisplayFn(arr) --На вход особая структура: { data, param }. data - ссылка на элемент MY_DATA, a param - ссылка на массив п.
	if arr.data == nil then
		return arr.param_str --Выводим строку в том виде, в каком пришла от сервера (без первого символа)
	end
	if arr.data.sign ~= nil and (tonumber(arr.param[1]) or -1) >= 0 then
		arr.param[1] = "+" .. tostring(arr.param[1])
	end
	local s = arr.data.desc .. " " .. tostring(arr.param[1])
	if arr.data.percent ~= nil then
		s = s .. "%"
	end
	return s
end
CallDefaultDisplayFn = DefaultDisplayFn --Для языкового модуля.

local function DefaultFraction(arr) --Типичный вывод: "Название: cur / max"
	local cur,mx = arr.param[1], arr.param[2]
	return arr.data.desc .. " " .. cur .. " / " .. mx 
end

MY_DATA.sanity.fn = function(arr)
	local str = DefaultDisplayFn(arr)
	if arr.param[2] == '1' then -- on pick up
		return str .. SHOWME_STRINGS.onpickup
	end
	return str
end
MY_DATA.hp.fn = function(arr) --Формирование строки на клиенте.
	local cur,mx = arr.param[1], arr.param[2]
	return cur .. " / " .. mx 
end
MY_DATA.owner.fn = function(arr) --Формирование строки на клиенте
	return arr.data.desc .. " " .. arr.param_str  --Игнорируем запятые, если есть в имени.
end
MY_DATA.loyal.fn = function(arr) --Формирование строки на клиенте
	if (tonumber(arr.param[1]) or 0) > 9000 then
		return arr.data.desc .. " " .. SHOWME_STRINGS.loyal 
	end
	return DefaultDisplayFn(arr) --Игнорируем запятые, если есть в имени.
end

MY_DATA.water.fn = DefaultFraction
MY_DATA.water_poisoned.fn = function(arr)
	return arr.data.desc
end

local function DataTimerFn(seconds)
    if (not seconds) then
		return 'error'
	end
	local total = math.abs(tonumber(seconds))
	local hours = math.floor(total * 0.0002777777777777) --целое кол-во часов. 1/3600
	local mins = math.floor((total - (hours * 3600)) * 0.01666666666666) --целое. 1/60
	local secs = total - (hours * 3600) - (mins * 60) --тоже должно быть целым.
	return 
		(hours > 0 and (hours .. ':'
			.. (mins > 9 and mins or ('0' .. mins)) .. ':'
			.. (secs > 9 and secs or ('0' .. secs))
		) or ( mins .. ':'
			.. (secs > 9 and secs or ('0' .. secs))
		))
end
MY_DATA.timer.fn = function(arr)
	local name = arr.param[2]
	return arr.data.desc
		.. (name and (' "'..name..'": ') or ': ')
		.. DataTimerFn(arr.param[1])
end

-- MY_DATA.timer.fn = function(arr)
	-- local total = _G.tonumber(arr.param[1])
	-- local name = arr.param[2]
	-- local hours = math.floor(total * 0.0002777777777777) --целое кол-во часов. 1/3600
	-- local mins = math.floor((total - (hours * 3600)) * 0.01666666666666) --целое. 1/60
	-- local secs = total - (hours * 3600) - (mins * 60) --тоже должно быть целым.
	-- return arr.data.desc
		-- .. (name and (' "'..name..'": ') or ': ')
		-- .. (hours > 0 and (hours .. ':'
			-- .. (mins > 9 and mins or ('0' .. mins)) .. ':'
			-- .. (secs > 9 and secs or ('0' .. secs))
		-- ) or ( mins .. ':'
			-- .. (secs > 9 and secs or ('0' .. secs))
		-- ))
-- end
MY_DATA.durability.fn = DefaultFraction

MY_DATA.dmg.fn = function(arr)
	local str = DefaultDisplayFn(arr)
	if arr.param[2] then --buff time
		str = str .. ', ' .. DataTimerFn(arr.param[2])
	end
	return str
end
MY_DATA.armor.fn = MY_DATA.dmg.fn
MY_DATA.effectiveness.fn = MY_DATA.dmg.fn

-- Temperature: +10, 0:05
MY_DATA.food_temperature.fn = function(arr) -- { temperature, time }
	local temperature_str = arr.param[1]
	if tonumber(temperature_str) > 0 then
		temperature_str = '+' .. temperature_str
	end
	local time_str = DataTimerFn(arr.param[2])
	return SHOWME_STRINGS.temperature .. ': ' .. temperature_str .. ', ' .. time_str
end                                                                          

MY_DATA.sanity_character.percent = true
MY_DATA.sanity.sign = true
MY_DATA.sanityaura.sign = true
MY_DATA.dmg_character.percent = true
MY_DATA.dmg_character.sign = true
MY_DATA.speed.percent = true
MY_DATA.speed.sign = true
MY_DATA.temperature.sign = true
MY_DATA.armor.percent = true
MY_DATA.armor_character.percent = true
MY_DATA.armor_character.sign = true
MY_DATA.waterproof.percent = true
MY_DATA.dmg_bonus.sign = true

MY_DATA.watergainspeed.sign = true
MY_DATA.sip.sign = true

MY_DATA.trade_gold.sign = true
MY_DATA.trade_rock.sign = true

MY_DATA.effectiveness.percent = true
MY_DATA.force.percent = true
MY_DATA.repairer.sign = true

local AOS_Temperature_fn --Клиентская функция конвертирования игровых юнтов температуры в визуальные.

local is_Fahrenheit = false
local function ConvertTemperature(val)
	if not val then
		return "???"
	end
	if is_Fahrenheit then
		return math.floor(1.8*(val) + 32.5).."\176F" 
	else
		return math.floor(val/2 + 0.5) .. "\176C"
	end
end

MY_DATA.temperature.sign = true
MY_DATA.temperature.fn = function(arr)
	arr.param[1] = AOS_Temperature_fn and AOS_Temperature_fn(tonumber(arr.param[1])) or ConvertTemperature(tonumber(arr.param[1]))
	return DefaultDisplayFn(arr)
end

--Возвращает полноценное название предмет. Берет из локальных переменных, так что должна быть переведено.
local function GetPrefabFancyName(prefab)
	local product = tostring(prefab or "nil")
	return _G.STRINGS.NAMES[string.upper(product)] or product
end

MY_DATA.cookpot.fn = function(arr)
	return arr.data.desc .. " " .. GetPrefabFancyName(arr.param[1])
end
MY_DATA.food.fn = function(arr)
	local hg,sn,hp = arr.param[1],arr.param[2],arr.param[3]
	if food_order <= 1 then
		if food_style <= 1 then
			return MY_DATA.hunger.desc .. " "..hg.." / "..MY_DATA.sanity.desc.." "..sn.." / "..MY_DATA.health.desc.." "..hp
		else
			return hg.." / "..sn.." / "..hp
		end
	else
		if food_style <= 1 then
			return MY_DATA.health.desc.." "..hp.." / "..MY_DATA.hunger.desc.." "..hg.." / "..MY_DATA.sanity.desc.." "..sn
		else
			return hp.." / "..hg.." / "..sn
		end
	end
end
MY_DATA.units_of.fn = function(arr)
	local s = FOOD_TAGS[arr.param[2]]
	s = s ~= "" and s or arr.param[2] --If translation exists.
	if arr.param[1] == "1" then
		return SHOWME_STRINGS.units_1 .. s
	else
		return arr.param[1] .. SHOWME_STRINGS.units_many .. s
	end
end
MY_DATA.uses_of.fn = function(arr)
	if arr.param[1] == "1" then
		return SHOWME_STRINGS.uses_1 .. arr.param[2]
	else
		return arr.param[1] .. SHOWME_STRINGS.uses_many .. arr.param[2]
	end
end
MY_DATA.perish.fn = function(arr)
	return arr.data.desc .. " " .. arr.param[1] .. SHOWME_STRINGS.days
end

MY_DATA.stale.fn = function(arr)
	return arr.data.desc .. " " .. arr.param[1] .. SHOWME_STRINGS.days
end

local PerishFunction = function(arr)
	return MY_DATA.perish.fn(arr) --Redirect to perish function with another description - "Will die in..."
end

MY_DATA.will_die.fn = PerishFunction
MY_DATA.will_dry.fn = PerishFunction --Здесь тоже просто делаем ссылку.
MY_DATA.grow_in.fn = PerishFunction
MY_DATA.just_time.fn = PerishFunction

MY_DATA.frigde.fn = function(arr)
	local v = tonumber(arr.param[1]);
	if v == 0 then
		return 'No rot'; --hard coded
	elseif v == 1 then
		return 'Broken';
	elseif v > 1 then
		return 'Hot +'..round2((v-1)*100)..'%';
	elseif v > 0.5 then
		return 'Weak +'..round2((v-0.5)*200)..'%';
	elseif v > 0 then
		return 'Cold +'..round2((0.5-v)*200)..'%';
	elseif v < 0 then
		return 'Refresh +'..round2((-v)*100)..'%';
	end
	return 'Paradox '..tostring(v); --error
end                                      
local CONST_COUNT = { ['1'] = '(1)', ['2'] = '(2)', ['3'] = '(3)', ['4'] = '(4)', ['5'] = '(5)', ['6'] = '(6)', ['7'] = '(7)',
	 ['8'] = '(8)', ['9'] = '(9)', ['10'] = '(10)', ['11'] = '(11)', ['12'] = '(12)', ['13'] = '(13)', ['14'] = '(14)', 
	 ['15'] = '(15)', ['16'] = '(16)', ['17'] = '(17)', ['18'] = '(18)', ['19'] = '(19)', ['20'] = '(20)', 
	 ['21'] = '(21)', ['22'] = '(22)', ['23'] = '(23)', ['24'] = '(24)', ['25'] = '(25)', 
	 ['26'] = '(26)', ['27'] = '(27)', ['28'] = '(28)', ['29'] = '(29)', ['30'] = '(30)', 
	 ['31'] = '(31)', ['32'] = '(32)', ['33'] = '(33)', ['34'] = '(34)', ['35'] = '(35)', 
	 ['36'] = '(36)', ['37'] = '(37)', ['38'] = '(38)', ['39'] = '(39)', ['40'] = '(40)', 
	 ['0'] = '', --Если нет конмонента stackable, то не показываем количество вообще.
}

--Особая функция вида "ПРОДУКТ: ВРЕМЯ"
--param[1] - продукт
--param[2] - оставшееся количество дней или nil
MY_DATA.perish_product.fn = function(arr)
	local name = GetPrefabFancyName(arr.param[1]) .. (
		CONST_COUNT[arr.param[2]] or ('(' .. tostring(arr.param[2]) .. ')')
	)
	if not arr.param[3] then --Время не указано.
		return name
	end
	arr.param[1] = arr.param[3] --dirty hack!!! Preparing for using in PerishFunction
	--arr.param[2] = nil --need not
	return name.. ":" .. PerishFunction(arr) -- desc == ""
end

MY_DATA.heal.sign = true
MY_DATA.fuel.percent = true
MY_DATA.obedience.percent = true
MY_DATA.domest.percent = true
--MY_DATA.fuel.percent = true
--MY_DATA.fuel.percent = true
--MY_DATA.fuel.percent = true

MY_DATA.crop.fn = function(arr) -- Product: percent
	return GetPrefabFancyName(arr.param[1]) .. ": " .. tostring(arr.param[2]) .. "%"
end

MY_DATA.growable.fn = function(arr) -- stage num or name, time, paused (1/0)
	arr=arr.param;
	local stagename = tonumber(arr[1]) and ('#' .. tostring(arr[1])) or tostring(arr[1]);
	local time_str = DataTimerFn(arr[2]);
	return stagename .. (arr[3] == '1' and ' ('..SHOWME_STRINGS.paused..'): ' or ': ') .. time_str;
end

--MY_STRINGS_OVERRIDE = nil

--Сокрытие некоторой (назойливой) информации.
if show_food_units == 0 or show_food_units == 2 then
	MY_DATA.units_of.hidden = true --Work on client only.
end



--Попытка определить клиентские моды и отправить их через RPC
AddModRPCHandler("ShowMe","AOS",function(inst)
	--Вызов этой функции означает отключение подсказок на деревьях для данного игрока.
	inst.has_AlwaysOnStatus = true
end)

--Учитывать ли статус порчи для конкретного пользователя.
AddModRPCHandler("ShowMe","Estimate",function(inst)
	--Вызов этой функции означает отключение подсказок на деревьях для данного игрока.
	inst.should_Estimate_Stale = true
end)

--local AOS_Temperature_fn --Функция конвертирования игровой температуры у клиента. (Объявлена ранее)

--Залезаем в клиентский интерфейс с целью уменьшить показываемую температуру
if CLIENT_SIDE then
	--Делаем самую правильную в мире функцию "AddPlayersPostInit" 
	--GetGlobal("mods",{})
	--if not _G.rawget(_G,"mods") then _G.rawset(_G,"mods",{}) end
	if not mods.player_preinit_fns then
		mods.player_preinit_fns={}
		--Dirty hack
		local old_MakePlayerCharacter = _G.require("prefabs/player_common")
		local function new_MakePlayerCharacter(...)
			local inst=old_MakePlayerCharacter(...)
			for _,v in ipairs(mods.player_preinit_fns) do
				v(inst)
			end
			return inst
		end
		_G.package.loaded["prefabs/player_common"] = new_MakePlayerCharacter
	end

	local function AddPlayersPreInit(fn)
		table.insert(mods.player_preinit_fns,fn)
	end

	local player_postinit_fns = {}
	local function AddPlayersPostInit(fn) -- <<<--------- Вот она!
		table.insert(player_postinit_fns,fn)
	end

	local done_players = {}
	AddPlayersPreInit(function(inst)
		local s = inst.prefab or inst.name
		if not done_players[s] then
			done_players[s] = true
			AddPrefabPostInit(s,function(inst)
				for _,v in ipairs(player_postinit_fns) do
					v(inst)
				end
			end)
		end
	end)

	local player_afterinit_fns = {}
	function AddPlayersAfterInit(fn) --Нулевой таймер после
		table.insert(player_afterinit_fns,fn)
	end
	AddPlayersPostInit(function(inst) --Задаем нулевой таймер
		if #player_afterinit_fns > 0 then
			inst:DoTaskInTime(0,function(inst)
				for i=1,#player_afterinit_fns do
					player_afterinit_fns[i](inst)
				end
			end)
		end
	end)
	
	--А вот и не угадали. Не трогаем интерфейс. Вместо этого определяем настройки и лишь в случае их отсутствия трогаем интерфейс.
    
	--Проверка температуры. Обратный формат и приведение к универсальному Цельсию.
	local tonumber = _G.tonumber
	local function FixTemperature(s)
		if type(s) ~= "string" then
			return s --Вообще не строка. Что за?
		end
		--На конце может быть один из конкретных вариантов строки.
		local sep = s:find("\176",1,true)
		if not sep then
			return s --Разделитель не найден.
		end
		local pre, pst = tonumber(s:sub(1,sep-1)), s:sub(sep+1)
		if not pre then
			return s --Первая часть строки не является числом.
		end
		if pst == "C" then
			return s --Это Цельсий. Не надо конвертировать.
		elseif pst == "F" then
			--Фаренгейт. Сложный случай. В целом тоже не надо трогать. Но меняем локальные настройки на Фаренгейт.
			is_Fahrenheit = true
			return s
		else
			--Иначе (по умолчанию) считаем, что температура в игровых единицах. Исправляем это дело на Цельсий.
			return ConvertTemperature(pre) --TODO: Есть небольшая погрешность в уменьшение. При температуре 5.1 покажется цифра 2, хотя должна 3.
		end
	end
	
    local AOS_UNITS, AOS_UNIT
	
	--Функция исправления интерфейса на клиенте. Запускается для всех игроков при появлении.
	local function FixClient(inst)
		if inst ~= _G.ThePlayer then
			return
		end
		
		--По-хакерски добавляем отправку настроек предпочтения показа еды
		if true then--food_estimation == 1 then
			--print("SendRPC")
            SendModRPCToServer(MOD_RPC.ShowMe.Estimate) -- if this is not made, the values will be wrong for stale items
		end
		
		local status = inst.HUD and inst.HUD.controls and inst.HUD.controls.status
		if not status then
			print("ERROR SHOW_ME: Can't fix client side status!")
			return
		end
		local AOS
		AOS_UNITS = TUNING.COMBINED_STATUS_UNITS
		AOS_UNIT = TUNING.COMBINED_STATUS_UNIT
		if (AOS_UNITS and AOS_UNIT and AOS_UNITS[AOS_UNIT]) then
			AOS = true
			AOS_Temperature_fn = AOS_UNITS[AOS_UNIT]
		else --older version of AOS
			if status.temperature then
				AOS = true
				local old_SetString = status.temperature.num.SetString
				status.temperature.num.SetString = function(self,s,...)
					return old_SetString(self,FixTemperature(s),...)
				end
			end
			if status.worldtemp then
				AOS = true
				local old_SetString = status.worldtemp.num.SetString
				status.worldtemp.num.SetString = function(self,s,...)
					return old_SetString(self,FixTemperature(s),...)
				end
			end
		end
		if AOS then
			SendModRPCToServer(MOD_RPC.ShowMe.AOS)
		end
	end
	AddPlayersAfterInit(FixClient) 
end


-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- HOST -----------------------------------------------------------------
--Works only on host.
if TheNet and TheNet:GetIsServer() then
require = _G.require





--Detecting enabled mods
local mod_names	 --названия всех модов (чтобы не дергать джвижок)
local mod_names_nover --названия модов с обрезанной версией (если смысловая часть достаточно длинная)
mod_names = {}
mod_names_nover = {}
local function GetAllModNames()
	if not (_G.KnownModIndex and _G.KnownModIndex.savedata and _G.KnownModIndex.savedata.known_mods
		and _G.ModManager and _G.ModManager.enabledmods)
	then
		return
	end
	local folders = {} --ассоциативный массив включенных модов (по папкам)
	for _,v in ipairs(_G.ModManager.enabledmods) do
		folders[v]=true
	end
	for folder, mod in pairs(_G.KnownModIndex.savedata.known_mods) do
		local name = mod.modinfo.name
		if name then
			mod_names[name]=folders[folder] and true or false
			--print("NEW_MOD: "..name.." "..tostring(mod_names[name]))
			local s=string.match(name,"^(.-)([0-9%._ ]+)$")
			if s then
				mod_names_nover[s]=name --обрезаем номер версии с конца
				--вместо true сохраняем полное имя мода (чтобы идентифицировать его в системе)
			else
				mod_names_nover[name]=name
			end
		end
	end
end
GetAllModNames()
mods.mod_names = mod_names
mods.mod_names_nover = mod_names_nover


local function SearchForModsByName()
	if mods.active_mods_by_name then
		return --Уже проинициализировано. Либо полная несовместимость.
	end
	mods.active_mods_by_name = {}
	if not (_G.KnownModIndex and _G.KnownModIndex.savedata and _G.KnownModIndex.savedata.known_mods) then
		print("ERROR COMMON LIB: Can't find KnownModIndex!")
		return
	end
	for name,mod in pairs(_G.KnownModIndex.savedata.known_mods) do
		if (mod.enabled or mod.temp_enabled or _G.KnownModIndex:IsModForceEnabled(name)) --Мод активен
			and not mod.temp_disabled --И не отключен
		then
			local real_name = mod.modinfo.name
			if real_name == nil then
				print("SHOW_ME ERROR: real_name of a mod is nil,",tostring(name))
				--TODO: error if TUNING.STAR_DEBUG 
			else
				mods.active_mods_by_name[real_name] = true
			end
		end
	end
end	
SearchForModsByName()
	
local is_HealthInfo = mods.active_mods_by_name["Health Info"] --Check it to decide, is there a reason to show hp in description.
local is_DisplayFoodValues = mods.active_mods_by_name["Display food values"]
--TODO: Эта проверка нужна на клиенте!
local is_AlwaysOnStatus = mods.active_mods_by_name["Combined Status"] or mods.active_mods_by_name["Always On Status"]
--_G.arr(mod_names)

local cooking = require("cooking")
local ing = cooking.ingredients
--local config = GetModConfigData("message_style") or 1

--local backdoors = GetGlobal("backdoors",{})
--backdoors.ShowMe={MY_STRINGS=MY_STRINGS} --welcome for translaters!
--for k,v in pairs(MY_STRINGS) do
--	MY_STRINGS[k]=v[config] --overwrites with string config values --Нельзя заменять, т.к. мы теперь используем ключи.
--end

--Добавляет строку в конец дескрипшена
--desc - исходная строка (копия), val - готовое значение, txt - ключ описания, no_table - если true, то ключ используется как строка.
--[[local function cn(desc,val,txt,no_table)
	if no_table then
		return (desc=="" and "" or (desc.."\n"))..txt.." "..tostring(val)
	elseif MY_STRINGS[txt] ~= nil and MY_STRINGS[txt][2] ~= nil then
		return (desc=="" and "" or (desc.."\n"))
			..MY_STRINGS[txt][2]
			..tostring(val)
	else
		return (desc=="" and "" or (desc.."\n"))..val.." (bug?)"
	end
end--]]

local ww
AddPrefabPostInit("world",function(inst)
	ww = inst.state
end)


------------------------------------------Current Beefalo Status-------------------------------------
local Hunger = "Hunger "
local Obey = "Obedience "
local Process = "Tamed "
AddComponentPostInit("inspectable", function(inst)
    local oldGetDesc = inst.GetDescription
    function inst:GetDescription(viewer)
        local desc = oldGetDesc(self,viewer)
        if self.inst and self.inst.components and self.inst.components.domesticatable then
            is_admin = nil
            local item = self.inst
            local prefab = item.prefab
            if type(desc)~="string" then
                desc=""
            end
            local c=item.components
            if c.domesticatable then 
                local myhunger = c.hunger and c.hunger.current or 0
                local myobey = c.domesticatable:GetObedience()*100
                local mydomesticate = c.domesticatable:GetDomestication()*100
                desc = (desc.."\n")..Hunger..tostring(round2(myhunger,1))
                desc = (desc.."\n")..Obey..tostring(round2(myobey,2)).."%"
                desc = (desc.."\n")..Process..tostring(round2(mydomesticate,2)).."%"
            end
        end
        return desc
    end
end)

AddPlayerPostInit(function(inst)
    inst.MountStartTime = 0
    inst:ListenForEvent("mounted",function(inst)
        inst.MountStartTime = _G.GetTime()
    end)
    inst:ListenForEvent("dismounted",function(inst)
        inst.MountStartTime = 0
    end)
end)

local function GetPerishTime(inst,c)
	local modifier = 1
	local owner = c.inventoryitem and c.inventoryitem.owner or nil
	if not owner and c.occupier then
		owner = c.occupier:GetOwner() --Для птичек?
	end

	if owner then
		if owner.components.preserver ~= nil then
			modifier = owner.components.preserver:GetPerishRateMultiplier()
		elseif owner:HasTag("fridge") then
			if inst:HasTag("frozen") and not owner:HasTag("nocool") and not owner:HasTag("lowcool") then
				modifier = TUNING.PERISH_COLD_FROZEN_MULT
			else
				modifier = TUNING.PERISH_FRIDGE_MULT
			end
		elseif owner:HasTag("foodpreserver") then
			modifier = TUNING.PERISH_FOOD_PRESERVER_MULT
		elseif owner:HasTag("spoiler") then
			modifier = TUNING.PERISH_GROUND_MULT
		elseif owner:HasTag("cage") and inst:HasTag("small_livestock") then
			modifier = TUNING.PERISH_CAGE_MULT
		end
	else
		modifier = TUNING.PERISH_GROUND_MULT
	end

	if inst:GetIsWet() then
		modifier = modifier * TUNING.PERISH_WET_MULT
	end

	
	if ww.temperature < 0 then
		if inst:HasTag("frozen") and not c.perishable.frozenfiremult then
			modifier = TUNING.PERISH_COLD_FROZEN_MULT
		else
			modifier = modifier * TUNING.PERISH_WINTER_MULT
		end
	end

	if c.perishable.frozenfiremult then
		modifier = modifier * TUNING.PERISH_FROZEN_FIRE_MULT
	end

	if ww.temperature > TUNING.OVERHEAT_TEMP then
		modifier = modifier * TUNING.PERISH_SUMMER_MULT
	end

	if c.perishable.localPerishMultiplyer then
		modifier = modifier * c.perishable.localPerishMultiplyer
	end

	modifier = modifier * TUNING.PERISH_GLOBAL_MULT
	
	local old_val = c.perishable.perishremainingtime
	if old_val ~= nil then
		local delta = old_val / modifier
        if delta ~= nil and delta >= 0 then
			return delta,modifier
		end
	end
end



--Новая функция
local desc_table
local function cn(key,param1,param2,param3)
    local data = MY_DATA[key]
    if data == nil then
        return
    end
    if param1 == nil then
		table.insert(desc_table, data.sym)
		return 
	end
	if param2 == nil then
		table.insert(desc_table, data.sym ..tostring(param1))
		return 
	end
	if param3 == nil then
		table.insert(desc_table, data.sym ..tostring(param1) .. "," ..tostring(param2))
		return
	end
	table.insert(desc_table, data.sym ..tostring(param1) .. "," ..tostring(param2) .. "," ..tostring(param3))
	return 
end


function CalcDamage(self, weapon)
    local multiplier = 1
    local target = nil
    local basedamage
    local basemultiplier = self.damagemultiplier
    local externaldamagemultipliers = self.externaldamagemultipliers
    local bonus = self.damagebonus --not affected by multipliers
    local playermultiplier = 1
    local pvpmultiplier = 1

    --NOTE: playermultiplier is for damage towards players
    --      generally only applies for NPCs attacking players

    if weapon ~= nil then
        --No playermultiplier when using weapons
        -- basedamage = weapon.components.weapon:GetDamage(self.inst, target) or 0 -- we have no target and devs tend to forget ~=nil checks, so too dangerous to use GetDamage()
        basedamage = weapon.components.weapon~=nil and weapon.components.weapon.damage~=nil and type(weapon.components.weapon.damage)=="number" and weapon.components.weapon.damage or 0
        playermultiplier = 1
    else
        basedamage = self.defaultdamage
        playermultiplier = playermultiplier and self.playerdamagepercent or 1

        if self.inst.components.rider ~= nil and self.inst.components.rider:IsRiding() then
            local mount = self.inst.components.rider:GetMount()
            if mount ~= nil and mount.components.combat ~= nil then
                basedamage = mount.components.combat.defaultdamage
                basemultiplier = mount.components.combat.damagemultiplier
                externaldamagemultipliers = mount.components.combat.externaldamagemultipliers
                bonus = mount.components.combat.damagebonus
            end

            local saddle = self.inst.components.rider:GetSaddle()
            if saddle ~= nil and saddle.components.saddler ~= nil then
                basedamage = basedamage + saddle.components.saddler:GetBonusDamage()
            end
        end
    end

    return basedamage
        * (basemultiplier or 1)
        * self.externaldamagemultipliers:Get()
        * playermultiplier
        * pvpmultiplier
        -- * (self.customdamagemultfn ~= nil and self.customdamagemultfn(self.inst, target, weapon, multiplier) or 1) -- does not work without target
        + (bonus or 0)
end

local function GetFoodTemperature(self) -- unfortunately edible has no function like this, we have to copy paste from the oneaten function...    
    local delta_multiplier = 1
    local duration_multiplier = 1
    local temperaturedelta_final = 0
    local temperatureduration_final = 0
    if self.temperaturedelta ~= 0 and self.temperatureduration ~= 0 and self.chill < 1 then
        if self.spice and TUNING.SPICE_MULTIPLIERS[self.spice] then
            if TUNING.SPICE_MULTIPLIERS[self.spice].TEMPERATUREDELTA then
                delta_multiplier = delta_multiplier + TUNING.SPICE_MULTIPLIERS[self.spice].TEMPERATUREDELTA -- spice only increases hot/cold, but does not add it itself
            end
            if TUNING.SPICE_MULTIPLIERS[self.spice].TEMPERATUREDURATION then
                duration_multiplier = duration_multiplier + TUNING.SPICE_MULTIPLIERS[self.spice].TEMPERATUREDURATION
            end
        end
        -- Food is an implicit heater/cooler if it has temperature
        temperaturedelta_final = self.temperaturedelta * (1 - self.chill) * delta_multiplier
        temperatureduration_final = self.temperatureduration * duration_multiplier
    end
    return {temperaturedelta_final,temperatureduration_final}
end

local spicedfoods = require("spicedfoods") -- to get buff effects
local preparedfoods = require("preparedfoods") 
local preparedfoods_warly = require("preparedfoods_warly") 

--Hack for LRP
--[[if _G.rawget(_G,"RussificationVersion") and _G.RussificationVersion<"3.6" then
	local player = _G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PLAYER
	if player then --Add some spaces to strings. So they are incorruptible.
		player.GENERIC = "It  is %s!"
		player.ATTACKER = "That %s looks  shifty..."
		player.MURDERER = "Murderer !"
		player.REVIVER = "%s, friend  of ghosts."
		player.GHOST = "%s could use a	heart."
	end
end --]]


local is_admin
local last_user_talbe = {}
--Проверяет, является ли чел админом.
local function IsAdmin(viewer)
	if is_admin ~= nil then
		return is_admin
	end
	if not (viewer and viewer.userid) then
		return false
	end
	for i=1,#last_user_talbe do
		local user = last_user_talbe[i]
		if user.userid == viewer.userid then
			is_admin = user.admin or false
			return is_admin
		end
	end
	last_user_talbe = _G.TheNet:GetClientTable()
	for i=1,#last_user_talbe do
		local user = last_user_talbe[i]
		if user.userid == viewer.userid then
			is_admin = user.admin or false
			return is_admin
		end
	end
end


local function name_by_id(userid)
	for i,v in ipairs(_G.AllPlayers) do
		if v.userid == userid then
			return v.name
		end
	end
	return "---Unknown---"
end
--GetGlobal("name_by_id",name_by_id)

--local TemperatureFormatLocal

local SPICIAL_STRUCTURES = {
	campfire = true, coldfire = true, firesuppressor = true, redlantern = true, lantern = true,
}

--add a timer to player, so wood repairer info active
local function AddBoatStatus(viewer)
	if viewer.boat_status_task then
		viewer.boat_status_task:Cancel()
	end
	viewer.boat_status_task = viewer:DoTaskInTime(120,function(inst)
		inst.boat_status_task = nil
	end)
end
--Основная функция получения описания.
function GetTestString(item,viewer) --Отныне форкуемся от Tell Me, ибо всё сложно.
	--line_cnt = 0
	desc_table = {} --старый desc отменяется
			
	is_admin = nil
	local prefab = item.prefab
	local c=item.components
	local has_owner = false --Выводим инфу о владельце лишь ОДИН раз!
	if (prefab=="evergreen" or prefab=="deciduoustree") and not viewer.has_AlwaysOnStatus and show_worldstatus==1 then
		--if not is_AlwaysOnStatus then --TODO: Do not check! NB!
			local w=_G.TheWorld.state
			local tt=round2(w.temperature,1)
			if w.iswinter then cn("S1")
			elseif w.issummer then cn("S2")
			elseif w.isspring then cn("S3")
			elseif w.isautumn then cn("S4")
			end
			cn("remaining_days",w.remainingdaysinseason)
			cn("temperature",tt)
				--..MY_STRINGS["remaining_days"][2]..": "..w.remainingdaysinseason.."\n"
				--.."t "..(tt>=0 and "+" or "")..tt
		--end
	elseif c.health and not item.grow_stage then --Health, Hunger, Sanity Bar
		local h=c.health
		--cheat
		if item.is_admin then
			cn("is_admin")
			return desc_table[1]
		end
		
		if not is_HealthInfo then --c.health
			local mx=math.ceil(h.maxhealth-h.minhealth)
			local cur=math.ceil(h.currenthealth-h.minhealth)
			if cur>mx then cur=mx end
			cn("hp",cur,mx)
		end
		
		if c.hunger then
			local val = c.hunger:GetPercent()
			--Либо голода мало, либо это вообще не игрок.
			if (c.grogginess and val <= 0.5) or (not c.grogginess and (val > 0 or prefab ~= "beefalo")) then
				cn("hunger",round2(c.hunger.current,0))
			end
		elseif c.perishable ~= nil and c.perishable.updatetask ~= nil then --Here "Perishable" means "Hunger".
			local time,modifier = GetPerishTime(item, c)
			if time ~= nil then
				cn("will_die",round2(time/TUNING.TOTAL_DAY_TIME,1))
			end
        end
		if c.sanity and c.sanity:GetPercent()<=0.5 then
			local sanity = round2(math.floor(c.sanity:GetPercent()*100+0.5),1)
			cn("sanity_character",sanity)
		end
		if c.follower then
			if c.follower.leader and c.follower.leader:IsValid() and c.follower.leader:HasTag("player")
				and c.follower.leader.name and c.follower.leader.name ~= ""
			then
				cn("owner",c.follower.leader.name)
				has_owner = true
			end
			if c.follower.maxfollowtime then
				mx = c.follower.maxfollowtime
				cur = math.floor(c.follower:GetLoyaltyPercent()*mx+0.5)
				if cur>0 then
					cn("loyal",cur,mx)
				end
			end
		end
        if show_creature_speed==1 then
            if c.locomotor and type(c.locomotor.walkspeed)=="number" then
                local speed = c.locomotor:GetWalkSpeed() 
                local runspeed = c.locomotor:GetRunSpeed()
                if runspeed~=nil then
                    cn("creature_speed",tostring(round2(speed,2)).." / "..tostring(round2(runspeed,2))) -- speed, and run speed
                else
                    cn("creature_speed",round2(speed,2)) 
                end
            end 
        end
		if item.kills and item.kills>0 then
			cn(item.kills==1 and "kill" or "kills",item.kills)
		end
		if item.aggro and item.aggro>0 then
			cn("aggro",item.aggro)
		end
		if c.combat and c.combat.damagemultiplier and c.combat.damagemultiplier ~= 1 then
			local perc = c.combat.damagemultiplier - 1
			cn("dmg_character",round2(perc*100,0))
		end
        --Урон
		if c.combat and c.combat.defaultdamage and c.combat.defaultdamage > 0 then
			
            
            --Игнорируем всех, чья сила равна 10 или меньше.
			local com = c.combat
            if c.rider and c.rider:IsRiding() then
                local beef = c.rider:GetMount()
                local saddle = c.rider:GetSaddle()
                if beef~=nil then
                    local dmg = beef.components and beef.components.combat and beef.components.combat.defaultdamage or 0
                    if saddle~=nil and saddle.components and saddle.components.saddler then
                        dmg = dmg + saddle.components.saddler:GetBonusDamage()
                    end
                    cn("beefstrength", math.floor( dmg + 0.5))
                end
            else
                -- local dmg = com.defaultdamage * (com.playerdamagepercent or 1)
                -- cn("strength", math.floor( dmg + 0.5))
                local damamge = nil
                local item = nil
                if c.inventory~=nil then 
                    item = c.inventory:GetEquippedItem(_G.EQUIPSLOTS.HANDS)
                    -- print("Showme found item in hand"..tostring(item))
                    if item~=nil and item.components.weapon==nil then
                        item = nil -- then it is not a weapon
                    end
                end
                damamge = CalcDamage(c.combat,item)
                -- print("shwome damage: "..tostring(damamge).." weapon: "..tostring(item))
                cn("strength", math.floor(damamge+0.5))
                if com.areahitdamagepercent then --AoE
                    cn("aoe", math.floor( damamge * com.areahitdamagepercent + 0.5))
                end
            end
		end
		if h.absorb~=0 or h.playerabsorb~=0 then
			local perc = 1-(1-h.absorb)*(1-h.playerabsorb)
			cn("armor_character",round2(perc*100,0))
		end
		if item.asunaheal_score and item.prefab == "asuna" and TUNING.ASUNA_HEAL_SCORE_SWORD
			and item.asunaheal_score < TUNING.ASUNA_HEAL_SCORE_SWORD
		then
			local asuna_proof = round2(math.floor((item.asunaheal_score/TUNING.ASUNA_HEAL_SCORE_SWORD)*100+0.5),0)
			if asuna_proof > 99 then
				asuna_proof = 99
			end
			table.insert(desc_table, "$Asuna Proof: "..asuna_proof.."%")
		end
		-- if c.domesticatable ~= nil then -- stattdessen ausgeben, wenn examined
			-- if c.domesticatable.GetObedience ~= nil then
				-- local obedience = c.domesticatable:GetObedience()
				-- if obedience ~= 0 then
					-- cn("obedience",round2(obedience*100,0))
				-- end
			-- end
			-- if c.domesticatable.GetDomestication ~= nil then
				-- local domest = c.domesticatable:GetDomestication()
				-- if domest ~= 0 then
					-- cn("domest",round2(domest*100,0))
				-- end
			-- end
		-- end
        -- if c.rideable ~= nil then -- show uses of saddle when on beefalo ... but uses only reduce when the saddle is thrown off from beefalo, so there is no need in showing it while it is on beefalo
            -- local saddle = c.rideable.saddle
            -- if not saddle then
                -- local rider = c.rideable:GetRider()
                -- if rider and rider.components and rider.components.rider then
                    -- saddle = rider.components.rider:GetSaddle()
                -- end
            -- end
            -- if saddle and saddle.components and saddle.components.finiteuses then
                -- local mult = 1
                -- if saddle.components.finiteuses.consumption then
                    -- for k,v in pairs(saddle.components.finiteuses.consumption) do
                        -- mult = 1/v
                    -- end
                -- end
                -- local cur = math.floor(saddle.components.finiteuses.current * mult + 0.5)
                -- if saddle.components.finiteuses.current > cur then
                    -- cur = cur + 1
                -- end
                -- cn("uses_of",cur,math.floor(saddle.components.finiteuses.total * mult + 0.5))
            -- end
        -- end
        if c.moisture~=nil then
            if c.moisture:GetMoistureRate() > 0 then
                cn("moisturerate",round2(c.moisture:GetMoistureRate(),3).."/s")
            end
        end
        local mount = c.rider~=nil and c.rider:GetMount() or nil
        if mount~=nil then
            if mount.components.health~=nil then
                cn("beefalohealth",round2(mount.components.health.currenthealth,0))
            end
            if mount._bucktask~=nil then
                local bucktime = mount._bucktask.period or 0 -- get the total time directly from the task defined in beefalo script
                cn("bucktime",round2(math.max(item.MountStartTime+bucktime-_G.GetTime(),0),0).."sec") -- bucktime wird runtergezählt
            end
        end
        if c.growable and c.growable.GetStage then
			local g = c.growable
            local t = (g.pausedremaining ~= nil and math.max(0, math.floor(g.pausedremaining)))
				or (g.targettime ~= nil and math.floor(g.targettime - _G.GetTime()))
				or nil
			if t then
				local stage = g.stage ~= 1 and tonumber(g.stage) or 1;
				local data = g.stages and g.stages[stage];
				cn("growable",data and data.name or stage,round2(t),g.pausedremaining ~= nil and 1 or 0);
			end
		end
        if c.sanityaura then
			local s = c.sanityaura;
			local aura_val = s.aurafn and s.aurafn(item, viewer) or s.aura
			if aura_val then
				if s.fallofffn then -- fallofffn but not distance
					local fall = s.fallofffn(item, viewer, 99)
					if fall and fall ~= 0 and (fall < 0.98 or fall > 1.02) then
						aura_val = aura_val / fall;
					end
				end
				aura_val = round2(aura_val * TUNING.TOTAL_DAY_TIME * 0.125,1) --240 hardcoded. I'm not sure what it is
				if aura_val ~= 0 then
					cn("sanityaura",aura_val)
				end
			end
		end
	else --elseif prefab~="rocks" and prefab~="flint" then --No rocks and flint
        -- speed from home bonus mod
        if c.locomotor and type(c.locomotor.walkspeed)=="number" and (item.prefab=="turf_woodfloor" or item.prefab=="turf_carpetfloor" or item.prefab=="turf_checkerfloor") then -- added by serp to show carpet mod bonus 
            local speed = c.locomotor:GetExternalSpeedMultiplier(item) -- get the external speed from mods
			if speed>1.01 or speed<0.99 then
				cn("creature_speed","x"..round2(speed,2))
			end
		end 
		--Part 1: primary info
		if c.stewer and c.stewer.product and c.stewer.IsCooking and c.stewer:IsCooking() then
			local tm=round2(c.stewer.targettime-_G.GetTime(),0)
			if tm<0 then tm=0 end
			cn("cookpot", c.stewer.product)
			cn("sec",tm)
        elseif c.stewer and c.stewer.IsCooking and not c.stewer:IsCooking() then
            cn("nothing","") -- make it back to normal
		end
        if c.cooldown and c.cooldown.GetTimeToCharged and not c.cooldown.charged then
			local timer = round2(c.cooldown:GetTimeToCharged(),0)
			cn("cooldown", timer)
		end
        if c.growable and c.growable.GetStage then
			local g = c.growable
            local t = (g.pausedremaining ~= nil and math.max(0, math.floor(g.pausedremaining)))
				or (g.targettime ~= nil and math.floor(g.targettime - _G.GetTime()))
				or nil
			if t then
				local stage = g.stage ~= 1 and tonumber(g.stage) or 1;
				local data = g.stages and g.stages[stage];
				cn("growable",data and data.name or stage,round2(t),g.pausedremaining ~= nil and 1 or 0);
			end
		end
		--Part 2: secondary info
		if c.armor and c.armor.absorb_percent and type(c.armor.absorb_percent)=="number" then
			local r=c.armor.absorb_percent
			cn("armor",round2(r*100,0))
			--Support of absorption mod.
			if item.phys and (item.phys.blunt or item.phys.pierc or item.phys.slash) then
				local p = item.phys
				cn("absorb",(p.blunt or 0).." / "..(p.pierc or 0).." / "..(p.slash or 0))
			end
            if c.armor.condition and c.armor.condition > 0 and c.armor.maxcondition then
				cn("durability", math.floor(c.armor.condition + 0.5), math.floor(c.armor.maxcondition + 0.5))
			end
		end
		if item.damage and type(item.damage)=="number" and item.damage>0 then
			cn("dmg",round2(item.damage,1))
		elseif c.weapon ~= nil and c.weapon.damage and type(c.weapon.damage)=="number" and c.weapon.damage>0 then
			cn("dmg",round2(c.weapon.damage,1))
			--Support of absobtion mod.
			if item.phys_dmg then
				local p = item.phys_dmg == "blunt" and "Blunt" or (
					item.phys_dmg == "pierc" and "Piercing" or (
						item.phys_dmg == "slash" and "Slashing" or nil
					)
				)
				if p ~= nil then
					table.insert(desc_table, "$Type: "..p)
				end
			end
		elseif c.zupalexsrangedweapons ~= nil
			and c.zupalexsrangedweapons.GetArrowBaseDamage ~= nil
			and type(c.zupalexsrangedweapons.GetArrowBaseDamage) == "function"
		then
			local dmg = c.zupalexsrangedweapons:GetArrowBaseDamage()
			if dmg ~= nil and type(dmg) == "number" and dmg > 0 then
				cn("dmg",round2(dmg,1))
			end
		end
		if c.weapon and c.weapon.damage and type(c.weapon.attackrange)=="number" and c.weapon.attackrange>0.3 then
			cn("range",round2(c.weapon.attackrange,1))
		elseif c.projectile and c.projectile.damage and type(c.projectile.range)=="number" and c.projectile.range>0.3 then
			cn("range",round2(c.projectile.range,1))
		elseif c.combat and c.combat.damage and type(c.combat.attackrange)=="number" and c.combat.attackrange>2.5 then
			cn("range",round2(c.combat.attackrange,1))
		end
		if c.insulator and c.insulator.insulation and type(c.insulator.insulation)=="number" and c.insulator.insulation~=0 then
			if c.insulator.SetInsulationEx then --ServerMod
				local winter,summer = c.insulator:GetInsulationEx()
				if winter~=0 then
					cn("warm",round2(winter,0))
				end
				if summer~=0 then
					cn("summer",round2(summer,0))
				end
			elseif c.insulator.GetInsulation then
				local insul,typ = c.insulator:GetInsulation()
				if insul~=0 and typ == _G.SEASONS.WINTER then
					cn("warm",round2(insul,0))
				elseif insul~=0 and typ == _G.SEASONS.SUMMER then
					cn("summer",round2(insul,0))
				end
            end
		end
		if c.dapperness and c.dapperness.dapperness and type(c.dapperness.dapperness)=="number" and c.dapperness.dapperness~=0 then
			local sanity = round2(c.dapperness.dapperness*54,1)
			cn("sanity",sanity)
		elseif c.equippable and c.equippable.dapperness and type(c.equippable.dapperness)=="number" and c.equippable.dapperness~=0 then
			local sanity = round2(c.equippable.dapperness*54,1)
			cn("sanity",sanity)
		elseif prefab == "flower_evil" then
			cn("sanity",-_G.TUNING.SANITY_TINY,1)
        end
		if c.sanityaura then
			local s = c.sanityaura;
			local aura_val = s.aurafn and s.aurafn(item, viewer) or s.aura
			if aura_val then
				if s.fallofffn then -- fallofffn but not distance
					local fall = s.fallofffn(item, viewer, 99)
					if fall and fall ~= 0 and (fall < 0.98 or fall > 1.02) then
						aura_val = aura_val / fall;
					end
				end
				aura_val = round2(aura_val * TUNING.TOTAL_DAY_TIME * 0.125,1)
				if aura_val ~= 0 then
					cn("sanityaura",aura_val)
				end
			end
		end
        if c.equippable and c.equippable.walkspeedmult and c.equippable.walkspeedmult ~= 1 then
			local added_speed = math.floor((c.equippable.walkspeedmult - 1)*100+0.5)
			cn("speed",added_speed)
		end
		if c.dapperness and c.dapperness.mitigates_rain and prefab ~= "umbrella" then
			cn("waterproof","90")
		elseif item.protect_from_rain then
			cn("waterproof",round2((item.protect_from_rain)*100,0))
		elseif c.waterproofer then
			local effectiveness = _G.tonumber(c.waterproofer.effectiveness) or 0
			if effectiveness ~= 0 then
				cn("waterproof",round2((effectiveness)*100,0))
			else
				--desc = (desc=="" and "" or (desc.."\n")).."Waterproofer"
			end
		end
        if c.oar and c.oar.force and tonumber(c.oar.force) then
			cn('force',round2(c.oar.force*100))
		end
		--if c.striker and c.striker.chance and type(c.striker.chance) == "number" then
		--	desc = cn(desc,round2((c.striker.chance)*100,0).."%","striker")
		--end
		--if c.tinder and c.tinder.tinder and c.tinder.GetTinder then
		--	local power = c.tinder:GetTinder()
		--	if power >= 0.005 then
		--		desc = cn(desc,round2(power*100,0).."%","tinder")
		--	end
		--end
		if c.edible and not is_DisplayFoodValues then
			local can_eat = false
			if viewer and viewer.components.eater then
				can_eat = viewer.components.eater:CanEat(item)
			end
			if can_eat then
				local should_Estimate_Stale = viewer and viewer.should_Estimate_Stale --client priority
				if not should_Estimate_Stale then
					should_Estimate_Stale = food_estimation ~= 0
				end
				local hp,hg,sn
				if should_Estimate_Stale and c.edible.GetSanity then
					-- print("Estimate") -- is always done, because viewer.should_Estimate_Stale is always set to true
					hp=round2(c.edible:GetHealth(viewer),1)
					hg=round2(c.edible:GetHunger(viewer),1)
					sn=round2(c.edible:GetSanity(viewer),1)
				else
					-- print("Not Estimate")
					hp=round2(c.edible.healthvalue,1)
					hg=round2(c.edible.hungervalue,1)
					sn=round2(c.edible.sanityvalue,1)
				end
				if viewer ~= nil and viewer.FoodValuesChanger ~= nil then --Особая функция, призвание которой - менять еду при съедании.
					--print("+")
					--Правда, здесь мы можешь слегка подсмотреть ее результаты до поедания.
					local hp2, hg2, sn2 = viewer:FoodValuesChanger(item)
					if sn2 ~= nil then
						--print("++")
						hp=round2(hp2,1)
						hg=round2(hg2,1)
						sn=round2(sn2,1)
					end
				end
                if show_foodstats_multiplier==1 then --check eater specific multipliers
					if not viewer.components.eater:DoFoodEffects(item) then -- then no health and sanity loss (eg with strongstomach and eating monstermeat)
                        hp = 0
                        sn = 0
                    end
                    local base_mult = viewer ~= nil and viewer.components.foodmemory ~= nil and viewer.components.foodmemory:GetFoodMultiplier(prefab) or 1
					local eater = viewer.components.eater
                    local hp_mult = (eater.healthabsorption or 1) * base_mult
					local hg_mult = (eater.hungerabsorption or 1) * base_mult
					local sn_mult = (eater.sanityabsorption or 1) * base_mult
					hp = hp * hp_mult
					hg = hg * hg_mult
					sn = sn * sn_mult
				end
                if prefab=="petals_evil" then
                    sn = round2(sn - _G.TUNING.SANITY_TINY,1)
                end
				if hp > 0 then
					hp = "+" .. tostring(hp)
				end
				if hg > 0 then
					hg = "+" .. tostring(hg)
				end
				if sn > 0 then
					sn = "+" .. tostring(sn)
				end
				cn("food",hg,sn,hp)
                local FoodTemp = GetFoodTemperature(c.edible)
                local temperaturedelta_final = FoodTemp[1]
                local temperatureduration_final = FoodTemp[2]
                if temperaturedelta_final and temperaturedelta_final~=0 and temperatureduration_final then
                    local stri = ""
                    if temperaturedelta_final<0 then
                        stri = "Cold "..tostring(round2(temperaturedelta_final,1))
                    else
                        stri = "Hot "..tostring(round2(temperaturedelta_final,1))
                    end
                    local duration = ""
                    if temperatureduration_final<=5 then
                        duration = "Brief"
                    elseif temperatureduration_final<=10 then
                        duration = "Average"
                    elseif temperatureduration_final<=15 then
                        duration = "Long"
                    elseif temperatureduration_final<=20 then
                        duration = "Very Long"
                    elseif temperatureduration_final==TUNING.BUFF_FOOD_TEMP_DURATION then
                        local dur = round2(TUNING.BUFF_FOOD_TEMP_DURATION/TUNING.TOTAL_DAY_TIME,1)
                        duration = tostring(dur).." days long" -- 0.625 days
                    else
                        duration = "Duration "..tostring(temperatureduration_final)
                    end
                    local komplett = stri.." - "..tostring(duration)
                    cn("nothing",komplett)
                end
                local buffs = {}
                if spicedfoods[prefab]~=nil then
                    buffs = GLOBAL.ArrayUnion(buffs, spicedfoods[prefab].prefabs)
                elseif preparedfoods[prefab]~=nil then
                    buffs = GLOBAL.ArrayUnion(buffs,preparedfoods[prefab].prefabs)
                elseif preparedfoods_warly[prefab]~=nil then
                    buffs = GLOBAL.ArrayUnion(buffs,preparedfoods_warly[prefab].prefabs)
                end
                if GLOBAL.next(buffs) then
                    local buffsstring = ""
                    for _,b in ipairs(buffs) do
                        buffsstring = buffsstring..b.."  "
                    end
                    cn("nothing",buffsstring)
                end
			end
		end
		if c.perishable ~= nil and c.perishable.updatetask ~= nil and food_estimation~=0 then
			local time,modifier = GetPerishTime(item, c)
			if time ~= nil then
				if food_estimation==1 or food_estimation==3 then
                    local staletime = time - (c.perishable.perishtime / modifier / 2) -- when remainingtime reaches half of total time, it is stale
                    if staletime >= 0 then -- if it is already stale, no need to show 0 days.
                        cn("stale",round2(staletime/TUNING.TOTAL_DAY_TIME,2))
                    end
                end
                if food_estimation==2 or food_estimation==3 then
                    cn("perish",round2(time/TUNING.TOTAL_DAY_TIME,2))
                end
			end
		end
		if ing[prefab] and (display_units==1 or viewer:HasTag("ShowUnits")) then -- Serp
			for k,v in pairs(ing[prefab].tags) do
				if k~="precook" and k~="dried" then
					cn("units_of",v,k)
				end
			end
		end
		if c.healer then
			cn("heal",round2(c.healer.health,1))
		end
		--[[if item.grow_stage and type(item.grow_stage) == "number" then --Support Clan System mod
			local val = math.floor(item.grow_stage+0.5)
			desc = cn(desc,tostring(val).."%","power")
			if IsAdmin(viewer) then
				desc = cn(desc,item.show_stage,"show_stage",true)
				desc = cn(desc,item.grow_stage,"grow_stage",true)
				desc = cn(desc,item.active,"active",true)
				desc = cn(desc,item.fuel,"fuel",true)
			end
		else--]]
		if c.finiteuses and (showuses_item==1 and c.inventoryitem~=nil or showuses_other==1 and c.inventoryitem==nil) then
			local mult = 1
			if c.finiteuses.consumption then
				for k,v in pairs(c.finiteuses.consumption) do
					mult = 1/v
				end
			end
			local cur = math.floor(c.finiteuses.current * mult + 0.5)
			if c.finiteuses.current > cur then
				cur = cur + 1
			end
			cn("uses_of",cur,math.floor(c.finiteuses.total * mult + 0.5))
			--desc = (desc=="" and "" or (desc.."\n"))..cur.." use"..(cur~=1 and "s" or "").." of "..c.finiteuses.total
		end
		if c.temperature and c.temperature.current and type(c.temperature.current) == "number" then
			cn("temperature",round2(c.temperature.current,1))
		end
		if c.fueled and c.fueled:GetPercent()>0 and (item:HasTag("structure") or SPICIAL_STRUCTURES[prefab]) then
			cn("fuel",round2(c.fueled:GetPercent()*100,0))
		end
		if c.instrument and type(c.instrument.range)=="number" and c.instrument.range>0.4 then
			cn("range",round2(c.instrument.range,0))
		end
		if c.crystallizable and c.crystallizable.formation --support of Krizor's mod breakable ice
			and c.crystallizable.formation.thickness
			and type(c.crystallizable.formation.thickness)=="table"
			and c.crystallizable.formation.thickness.current
			and c.crystallizable.formation.thickness.current>0
		  then
            cn("thickness",round2(c.crystallizable.formation.thickness.current,1))
		end
		if c.mine then
			if c.mine.nick then
				cn("owner",c.mine.nick)
				has_owner = true
			end
			--[[if c.mine.pret and viewer and viewer.userid then
				for k,v in pairs(c.mine.pret) do
					if k==viewer.userid then
						--desc = (desc=="" and "" or (desc.."\n")).."I can see it!"
						desc = cn(desc,v,"known",true)
						break
					end
				end
			end--]]
		end
		if not has_owner then
			if item.stealable and item.stealable.owner and item.stealable.owner ~= "_?\1" then
				cn("owner",item.stealable.owner)
				has_owner = true
			elseif item.owner and type(item.owner)=="string" and string.sub(item.owner,1,3) ~= "KU_" then
				--Мы не знаем, что за имя. Но это "владелец". Так что надо вывести. И это точно не user_id.
				cn("owner",item.owner)
				has_owner = true
			end
		end
		if c.occupiable then
			local item = c.occupiable:GetOccupant()
			if item then
				local c = item.components
				if c.perishable ~= nil and c.perishable.updatetask ~= nil then --Here "Perishable" means "Hunger".
					local time,modifier = GetPerishTime(item, c)
					if time ~= nil then
						cn("will_die",round2(time/TUNING.TOTAL_DAY_TIME,1))
					end
				end
			end
		end
		if c.dryer and c.dryer.IsDrying then
			if c.dryer:IsDrying() and c.dryer.GetTimeToDry then
				cn("will_dry",round2(c.dryer:GetTimeToDry()/TUNING.TOTAL_DAY_TIME,1))
				--if c.dryer:IsPaused() then
				--end
			elseif c.dryer.IsDone and c.dryer:IsDone() and c.dryer.GetTimeToSpoil then
				cn("perish",round2(c.dryer:GetTimeToSpoil()/TUNING.TOTAL_DAY_TIME,1))
			end
		end
		if c.saddler then --Седло и его параметры.
			if c.saddler.speedmult and c.saddler.speedmult ~= 0 then
				local added_speed = math.floor((c.saddler.speedmult - 1)*100 + 0.5) -- (1.4 - 1) == 0.4
				cn("speed",added_speed)
			end
			if c.saddler.bonusdamage and c.saddler.bonusdamage ~= 0 then
				cn("dmg_bonus",round2(c.saddler.bonusdamage,1))
			end
		end
		if c.timer and c.timer.timers then
			local get_time = GetTime()
			for name, data in pairs(c.timer.timers) do
				cn('timer', round2(data.end_time - get_time,0), name)
			end
		end
		if c.tradable then
			if c.tradable.goldvalue and c.tradable.goldvalue > 0 then
				cn("trade_gold", c.tradable.goldvalue)
			end
			if c.tradable.rocktribute and c.tradable.rocktribute > 0 and _G.TheWorld.state.issummer then
				cn("trade_rock", c.tradable.rocktribute)
			end
        end
        if c.fishable and c.fishable.fishleft then
			cn(c.fishable.fishleft==1 and "fish" or "fishes",c.fishable.fishleft)
		end
        if TUNING.PERISH_FRIDGE_MULT ~= 0.5 and item:HasTag("fridge") then --icebox etc
			local fridge = tonumber(TUNING.PERISH_FRIDGE_MULT);
			if fridge then
				cn("frigde",round2(fridge,1))
			end
		end
		if viewer.boat_status_task and c.repairer and c.repairer.healthrepairvalue and c.repairer.healthrepairvalue ~= 0 then
			cn("repairer",round2(c.repairer.healthrepairvalue,2))
		end
        if item:HasTag("slingshotammo") then -- the damage is unfortunately not saved in the inventory object, but in prefab_proj ... so we could either spawn that projectile and get the damage, or we hardcode to use the tuning values...
            if prefab=="slingshotammo_rock" then
                cn("dmg",round2(TUNING.SLINGSHOT_AMMO_DAMAGE_ROCKS,1))
            elseif prefab=="slingshotammo_gold" then
                cn("dmg",round2(TUNING.SLINGSHOT_AMMO_DAMAGE_GOLD,1))
            elseif prefab=="slingshotammo_marble" then
                cn("dmg",round2(TUNING.SLINGSHOT_AMMO_DAMAGE_MARBLE,1))
            elseif prefab=="slingshotammo_thulecite" then
                cn("dmg",round2(TUNING.SLINGSHOT_AMMO_DAMAGE_THULECITE,1))
            elseif prefab=="slingshotammo_slow" then
                cn("dmg",round2(TUNING.SLINGSHOT_AMMO_DAMAGE_SLOW,1))
            elseif prefab=="trinket_1" then
                cn("dmg",round2(TUNING.SLINGSHOT_AMMO_DAMAGE_TRINKET_1,1))
            end
            
        end
		------------------Check prefabs?----------------------
		if prefab=="panflute" then
			--desc = cn("power","10")
		elseif prefab=="blowdart_sleep" then
			--desc = cn(desc,"1","power")
		--[[elseif prefab=="pond" and item.targettime then
			local tm = item.targettime - _G.GetTime()
			if tm>0 then
				desc = "Broken "..cn(desc,tm,"sec")
			elseif item.broken then
				desc = (desc=="" and "" or (desc.."\n")).."Broken"
			end--]]
		elseif prefab=="aqvarium" and item.data then
			if item.data.seeds and item.data.seeds>0 then
				table.insert(desc_table, "$Seeds: "..tostring(item.data.seeds))
			end
			if item.data.meat and item.data.meat>0 then
				table.insert(desc_table, "$Meat: "..tostring(item.data.meat))
				--desc = cn(desc,item.data.meat,"Meat:",true)
			end
			local need_wet= item.data.need_wet or 60
			if item.data.wet and item.data.wet>0 and item.data.wet<need_wet then
				table.insert(desc_table, "$Water: "..tostring(round2(100*item.data.wet/need_wet).."%"))
				--desc = cn(desc,round2(100*item.data.wet/need_wet).."%","Water:",true)
			end
			if item.total_heat then
				local temp = item.total_heat/10 --+ _G.TheWorld.state.temperature
				if temp>40 then temp = 40 end
				if temp>=0 then
					cn("temperature",tostring(round2(temp,1)))
				end
			end
		elseif prefab=="rainometer" then
            cn("precipitationrate",round2(easing.inSine(_G.TheWorld.state.precipitationrate, 0, 0.75, 1),3).."/s") 
            cn("wetness",round2(_G.TheWorld.state.wetness,1)) 
        elseif prefab=="winterometer" then
            local w=_G.TheWorld.state
			local tt=round2(w.temperature,1)
            cn("temperature",tt)
        elseif prefab=="moon_fissure" and c.sanityaura and c.sanityaura.aurafn then
			local current_sanity = c.sanityaura.aurafn(item, viewer)
			local max_sanity = 100/(TUNING.SEG_TIME*2) -- hardcoded!
			local effectiveness = current_sanity / max_sanity
			cn("effectiveness",round2(effectiveness * 100))
		elseif prefab=='boat' or prefab=='anchor' or prefab=='mast' or prefab=='boat_leak' or prefab=='mast_malbatross' or prefab=='steeringwheel' then
			--no info but boat status
			AddBoatStatus(viewer)                                              
        elseif prefab=="woby" or prefab=="wobysmall" or prefab=="wobybig" then
            if c.hunger then
				cn("hunger",round2(c.hunger.current,0))
			end
        end
		--Charges: lightning rod / lamp
		if item.chargeleft and item.chargeleft > 0 then	
			table.insert(desc_table, "$Days left: "..tostring(math.floor(item.chargeleft+0.5)))
		end
        --Mod support:
		if item.GetShowItemInfo then
			local custom1, custom2, custom3 = item:GetShowItemInfo()
			if custom1 then table.insert(desc_table, "$"..tostring(custom1)) end
			if custom2 then table.insert(desc_table, "$"..tostring(custom2)) end
			if custom3 then table.insert(desc_table, "$"..tostring(custom3)) end
		end
		if c.pickable and c.pickable.task then --Трава и ветки.
			local targettime = c.pickable.targettime
			if targettime then
				local delta = targettime - GetTime()
				if delta > 0 then
					cn("grow_in",round2(delta/TUNING.TOTAL_DAY_TIME,1)) --days
				end
			end
		end
		--[[if c.witherable then
			local time = GetTime()
			table.insert(desc_table, "$witherable: "
				..tostring(c.delay_to_time and (time-c.delay_to_time)) .. ", "
				..tostring(c.task_to_time and (time-c.task_to_time)) .. ", "
				..tostring(c.protect_to_time and (time-c.protect_to_time)) .. ", "
				..tostring(c.is_watching_rain)
			)
		end
		if c.diseaseable then
			local time = GetTime()
			table.insert(desc_table, "$diseaseable: "
				--..tostring(c._spreadtask and (time-c.delay_to_time)) .. ", "
				--..tostring(c.task_to_time and (time-c.task_to_time)) .. ", "
				--..tostring(c.protect_to_time and (time-c.protect_to_time)) .. ", "
				--..tostring(c.is_watching_rain)
			)
		end--]]
		--Грядки - это на самом деле высаженные всходы (мышка наводится на них поверх грядок).
		if c.crop and c.crop.product_prefab and c.crop.product_prefab and c.crop.growthpercent
			and type(c.crop.growthpercent) == 'number' and c.crop.growthpercent < 1
		then
			--Передаем названием продукта и процент созревания (до целых).
			cn("crop",c.crop.product_prefab,round2(c.crop.growthpercent*100,0))
		end
		--c.unwrappable.itemdata[1].prefab
		--c.unwrappable.itemdata[1].data.perishable.time - оставшееся время порчи в секундах.
		--	   .stackable.stack - количество
		if c.unwrappable and c.unwrappable.itemdata and type(c.unwrappable.itemdata) == 'table' then
			--По одной строке на каждый предмет.
			for i,v in ipairs(c.unwrappable.itemdata) do
				if v.prefab then
					--Пересылаем название префаба и количество дней.
					local delta = v.data and v.data.perishable and v.data.perishable.time
					local count = v.data and v.data.stackable and v.data.stackable.stack
					cn('perish_product', v.prefab, count or 0, delta and round2(delta/TUNING.TOTAL_DAY_TIME,1))
				end
			end
		end
		--Боченок рассола из мода "Pickle It!"
		if c.pickler and c.pickler.targettime then
			local delta = c.pickler.targettime - GetTime()
			cn('just_time', round2(delta/TUNING.TOTAL_DAY_TIME,1))
		end
		--Для мода "Thirst" проверяем компонент "cwater"
		if c.cwater then
			local w = c.cwater
			--Особо не заморачиваемся. Просто выводим то, что в нём есть.
			if w.current and w.max then
				cn('water',round2(w.current,0),round2(w.max,0))
			end
			if w.waterperdrink and type(w.waterperdrink)=="number" and w.waterperdrink ~= 0 then
				cn("sip",round2(w.waterperdrink,0))
			end
			if w.watergainspeed and type(w.watergainspeed)=="number" and w.watergainspeed ~= 0 then
				cn("watergainspeed",round2(w.watergainspeed,0))
			end
			if w.poisoned then
				cn("water_poisoned")
			end
		end
        if c.explosive~=nil then
            cn("explosive_damage",round2(c.explosive.explosivedamage or 0,1))
            cn("explosive_range",round2(c.explosive.explosiverange or 0,1))
        end
	end
	--Depending from weapon info:
	if viewer and type(viewer)=="table" and viewer.components and viewer.components.inventory then
		local weapon = viewer.components.inventory:GetEquippedItem(_G.EQUIPSLOTS.HANDS)
		if weapon then
			local resist = nil --base resist
			local total_resist = nil --base + bonus resist
			local now = nil --amount of current resist
			if weapon.prefab=="icestaff" and c.freezable then
				resist = c.freezable.resistance
				total_resist = c.freezable.ResolveResistance and c.freezable:ResolveResistance() or resist
				if c.freezable.coldness and c.freezable.coldness ~= 0 then
					now = round2(total_resist - c.freezable.coldness,1)
				end
				--cn("resist",c.freezable.resistance)
			elseif (weapon.prefab=="blowdart_sleep" or weapon.prefab=="panflute") and c.sleeper then
				resist = c.sleeper.resistance
				total_resist = resist -- there is sleep time bonus but not sleep armor bonus
				if c.sleeper.sleepiness and c.sleeper.sleepiness ~= 0 then
					now = round2(total_resist - c.sleeper.sleepiness,1)
				end
				--cn("resist",c.sleeper.resistance)
			end
			if resist then
				if total_resist ~= resist then
					resist = resist .. '+' .. round2(math.abs(total_resist-resist),1)
				end
				if now then
					resist = now .. ' / ' .. resist
				end
				cn("resist",resist)
			end
		end
	end
	if item.inlove and item.inlove>0 then
		if prefab=="chester" then
			cn("love",item.inlove/10)
		else
			cn("love",item.inlove)
		end
	end
	--Additional
	--[[
	if prefab=="chester" then
		local name = name_by_id(self.inst.userid)
		desc = (desc=="" and "" or (desc.."\n")).."Owner: "..name
			.."\nuserid="..tostring(self.inst.userid)
			.."\nLeader: "..tostring(c.follower.leader)
		has_owner = true
	end
	if prefab=="chester_eyebone" then
		local name = name_by_id(self.inst.userid)
		desc = (desc=="" and "" or (desc.."\n")).."Owner: "..name
			.."\nuserid="..tostring(self.inst.userid)
		has_owner = true
	end
	--]]
	--print("GetTestString: "..tostring(item)..", "..tostring(viewer)..", "..tostring(desc))
	--for i=1,line_cnt do
	--	desc = desc .. "\n" --Поднимаем описание предмета, чтобы оно было НАД предметом. Но лучше это сделать на клиенте.
	--end
	return table.concat(desc_table,"\2")
end

--Main description function
--[[
AddComponentPostInit("inspectable", function(inst)
	local oldGetDesc = inst.GetDescription
	function inst:GetDescription(viewer)
		local desc = oldGetDesc(self,viewer)
		if self.inst and self.inst.components then
			local item = self.inst
			if type(desc)~="string" then
				desc=""
			end
			local desc = GetTestString(item,viewer,desc)
		end
		return desc
	end
end)
--]]

--[[
AddPrefabPostInit("wes",function(wes)
	if wes.components and wes.components.talker then
		local oldSay = wes.components.talker.Say
		function wes.components.talker:Say(script, time, noanim)
			local test=type(script)=="string" and string.match(script,"([0-9]+ / [0-9]+)$") or ""
			if test then
				script=test
			else
				script=""
			end
			oldSay(self, script, time, noanim)
		end
		wes.components.talker.special_speech = false
	end
end)

GetGlobal("fol",function()
	
end)
--]]


end



------------------------------------------- HOST & CLIENT AGAIN ---------------------------------------------





--Добавляем подсказку для игрока, через которую будем пересылать данные (всплывающий текст с инфой под именем предмета)
do
	--Функция возвращает подсказку, если она в точности совпадает с присланной информацией (в player_classified).
	--И возвращает подсказку, либо "".
	local function CheckUserHint(inst)
		local c = _G.ThePlayer and _G.ThePlayer.player_classified
		if c == nil then --Нет локального игрока или classified
			return ""
		end
		--c.showme_hint1
		local i = string.find(c.showme_hint1,';',1,true)
		if i == nil then --Строка имеет неправильный формат.
			return ""
		end
		local guid = _G.tonumber(c.showme_hint1:sub(1,i-1))
		if guid ~= inst.GUID then --guid не совпадает (либо вообще nil)
			return ""
		end
		return c.showme_hint1:sub(i+1)
	end
	if CLIENT_SIDE then
		--patching Get Display Name. Нужно только клиенту.
		--[[local old_GetDisplayName = _G.EntityScript.GetDisplayName
		_G.EntityScript.GetDisplayName = function(self)
			local old_name = old_GetDisplayName(self)
			if type(old_name) ~= "string" then
				return old_name
			end
			local str2 = CheckUserHint(self)
			return old_name .. str2
		end--]]
		
		--Разбираем случаи, когда нужно отправить guid об объекте под мышью.
		local old_inst --Запоминаем, чтобы не спамить один и тот же inst по несколько раз.
		--[[AddWorldPostInit(function(w)
			w:DoPeriodicTask(0.1,function(w)
				if _G.ThePlayer == nil then
					return
				end
				local inst = _G.TheInput:GetWorldEntityUnderMouse()
				if inst ~= nil then
					if inst == old_inst then
						return
					end
					old_inst = inst
					--Посылаем желаемую подсказку.
					SendModRPCToServer(MOD_RPC.ShowMeSHint.Hint, inst.GUID, inst)
				end
			end)
		end)--]]
		
		local function UnpackData(str,div)
			local pos,arr = 0,{}
			-- for each divider found
			for st,sp in function() return string.find(str,div,pos,true) end do
				table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
				pos = sp + 1 -- Jump past current divider
			end
			table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
			return arr
		end		

		local save_target
		local last_check_time = 0 --последнее время проверки. Будет устаревать каждые 2 сек.
		local LOCAL_STRING_CACHE = {} --База данных строк, чтобы не обсчитывать замены каждый раз (правда, будет потихоньку пожирать память)
		AddClassPostConstruct("widgets/hoverer",function(hoverer) --hoverer=self
			-- hoverer.AddWaterproofRow = function()
                -- local img = Image("images/iteminfo_images.xml", "waterproof.tex")
                -- self:AddChild1(img)
            -- end
            
            -- hoverer.AddChild1 = function(img)
                -- local pos_y = 0 * RowHeight + RowHeight/2

                -- local width = ImageWidth + Spacing
                
                -- if width > self.width then
                    -- self.width = width
                -- end
                -- self.height = self.height + RowHeight
                
                -- local left = width/2 * -1
                
                -- img:SetPosition(left + ImageWidth/2, pos_y)
                
                -- self:AddChild(img)
                
            -- end
            
            local old_SetString = hoverer.text.SetString
			hoverer.text.SetString = function(text,str) --text=self
				--print(tostring(str))
				local target = _G.TheInput:GetHUDEntityUnderMouse()
				if target ~= nil then
					--target.widget.parent - это ItemTile
					target = target.widget ~= nil and target.widget.parent ~= nil and target.widget.parent.item --реальный итем (на клиенте)
				else
					target = _G.TheInput:GetWorldEntityUnderMouse()
				end
				--local lmb = hoverer.owner.components.playercontroller:GetLeftMouseAction()
				if target ~= nil then
					--print(tostring(target))
					--Проверяем совпадение с данными.
					local str2 = CheckUserHint(target)
                    -- print("Check User Hint before: "..str2)
					if str2 ~= "" then
						--Так, сначала чистим старую строку от переходов на новую строку. Мало ли какие там моды чего добавили.
						local cnt_newlines, _ = 0 --Считаем переходы строк в конце строки (совместимость с DFV)
						while cnt_newlines < #str do
							local ch = str:sub(#str-cnt_newlines,#str-cnt_newlines)
							if ch ~= "\n" and ch ~= " " then
								break
							end
							cnt_newlines = cnt_newlines + 1
						end
						--Очищаем строку от этого мусора
						if cnt_newlines > 0 then
							str = str:sub(1,#str-cnt_newlines)
						end
						--print(#str,"clear")
						--Очищаем строку от промежуточного мусора
						if string.find(str,"\n\n",1,true) ~= nil then
							str = str:gsub("[\n]+","\n")
						end
						--[[ --Теперь это не нужно, т.к. мы тупо добавляем 1 строку.
						if string.find(str,"\n",1,true) ~= nil then
							_,cnt_newlines = str:gsub("\n","\n") --Подсчитываем количество переходов внутри (если есть).
						else
							cnt_newlines = 0
						end
						--]]

						--Извлекаем данные из полученной упакованной строки.
						str2 = UnpackData(str2,"\2")
						local arr2 = {} --Формируем массив данных в удобоваримом виде.
						for i,v in ipairs(str2) do
							if v ~= "" then
								local param_str = v:sub(2)
								local data = { param = UnpackData(param_str,","), param_str=param_str }
								local my_s = MY_STRINGS[string.byte(v:sub(1,1))-64]
								if my_s ~= nil then
									data.data = MY_DATA[my_s.key]
								end
								table.insert(arr2,data)
							end
						end
						arr2.str2= str2
						--_G.rawset(_G,"arr2",arr2) --Для теста.
						--Формируем строку
						str2=""
						for i,v in ipairs(arr2) do
							if v.data ~= nil and v.data.fn ~= nil then
								str2=str2.. v.data.fn(v) .. "\n"
							elseif v.hidden == nil then
								str2=str2 .. DefaultDisplayFn(v) .. "\n"
							end
						end
						
						--_G.arr({inst=text.inst,hover=text.parent},5)
						--print("-----"..str.."-----")
						--local sss=""
						--for i=#str,#str-10,-1 do
						--	sss=sss..string.byte(str:sub(i,i))..", "
						--end
						--print("Chars: "..sss)
						--[[print(#str,"cut str")
						--В конце тоже убираем переход, если есть.
						if str:sub(#str,#str) == "\n" then
							str = str:sub(1,#str-1)
						end--]]
						--print(#str,"test cache")
						--print("count new cache")
						--print("newlines",#str2)
						
						str = str .. "\n" .. str2
						
						--Заново считаем количество оставшихся переходов строк
						--cnt_newlines = cnt_newlines + #arr2 + 1 --Всего переходов строк.
						--cnt_newlines = math.floor((#arr2 + 1) * 0.5) --Увеличиваем, но не сильно.
						cnt_newlines = 1
						--В конце добавляем переходы
						--Добавляем пустые строки в конец. TODO: Это надо только если предмет в инвентаре.
						while cnt_newlines > 0 do
							str = str .. "\n "
							cnt_newlines = cnt_newlines - 1
						end
					end
					-- print("Check User Hint: "..str2)
					--Если первый раз, то отправляем запрос.
					if target ~= save_target or last_check_time + 1 < GetTime() then
						save_target = target
						last_check_time = GetTime()
						SendModRPCToServer(MOD_RPC.ShowMeSHint.Hint, save_target.GUID, save_target)
					end
				else
					--print("target nil")
				end
				return old_SetString(text,str)
			end
		end)
	end
	
	--Обработчик на сервере
	AddModRPCHandler("ShowMeSHint", "Hint", function(player, guid, item)
		if player.player_classified == nil then
			print("ERROR: player_classified not found!")
			return
		end
		if item ~= nil and item.components ~= nil then
			local s = GetTestString(item,player) --Формируем строку на сервере.
			if s ~= "" then
				player.player_classified.net_showme_hint1:set(guid..";"..s) --Пакуем в строку и отсылаем обратно тому же игроку.
			end
		end
	end)

	--networking
	AddPrefabPostInit("player_classified",function(inst)
		inst.showme_hint1 = ""
		inst.net_showme_hint1 = _G.net_string(inst.GUID, "showme_hint1", "showme_hint_dirty1")
		if CLIENT_SIDE then
			inst:ListenForEvent("showme_hint_dirty1",function(inst)
				inst.showme_hint1 = inst.net_showme_hint1:value()
			end)
		end
	end)
end


