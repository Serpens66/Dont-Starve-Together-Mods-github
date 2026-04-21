require "util"
require "strings"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Spinner = require "widgets/spinner"
local NumericSpinner = require "widgets/numericspinner"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/templates"

local PopupDialogScreen = require "screens/popupdialog"

local ScrollableList = require "widgets/scrollablelist"

local text_font = UIFONT

local enableDisableOptions = { { text = STRINGS.UI.OPTIONS.DISABLED, data = false }, { text = STRINGS.UI.OPTIONS.ENABLED, data = true } }
local spinnerFont = { font = BUTTONFONT, size = 30 }

local COLS = 2
local ROWS_PER_COL = 7

local fontz = NEWFONT_OUTLINE;

-- local ATLAS = "images/avatars.xml"

local letsDoDebug = false
local themodname = "Auto Actions"

local AASC = Class(Screen, function( self, lord )
    Screen._ctor(self, "AASC")
	
	self.thelord = lord
	
	self.client_config = false
	
	self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	-- self.black:SetTint(0,0,0,.85)	
	self.black:SetTint(0,0,0,0)
	
	self.root = self:AddChild(Widget("root"))
	self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0,0,0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
	
	self.bg = self.root:AddChild(Image( "images/newframe.xml", "mainframe.tex" ))
    self.bg:SetScale(1,1)
	
	local serverNameStr = "Auto Actions Settings"
    if not self.servertitle then
        self.servertitle = self.root:AddChild(Text(UIFONT,45))
        self.servertitle:SetColour(1,1,1,1)
    end
    self.servertitle:SetTruncatedString(serverNameStr, 800, 100, true)
	self.servertitle:SetPosition(0,215)
	
	local modname = KnownModIndex:GetModActualName(themodname) -- "Auto Actions - Local" "Auto Actions"
	
	self.modname = modname
	self.config = KnownModIndex:LoadModConfigurationOptions(modname, false)
	
	self.options = {}
	
	if self.config and type(self.config) == "table" then
		for i,v in ipairs(self.config) do
			-- Only show the option if it matches our format exactly
			if v.name and v.options and (v.saved ~= nil or v.default ~= nil) then
				local _value = v.saved
				if _value == nil then _value = v.default end
				table.insert(self.options, {name = v.name, label = v.longlabel or v.label, options = v.options, default = v.default, value = _value, hover = v.hover, originalvalue = _value})
			end
		end
	end

	self.started_default = self:IsDefaultSettings()
	
	self.option_offset = 0
	local xtable = {-205,0,205,-205,0,205,-205,0,205,-205,0,205};
	local ytable = {105,105,105,0,0,0,-105,-105,-105,-210,-210,-210};
	
	self.optionbuttons = {};
	local posID = 1
	local i = 1
	while i <= #self.options do
		if self.options[i] and self.options[i].name ~= "autoequipopeningamesettings" and string.match(self.options[i].name, "ae_") then
		
			local datalist = {};
			local fullimageopntions = {};
			local imageoptions = {};
			local idx = i
			for _,v in ipairs(self.options[idx].options) do
				local the_new_string = string.gsub(string.lower(v.description)," ","_") .. ".tex";
				table.insert(imageoptions,the_new_string)
				table.insert(datalist,v.data)
				table.insert(fullimageopntions,v.description)
			end
			
			local default_value = self.options[idx].value
			if default_value == nil then default_value = self.options[idx].default end
			
			if letsDoDebug then print("Current/default value is "..default_value) end
			if letsDoDebug then print("Current text is "..tostring(imageoptions[default_value+1])) end;
		
			self.optionbuttons[idx] = self.root:AddChild(ImageButton( "images/icons/"..(self.options[i].name)..".xml", imageoptions[default_value+1] ))
			self.optionbuttons[idx].theTitle = self.options[idx].label;
			self.optionbuttons[idx]:SetScale(1,1)
			self.optionbuttons[idx]:SetPosition(xtable[posID],ytable[posID])
			self.optionbuttons[idx]:SetFocusScale(1.05,1.05,1.05)
			self.optionbuttons[idx].cycleimages = imageoptions;
			self.optionbuttons[idx].selectedIndex = (default_value+1);
			self.optionbuttons[idx]:SetHoverText(self.optionbuttons[idx].theTitle.." - "..(fullimageopntions[default_value+1]),{offset_y = 100})
			self.optionbuttons[idx].onclick = function()
				if(table.getn(self.optionbuttons[idx].cycleimages) > 1) then
					if(self.optionbuttons[idx].cycleimages[self.optionbuttons[idx].selectedIndex+1] ~= nil) then
						self.optionbuttons[idx].selectedIndex = self.optionbuttons[idx].selectedIndex + 1;
						self.options[idx].value = datalist[self.optionbuttons[idx].selectedIndex]
						self.optionbuttons[idx]:SetTextures("images/icons/"..(self.options[idx].name)..".xml", self.optionbuttons[idx].cycleimages[self.optionbuttons[idx].selectedIndex] )
						self.optionbuttons[idx]:SetHoverText(self.optionbuttons[idx].theTitle.." - "..(fullimageopntions[self.optionbuttons[idx].selectedIndex]),{offset_y = 100})
						self:MakeDirty()
					else
						self.optionbuttons[idx].selectedIndex = 1;
						self.options[idx].value = datalist[1]
						self.optionbuttons[idx]:SetTextures("images/icons/"..(self.options[idx].name)..".xml", self.optionbuttons[idx].cycleimages[1] )
						self.optionbuttons[idx]:SetHoverText(self.optionbuttons[idx].theTitle.." - "..(fullimageopntions[1]),{offset_y = 100});
						self:MakeDirty()
					end
				end
			end
			self.optionbuttons[idx].SetToValue = function( val )
				self.optionbuttons[idx].selectedIndex = (val+1);
				self.optionbuttons[idx]:SetTextures("images/icons/"..(self.options[idx].name)..".xml", self.optionbuttons[idx].cycleimages[val+1] )
				self.optionbuttons[idx]:SetHoverText(self.optionbuttons[idx].theTitle.." - "..(fullimageopntions[val+1]),{offset_y = 100})
			end
			self.optionbuttons[idx].index = idx;
			
			posID = posID + 1
			
		end
		
		i = i + 1
	end
	
	if not TheInput:ControllerAttached() then
		self.menu = self.root:AddChild(Menu(nil, 0, true))
		self.resetbutton = self.menu:AddItem(STRINGS.UI.MODSSCREEN.RESETDEFAULT, function() self:ResetToDefaultValues() end,  Vector3(5, -210, 0))
		self.applybutton = self.menu:AddItem(STRINGS.UI.MODSSCREEN.APPLY, function() self:Apply() end, Vector3(165, -210, 0), "large")
		self.cancelbutton = self.menu:AddItem(STRINGS.UI.MODSSCREEN.BACK, function() self:Cancel() end,  Vector3(-155, -210, 0))
		self.applybutton:SetScale(.7)
		self.cancelbutton:SetScale(.7)
		self.resetbutton:SetScale(.7)
		self.menu:SetPosition(0,0)
	end
	
	--[[
    self.optionspanel = self.root:AddChild(Widget("optionspanel"))	
    self.optionspanel:SetPosition(0,-20)

	self.dirty = false

    self.optionwidgets = {}
	
	
	local lepanel = Widget("option")
	lepanel.letext = lepanel:AddChild(Text( NEWFONT, 25, "" ))
	lepanel.letext:SetColour( 255, 255, 255, 1 )
	lepanel.letext:SetPosition( 325, 10 )
	lepanel.letext:SetRegionSize( 650, 130 )
	lepanel.letext:SetHAlign( ANCHOR_MIDDLE )
	lepanel.letext:SetHoverText( "And thank you for using my mod <3 If you have suggestions to the mod, post them on the workshop page :)" )
	lepanel.focus_forward = lepanel.letext
	table.insert(self.optionwidgets, lepanel)
	
	local xtable = {-205,0,205,-205,0,205,-205,0,205};
	local ytable = {105,105,105,0,0,0,-105,-105,-105};

	local i = 1
	local label_width = 340
	while i <= #self.options do
		if self.options[i] then
			local spin_options = {} --{{text="default"..tostring(idx), data="default"},{text="2", data="2"}, }
			local spin_options_hover = {}
			local idx = i
			for _,v in ipairs(self.options[idx].options) do
				table.insert(spin_options, {text=v.description, data=v.data, colour={ 1, 1, 1, 1 }})
				spin_options_hover[v.data] = v.hover
			end
			
			local opt = Widget("option"..idx)
			
			local spinner_height = 40
			local spinner_width = 240
			opt.spinner = opt:AddChild(Spinner( spin_options, spinner_width, nil, {font=NEWFONT, size=25}, nil, nil, nil, true, 200, nil))
			opt.spinner:SetTextColour(255,255,255,1)
			local default_value = self.options[idx].value
			if default_value == nil then default_value = self.options[idx].default end
			
			opt.spinner.OnChanged =
				function( _, data )
					self.options[idx].value = data
					opt.spinner:SetHoverText( spin_options_hover[data] or "" )
					self:MakeDirty()
				end
			opt.spinner:SetSelected(default_value)
			opt.spinner:SetHoverText( spin_options_hover[default_value] or "" )
			opt.spinner:SetPosition( 475+70, 0, 0 )

			local label = opt.spinner:AddChild( Text( NEWFONT, 25, (self.options[idx].label or self.options[idx].name) or STRINGS.UI.MODSSCREEN.UNKNOWN_MOD_CONFIG_SETTING ) )
			label:SetColour( 255, 255, 255, 1 )
			label:SetPosition( -label_width/2 - 220, 0, 0 )
			label:SetRegionSize( label_width+150, 50 )
			label:SetHAlign( ANCHOR_RIGHT )
			label:SetHoverText( self.options[idx].hover or "" )
			if TheInput:ControllerAttached() then
				opt:SetHoverText( self.options[idx].hover or "" )
			end

			opt.spinner.OnGainFocus = function()
  				Spinner._base.OnGainFocus(self)
				opt.spinner:UpdateBG()
  			end
			opt.focus_forward = opt.spinner

			opt.id = idx
			
			table.insert(self.optionwidgets, opt)
			i = i + 1
		end
	end
	
	if not TheInput:ControllerAttached() then
		self.menu = self.root:AddChild(Menu(nil, 0, true))
		self.resetbutton = self.menu:AddItem(STRINGS.UI.MODSSCREEN.RESETDEFAULT, function() self:ResetToDefaultValues() end,  Vector3(5, -230, 0))
		self.applybutton = self.menu:AddItem(STRINGS.UI.MODSSCREEN.APPLY, function() self:Apply() end, Vector3(165, -230, 0), "large")
		self.cancelbutton = self.menu:AddItem(STRINGS.UI.MODSSCREEN.BACK, function() self:Cancel() end,  Vector3(-155, -230, 0))
		self.applybutton:SetScale(.7)
		self.cancelbutton:SetScale(.7)
		self.resetbutton:SetScale(.7)
		self.menu:SetPosition(5,0)
	end

	self.default_focus = self.optionwidgets[1]
	
	self.options_scroll_list = self.optionspanel:AddChild(ScrollableList(self.optionwidgets, 700, 350, 40, 10))
	if self.options_scroll_list.scroll_bar_line:IsVisible() then
		self.options_scroll_list:SetPosition(20, 0)
	else
		self.options_scroll_list:SetPosition(0, 0)
	end
	]]
end)

