local G = GLOBAL
AddReplicableComponent("doc_query")
AddPlayerPostInit(function(inst)
    if G.TheWorld.ismastersim then inst:AddComponent("doc_query") end
end)
AddModRPCHandler("doc_query_demo", "CountFlowers", function(player, seq)
    if player == nil or not player:IsValid() or player:HasTag("playerghost") then return end
    if type(seq) ~= "number" or seq ~= seq or seq < 1 or seq > 65535 or seq ~= math.floor(seq) then return end
    local comp = player.components.doc_query
    if comp == nil or G.GetTime() < comp.next_request then return end
    comp.next_request = G.GetTime() + 1
    local x, y, z = player.Transform:GetWorldPosition()
    local flowers = G.TheSim:FindEntities(x, y, z, 8, { "flower" }, { "INLIMBO" })
    local replica = player.replica.doc_query
    if replica ~= nil then replica:SetReply(tostring(seq)..":"..tostring(math.min(#flowers, 9999))) end
end)
if not G.TheNet:IsDedicated() then
    AddClassPostConstruct("widgets/controls", function(self)
        local Text = G.require("widgets/text")
        local ImageButton = G.require("widgets/imagebutton")
        local label = self.topleft_root:AddChild(Text(G.UIFONT, 22, "Blumen: ?"))
        label:SetPosition(150, -150)
        local button = self.topleft_root:AddChild(ImageButton())
        button:SetText("Blumen zählen")
        button:SetPosition(150, -110)
        local seq = 0
        local next_request = 0
        local function Update()
            local replica = self.owner ~= nil and self.owner.replica.doc_query or nil
            if replica == nil then return end
            local id, count = replica:GetReply():match("^(%d+):(%d+)$")
            -- Dieser Callback behält die Mod-Umgebung; tonumber liegt in GLOBAL.
            if G.tonumber(id) == seq then label:SetString("Blumen: "..count) end
        end
        button:SetOnClick(function()
            if self.owner ~= G.ThePlayer or G.GetTime() < next_request then return end
            if self.owner.replica.doc_query == nil then return end
            next_request = G.GetTime() + 1.1
            seq = seq % 65535 + 1
            label:SetString("Blumen: Anfrage läuft")
            SendModRPCToServer(GetModRPC("doc_query_demo", "CountFlowers"), seq)
        end)
        self.inst:ListenForEvent("doc_query_updated", Update, self.owner)
    end)
end
