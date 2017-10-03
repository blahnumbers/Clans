-- UI class

WIN_W, WIN_H = get_window_size()

SQUARE = 1
ROUNDED = 2

LEFT = 0
CENTER = 1
RIGHT = 2

BTN_DN = 1
BTN_HVR = 2

do
	UIVisualManager = {}
	UIMouseHandler = {}
	
	UIElement = {}
	UIElement.__index = UIElement
	
	
	-- Spawns new UI Element
	-- Display is enabled by default, comment out line 60 to disable and use show() method instead
	function UIElement:new(o)
		local elem = {	parent = nil,
						child = {},
						text = nil,
						pos = { x = nil, y = nil },
						shift = { x = nil, y = nil },
						size = { w = nil, h = nil },
						bgColor = { 1, 1, 1, 0 },
						bgImage = nil,
						shapeType = SQUARE,
						customDisplayTrue = false,
						customDisplay = function() end,
						interactive = false,
						}
		setmetatable(elem, UIElement)
		
		o = o or nil
		if (o) then
			if (o.parent) then
				elem.parent = o.parent
				table.insert(elem.parent.child, elem)
				elem.shift.x = o.pos[1]
				elem.shift.y = o.pos[2]
			else
				elem.pos.x = o.pos[1]
				elem.pos.y = o.pos[2]
			end
			elem.size.w = o.size[1]
			elem.size.h = o.size[2]
			if (o.text) then elem.text = o.text end
			if (o.bgColor) then
				elem.bgColor = o.bgColor
			end
			if (o.bgImage) then elem.bgImage = load_texture(o.bgImage) end
			if (o.shapeType) then 
				elem.shapeType = o.shapeType
				if (o.rounded * 2 > elem.size.w or o.rounded * 2 > elem.size.h) then
					if (elem.size.w > elem.size.h) then
						elem.rounded = elem.size.h / 2
					else
						elem.rounded = elem.size.w / 2
					end
				else
					elem.rounded = o.rounded
				end
			end
			if (o.interactive) then 
				elem.interactive = o.interactive
				elem.hoverColor = o.hoverColor or nil
				elem.pressedColor = o.pressedColor or nil
				elem.hoverState = false
				elem.pressedPos = { x = nil, y = nil }
				elem.btnDown = function() end
				elem.btnUp = function() end
				elem.btnHover = function() end
				table.insert(UIMouseHandler, elem)
			end
		end
		
		table.insert(UIVisualManager, elem)
		return elem
	end
	
	function UIElement:addMouseHandlers(btnDown, btnUp, btnHover)
		if (btnDown) then
			self.btnDown = btnDown
		end
		if (btnUp) then
			self.btnUp = btnUp
		end
		if (btnHover) then
			self.btnHover = btnHover
		end
	end
	
	function UIElement:addCustomDisplay(funcTrue, func)
		self.customDisplayTrue = funcTrue
		self.customDisplay = func
	end
	
	function UIElement:kill()
		for i,v in pairs(self.child) do
			v:kill()
		end
		self:hide()
		self = {	pos = { x = nil, y = nil },
					size = { w = nil, h = nil },
					bgColor = { 1, 1, 1, 0 }
				}
		if (self.bgImage) then unload_texture(self.bgImage) end
	end
	
	function UIElement:display()
		if (not self.customDisplayTrue) then
			if (self.hoverState == BTN_HVR and self.hoverColor) then
				set_color(unpack(self.hoverColor))
			elseif (self.hoverState == BTN_DN and self.pressedColor) then
				set_color(unpack(self.pressedColor))
			else
				set_color(unpack(self.bgColor))
			end
			if (self.parent) then self:updateChildPos() end
			if (self.shapeType == ROUNDED) then
				draw_disk(self.pos.x + self.rounded, self.pos.y + self.rounded, 0, self.rounded, 500, 1, -180, 90, 0)
				draw_disk(self.pos.x + self.rounded, self.pos.y + self.size.h - self.rounded, 0, self.rounded, 500, 1, -90, 90, 0)
				draw_disk(self.pos.x + self.size.w - self.rounded, self.pos.y + self.rounded, 0, self.rounded, 500, 1, 90, 90, 0)
				draw_disk(self.pos.x + self.size.w - self.rounded, self.pos.y + self.size.h - self.rounded, 0, self.rounded, 500, 1, 0, 90, 0)
				draw_quad(self.pos.x + self.rounded, self.pos.y, self.size.w - self.rounded * 2, self.rounded)
				draw_quad(self.pos.x, self.pos.y + self.rounded,self.size.w, self.size.h - self.rounded * 2)
				draw_quad(self.pos.x + self.rounded, self.pos.y + self.size.h - self.rounded, self.size.w - self.rounded * 2, self.rounded)
			else
				draw_quad(self.pos.x, self.pos.y, self.size.w, self.size.h)
			end
			if (self.bgImage) then
				draw_quad(self.pos.x, self.pos.y, self.size.w, self.size.h, self.bgImage)
			end
		end	
		self.customDisplay()
	end
	
	function UIElement:show()
		table.insert(UIVisualManager, self)
		if (self.interactive) then
			table.insert(UIMouseHandler, self)
		end
	end
	
	function UIElement:hide()
		local num = nil
		for i,v in pairs(self.child) do
			v:hide()
		end
		if (self.interactive) then
			for i,v in pairs(UIMouseHandler) do
				if (self == v) then
					num = i
					break
				end
			end
			if (num) then
				table.remove(UIMouseHandler, num)
			else
				err(UIMouseHandlerEmpty)
			end
		end
		for i,v in pairs(UIVisualManager) do
			if (self == v) then
				num = i
				break
			end
		end
		
		if (num) then
			table.remove(UIVisualManager, num)
		else
			err(UIElementEmpty)
		end
	end
	
	function UIElement:handleMouseDn(s, x, y)
		for i, v in pairs(UIMouseHandler) do
			if (x > v.pos.x and x < v.pos.x + v.size.w and y > v.pos.y and y < v.pos.y + v.size.h) then
				v.hoverState = BTN_DN
				v.btnDown(s, x, y)
			end
		end
	end
	
	function UIElement:handleMouseUp(s, x, y)
		for i, v in pairs(UIMouseHandler) do
			if (x > v.pos.x and x < v.pos.x + v.size.w and y > v.pos.y and y < v.pos.y + v.size.h) then
				v.hoverState = BTN_HVR
				v.btnUp(s, x, y)
			end
		end
	end
	
	function UIElement:handleMouseHover(x, y)
		for i, v in pairs(UIMouseHandler) do
			if (x > v.pos.x and x < v.pos.x + v.size.w and y > v.pos.y and y < v.pos.y + v.size.h) then
				if (v.hoverState ~= BTN_DN) then
					v.hoverState = BTN_HVR
				end
				v.btnHover(x,y)
			else 
				v.hoverState = false
			end
		end
	end
	
	function UIElement:moveTo(x, y)
		self.pos.x = x
		self.pos.y = y
	end
	
	function UIElement:updateChildPos()
		if (self.shift.x < 0) then
			self.pos.x = self.parent.pos.x + self.parent.size.w + self.shift.x
		else
			self.pos.x = self.parent.pos.x + self.shift.x
		end
		if (self.shift.y < 0) then
			self.pos.y = self.parent.pos.y + self.parent.size.h + self.shift.y
		else
			self.pos.y = self.parent.pos.y + self.shift.y
		end
	end
	
	function UIElement:uiText(str, x, y, font, align, scale, angle)
		local font = font or FONTS.SMALL
		local font_mod = font
		local scale = scale or 1
		local angle = angle or 0
		local pos = 0
		local align = align or LEFT
		if (font == FONTS.BIG) then
			font_mod = 4.5
		elseif (font == 4) then
			font_mod = 2.4
		end
	
		str = textAdapt(str, font, scale, self.size.w)
		
		for i = 1, #str do
			if (align == CENTER) then
				xPos = x + self.size.w / 2 - get_string_length(str[i], font) * scale / 2 
			elseif (align == RIGHT) then
				xPos = x + self.size.w - get_string_length(str[i], font) * scale
			else
				xPos = x
			end
			if (self.size.h > (pos + 1) * font_mod * 10 * scale + font_mod * 10) then
				draw_text_angle_scale(str[i], xPos, y + (pos * font_mod * 10 * scale), angle, scale, font)
				if (font == FONTS.BIG or font == FONTS.MEDIUM) then
					draw_text_angle_scale(str[i], xPos, y + (pos * font_mod * 10 * scale), angle, scale, font)
				end
				pos = pos + 1
			elseif (i ~= #str) then
				draw_text_angle_scale(str[i]:gsub(".$", "..."), xPos, y + (pos * font_mod * 10 * scale), angle, scale, font)
				if (font == FONTS.BIG or font == FONTS.MEDIUM) then
					draw_text_angle_scale(str[i]:gsub(".$", "..."), xPos, y + (pos * font_mod * 10 * scale), angle, scale, font)
				end
				break		
			else
				draw_text_angle_scale(str[i], xPos, y + (pos * font_mod * 10 * scale), angle, scale, font)
				if (font == FONTS.BIG or font == FONTS.MEDIUM) then
					draw_text_angle_scale(str[i], xPos, y + (pos * font_mod * 10 * scale), angle, scale, font)
				end
			end			
		end
	end
	
	function textAdapt(str, font, scale, maxWidth)
		local destStr = {}
		
		while ((get_string_length(str, font) * scale) > maxWidth) do
			local newStr = string.match(str, "[^%s]+[%s]*")
			str = str:gsub(strEsc(newStr), "")
			str = addWord(destStr, str, newStr, font, scale, maxWidth)
		end
		table.insert(destStr, str)
		return destStr
	end
	
	function addWord(destStr, str, newStr, font, scale, maxWidth)		
		local word = string.match(str, "%a+.")
		if ((get_string_length(newStr .. word, font) * scale) < maxWidth) then
			str = str:gsub(word, "")
			newStr = newStr..word
			str = addWord(destStr, str, newStr, font, scale, maxWidth)
			return str
		else
			table.insert(destStr, newStr)
			return str
		end
	end
	
	function strEsc(str)
		return (str:gsub('%(', '%%(')
					:gsub('%)', '%%)')
					:gsub('%[', '%%[')
					:gsub('%]', '%%]'))
	end
end