function AASC:ConfirmRevert(callback)
	TheFrontEnd:PushScreen(
		PopupDialogScreen( STRINGS.UI.MODSSCREEN.BACKTITLE, STRINGS.UI.MODSSCREEN.BACKBODY,
		  { 
		  	{ 
		  		text = STRINGS.UI.MODSSCREEN.YES, 
		  		cb = callback or function()
					TheFrontEnd:PopScreen()
				end
			},
			{ 
				text = STRINGS.UI.MODSSCREEN.NO, 
				cb = function()
					TheFrontEnd:PopScreen()
				end
			}
		  }
		)
	)		
end

function AASC:Cancel()
	if self:IsDirty() and not (self.started_default and self:IsDefaultSettings()) then
		self:ConfirmRevert(function()
			self:MakeDirty(false)
			TheFrontEnd:PopScreen()
			TheFrontEnd:PopScreen()
		end)
	else
		self:MakeDirty(false)
	    TheFrontEnd:PopScreen()
	end
end

function AASC:MakeDirty(dirty)
	if dirty ~= nil then
		self.dirty = dirty
	else
		self.dirty = true
	end
end

function AASC:IsDirty()
	return self.dirty
end

function AASC:CollectSettings()
	local settings = nil
	for i,v in pairs(self.options) do
		if not settings then settings = {} end
		table.insert(settings, {name=v.name, label = v.label, options=v.options, default=v.default, saved=v.value})
	end
	return settings
