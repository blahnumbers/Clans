dofile("system/es_assistant_manager.lua")
dofile("toriui/uielement.lua")

ES:create()
ES:showMain()

add_hook("mouse_button_down", "uiMouseHandler", function(s, x, y) UIElement:handleMouseDn(s, x, y) end)
add_hook("mouse_button_up", "uiMouseHandler", function(s, x, y) UIElement:handleMouseUp(s, x, y) end)
add_hook("mouse_move", "uiMouseHandler", function(x, y) UIElement:handleMouseHover(x, y) end)
add_hook("key_up", "uiKeyboardHandler", function(key) UIElement:handleKeyUp(key) end)
add_hook("key_down", "uiKeyboardHandler", function(key) UIElement:handleKeyDown(key) end)
add_hook("draw2d", "esAssistantVisual", function() UIElement:drawVisuals() end)