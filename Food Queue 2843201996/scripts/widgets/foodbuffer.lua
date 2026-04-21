local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ItemSlot = require "widgets/itemslot"
local ImageButton = require "widgets/imagebutton"

local imageoverrides = {
  tomato="quagmire_tomato",
  tomato_cooked="quagmire_tomato_cooked",
  onion="quagmire_onion",
  onion_cooked="quagmire_onion_cooked"
}

local function XYToScreensize(x,y,screenX,screeny)
    -- w = w*scale.x
    -- h = h*scale.y
    
    -- x = math.max(x, w/2 + XOFFSET)
    -- x = math.min(x, scr_w - w/2 - XOFFSET)

    -- y = math.max(y, h/2 + YOFFSETDOWN*scale.y)
    -- y = math.min(y, scr_h - h/2 - YOFFSETUP*scale.y)
    
	local pos_x = screenX/2 + x
    local pos_y = y
    
    return pos_x,pos_y
end


local FoodBufferWidget = Class(Widget, function (self, owner)
  self.owner = owner
  Widget._ctor(self, "FoodBuffer")
  
  
  
  
  
  self.bg = self:AddChild(UIAnim())
  self.bg:GetAnimState():SetBank("foodbuffer")
  self.bg:GetAnimState():SetBuild("foodbuffer")
  self.bg:GetAnimState():PlayAnimation("idle")
  -- self:SetPosition(-1100, 100, 0)
  self:SetPosition(-1100, 100, 0)

  self._slots = {}
  for i = 1, 6 do
    local child = self.bg:AddChild(ItemSlot("images/hud.xml", "inv_slot.tex", self.owner))
    -- child:SetPosition(-191 + 78 * (6 - i), -4, 0)  -- orig
    -- child:SetPosition(-191 + 78 * (i-1), -4, 0) -- add the slots from left to right instead, so it is the same as buffer order. This looks better to me, but maybe add a setting for it..
    child:SetPosition(-191 + 78 * (i-1), -4, 0) -- add the slots from left to right instead, so it is the same as buffer order. This looks better to me, but maybe add a setting for it..
    self._slots[i] = child
  end
  
  -- add a close/open button
  self.open = true
  self.togglebutton = self:AddChild(ImageButton())
  self.togglebutton:ForceImageSize(35,35)
  self.togglebutton:SetOnClick( function() self:ToggleOpen() end )
  self.togglebutton:SetText("X")
  -- self.togglebutton:SetPosition(-240, 50, 0)
  self.togglebutton:SetPosition(-240, 50, 0)



  self:StartUpdating()
end)

function FoodBufferWidget:UpdatePosition(screenw,screenh)
    self.screenw, self.screenh = screenw,screenh
      print(screenw,screenh,hudscale.x,hudscale.y)
      -- [00:01:07]: 1920	1080	1	1	
      print(XYToScreensize(-1100,100,screenw,screenh,hudscale.x,hudscale.y))
      print(XYToScreensize(-240,100,screenw,screenh,hudscale.x,hudscale.y))
end

function FoodBufferWidget:OnUpdate(dt)
  if TheNet:IsServerPaused() then return end

  local screenw, screenh = TheSim:GetScreenSize()
  if self.screenw~=screenw or self.screenh~=screenh then
    self:UpdatePosition(screenw,screenh)
  end

  local buffer = self.owner.replica._foodbuffer:Buffer()
  
  for i, j in pairs(buffer) do
    if j ~= nil and j~=false then
      local ingredient = Ingredient(imageoverrides[j] and imageoverrides[j] or j, 1)
      if ingredient ~= nil and string.len(ingredient.type) > 1 then
        -- self._slots[i]:SetBGImage2(ingredient:GetAtlas(), ingredient.type..".tex", { 1, 1, 1, .4 + .1*(6-i) }) -- orig
        self._slots[i]:SetBGImage2(ingredient:GetAtlas(), ingredient.type..".tex", { 1, 1, 1, .4 + .1*(i) })
      end
    end
  end
  
end

-- add a close/open button
function FoodBufferWidget:ToggleOpen()
	self:SetOpen( not self:IsOpen() )
end
function FoodBufferWidget:SetOpen( state )
	if state == nil then state = true end
    if state then
		self.open = true
    	self.bg:Show()
	else
		self.open = false
    	self.bg:Hide()
	end
end
function FoodBufferWidget:IsOpen()
	return self.open
end

return FoodBufferWidget