end

function AASC:Apply()
	if self:IsDirty() then
		local settings = self:CollectSettings()
		KnownModIndex:SaveConfigurationOptions(function() 
			self:MakeDirty(false)
		    TheFrontEnd:PopScreen()
		end, self.modname, settings, self.client_config)
	else
		self:MakeDirty(false)
	    TheFrontEnd:PopScreen()
	end
	
	self.thelord.updatesettings = true
end

function AASC:IsDefaultSettings()
	local alldefault = true
	for i,v in pairs(self.options) do
		-- print(options[i].value, options[i].default)
		if self.options[i].value ~= self.options[i].default then
			alldefault = false
			break
		end
	end
	return alldefault
end

function AASC:ResetToDefaultValues()
	local function reset()
		for k,v in pairs(self.optionbuttons) do
			if letsDoDebug then print("Resetting "..(self.options[v.index].name)) end
			self.options[v.index].value = self.options[v.index].default
			v.SetToValue(self.options[v.index].value)
		end
	end

	if not self:IsDefaultSettings() then
		self:ConfirmRevert(function() 
			TheFrontEnd:PopScreen()
			self:MakeDirty()
			reset()
		end)
	end
end

function AASC:OnControl(control, down)
    if AASC._base.OnControl(self, control, down) then return true end
    
    if not down then
	    if control == CONTROL_CANCEL then
			self:Cancel()
	    elseif control == CONTROL_PAUSE and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
	    	self:Apply() --apply changes and go back, or stay
    	elseif control == CONTROL_MAP and TheInput:ControllerAttached() then
			self:ResetToDefaultValues()
			return true
		else
    		return false
    	end 

    	return true
	end
end

return AASC