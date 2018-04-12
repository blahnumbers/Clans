-- modern main menu manager class
-- DO NOT MODIFY THIS FILE

ORIENTATION_PORTRAIT = 1
ORIENTATION_LANDSCAPE = 2

TB_MENU_DEFAULT_BG_COLOR = { 0.67, 0.11, 0.11, 1 }
TB_NAVBAR_DEFAULT_BG_COLOR = { 0.7, 0.11, 0.11, 1 }

--Global objects
tbMenuMain = nil -- base parent element
tbMenuCurrentSection = nil -- parent element for current section items
tbMenuNavigationBar = nil -- parent element for navbar

do
	TBMenu = {}
    TBMenu.__index = TBMenu
	    
    function TBMenu:create()
		TB_MENU_MAIN_ISOPEN = 1
		local cln = {}
		setmetatable(cln, TBMenu)
    end
	
	function TBMenu:quit()
		remove_hooks("tbMainMenuVisual")
		TB_MENU_MAIN_ISOPEN = 0
		disable_blur()
		tbMenuMain:kill()
	end	
	
	function TBMenu:createCurrentSectionView()
		tbMenuCurrentSection = UIElement:new( {
			parent = tbMenuMain,
			pos = { 75, 200 },
			size = { WIN_W - 150, WIN_H - 320 }
		})
	end
	
	-- Get image based on screen and element size
	function TBMenu:getImageDimensions(width, height, ratio, shift1, shift2)
		local elementWidth = width - 20
		if (elementWidth * ratio > height - 20) then
			elementWidth = (height - 20) / ratio
		end
		local elementHeight = elementWidth * ratio
		if (elementHeight + shift1 + shift2 <= height - 20) then
			return { elementWidth, elementHeight, 0 }
		elseif (elementHeight + shift2 <= height - 20) then
			return { elementWidth, elementHeight, shift1 }
		else
			return { elementWidth, elementHeight, shift1 + shift2 }
		end
		return { elementWidth, elementHeight, heightShift }
	end
		
	function TBMenu:createImageButtons(parentElement, x, y, w, h, img, imgHvr, imgPress, col, colHvr, colPress)
		if (not parentElement or not x or not y or not w or not h or not img) then
			return false
		end
		local imgHvr = imgHvr or img
		local imgPress = imgPress or img
		local col = col or nil
		local colHvr = colHvr or col
		local colPress = colPress or colHvr
		local buttonMain = UIElement:new( {
			parent = parentElement,
			pos = { x, y },
			size = { w, h },
			interactive = true,
			bgColor = col,
			hoverColor = colHvr,
			pressedColor = colPress,
			hoverSound = 31
		})
		local buttonImage = UIElement:new( {
			parent = buttonMain,
			pos = { 0, 0 },
			size = { 0, 0 },
			bgImage = img
		})
		buttonImage:addCustomDisplay(true, function() end)
		local buttonImageHover = UIElement:new( {
			parent = buttonMain,
			pos = { 0, 0 },
			size = { 0, 0 },
			bgImage = imgHvr
		})
		buttonImageHover:addCustomDisplay(true, function() end)
		local buttonImagePress = UIElement:new( {
			parent = buttonMain,
			pos = { 0, 0 },
			size = { 0, 0 },
			bgImage = imgPress
		})
		buttonImagePress:addCustomDisplay(true, function()
				if (buttonMain.hoverState == false) then
					draw_quad(buttonMain.pos.x, buttonMain.pos.y, buttonMain.size.w, buttonMain.size.h, buttonImage.bgImage)
				elseif (buttonMain.hoverState == BTN_HVR) then
					draw_quad(buttonMain.pos.x, buttonMain.pos.y, buttonMain.size.w, buttonMain.size.h, buttonImageHover.bgImage)
				elseif (buttonMain.hoverState == BTN_DN) then
					draw_quad(buttonMain.pos.x, buttonMain.pos.y, buttonMain.size.w, buttonMain.size.h, buttonImagePress.bgImage)
				end
			end)
		return buttonMain
	end
	
	function TBMenu:changeCurrentEvent(viewElement, eventsData, eventItems, reloadElement, direction)
		for i, v in pairs(eventItems) do
			if (i == TB_MENU_HOME_CURRENT_ANNOUNCEMENT) then
				v.image:hide()
				TB_MENU_HOME_CURRENT_ANNOUNCEMENT = TB_MENU_HOME_CURRENT_ANNOUNCEMENT + direction
				if (TB_MENU_HOME_CURRENT_ANNOUNCEMENT > #eventItems) then
					TB_MENU_HOME_CURRENT_ANNOUNCEMENT = TB_MENU_HOME_CURRENT_ANNOUNCEMENT - #eventItems
				elseif (TB_MENU_HOME_CURRENT_ANNOUNCEMENT < 1) then
					TB_MENU_HOME_CURRENT_ANNOUNCEMENT = #eventItems
				end
				eventItems[TB_MENU_HOME_CURRENT_ANNOUNCEMENT].image:show()
				viewElement:addMouseHandlers(nil, eventsData[TB_MENU_HOME_CURRENT_ANNOUNCEMENT].action, nil)
				reloadElement:reload()
				break
			end
		end
	end
		
	-- Stores and displays event announcements with timed rotation
	function TBMenu:showEvents(viewElement)
		-- Table to store event announcement data
		local eventsData = {
			{
				title = "April Shiai Items", 
				subtitle = "Set off on a journey beyond the stars!", 
				image = "../textures/menu/promo/astroshiai.tga",
				action = function() 
						open_url("http://forum.toribash.com/tori_token_exchange.php") 
					end
				},
			{ 
				title = "Opener Challenge - Space Edition", 
				subtitle = "Fight Uke in the hostile space envorinment and finish repairments of your space station!", 
				image = "../textures/menu/promo/openerchallenge13.tga",
				action = function() 
						open_url("http://forum.toribash.com/showthread.php?t=612869") 
					end
			},
 			{ 
 				title = "Torisoccer", 
 				subtitle = "You've been tasked with the final penalty shot at ToriWorld Cup. Unfortunately, you don't seem to have a ball. Well, except for Uke's head.", 
 				image = "../textures/menu/promo/torisoccer.tga",
 				action = function() 
 						open_url("http://forum.toribash.com/showthread.php?t=612947") 
 					end
 			 },
		}
		viewElement:addMouseHandlers(nil, eventsData[TB_MENU_HOME_CURRENT_ANNOUNCEMENT].action, nil)
		local textHeight, descHeight = 50, 50
		local elementWidth, elementHeight, heightShift = unpack(TBMenu:getImageDimensions(viewElement.size.w, viewElement.size.h, 0.5, textHeight, descHeight))
		-- Spawn event announcement elements
		local eventItems = {}
		for i, v in pairs (eventsData) do
			local titleTextScale, subtitleTextScale = 0.75, 1
			eventItems[i] = {}
			eventItems[i].image = UIElement:new( {
				parent = viewElement,
				pos = { (viewElement.size.w - elementWidth) / 2, 10 },
				size = { elementWidth, elementHeight },
				bgImage = v.image
			})
			eventItems[i].button = UIElement:new( {
				parent = eventItems[i].image,
				pos = { 0, eventItems[i].image.size.h - heightShift },
				size = { eventItems[i].image.size.w, textHeight + descHeight }
			})
			local textColor, descColor = { 0.64, 0.11, 0.11, 0.8 }, { 0.64, 0.11, 0.11, 0.8 }
			if (heightShift == textHeight) then
				descColor = nil
			elseif (heightShift == 0) then
				descColor, textColor = nil, nil
			end
			eventItems[i].titleView = UIElement:new( {
				parent = eventItems[i].button,
				pos = { 0, 0 },
				size = { eventItems[i].button.size.w, textHeight },
				bgColor = textColor
			})
			eventItems[i].title = UIElement:new( {
				parent = eventItems[i].titleView,
				pos = { 10, 5 },
				size = { eventItems[i].titleView.size.w - 20, eventItems[i].titleView.size.h - 10 }
			})
			while (not eventItems[i].title:uiText(v.title, nil, nil, FONTS.BIG, LEFT, titleTextScale, nil, nil, nil, nil, nil, true)) do
				titleTextScale = titleTextScale - 0.05
			end
			eventItems[i].title:addCustomDisplay(false, function()
					eventItems[i].title:uiText(v.title, nil, nil, FONTS.BIG, LEFT, titleTextScale)
				end)
			eventItems[i].subtitleView = UIElement:new( {
				parent = eventItems[i].button,
				pos = { 0, textHeight },
				size = { eventItems[i].button.size.w, descHeight },
				bgColor = descColor
			})
			eventItems[i].subtitle = UIElement:new( {
				parent = eventItems[i].subtitleView,
				pos = { 10, 5 },
				size = { eventItems[i].subtitleView.size.w - 20, eventItems[i].subtitleView.size.h - 10 }
			})
			while (not eventItems[i].title:uiText(v.subtitle, nil, nil, 4, LEFT, subtitleTextScale, nil, nil, nil, nil, nil, true) and subtitleTextScale > 0.6) do
				subtitleTextScale = subtitleTextScale - 0.05
			end
			eventItems[i].subtitle:addCustomDisplay(false, function()
					eventItems[i].subtitle:uiText(v.subtitle, nil, nil, 4, LEFT, subtitleTextScale)
				end)
			if (i ~= TB_MENU_HOME_CURRENT_ANNOUNCEMENT) then
				eventItems[i].image:hide()
			end
		end
		
		-- Store all elements that would require reloading when switching event announcements in one table
		local toReload = UIElement:new({
			parent = viewElement,
			pos = { 0, 0 },
			size = { viewElement.size.w, viewElement.size.h }
		})
		
		-- Create bottom splat
		local eventButtonSplat = TBMenu:addBottomBloodSmudge(toReload, 1)
		
		-- Spawn progress bar before next/prev buttons
		local eventDisplayTime = UIElement:new( {
			parent = toReload,
			pos = {0, 0},
			size = {0, 0}
		})
		
		-- Manual announcement change
		local eventPrevButton = TBMenu:createImageButtons(toReload, 10, toReload.size.h / 2 - 32, 32, 64, "/system/arrowleft.tga", nil, nil, { 0, 0, 0, 0 }, { 0, 0, 0, 0.7 })
		eventPrevButton:addMouseHandlers(nil, function()
				TBMenu:changeCurrentEvent(viewElement, eventsData, eventItems, toReload, -1)
			end, nil)
		local eventNextButton = TBMenu:createImageButtons(toReload, toReload.size.w - 42, toReload.size.h / 2 - 32, 32, 64, "/system/arrowright.tga", nil, nil, { 0, 0, 0, 0 }, { 0, 0, 0, 0.7 })
		eventNextButton:addMouseHandlers(nil, function()
				TBMenu:changeCurrentEvent(viewElement, eventsData, eventItems, toReload, 1)
			end, nil)
		
		-- Auto-rotate event announcements
		local rotateTime = 10
		local startTime = os.time()
		local startClock = math.floor(os.clock()) + TB_MENU_OS_CLOCK_SHIFT
		local lastTime = startTime
		eventDisplayTime:addCustomDisplay(true, function()
				set_color(1,1,1,1)
				if (startClock < os.clock()) then
					draw_quad(eventItems[1].button.pos.x, eventItems[1].button.pos.y - 5, (os.clock() - startClock) % rotateTime / rotateTime * eventItems[1].button.size.w, 5)
				else
					startClock = startClock - 1
				end
			end)
		viewElement:addCustomDisplay(false, function()
				if ((os.time() - startTime) % rotateTime == 0 and os.time() ~= lastTime) then
					lastTime = os.time()
					TBMenu:changeCurrentEvent(viewElement, eventsData, eventItems, toReload, 1)
				end
			end)
	end
	
	function TBMenu:showHomeButton(viewElement, buttonData)
		local titleHeight, descHeight = 34, 35
		local elementWidth, elementHeight, heightShift
		local itemIcon
		if (viewElement.size.h < viewElement.size.w and buttonData.image2) then
			elementWidth, elementHeight, heightShift = unpack(TBMenu:getImageDimensions(viewElement.size.w, viewElement.size.h, buttonData.ratio2, titleHeight, descHeight))
			itemIcon = UIElement:new( {
				parent = viewElement,
				pos = { (viewElement.size.w - elementWidth) / 2, 10 },
				size = { elementWidth, elementHeight },
				bgImage = buttonData.image2
			})
		else
			elementWidth, elementHeight, heightShift = unpack(TBMenu:getImageDimensions(viewElement.size.w, viewElement.size.h, buttonData.ratio, titleHeight, descHeight))
			itemIcon = UIElement:new( {
				parent = viewElement,
				pos = { (viewElement.size.w - elementWidth) / 2, 10 },
				size = { elementWidth, elementHeight },
				bgImage = buttonData.image
			})
		end
		local textColor, descColor = { 0.64, 0.11, 0.11, 0.8 }, { 0.64, 0.11, 0.11, 0.8 }
		if (heightShift == titleHeight) then
			descColor = nil
		elseif (heightShift == 0) then
			descColor, textColor = nil, nil
		end
		local buttonOverlay = UIElement:new( {
			parent = itemIcon,
			pos = { 0, elementHeight - heightShift },
			size = { elementWidth, titleHeight + descHeight }
		})
		local shopTitleView = UIElement:new( {
			parent = buttonOverlay,
			pos = { 0, 0 },
			size = { elementWidth, titleHeight },
			bgColor = textColor
		})
		local shopTitle = UIElement:new( {
			parent = shopTitleView,
			pos = { 5, 0 },
			size = { shopTitleView.size.w - 10, shopTitleView.size.h }
		})
		shopTitle:addCustomDisplay(false, function()
				shopTitle:uiText(buttonData.title, nil, nil, FONTS.BIG, LEFT, 0.55)
			end)
		if (descHeight - heightShift == 0) then
			textOverlayColor = { 0, 0, 0, 0 }
		end
		local shopSubtitleView = UIElement:new( {
			parent = buttonOverlay,
			pos = { 0, titleHeight },
			size = { elementWidth, descHeight },
			bgColor = descColor
		})
		local shopSubtitle = UIElement:new( {
			parent = shopSubtitleView,
			pos = { 5, 2 },
			size = { shopSubtitleView.size.w - 10, shopSubtitleView.size.h - 4 }
		})
		shopSubtitle:addCustomDisplay(false, function()
				shopSubtitle:uiText(buttonData.subtitle, nil, nil, 4, LEFT, 0.6)
			end)
		viewElement:addMouseHandlers(nil, buttonData.action, nil)
	end
	
	-- Loads home section
	-- Uses custom methods, can't be loaded with showSection() unlike other sections
	function TBMenu:showHome()
		-- Buttons data; doesn't include events section
		local tbMenuHomeButtonsData = {
			shop = {
				title = "Torishop",
				subtitle = "Try out and purchase items for your Tori",
				image = "/system/freeplay.tga",
				ratio = 0.41,
				action = function() open_menu(12) end
			},
			clan = {
				title = "Clan",
				subtitle = "Explore Toribash clans",
				image = "/system/matchmaking.tga",
				image2 = "../textures/menu/fightuke.tga",
				ratio = 1,
				ratio2 = 0.5,
				action = function() dofile("clans.lua") end
			},
			replays = {
				title = "Replays",
				subtitle = "View your downloaded replays",
				image = "/system/matchmaking.tga",
				image2 = "../textures/menu/freeplay.tga",
				ratio = 1,
				ratio2 = 0.5,
				action = function() open_menu(6) end
			}
		}
		
		-- Base UI element
		if (not tbMenuCurrentSection) then
			TBMenu:createCurrentSectionView()
		end
		
		-- Create and load events view
		local tbMenuHomeEventsView = UIElement:new( {
			parent = tbMenuCurrentSection,
			pos = { 5, 0 },
			size = { tbMenuCurrentSection.size.w * 0.6 - 10, tbMenuCurrentSection.size.h },
			bgColor = TB_MENU_DEFAULT_BG_COLOR,
			interactive = true,
			hoverColor = { 0.5, 0.1, 0.1, 1 },
			pressedColor = { 0.3, 0.1, 0.1, 1 },
			hoverSound = 31			
		})
		TBMenu:showEvents(tbMenuHomeEventsView)
		
		-- Create and load home section buttons
		local tbMenuShopButton = UIElement:new({
			parent = tbMenuCurrentSection,
			pos = { tbMenuCurrentSection.size.w * 0.6 + 5, 0 },
			size = { tbMenuCurrentSection.size.w * 0.4 - 10, tbMenuCurrentSection.size.h / 2 - 5 },
			interactive = true,
			bgColor = TB_MENU_DEFAULT_BG_COLOR,
			hoverColor = { 0.5, 0.1, 0.1, 1 },
			pressedColor = { 0.3, 0.1, 0.1, 1 },
			hoverSound = 31
		})
		TBMenu:showHomeButton(tbMenuShopButton, tbMenuHomeButtonsData.shop)
		local tbMenuClansButton = UIElement:new({
			parent = tbMenuCurrentSection,
			pos = { tbMenuCurrentSection.size.w * 0.6 + 5, tbMenuCurrentSection.size.h / 2 + 5 },
			size = { tbMenuCurrentSection.size.w * 0.2 - 10, tbMenuCurrentSection.size.h / 2 - 5 },
			interactive = true,
			bgColor = TB_MENU_DEFAULT_BG_COLOR,
			hoverColor = { 0.5, 0.1, 0.1, 1 },
			pressedColor = { 0.3, 0.1, 0.1, 1 },
			hoverSound = 31		
		})
		TBMenu:showHomeButton(tbMenuClansButton, tbMenuHomeButtonsData.clan)
		local tbMenuClansBottomSplat = TBMenu:addBottomBloodSmudge(tbMenuClansButton, 1)
		local tbMenuReplaysButton = UIElement:new({
			parent = tbMenuCurrentSection,
			pos = { tbMenuCurrentSection.size.w * 0.8 + 5, tbMenuCurrentSection.size.h / 2 + 5 },
			size = { tbMenuCurrentSection.size.w * 0.2 - 10, tbMenuCurrentSection.size.h / 2 - 5 },
			interactive = true,
			bgColor = TB_MENU_DEFAULT_BG_COLOR,
			hoverColor = { 0.5, 0.1, 0.1, 1 },
			pressedColor = { 0.3, 0.1, 0.1, 1 },
			hoverSound = 31			
		})
		TBMenu:showHomeButton(tbMenuReplaysButton, tbMenuHomeButtonsData.replays)
		local tbMenuReplaysBottomSplat = TBMenu:addBottomBloodSmudge(tbMenuReplaysButton, 2)
	end
	
	-- Clears navigation bar and current section element for side modules
	function TBMenu:clearNavSection()
		tbMenuNavigationBar:kill()
		if (not tbMenuCurrentSection) then
			TBMenu:createCurrentSectionView()
		else
			tbMenuCurrentSection:kill(true)
		end
	end
	
	function TBMenu:showLoginRewards()
		local rewards = PlayerInfo:getLoginRewards()
		if (rewards.days == 0 and rewards.available == false and rewards.timeLeft == 0) then
			return 0
		end
		if (Rewards:getRewardData()) then
			TBMenu:clearNavSection()
			Rewards:showMain(tbMenuCurrentSection, rewards)
			TBMenu:showNavigationBar(Rewards:getNavigationButtons(), true)
			TB_MENU_NOTIFICATIONS_ISOPEN = 1
		else
			echo("^04Error: ^07missing daily rewards data")
		end
	end
	
	function TBMenu:showMatchmaking()
		TBMenu:clearNavSection()
		-- Connect user to matchmake server
		Matchmake:connect()
		Matchmake:showMain(tbMenuCurrentSection)
		TBMenu:showNavigationBar(Matchmake:getNavigationButtons(), true)
	end
	
	function TBMenu:showPlaySection()
		local tbMenuPlayButtonsData = {
			{ title = "Free Play", subtitle = "Practice your skills or make replays in Single Player mode", size = 0.5, image = "../textures/menu/freeplay.tga", mode = ORIENTATION_LANDSCAPE, action = function() open_menu(1) end, noQuit = true },
			{ title = "Matchmaking", subtitle = "Quick way to get placed in one-on-one fights", size = 0.25, image = "../textures/menu/matchmaking.tga", mode = ORIENTATION_PORTRAIT, action = function() TBMenu:showMatchmaking() end, noQuit = true },
			{ title = "Room List", subtitle = "Create your own online room or join any of the existing ones", size = 0.25, image = "/system/multiplayer.tga", mode = ORIENTATION_PORTRAIT, action = function() open_menu(2) end, noQuit = true }
		}
		TBMenu:showSection(tbMenuPlayButtonsData)
	end
	
	function TBMenu:showPracticeSection()
		local tbMenuPracticeButtonsData = {
			{ title = "Beginner Tutorial", subtitle = "Learn Toribash basics: controls, gameplay and more", size = 0.3, vsize = 0.5, mode = ORIENTATION_PORTRAIT, action = function() run_tutorial(1) end },
			{ title = "Advanced Moves", subtitle = "Discover advanced moves to use in multiplayer", size = 0.3, vsize = 0.5, mode = ORIENTATION_PORTRAIT, action = function() run_tutorial(2) end },
			{ title = "Fight Uke", subtitle = "Put your skills against Tori's ultimate foe", size = 0.467, image = "../textures/menu/fightuke.tga", mode = ORIENTATION_LANDSCAPE, action = function() run_tutorial(4) end },
			{ title = "Comeback Practice", subtitle = "Keep catching Uke without getting disqualified", size = 0.233, image = "/system/matchmaking.tga", mode = ORIENTATION_PORTRAIT }
		}
		TBMenu:showSection(tbMenuPracticeButtonsData)
	end
	
	function TBMenu:showModsSection()
		local tbMenuModsButtonsData = {
			{ title = "Game Rules", subtitle = "Customize gravity and other mod settings", size = 0.233, image = "/system/matchmaking.tga", mode = ORIENTATION_PORTRAIT, action = function() open_menu(5) end, noQuit = true },
			{ title = "Mod List", subtitle = "Load one of the downloaded mods", size = 0.467, image = "/system/toribashsplash.tga", mode = ORIENTATION_LANDSCAPE, action = function() open_menu(7) end, noQuit = true },
			{ title = "Modmaker", subtitle = "Create your own mod for Toribash", size = 0.3, vsize = 0.5, image = "/system/multiplayer.tga", mode = ORIENTATION_PORTRAIT, action = function() open_menu(17) end },
			{ title = "Discover", subtitle = "Search for new mods created by other players", size = 0.3, vsize = 0.5, image = "/system/matchmaking.tga", mode = ORIENTATION_PORTRAIT, noQuit = true }
		}
		TBMenu:showSection(tbMenuModsButtonsData)
	end
	
	function TBMenu:showToolsSection()
		local tbMenuToolsButtonsData = {
			{ title = "Shaders", subtitle = "Customize lighting and environment colors", size = 0.25, image = "/system/multiplayer.tga", mode = ORIENTATION_PORTRAIT, action = function() open_menu(9) end, noQuit = true },
			{ title = "Atmospheres", subtitle = "Set up a custom environment to play in", size = 0.25, image = "/system/matchmaking.tga", mode = ORIENTATION_PORTRAIT, noQuit = true },
			{ title = "Scripts", subtitle = "Load pre-installed or third-party scripts for Toribash", size = 0.25, image = "/system/multiplayer.tga", mode = ORIENTATION_PORTRAIT, action = function() open_menu(8) end, noQuit = true },
			{ title = "Sounds", subtitle = "Toggle custom sounds on/off", size = 0.25, image = "/system/matchmaking.tga", mode = ORIENTATION_PORTRAIT, action = function() open_menu(16) end, noQuit = true }
		}
		TBMenu:showSection(tbMenuToolsButtonsData)		
	end
	
	function TBMenu:addBottomBloodSmudge(parentElement, num, scale)
		local scale = scale or 64
		local bottomSmudge = "system/sectionbottomsplat1.tga"
		if (parentElement.size.w < 400) then
			if (num % 2 == 1) then
				bottomSmudge = "/system/sectionbottomsplat2.tga"
			else
				bottomSmudge = "/system/sectionbottomsplat3.tga"
			end
		end
		local smudgeElement = UIElement:new({
			parent = parentElement,
			pos = { 0, -(scale / 2) },
			size = { parentElement.size.w, scale },
			bgImage = bottomSmudge
		})
		return smudgeElement
	end
	
	function TBMenu:showSection(buttonsData)
		if (not tbMenuCurrentSection) then
			TBMenu:createCurrentSectionView()
		end
		local tbMenuSectionButtons = {}
		local sectionX = 5
		local sectionY = 0
		local maxWidthButton = { 0, 0 }
		for i, v in pairs (buttonsData) do
			if v.size > maxWidthButton[2] then
				maxWidthButton[2] = v.size
				maxWidthButton[1] = i
			end
		end
		local imageRes = tbMenuCurrentSection.size.w * buttonsData[maxWidthButton[1]].size - 10
		local titleScaleModifier, subtitleScaleModifier = 1, 1
		for i, v in pairs (buttonsData) do
			if (v.vsize) then
				titleScaleModifier, subtitleScaleModifier = 0.7, 0.8
				break
			end
		end
		for i, v in pairs (buttonsData) do
			tbMenuSectionButtons[i] = {}
			if (buttonsData[i].vsize) then
				if (sectionY + tbMenuCurrentSection.size.h * buttonsData[i].vsize - 5 > tbMenuCurrentSection.size.h) then 
					local bottomSmudge = TBMenu:addBottomBloodSmudge(tbMenuSectionButtons[i - 1].mainView, i - 1)
					sectionY = 0
					sectionX = sectionX + tbMenuCurrentSection.size.w * buttonsData[i].size
				end
				tbMenuSectionButtons[i].mainView = UIElement:new( {
					parent = tbMenuCurrentSection,
					pos = { sectionX, sectionY },
					size = { tbMenuCurrentSection.size.w * buttonsData[i].size - 10, tbMenuCurrentSection.size.h * buttonsData[i].vsize - 5 },
					bgColor = TB_MENU_DEFAULT_BG_COLOR,
					interactive = true,
					hoverColor = { 0.5, 0.1, 0.1, 1 },
					pressedColor = { 0.3, 0.1, 0.1, 1 },
					hoverSound = 31
				})
				if (i == #buttonsData) then 
					local bottomSmudge = TBMenu:addBottomBloodSmudge(tbMenuSectionButtons[i].mainView, i - 1)
				end
				sectionY = sectionY + tbMenuCurrentSection.size.h * buttonsData[i].vsize + 5
			else
				if (i > 1 and tbMenuSectionButtons[i - 1].mainView.shift.x == sectionX) then
					sectionX = sectionX + tbMenuCurrentSection.size.w * buttonsData[i - 1].size
					local bottomSmudge = TBMenu:addBottomBloodSmudge(tbMenuSectionButtons[i - 1].mainView, i - 1)
				end
				tbMenuSectionButtons[i].mainView = UIElement:new( {
					parent = tbMenuCurrentSection,
					pos = { sectionX, 0 },
					size = { tbMenuCurrentSection.size.w * buttonsData[i].size - 10, tbMenuCurrentSection.size.h },
					bgColor = TB_MENU_DEFAULT_BG_COLOR,
					interactive = true,
					hoverColor = { 0.5, 0.1, 0.1, 1 },
					pressedColor = { 0.3, 0.1, 0.1, 1 },
					hoverSound = 31
				})
				local bottomSmudge = TBMenu:addBottomBloodSmudge(tbMenuSectionButtons[i].mainView, i)
				sectionX = sectionX + tbMenuCurrentSection.size.w * buttonsData[i].size
			end
			if ((imageRes / 2 < tbMenuSectionButtons[i].mainView.size.h / 5 * 4 and buttonsData[maxWidthButton[1]].mode == ORIENTATION_LANDSCAPE) or (imageRes < tbMenuSectionButtons[i].mainView.size.h / 5 * 4 and buttonsData[maxWidthButton[1]].mode == ORIENTATION_PORTRAIT) and not buttonsData[i].vsize) then
				local imageBottom
				if (buttonsData[i].mode == ORIENTATION_PORTRAIT) then
					tbMenuSectionButtons[i].imageView = UIElement:new( {
						parent = tbMenuSectionButtons[i].mainView,
						pos = { 10, 10 },
						size = { tbMenuSectionButtons[i].mainView.size.w - 20, (imageRes - 20) / maxWidthButton[2] * buttonsData[i].size },
						bgImage = buttonsData[i].image
					})
					imageBottom = (imageRes - 20) / maxWidthButton[2] * buttonsData[i].size + 20
				else
					tbMenuSectionButtons[i].imageView = UIElement:new( {
						parent = tbMenuSectionButtons[i].mainView,
						pos = { 10, 10 },
						size = { (imageRes - 20) / maxWidthButton[2] * buttonsData[i].size, (imageRes - 20) / maxWidthButton[2] * buttonsData[i].size / 2 },
						bgImage = buttonsData[i].image
					})
					imageBottom = (imageRes - 20) / maxWidthButton[2] * buttonsData[i].size / 2 + 20
				end
				tbMenuSectionButtons[i].titleView = UIElement:new( {
					parent = tbMenuSectionButtons[i].mainView,
					pos = { 20, imageBottom},
					size = { tbMenuSectionButtons[i].mainView.size.w - 40, (tbMenuSectionButtons[i].mainView.size.h - imageBottom) / 2 - 10 }
				})
				tbMenuSectionButtons[i].subtitleView = UIElement:new( {
					parent = tbMenuSectionButtons[i].mainView,
					pos = { 20, imageBottom + (tbMenuSectionButtons[i].mainView.size.h - imageBottom) / 2 },
					size = { tbMenuSectionButtons[i].mainView.size.w - 40, (tbMenuSectionButtons[i].mainView.size.h - imageBottom) / 3 }
				})
			elseif (buttonsData[i].vsize) then
				tbMenuSectionButtons[i].titleView = UIElement:new( {
					parent = tbMenuSectionButtons[i].mainView,
					pos = { 20, tbMenuSectionButtons[i].mainView.size.h * 2 / 7 },
					size = { tbMenuSectionButtons[i].mainView.size.w - 40, tbMenuSectionButtons[i].mainView.size.h * 2 / 7 - 10 }
				})
				tbMenuSectionButtons[i].subtitleView = UIElement:new( {
					parent = tbMenuSectionButtons[i].mainView,
					pos = { 20, tbMenuSectionButtons[i].mainView.size.h * 4 / 7 },
					size = { tbMenuSectionButtons[i].mainView.size.w - 40, tbMenuSectionButtons[i].mainView.size.h * 2 / 7 }
				})
			else
				tbMenuSectionButtons[i].titleView = UIElement:new( {
					parent = tbMenuSectionButtons[i].mainView,
					pos = { 20, -tbMenuSectionButtons[i].mainView.size.h / 4},
					size = { tbMenuSectionButtons[i].mainView.size.w - 40, 50 }
				})
				tbMenuSectionButtons[i].subtitleView = UIElement:new( {
					parent = tbMenuSectionButtons[i].mainView,
					pos = { 20, -tbMenuSectionButtons[i].mainView.size.h / 7 },
					size = { tbMenuSectionButtons[i].mainView.size.w - 40, 50 }
				})
			end
			while (tbMenuSectionButtons[i].titleView:uiText(buttonsData[i].title, nil, nil, FONTS.BIG, LEFT, titleScaleModifier, nil, nil, nil, nil, nil, true) == false) do
				titleScaleModifier = titleScaleModifier - 0.05
			end
			while (tbMenuSectionButtons[i].subtitleView:uiText(buttonsData[i].subtitle, nil, nil, 4, LEFT, subtitleScaleModifier, nil, nil, nil, nil, nil, true) == false) do
				subtitleScaleModifier = subtitleScaleModifier - 0.05
			end
		end
		for i, v in pairs (buttonsData) do
			tbMenuSectionButtons[i].mainView:addMouseHandlers(nil, function()
					if (not v.noQuit) then
						TBMenu:quit()
					end
					buttonsData[i].action()
				end, nil)
			tbMenuSectionButtons[i].titleView:addCustomDisplay(false, function()
					tbMenuSectionButtons[i].titleView:uiText(buttonsData[i].title, nil, nil, FONTS.BIG, LEFTBOT, titleScaleModifier, nil, nil, nil, nil, 0.2)
				end)
			tbMenuSectionButtons[i].subtitleView:addCustomDisplay(false, function()
					tbMenuSectionButtons[i].subtitleView:uiText(buttonsData[i].subtitle, nil, nil, 4, LEFT, subtitleScaleModifier)
				end)
		end
	end
	
	function TBMenu:openMenu(screenId)
		if (TB_MENU_MATCHMAKE_ISOPEN == 1) then
			TBMenu:showMatchmaking()
		elseif (screenId == 1) then
			TBMenu:showHome()
		elseif (screenId == 2) then
			TBMenu:showPlaySection()
		elseif (screenId == 3) then
			TBMenu:showPracticeSection()
		elseif (screenId == 4) then
			TBMenu:showModsSection()
		elseif (screenId == 5) then
			TBMenu:showToolsSection()
		elseif (screenId == 101) then
			TBMenu:showLoginRewards()
		end
	end
	
	function TBMenu:showGameLogo()
		local logo = "/system/tblogo128.tga"
		local gametitle = "/system/toribashgametitle.tga"
		local logoSize = 80
		local customLogo = io.open("custom/" .. TB_MENU_PLAYER_INFO.username .. "/logo.tga", "r", 1)
		if (customLogo) then
			logo = "../../custom/" .. TB_MENU_PLAYER_INFO.username .. "/logo.tga"
			logoSize = 120
			customLogo:close()
		end
		local customGametitle = io.open("custom/" .. TB_MENU_PLAYER_INFO.username .. "/header.tga", "r", 1)
		if (customGametitle) then
			gametitle = "../../custom/" .. TB_MENU_PLAYER_INFO.username .. "/header.tga"
			customGametitle:close()
		end
		local tbMenuLogo = UIElement:new( {
			parent = tbMenuMain,
			pos = {50, 15},
			size = {logoSize, logoSize},
			bgImage = logo
		})
		local tbMenuGameTitle = UIElement:new( {
			parent = tbMenuMain,
			pos = {135, 25},
			size = {200, 200},
			bgImage = gametitle
		})
	end
	
	function TBMenu:showUserBar()
		local tbMenuTopBarWidth = 512
		
		local tbMenuUserBar = UIElement:new( {
			parent = tbMenuMain,
			pos = {-tbMenuTopBarWidth, 0},
			size = {tbMenuTopBarWidth, 100},
			bgColor = TB_MENU_DEFAULT_BG_COLOR
		})
		local tbMenuUserBarBottomSplat2 = UIElement:new( {
			parent = tbMenuUserBar,
			pos = {-tbMenuTopBarWidth, 0},
			size = {512, 128},
			bgImage = "/system/menutopbottomsplat.tga"
		})
		local tbMenuUserBarSplat = UIElement:new( {
			parent = tbMenuUserBar,
			pos = { -tbMenuTopBarWidth - 107, 0 },
			size = { 107, 107 },
			bgImage = "/system/menutopleftsplat.tga"
		})
		local tbMenuUserHeadAvatarViewport = UIElement:new( {
			parent = tbMenuUserBar,
			pos = { -tbMenuUserBar.size.w - 10, 10 },
			size = { 80, 80 },
			viewport = true
		})
		local headTexture = { "../../custom/tori/head.tga", "../../custom/tori/head.tga" }
		if (TB_MENU_PLAYER_INFO.items.textures.head.equipped) then
			headTexture[1] = "../../custom/" .. TB_MENU_PLAYER_INFO.username .. "/head.tga"
		end
		local tbMenuUserHeadAvatar = UIElement:new({
			parent = tbMenuUserHeadAvatarViewport,
			pos = { 0, 0, 10 },
			rot = { 0, 0, 0 },
			radius = 1,
			bgColor = { 1, 1, 1, 1 },
			bgImage = headTexture
		})
		local headRotation, headRotationDirection = 0, 1
		tbMenuUserHeadAvatar:addCustomDisplay(false, function()
				tbMenuUserHeadAvatar.rot.z = 180 - 180 * math.cos(headRotation) * headRotationDirection
				headRotation = headRotation + math.pi / 250
				if (math.floor(headRotation * 100) % math.floor(math.pi * 100) == 0) then
					headRotationDirection = headRotationDirection * -1
				end
			end)
		local color = get_color_info(TB_MENU_PLAYER_INFO.items.colors.force)
		local tbMenuUserHeadAvatarNeck = UIElement:new({
			parent = tbMenuUserHeadAvatarViewport,
			pos = { 0, 0, 9.35 },
			rot = { 0, 0, 0 },
			radius = 0.6,
			bgColor = { color.r, color.g, color.b, 1 }
		})
		local tbMenuUserName = UIElement:new( {
			parent = tbMenuUserBar,
			pos = { 80, 10 },
			size = { 350, 25 }
		})
		tbMenuUserName:addCustomDisplay(false, function()
				tbMenuUserName:uiText(TB_MENU_PLAYER_INFO.username, tbMenuUserName.pos.x + 2, tbMenuUserName.pos.y + 2, FONTS.BIG, LEFT, 0.55, nil, nil, {0,0,0,0.2})
				tbMenuUserName:uiText(TB_MENU_PLAYER_INFO.username, nil, nil, FONTS.BIG, LEFT, 0.55)
			end)
		if (TB_MENU_PLAYER_INFO.clan.clanid ~= 0) then
			local tbMenuClan = UIElement:new( {
				parent = tbMenuUserBar,
				pos = { 80, 45 },
				size = { 350, 20 }
			})
			tbMenuClan:addCustomDisplay(false, function()
					tbMenuClan:uiText("Clan: " .. TB_MENU_PLAYER_INFO.clan.clanTag .. "  |  " .. TB_MENU_PLAYER_INFO.clan.clanName, nil, nil, 4, LEFT, 0.6)
				end)
		end
		local tbMenuUserTcView = UIElement:new( {
			parent = tbMenuUserBar,
			pos = { 80, 65 },
			size = { 170, 25 },
			interactive = true,
			bgColor = {1,1,1,1},
			hoverColor = { 1, 0.81, 0.81, 1 },
			pressedColor = { 0.85, 0.42, 0.42, 1 },
			hoverSound = 31
		})
		tbMenuUserTcView:addCustomDisplay(true, function() end)
		tbMenuUserTcView:addMouseHandlers(nil, function()
				dofile("tc_purchase.lua")
			end, nil)
		local tbMenuUserTcIcon = UIElement:new( {
			parent = tbMenuUserTcView,
			pos = { 0, 0 },
			size = { tbMenuUserTcView.size.h, tbMenuUserTcView.size.h },
			bgImage = "/system/tc32px.tga"
		})
		tbMenuUserTcIcon:addCustomDisplay(false, function()
				local scale = 1.1
				local growth = 0.4
				if (tbMenuUserTcView.hoverState == BTN_HVR) then
					if (tbMenuUserTcIcon.size.h < tbMenuUserTcView.size.h * scale) then
						tbMenuUserTcIcon.size.h = tbMenuUserTcIcon.size.h + growth
						tbMenuUserTcIcon.size.w = tbMenuUserTcIcon.size.h
						if (tbMenuUserTcIcon.shift.x >= 0) then 
							tbMenuUserTcIcon.shift.x = -tbMenuUserTcView.size.w - growth / 2
							tbMenuUserTcIcon.shift.y = -tbMenuUserTcView.size.h - growth / 2
						else
							tbMenuUserTcIcon.shift.x = tbMenuUserTcIcon.shift.x - growth / 2 
							tbMenuUserTcIcon.shift.y = tbMenuUserTcIcon.shift.y - growth / 2
						end
					end
				elseif (tbMenuUserTcView.hoverState == BTN_DN) then
					tbMenuUserTcIcon.size.h = tbMenuUserTcView.size.h * scale
					tbMenuUserTcIcon.size.w = tbMenuUserTcIcon.size.h
					tbMenuUserTcIcon.shift.x = -tbMenuUserTcView.size.w - tbMenuUserTcView.size.h * (scale - 1) / 2
					tbMenuUserTcIcon.shift.y = -tbMenuUserTcView.size.h - tbMenuUserTcView.size.h * (scale - 1) / 2
				else
					tbMenuUserTcIcon.shift.x = 0
					tbMenuUserTcIcon.shift.y = tbMenuUserTcIcon.shift.x
					tbMenuUserTcIcon.size.h = tbMenuUserTcView.size.h
					tbMenuUserTcIcon.size.w = tbMenuUserTcIcon.size.h
				end
			end)
		local tbMenuUserTcBalance = UIElement:new( {
			parent = tbMenuUserTcView,
			pos = { 30, 0 },
			size = { tbMenuUserTcView.size.w - tbMenuUserTcIcon.size.w - 5, tbMenuUserTcView.size.h }
		})
		tbMenuUserTcBalance:addCustomDisplay(false, function()
				tbMenuUserTcBalance:uiText(PlayerInfo:tcFormat(TB_MENU_PLAYER_INFO.data.tc), nil, tbMenuUserTcBalance.pos.y + 2, nil, LEFT, 0.9, nil, nil, tbMenuUserTcView:getButtonColor())
			end)
		local tbMenuUserStView = UIElement:new( {
			parent = tbMenuUserBar,
			pos = { 255, 65 },
			size = { 100, 25 },
		})
		local tbMenuUserStIcon = UIElement:new( {
			parent = tbMenuUserStView,
			pos = { 0, 0 },
			size = { tbMenuUserStView.size.h, tbMenuUserStView.size.h },
			bgImage = "/system/st32px.tga"
		})
		local tbMenuUserStBalance = UIElement:new( {
			parent = tbMenuUserStView,
			pos = { 30, 0 },
			size = { tbMenuUserStView.size.w - 30, tbMenuUserStView.size.h }
		})
		tbMenuUserStBalance:addCustomDisplay(false, function()
				tbMenuUserStBalance:uiText(TB_MENU_PLAYER_INFO.data.st, nil, tbMenuUserStBalance.pos.y + 2, nil, LEFT, 0.9)
			end)
		local tbMenuUserQiView = UIElement:new( {
			parent = tbMenuUserBar,
			pos = { 325, 65 },
			size = { 125, 25 }
		})
		local tbMenuUserQi = UIElement:new( {
			parent = tbMenuUserQiView,
			pos = { 30, 0 },
			size = { tbMenuUserQiView.size.w - 25, tbMenuUserQiView.size.h }
		})
		tbMenuUserQi:addCustomDisplay(false, function()
				tbMenuUserQi:uiText(TB_MENU_PLAYER_INFO.data.qi .. " Qi", nil, tbMenuUserQi.pos.y + 2, nil, LEFT, 0.9)
			end)
	end
	
	function TBMenu:showNavigationBar(buttonsData, customNav)
		local tbMenuNavigationButtonsData = buttonsData or TBMenu:getMainNavigationButtons()
		local customNav = customNav or nil
		local tbMenuNavigationButtons = {}
		-- Button width has to be divisable by 10
		local navX = 30
		tbMenuNavigationBar = UIElement:new( {
			parent = tbMenuMain,
			pos = { 50, 130 },
			size = { WIN_W - 100, 50 },
			bgColor = { 0, 0, 0, 0.9 },
			shapeType = ROUNDED, 
			rounded = 15
		} )
		for i, v in pairs(tbMenuNavigationButtonsData) do 
			tbMenuNavigationButtons[i] = UIElement:new( {
				parent = tbMenuNavigationBar,
				pos = { navX, 0},
				size = { v.width, 50 },
				bgColor = { 0.2, 0.2, 0.2, 0 },
				interactive = true,
				hoverColor = TB_NAVBAR_DEFAULT_BG_COLOR,
				pressedColor = { 0.51, 0.11, 0.11, 1 },
				hoverSound = 31
			})
			navX = navX + v.width
			if (TB_LAST_MENU_SCREEN_OPEN == v.sectionId and not customNav) then
				tbMenuNavigationButtons[i].bgColor = TB_NAVBAR_DEFAULT_BG_COLOR
			end
			tbMenuNavigationButtons[i]:addCustomDisplay(false, function()
					set_color(tbMenuNavigationButtons[i].animateColor[1] - 0.1, tbMenuNavigationButtons[i].animateColor[2], tbMenuNavigationButtons[i].animateColor[3], tbMenuNavigationButtons[i].animateColor[4])
					for j = 40, 10, -10 do
						draw_line(tbMenuNavigationButtons[i].pos.x, tbMenuNavigationButtons[i].pos.y + j, tbMenuNavigationButtons[i].pos.x + j, tbMenuNavigationButtons[i].pos.y, 0.5)
					end
					for j = 0, tbMenuNavigationButtons[i].size.w - 50, 10 do
						draw_line(tbMenuNavigationButtons[i].pos.x + 50 + j, tbMenuNavigationButtons[i].pos.y, tbMenuNavigationButtons[i].pos.x + j, tbMenuNavigationButtons[i].pos.y + 50, 0.5)
					end
					for j = 40, 10, -10 do
						draw_line(tbMenuNavigationButtons[i].pos.x + tbMenuNavigationButtons[i].size.w - j, tbMenuNavigationButtons[i].pos.y + 50, tbMenuNavigationButtons[i].pos.x + tbMenuNavigationButtons[i].size.w, tbMenuNavigationButtons[i].pos.y + 50 - j, 0.5)
					end
					tbMenuNavigationButtons[i]:uiText(v.text, nil, tbMenuNavigationButtons[i].pos.y + 4, FONTS.BIG, nil, 0.65)
				end)
			tbMenuNavigationButtons[i]:addMouseHandlers(nil, function() 
					if (not customNav) then
						if (v.sectionId ~= TB_LAST_MENU_SCREEN_OPEN) then
							tbMenuCurrentSection:kill()
							TB_LAST_MENU_SCREEN_OPEN = v.sectionId
							for i, v in pairs(tbMenuNavigationButtons) do
								v.bgColor = { 0.2, 0.2, 0.2, 0 }
							end
							tbMenuNavigationButtons[i].bgColor = TB_NAVBAR_DEFAULT_BG_COLOR
							TBMenu:openMenu(TB_LAST_MENU_SCREEN_OPEN)
						end
					else 
						v.action()
					end
				end, nil)
		end
	end
	
	function TBMenu:getMainNavigationButtons()
		local buttonData = {
			{ text = "Home", sectionId = 1, width = 120 },
			{ text = "Play", sectionId = 2, width = 120 },
			{ text = "Practice", sectionId = 3, width = 190 },
			{ text = "Mods", sectionId = 4, width = 120 },
			{ text = "Tools", sectionId = 5, width = 140 }
		}
		return buttonData
	end
	
	function TBMenu:showBottomBar()
		local tbMenuBottomLeftBar = UIElement:new( {
			parent = tbMenuMain,
			pos = { 45, -80 },
			size = { 110, 50 }
		})
		local tbMenuBottomLeftButtonsData = {
			{ action = function() open_menu(3) end, image = "/system/settingsred.tga", imageHover = "/system/settingsredhover.tga", imagePress = "/system/settingsredpress.tga" },
			{ action = function() open_url("http://discord.gg/toribash") end, image = "/system/discordred.tga", imageHover = "/system/discordredhover.tga", imagePress = "/system/discordredpress.tga" }
		}
		local tbMenuBottomLeftButtons = {}
		for i, v in pairs(tbMenuBottomLeftButtonsData) do
			tbMenuBottomLeftButtons[i] = TBMenu:createImageButtons(tbMenuBottomLeftBar, (i - 1) * (tbMenuBottomLeftBar.size.h + 10), 0, tbMenuBottomLeftBar.size.h, tbMenuBottomLeftBar.size.h, v.image, v.imageHover, v.imagePress)
			tbMenuBottomLeftButtons[i]:addMouseHandlers(nil, v.action, nil)
		end
		
		local tbMenuBottomRightBar = UIElement:new({
			parent = tbMenuMain,
			pos = { -95, -80 },
			size = { 50, 50 }
		})
		local tbMenuNotifications = TBMenu:createImageButtons(tbMenuBottomRightBar, 0, 0, tbMenuBottomRightBar.size.h, tbMenuBottomRightBar.size.h, "system/notifications.tga", "system/notificationshover.tga", "system/notificationspress.tga")
		tbMenuNotifications:addMouseHandlers(nil, function()
				if (TB_MENU_NOTIFICATIONS_ISOPEN == 0) then
					TBMenu:openMenu(101)
				else
					Rewards:quit()
				end
			end, nil)
	end
	
	function TBMenu:showMain()
		local mainBgColor = nil
		if (enable_blur() == 0) then
			mainBgColor = {0, 0, 0, 0.1}
		end
		tbMenuMain = UIElement:new( {
			pos = {0, 0},
			size = {WIN_W, WIN_H},
			bgColor = mainBgColor
		})
		local splatLeftImg = "system/bloodsplatleft.tga"
		local splatCustom = false
		local customLogo = io.open("custom/" .. TB_MENU_PLAYER_INFO.username .. "/splatt1.tga", "r", 1)
		if (customLogo) then
			splatLeftImg = "../../custom/" .. TB_MENU_PLAYER_INFO.username .. "/splatt1.tga"
			splatCustom = true
			customLogo:close()
		end
		local splatLeft = UIElement:new( {
			parent = tbMenuMain,
			pos = { 10, 200 },
			size = { splatCustom and WIN_H - 320 or (WIN_H - 320) / 2, WIN_H - 320 },
			bgImage = splatLeftImg
		})
		local splatRight = UIElement:new( {
			parent = tbMenuMain,
			pos = { -(WIN_H - 320) - 10, 200 },
			size = { (WIN_H - 320), WIN_H - 320 },
			bgImage = splatCustom and splatLeftImg or "system/bloodsplatright.tga"
		})
		if (not TB_MENU_OS_CLOCK_SHIFT) then
			local tbMenuTime = UIElement:new({
				parent = tbMenuMain,
				pos = {0,0},
				size = {0,0}
			})
			local timeclock = os.time()
			tbMenuTime:addCustomDisplay(true, function()
					if (os.time() > timeclock) then
						TB_MENU_OS_CLOCK_SHIFT = os.clock() - math.floor(os.clock())
						tbMenuTime:kill()
					end
				end)
		end
		TBMenu:showGameLogo()
		TBMenu:showUserBar()
		TBMenu:showNavigationBar()
		TBMenu:openMenu(TB_LAST_MENU_SCREEN_OPEN)
		TBMenu:showBottomBar()
	end
		
		
	-- Draw functions for hooks	
	function TBMenu:drawVisuals()
		for i, v in pairs(UIElementManager) do
			v:updatePos()
		end
		for i, v in pairs(UIVisualManager) do
			v:display()
		end
	end
	
	function TBMenu:drawViewport()
		for i, v in pairs(UIViewportManager) do
			v:displayViewport()
		end
	end
	
end