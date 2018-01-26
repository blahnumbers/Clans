if (get_option("newshopitem") == 0) then
	return
end

dofile("system/noqi_announcement_manager.lua")
dofile("toriui/uielement.lua")

NQAnn:create()
NQAnn:showMain()

add_hook("mouse_button_down", "uiMouseHandler", function(s, x, y) UIElement:handleMouseDn(s, x, y) end)
add_hook("mouse_button_up", "uiMouseHandler", function(s, x, y) UIElement:handleMouseUp(s, x, y) end)
add_hook("mouse_move", "uiMouseHandler", function(x, y) UIElement:handleMouseHover(x, y) end)
add_hook("draw2d", "noQiAnnouncementVisual", function() LoginDaily:drawVisuals() end)