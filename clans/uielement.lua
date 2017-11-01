-- UI class

WIN_W, WIN_H = get_window_size()

SQUARE = 1
ROUNDED = 2

LEFT = 0
CENTER = 1
RIGHT = 2

BTN_DN = 1
BTN_HVR = 2

DEFTEXTURE = "torishop/icons/defaulticon.tga"

do
	UIElementManager = {}
	UIVisualManager = {}
	UIMouseHandler = {}
	
	UIElement = {}
	UIElement.__index = UIElement
	
	
	-- Spawns new UI Element
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
			if (o.bgColor) then	elem.bgColor = o.bgColor end
			if (o.bgImage) then 
				elem:updateImage(o.bgImage)
			end
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
				elem.scrollEnabled = o.scrollEnabled or nil
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
		
		table.insert(UIElementManager, elem)
		table.insert(UIVisualManager, elem) -- Display is enabled by default, comment this line out to disable
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
	
	function UIElement:addScrollFor(list, listElements, topBorder, botBorder, shiftPosList, shiftPosScroll, speed)
		local shiftPosList = shiftPosList or 0
		local shiftPosScroll = shiftPosScroll or 0
		local speed = speed or 1
		local elHeight = listElements[1].size.h
		local scrollMin = self.shift.y
		local scrollMax = self.parent.size.h - scrollMin - self.size.h
		local minHeight = list.shift.y
		local maxHeight = #listElements * elHeight
		local enabled = nil
		if (shiftPosList ~= 0) then
			enabled = list:getEnabled(listElements, -shiftPosList + minHeight)
		else
			enabled = list:getEnabled(listElements, 0)
		end
		
		self:addMouseHandlers(
			function(s, x, y)
				if (s < 4) then
					self.pressedPos = self:getLocalPos(x,y)
					self.hoverState = BTN_DN
				else
					self:mouseScroll(list, elHeight, scrollMin, scrollMax, minHeight, maxHeight, y * speed)
					enabled = self:scrollElements(listElements, topBorder, botBorder, enabled)
				end
			end, nil,
			function(x, y)
				if (self.hoverState == BTN_DN) then
					local lPos = self:getLocalPos(x,y)
					local posY = lPos.y - self.pressedPos.y + self.shift.y
					
					self:barScroll(list, elHeight, scrollMin, scrollMax, minHeight, maxHeight, posY)
					enabled = self:scrollElements(listElements, topBorder, botBorder, enabled)
				end
			end)
		if (shiftPosScroll ~= 0 and shiftPosList ~= 0) then
			self:moveTo(nil, shiftPosScroll)
			list:moveTo(nil, shiftPosList)
		end
	end
	
	function UIElement:getEnabled(elements, shiftPos)
		local enabled = {}
		local elHeight = elements[1].size.h
		for i = 1, #elements do
			if (i * elHeight - shiftPos > self.size.h or i * elHeight - shiftPos < 0) then
				elements[i]:hide()
				enabled[i] = false
			else 
				enabled[i] = true
			end
		end
		return enabled
	end
	
	function UIElement:mouseScroll(list, elHeight, scrollMin, scrollMax, minHeight, maxHeight, speed)	
		if (list.shift.y + speed * elHeight >= minHeight) then
			self:moveTo(self.shift.x, scrollMin)
			list:moveTo(list.shift.x, minHeight)
		elseif (list.shift.y + speed * elHeight <= -maxHeight) then
			self:moveTo(self.shift.x, scrollMax)
			list:moveTo(list.shift.x, -maxHeight)
		else
			list:moveTo(list.shift.x, list.shift.y + speed * elHeight)
			local scrollProgress = -(list.shift.y - minHeight) / (maxHeight + minHeight)
			self:moveTo(self.shift.x, scrollMin + (self.parent.size.h - self.size.h - scrollMin * 2) * scrollProgress)
		end	
	end
	
	function UIElement:barScroll(list, elHeight, scrollMin, scrollMax, minHeight, maxHeight, posY)
		local sizeH = math.floor(self.size.h / 4)
		local scrollScale = (self.parent.size.h - (scrollMin * 2 + self.size.h)) / maxHeight
		
		if (posY <= scrollMin) then
			if (self.pressedPos.y < sizeH) then
				self.pressedPos.y = sizeH
			end
			
			self:moveTo(self.shift.x, scrollMin)
			list:moveTo(list.shift.x, minHeight)
		elseif (posY >= scrollMax) then
			if (self.pressedPos.y > self.parent.size.h - sizeH) then
				self.pressedPos.y = self.parent.size.h - sizeH
			end
			
			self:moveTo(self.shift.x, scrollMax)
			list:moveTo(list.shift.x, -maxHeight)
		else
			self:moveTo(self.shift.x, posY)
			local scrollProgress = (self.shift.y - scrollMin) / (self.parent.size.h - scrollMin * 2 - self.size.h)
			list:moveTo(list.shift.x, minHeight - (posY - scrollMin) * (1 / scrollScale) + ((list.size.h - elHeight) * scrollProgress))
		end
	end
	
	function UIElement:scrollElements(list, topBorder, botBorder, enabled)
		for i = 1, #list do
			lPos = list[i]:getLocalPos(0,0)
			if (-lPos.y <= topBorder.pos.y or -lPos.y >= botBorder.pos.y) then
				if (enabled[i] == true) then
					list[i]:hide()
					enabled[i] = false
				end
			else
				if (enabled[i] == false) then
					list[i]:show()
					enabled[i] = true
				end
			end
		end
		topBorder:hide()
		botBorder:hide()
		topBorder:show()
		botBorder:show()
		return enabled
	end
	
	function UIElement:addCustomDisplay(funcTrue, func)
		self.customDisplayTrue = funcTrue
		self.customDisplay = func
	end
	
	function UIElement:kill()
		for i,v in pairs(self.child) do
			v:kill()
		end
		if (self.bgImage) then unload_texture(self.bgImage) end
		for i,v in pairs(UIMouseHandler) do
			if (self == v) then
				table.remove(UIMouseHandler, i)
				break
			end
		end
		for i,v in pairs(UIVisualManager) do
			if (self == v) then
				table.remove(UIVisualManager, i)
				break
			end
		end
		for i,v in pairs(UIElementManager) do
			if (self == v) then
				table.remove(UIElementManager, i)
				break
			end
		end
		self = nil
	end
	
	function UIElement:updatePos()
		if (self.parent) then 
			self:updateChildPos()
		end
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
		local num = nil
		for i,v in pairs(UIVisualManager) do
			if (self == v) then
				num = i
				break
			end
		end
		
		if (not num) then
			table.insert(UIVisualManager, self)
			if (self.interactive) then
				table.insert(UIMouseHandler, self)
			end
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
			if (x > v.pos.x and x < v.pos.x + v.size.w and y > v.pos.y and y < v.pos.y + v.size.h and s < 4) then
				v.hoverState = BTN_DN
				v.btnDown(s, x, y)
			elseif (s >= 4 and v.scrollEnabled == true) then
				v.btnDown(s, x, y)
			end
		end
	end
	
	function UIElement:handleMouseUp(s, x, y)
		for i, v in pairs(UIMouseHandler) do
			if (v.hoverState == BTN_DN) then
				v.hoverState = nil
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
			elseif (v.hoverState == BTN_DN) then
				v.btnHover(x,y)
			else
				v.hoverState = false
			end
		end
	end
	
	function UIElement:moveTo(x, y)
		if (self.parent) then
			if (x) then self.shift.x = x end
			if (y) then self.shift.y = y end
		else
			if (x) then self.pos.x = x end
			if (y) then self.pos.y = y end
		end
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
		local x = x or self.pos.x
		local y = y or self.pos.y
		local font_mod = font
		local scale = scale or 1
		local angle = angle or 0
		local pos = 0
		local align = align or LEFT
		if (font == FONTS.BIG) then
			font_mod = 4.5
		elseif (font == 4) then
			font_mod = 2.4
		elseif (font == FONTS.SMALL) then
			font_mod = 1.5
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
	
	function UIElement:setButtonColor()
		if (self.hoverState == BTN_DN) then
			set_color(unpack(self.pressedColor))
		elseif (self.hoverState == BTN_HVR) then
			set_color(unpack(self.hoverColor))
		else
			set_color(unpack(self.bgColor))
		end
	end
	
	function UIElement:getPos()
		local pos = {self.shift.x, self.shift.y}
		return pos
	end
	
	function UIElement:getLocalPos(xPos, yPos, pos)
		local pos = pos or { x = xPos, y = yPos}
		if (self.parent) then
			pos = self.parent:getLocalPos(xPos, yPos, pos)
			if (self.shift.x < 0) then
				pos.x = pos.x - self.parent.size.w - self.shift.x
			else
				pos.x = pos.x - self.shift.x
			end
			if (self.shift.y < 0) then
				pos.y = pos.y - self.parent.size.h - self.shift.y
			else
				pos.y = pos.y - self.shift.y
			end
		else
			pos.x = xPos - self.pos.x
			pos.y = yPos - self.pos.y
		end
		return pos
	end
	
	-- Used to update background texture
	-- Image can be either a string with texture path or a table where image[1] is a path and image[2] is default icon path
	function UIElement:updateImage(image, default)
		local default = default or DEFTEXTURE
		if (image[2]) then
			default = image[2]
			image = image[1]
		end
		if (self.bgImage) then
			unload_texture(self.bgImage)
		end
		local filename
		if (image:find("^%.%./")) then
			filename = image:gsub("%.%./", "data/")
		else 
			filename = "data/script/" .. image:gsub("^/", "")
		end
		local tempicon = io.open(filename, "r", 1)
		if (tempicon == nil) then
			self.bgImage = load_texture(default)
		else
			local textureid = load_texture(image)
			if (textureid == -1) then
				unload_texture(textureid)
				self.bgImage = load_texture(default)
			else
				self.bgImage = textureid
			end
			io.close(tempicon)
		end
	end
	
	function textAdapt(str, font, scale, maxWidth)
		local destStr = {}
		
		while ((get_string_length(str, font) * scale) > maxWidth) do
			local newStr = string.match(str, "[^%s]+[%s]*")
			str = str:gsub(strEsc(newStr), "")
			if (str == "") then
				table.insert(destStr, newStr)
				return destStr
			end
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
					:gsub('%]', '%%]')
					:gsub('%-', '%%-'))
	end
end