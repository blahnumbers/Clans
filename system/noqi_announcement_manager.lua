do
	NQAnn = {}
    NQAnn.__index = NQAnn
    
    function NQAnn:create()
		local cln = {}
		setmetatable(cln, NQAnn)
    end
	
	function NQAnn:showMain()
		nqaViewBG = UIElement:new( {	pos = { WIN_W/2 - 354, WIN_H/2 - 264 },
										size = { 708, 528 },
										bgColor = {0,0,0,0.95},
										shapeType = ROUNDED,
										rounded = 25 } )
		local nqaView = UIElement:new( {	parent = nqaViewBG,
											pos = { 4, 4 },
											size = { nqaViewBG.size.w - 8, nqaViewBG.size.h - 8 },
											bgColor = {0.6,0,0,1},
											shapeType = nqaViewBG.shapeType,
											rounded = 22.5,
											innerShadow = {0, 15},
											shadowColor = { {0,0,0,0}, {0.5,0,0,1} } } )
		local nqaViewTitle = UIElement:new( {	parent = nqaView,
												pos = {0, 7},
												size = {nqaView.size.w, 50} } )
		nqaViewTitle:addCustomDisplay(false, function()
				nqaViewTitle:uiText("No-qi Item Sale!", nil, nil, FONTS.BIG, nil, 0.8, 0, 2)
			end)
		local quitButton = UIElement:new( {	parent = nqaViewTitle,
											pos = { -50, 5 },
											size = { 40, 40 },
											bgColor = { 0,0,0,0.7 },
											shapeType = ROUNDED,
											rounded = 17,
											interactive = true,
											hoverColor = { 0.2,0,0,0.7},
											pressedColor = { 1,0,0,0.5} } )
		quitButton:addCustomDisplay(false, function()
			local indent = 12
			local weight = 5
			set_color(1,1,1,1)
			draw_line(quitButton.pos.x + indent, quitButton.pos.y + indent, quitButton.pos.x + quitButton.size.w - indent, quitButton.pos.y + quitButton.size.h - indent, weight)
			draw_line(quitButton.pos.x + quitButton.size.w - indent, quitButton.pos.y + indent, quitButton.pos.x + indent, quitButton.pos.y + quitButton.size.h - indent, weight)
		end)
		quitButton:addMouseHandlers(function() end, function()
				nqaViewBG:kill()
				remove_hooks("noQiAnnouncementVisual")
			end, function() end)
		local nqaGoToShop = UIElement:new( {	parent = nqaView,
												pos = { 50, 65 },
											 	size = { nqaView.size.w - 100, nqaView.size.h - 95 },
											 	bgColor = { 0.55, 0, 0, 1},
											 	shapeType = ROUNDED,
												rounded = 15,
												interactive = true,
												hoverColor = {0.7, 0, 0, 1},
												pressedColor = {0.5, 0, 0, 1} } )
		nqaGoToShop:addMouseHandlers(function() end, function()
				nqaViewBG:kill()
				remove_hooks("noQiAnnouncementVisual")
				open_menu(12)
			end, function() end)
		local nqaViewImage = UIElement:new( {	parent = nqaView,
												pos = { 119, 75 },
												size = { 462, 462 },
												bgImage = "system/noqisalessplash.tga" } )
		nqaViewImage:addCustomDisplay(false, function()
				nqaViewImage:uiText("Get Items in Torishop", nil, nqaViewImage.pos.y + 350, FONTS.BIG, nil, 0.85, nil, 2.5)
			end)
	end
end