-- modern main menu UI
-- DO NOT MODIFY THIS FILE

TB_MENU_MAIN_ISOPEN = TB_MENU_MAIN_ISOPEN or 0
TB_MENU_MATCHMAKE_ISOPEN = TB_MENU_MATCHMAKE_ISOPEN or 0
TB_MENU_NOTIFICATIONS_ISOPEN = 0
TB_LAST_MENU_SCREEN_OPEN = TB_LAST_MENU_SCREEN_OPEN or 2
TB_MENU_HOME_CURRENT_ANNOUNCEMENT = TB_MENU_HOME_CURRENT_ANNOUNCEMENT or 1
TB_MENU_OS_CLOCK_SHIFT = TB_MENU_OS_CLOCK_SHIFT or nil

if (TB_MENU_MAIN_ISOPEN == 1) then
	remove_hooks("tbMainMenuVisual")
	disable_blur()
	TB_MENU_MAIN_ISOPEN = 0
	tbMenuMain:kill()
	return
end

dofile("toriui/uielement.lua")
dofile("system/menu_manager.lua")
dofile("system/player_info.lua")
dofile("system/torishop_data.lua")
dofile("system/matchmake_manager.lua")
dofile("system/rewards_manager.lua")

TB_MENU_PLAYER_INFO = {}
TB_MENU_PLAYER_INFO.username = PlayerInfo:getUser()
TB_MENU_PLAYER_INFO.clan = PlayerInfo:getClan(TB_MENU_PLAYER_INFO.username)
TB_MENU_PLAYER_INFO.data = PlayerInfo:getUserData(TB_MENU_PLAYER_INFO.username)
TB_MENU_PLAYER_INFO.ranking = PlayerInfo:getRanking()
TB_MENU_PLAYER_INFO.items = PlayerInfo:getItems(TB_MENU_PLAYER_INFO.username)

--TB_MENU_TORISHOP_INFO = {}
--TB_MENU_TORISHOP_INFO.sale = TorishopData:getSaleItem()

TBMenu:create()
TBMenu:showMain()

add_hook("mouse_button_down", "uiMouseHandler", function(s, x, y) 
	UIElement:handleMouseDn(s, x, y) 
	if (TB_MENU_MAIN_ISOPEN == 1) then 
		return 1 
	end 
end)
add_hook("mouse_button_up", "uiMouseHandler", function(s, x, y) UIElement:handleMouseUp(s, x, y) end)
add_hook("mouse_move", "uiMouseHandler", function(x, y) 
	UIElement:handleMouseHover(x, y) 
	if (TB_MENU_MAIN_ISOPEN == 1) then 
		return 1 
	end 
end)
add_hook("draw2d", "tbMainMenuVisual", function() TBMenu:drawVisuals() end)
add_hook("draw_viewport", "tbMainMenuVisual", function() TBMenu:drawViewport() end)