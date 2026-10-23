local G = GLOBAL
if G.TheNet:IsDedicated() then
    return
end
local Text = G.require("widgets/text")
AddClassPostConstruct("widgets/controls", function(self)
    if self.topleft_root == nil or self.doc_example_label ~= nil then
        return
    end
    self.doc_example_label = self.topleft_root:AddChild(Text(G.BODYTEXTFONT, 24, "Mod-Beispiel aktiv"))
    self.doc_example_label:SetPosition(180, -70, 0)
    -- A passive label should not capture gameplay mouse clicks.
    self.doc_example_label:SetClickable(false)
end)
