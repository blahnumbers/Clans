-- clans view script
-- made by sir

CLANVIEWLASTPOS = CLANVIEWLASTPOS or nil
FREEJOINENABLED = true

dofile("clans/clandatamanager.lua")
dofile("clans/uielement.lua")

local totalClans = Clan:getClanData()
local clan = Clan:create(ARG1)

Clan:getLevelData()
Clan:getAchievementData()

Clan:showMain()

if (clan.clanid) then
	Clan:showData(clan.clanid)
end

add_hook("draw2d", "clanVisual", function() Clan:drawVisuals() end)
add_hook("mouse_button_down", "uiMouseHandler", function(s, x, y) UIElement:handleMouseDn(s, x, y) end)
add_hook("mouse_button_up", "uiMouseHandler", function(s, x, y) UIElement:handleMouseUp(s, x, y) end)
add_hook("mouse_move", "uiMouseHandler", function(x, y) UIElement:handleMouseHover(x, y) end)