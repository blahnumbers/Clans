-- clan data manager class

dofile("clans/errors.lua")

do
	Clan = {}
	Clan.__index = Clan
	
	ClanData = {}
	LevelData = {}
	AchievementData = {}
	
	-- Creates clan class
	function Clan:create(player)
		local cln = {}
		setmetatable(cln, Clan)
	
		if (player == "" or nil) then
			cln.clanid = 1
			--player = get_master().master.nick
		--end
		else
		cln.clanid = getClanId(player)
		end
		return cln
	end
	
	
	-- Populates clan data table
	-- clans/clan.txt is fetched from server
	function Clan:getClanData()
		local entries = 0
		local data_types = { "clanname", "clantag", "isofficial", "rank", "clanlevel", "clanxp", "memberstotal", "isfreeforall", "clantopach", "members", "leaders" }
		local file = io.open("clans/clans.txt")
		if (file == nil) then
			err(ERR.clanDataEmpty)
			file:close()
			return false
		end
		
		for ln in file:lines() do
			if string.match(ln, "^CLAN") then
				local segments = 13
				local data_stream = { ln:match(("([^\t]*)\t"):rep(segments)) }
				local clanid = tonumber(data_stream[2])
				for i = 5, 11 do 
					data_stream[i] = tonumber(data_stream[i])
				end
				ClanData[clanid] = {}
				
				for i, v in ipairs(data_types) do
					ClanData[clanid][v] = data_stream[i + 2]
				end
				entries = entries + 1
			end
		end
		
		file:close()
		return entries
	end
	
	function Clan:getLevelData()
		local file = io.open("clans/clanlevels.txt")
		if (file == nil) then
			err(ERR.clanLevelDataEmpty)
			file:close()
			return false
		end
		
		for ln in file:lines() do
			if string.match(ln, "^LEVEL") then
				local segments = 3
				local data_stream = { ln:match(("([^\t]*)\t"):rep(segments)) }
				local level = tonumber(data_stream[2])
				LevelData[level] = tonumber(data_stream[3])
			end
		end
		
		file:close()
		return entries
	end
	
	function Clan:getAchievementData()
		local data_types = { "achname", "achdesc" }
		local file = io.open("clans/clanachievements.txt")
		if (file == nil) then
			err(ERR.clanAchievementDataEmpty)
			file:close()
			return false
		end
		
		for ln in file:lines() do
			if string.match(ln, "^ACHIEVEMENT") then
				local segments = 4
				local data_stream = { ln:match(("([^\t]*)\t"):rep(segments)) }
				local level = tonumber(data_stream[2])
				AchievementData[level] = {}
				
				for i, v in ipairs(data_types) do
					AchievementData[level][v] = data_stream[i + 2]
				end
			end
		end
		
		file:close()
		return entries
	end
	
	function Clan:showMain()
		clanViewBG = UIElement:new( {	pos = CLANVIEWLASTPOS or {WIN_W/2 - 400, WIN_H/2 - 225},
										size = {800, 450},
										bgColor = {.1,.1,.1,0.9},
										interactive = true,
										shapeType = ROUNDED,
										rounded = 10 } )
		clanViewBG:addMouseHandlers(
			function(s,x,y)
				clanViewBG.pressedPos.x = clanViewBG.pos.x - x
				clanViewBG.pressedPos.y = clanViewBG.pos.y - y
			end, nil, 
			function(x,y)
				if (clanViewBG.hoverState == BTN_DN) then
					local posX = x + clanViewBG.pressedPos.x
					local posY = y + clanViewBG.pressedPos.y
					clanViewBG:moveTo(posX, posY)
					CLANVIEWLASTPOS = { clanViewBG.pos.x, clanViewBG.pos.y }
				end
			end)
		clanView = UIElement:new( {	parent = clanViewBG,
											pos = {4,4},
											bgColor = {1,1,1,0.6},
											size = {clanViewBG.size.w - 8, clanViewBG.size.h - 8},
											shapeType = clanViewBG.shapeType,
											rounded = clanViewBG.rounded / 3 * 2 } )
		clanTopBar = UIElement:new( {	parent = clanView,
											pos = {0,0},
											bgColor = {0.2,0.2,0.2,1},
											size = {clanView.size.w, 50},
											shapeType = clanView.shapeType,
											rounded = clanView.rounded } )
		clanTopBar:addCustomDisplay(false, function()
				draw_quad(clanTopBar.pos.x, clanTopBar.pos.y + clanTopBar.size.h - 10, clanTopBar.size.w, 10)
			end)
		clanViewQuitButton = UIElement:new( {	parent = clanTopBar,
												pos = {-45, 5},
												size = {35, 35},
												bgColor = {0.5,0.5,0.5,1},
												interactive = true,
												hoverColor = {0.6,0.4,0.4,1},
												pressedColor = {1,0.3,0.3,1},
												shapeType = ROUNDED,
												rounded = 10 } )
		clanViewQuitButton:addMouseHandlers(function() end,
			function()
				remove_hooks("clanVisual")
				remove_hooks("uiMouseHandler")
				clanView:kill()
			end, function() end)
		clanViewQuitButton:addCustomDisplay(false, function()
			local indent = 8
			local weight = 10
			-- Quit button
			if (clanViewQuitButton.hoverState == BTN_DN) then
				set_color(1,1,1,1)
			else
				set_color(0,0,0,1)
			end
			draw_line(clanViewQuitButton.pos.x + indent, clanViewQuitButton.pos.y + indent, clanViewQuitButton.pos.x + clanViewQuitButton.size.w - indent, clanViewQuitButton.pos.y + clanViewQuitButton.size.h - indent, weight)
			draw_line(clanViewQuitButton.pos.x + clanViewQuitButton.size.w - indent, clanViewQuitButton.pos.y + indent, clanViewQuitButton.pos.x + indent, clanViewQuitButton.pos.y + clanViewQuitButton.size.h - indent, weight)
		end)
		clanViewBackButton = UIElement:new( {	parent = clanTopBar,
												pos = {10, 5},
												size = {35, 35},
												bgColor = {0.5,0.5,0.5,1},
												interactive = true,
												hoverColor = {0.7,0.7,0.7,1},
												pressedColor = {0.3,0.3,0.3,1},
												shapeType = ROUNDED,
												rounded = 10 } )
		clanViewBackButton:addCustomDisplay(false, function()
			local indent = 4
			local weight = 10
			-- Back button
			if (clanViewBackButton.hoverState == BTN_DN) then
				set_color(1,1,1,1)
			else
				set_color(0,0,0,1)
			end
			draw_line(clanViewBackButton.pos.x + indent * 2, clanViewBackButton.pos.y + clanViewBackButton.size.h / 2, clanViewBackButton.pos.x + clanViewBackButton.size.w - indent, clanViewBackButton.pos.y + clanViewBackButton.size.h / 2, weight)
			draw_disk(clanViewBackButton.pos.x + 14, clanViewBackButton.pos.y + 13.5 + indent, 0, 11, 3, 1, -90, 360, 0)
		end)
		tabName = UIElement:new( {	parent = clanTopBar,
									pos = {clanViewBackButton.size.w + 20,2},
									size = {clanView.size.w - clanViewQuitButton.size.w - clanViewBackButton.size.w - 40, 45} } )
	end
	
	-- Displays single clan data
	function Clan:showClan(clanid)
		local clanLevelValue = ClanData[clanid].clanlevel
		local clanTopAch = ClanData[clanid].clantopach
		local xpBarProgress = (ClanData[clanid].clanxp - LevelData[clanLevelValue]) / (LevelData[clanLevelValue + 1] - LevelData[clanLevelValue])
		
		clanViewBackButton:addMouseHandlers(function() end, function() end, function() end)
		tabName:addCustomDisplay(false, function()
			local clanNameStr = nil
			if (ClanData[clanid].isofficial == 1) then
				clanNameStr = "[" .. ClanData[clanid].clantag .. "] " .. ClanData[clanid].clanname
			else
				clanNameStr = "(" .. ClanData[clanid].clantag .. ") " .. ClanData[clanid].clanname
			end
			set_color(1,1,1,1)
			tabName:uiText(clanNameStr, tabName.pos.x, tabName.pos.y, FONTS.BIG, CENTER, 0.7)
			end)
		
		local clanInfoView = UIElement:new( {	parent = clanView,
												pos = { 10, clanTopBar.size.h + 10 },
												size = { clanView.size.w - 275, clanView.size.h - clanTopBar.size.h - 20},
												bgColor = {0,0,0,0.1},
												shapeType = ROUNDED,
												rounded = 10 } )
		local clanInfoRightView = UIElement:new( {	parent = clanView,
													pos = { -260, clanTopBar.size.h + 10 },
													size = { 250, clanView.size.h - clanTopBar.size.h - 20 } } )
		local clanLevel = UIElement:new( {	parent = clanInfoView,
											pos = {0, 5},
											size = {clanInfoView.size.w, 35} } )
		clanLevel:addCustomDisplay(false, function()
			set_color(1,1,1,1)
			clanLevel:uiText("Clan Level " .. clanLevelValue, clanLevel.pos.x, clanLevel.pos.y, FONTS.BIG, CENTER, 0.6)
			end)
		local clanXpBarOutline = UIElement:new( {	parent = clanInfoView,
													pos = {10, 45},
													size = {clanInfoView.size.w - 20, 50},
													bgColor = {0.1,0.1,0.1,0.5},
													shapeType = ROUNDED,
													rounded = 10 } )
		local clanXpBar = UIElement:new( {	parent = clanXpBarOutline,
											pos = {2, 2},
											size = {clanXpBarOutline.size.w - 4, clanXpBarOutline.size.h - 4},
											bgColor = {1,1,1,0.3},
											shapeType = clanXpBarOutline.shapeType,
											rounded = clanXpBarOutline.rounded / 5 * 4 } )
		local clanXpBarProgress = UIElement:new( {	parent = clanXpBar,
													pos = {0, 0},
													size = {clanXpBar.size.w * xpBarProgress, clanXpBar.size.h},
													bgColor = {0,0.8,0,0.7},
													shapeType = clanXpBar.shapeType,
													rounded = clanXpBar.rounded } )
		local clanXp = UIElement:new( {	parent = clanXpBar,
										pos = {0, 8},
										size = {clanInfoView.size.w, 25} } )
		clanXp:addCustomDisplay(false, function()
			set_color(1,1,1,1)
			clanXp:uiText(ClanData[clanid].clanxp .. " / " .. LevelData[clanLevelValue + 1] .. " XP", clanXp.pos.x, clanXp.pos.y, FONTS.BIG, CENTER, 0.5)
		end)
		local clanForumLinkOutline = UIElement:new( {	parent = clanInfoView,
														pos = {clanInfoView.size.w / 2 - 160, -60},
														size = {300, 50},
														bgColor = {0.1,0.1,0.1,0.5},
														shapeType = ROUNDED,
														rounded = 10 } )
		local clanForumLink = UIElement:new( {	parent = clanForumLinkOutline,
												pos = {2, 2},
												size = {clanForumLinkOutline.size.w - 4, clanForumLinkOutline.size.h - 4},
												bgColor = {1,1,1,0.3},
												interactive = true,
												hoverColor = {1,1,1,0.5},
												pressedColor = {1,1,1,0.1},
												shapeType = clanForumLinkOutline.shapeType,
												rounded = clanForumLinkOutline.rounded / 5 * 4 } )
		clanForumLink:addMouseHandlers(nil,
			function()
				open_url("http://forum.toribash.com/clan.php?clanid="..clanid)
			end, nil)
		clanForumLink:addCustomDisplay(false, function()
			set_color(1,1,1,1)
			clanForumLink:uiText("Clan page on forum", clanForumLink.pos.x, clanForumLink.pos.y + 10, FONTS.MEDIUM, CENTER)
		end)
--[[	local clanMembersOutline = UIElement:new( {	parent = clanInfoView,
													pos = {10, 105},
													size = {clanInfoView.size.w / 2 - 15, 90},
													bgColor = {0,0,0,0.5},
													shapeType = ROUNDED,
													rounded = 10 } )
		local clanMembers = UIElement:new( {	parent = clanMembersOutline,
												pos = {2, 2},
												size = {clanMembersOutline.size.w - 4, clanMembersOutline.size.h - 4},
												bgColor = {1,1,1,0.5},
												shapeType = clanMembersOutline.shapeType,
												rounded = clanMembersOutline.rounded / 5 * 4 } )
		clanMembers:addCustomDisplay(false, function()
			set_color(1,1,1,1)
			clanMembers:uiText("Total Members", clanMembers.pos.x, clanMembers.pos.y, FONTS.MEDIUM, CENTER)
			clanMembers:uiText(ClanData[clanid].memberstotal, clanMembers.pos.x, clanMembers.pos.y + 35, FONTS.BIG, CENTER, 0.6)
		end)
		local clanLeadersOutline = UIElement:new( {	parent = clanInfoView,
													pos = {-clanInfoView.size.w / 2 + 5, 105},
													size = {clanInfoView.size.w / 2 - 15, 90},
													bgColor = {0,0,0,0.5},
													shapeType = ROUNDED,
													rounded = 10 } )
		local clanLeaders = UIElement:new( {	parent = clanLeadersOutline,
												pos = {2, 2},
												size = {clanLeadersOutline.size.w - 4, clanLeadersOutline.size.h - 4},
												bgColor = {1,1,1,0.5},
												shapeType = clanLeadersOutline.shapeType,
												rounded = clanLeadersOutline.rounded / 5 * 4 } )
		clanLeaders:addCustomDisplay(false, function()
			set_color(1,1,1,1)
			if (ClanData[clanid].leaders:match("%s")) then
				clanLeaders:uiText("Leaders", clanLeaders.pos.x, clanLeaders.pos.y, FONTS.MEDIUM, CENTER)
			else
				clanLeaders:uiText("Leader", clanLeaders.pos.x, clanLeaders.pos.y, FONTS.MEDIUM, CENTER)
			end
		end)
		local clanLeadersList = UIElement:new( {	parent = clanLeaders,
													pos = {5, 22},
													size = {40, clanLeaders.size.h - 20} } )
		clanLeadersList:addCustomDisplay(false, function()
			set_color(1,1,1,1)
			clanLeadersList:uiText(ClanData[clanid].leaders, clanLeadersList.pos.x, clanLeadersList.pos.y, 4, LEFT, 0.8)
		end)
--]]
		local clanMembersOutline = UIElement:new( {	parent = clanInfoView,
													pos = { 10, clanLevel.size.h + clanXpBarOutline.size.h + 20 },
													size = {clanInfoView.size.w - 20, 90},
													bgColor = {0,0,0,0.5},
													shapeType = ROUNDED,
													rounded = 10 } )
		local clanMembers = UIElement:new( {	parent = clanMembersOutline,
												pos = {2,2},
												size = {clanMembersOutline.size.w - 4, clanMembersOutline.size.h - 4},
												bgColor = {1,1,1,0.5},
												interactive = true,
												hoverColor = {1,1,1,0.6},
												pressedColor = {1,1,1,0.1},
												shapeType = clanMembersOutline.shapeType,
												rounded = clanMembersOutline.rounded / 5 * 4 } )
		clanMembers:addCustomDisplay(false, function()
			set_color(1,1,1,1)
			clanMembers:uiText("Clan Roster", clanMembers.pos.x, clanMembers.pos.y + 5, FONTS.BIG, CENTER, 0.5)
			clanMembers:uiText("Press to see all clan members", clanMembers.pos.x, clanMembers.pos.y + 45, FONTS.MEDIUM, CENTER, 0.9)
		end)
		clanMembers:addMouseHandlers(nil,
			function()
				clanInfoView:kill()
				clanInfoRightView:kill()
				Clan:showMembers(clanid)
			end, nil)
		local clanTopAchievementOutline = UIElement:new( {	parent = clanInfoView,
															pos = { 10, 205 },
															size = {clanInfoView.size.w - 20, 100},
															bgColor = {0,0,0,0.5},
															shapeType = ROUNDED,
															rounded = 10 } )
		local clanTopAchievement = UIElement:new( {	parent = clanTopAchievementOutline,
													pos = {2,2},
													size = {clanTopAchievementOutline.size.w - 4, clanTopAchievementOutline.size.h - 4},
													bgColor = {1,1,1,0.5},
													shapeType = clanTopAchievementOutline.shapeType,
													rounded = clanTopAchievementOutline.rounded / 5 * 4 } )
		local clanTopAchIcon
		local clanTopAchName
		local clanTopAchDesc
		if (clanTopAch ~= 0) then
			clanTopAchIcon = UIElement:new( {	parent = clanTopAchievement,
												pos = {10, 8},
												size = {80,80},
												bgImage = "/clans/aid"..clanTopAch..".tga" } )
			 clanTopAchName = UIElement:new( {	parent = clanTopAchievement,
												pos = {100, 5},
												size = {clanTopAchievement.size.w - 110, 20} } )
			clanTopAchName:addCustomDisplay(false, function()
				set_color(1,1,1,1)
				clanTopAchName:uiText(AchievementData[clanTopAch].achname, clanTopAchName.pos.x, clanTopAchName.pos.y, FONTS.MEDIUM, CENTER)
			end)
			clanTopAchDesc = UIElement:new( {	parent = clanTopAchievement,
													pos = {100, 30},
													size = {clanTopAchievement.size.w - 110, 66} } )
			clanTopAchDesc:addCustomDisplay(false, function()
				set_color(1,1,1,1)
				clanTopAchDesc:uiText(AchievementData[clanTopAch].achdesc, clanTopAchDesc.pos.x, clanTopAchDesc.pos.y, FONTS.SMALL, CENTER)
			end)
		else
			clanTopAchDesc = UIElement:new( {	parent = clanTopAchievement,
												pos = {50, 25},
												size = {clanTopAchievement.size.w - 100, 50} } )
			clanTopAchDesc:addCustomDisplay(false,
				function()
					set_color(1,1,1,1)
					clanTopAchDesc:uiText("This clan hasnt chosen an achievement to display", clanTopAchDesc.pos.x, clanTopAchDesc.pos.y, FONTS.MEDIUM, CENTER)
				end)
		end
		local clanRank = UIElement:new( {	parent = clanInfoRightView,
											pos = { 0, 0 },
											size = { clanInfoRightView.size.w, 50 },
											bgColor = {0,0,0,0.1},
											shapeType = ROUNDED,
											rounded = 10 } )
		clanRank:addCustomDisplay(false, function()
			set_color(1,1,1,1)
			clanRank:uiText("Rank "..ClanData[clanid].rank, clanRank.pos.x, clanRank.pos.y + 5, FONTS.BIG, CENTER, 0.6)
		end)
		local clanLogo = UIElement:new( {	parent = clanInfoRightView,
											pos = { 0, clanRank.size.h + 5 },
											size = { 250, 250 },
											bgColor = {0,0,0,0.1},
											bgImage = "/clans/cid"..clanid.."logo.tga",
											shapeType = ROUNDED,
											rounded = 10 } )
		local clanJoin = UIElement:new( {	parent = clanInfoRightView,
											pos = { 0, clanRank.size.h + clanLogo.size.h + 10 },
											size = { 250, 60 },
											bgColor = {0,0,0,0.1},
											shapeType = ROUNDED,
											rounded = 10 } )
		local clanJoinButtonOutline = nil
		local clanJoinButton = nil
		if (ClanData[clanid].isfreeforall == 1 and FREEJOINENABLED) then
			clanJoinButtonOutline = UIElement:new( {	parent = clanJoin,
														pos = { 10, 10 },
														size = {clanJoin.size.w - 20, clanJoin.size.h - 20},
														bgColor = {0.1,0.1,0.1,0.5},
														shapeType = ROUNDED,
														rounded = 10 } )
			clanJoinButton = UIElement:new( {	parent = clanJoinButtonOutline,
												pos = { 2, 2 },
												size = {clanJoinButtonOutline.size.w - 4, clanJoinButtonOutline.size.h - 4},
												bgColor = {1,1,1,0.3},
												interactive = true,
												hoverColor = {1,1,1,0.5},
												pressedColor = {1,1,1,0.1},
												shapeType = clanJoinButtonOutline.shapeType,
												rounded = clanJoinButtonOutline.rounded / 5 * 4 } )
			clanJoinButton:addCustomDisplay(false, function()
				set_color(1,1,1,1)
				clanJoinButton:uiText("Join Clan", clanJoinButton.pos.x, clanJoinButton.pos.y + 5, FONTS.MEDIUM, CENTER)
			end)
			clanJoinButton:addMouseHandlers(nil,
				function()
				open_url("http://forum.toribash.com/clan.php?clanid="..clanid.."?join=true")
			end, nil)
		elseif (ClanData[clanid].isfreeforall == 1) then
			clanJoin:addCustomDisplay(false, function()
				set_color(1,1,1,1)
				clanJoin:uiText("Free to join", clanJoin.pos.x, clanJoin.pos.y + 15, FONTS.MEDIUM, CENTER)
			end)
		else
			clanJoin:addCustomDisplay(false, function()
				set_color(1,1,1,1)
				clanJoin:uiText("Invite Only", clanJoin.pos.x, clanJoin.pos.y + 15, FONTS.MEDIUM, CENTER)
			end)
		end
	end
	
	function Clan:showMembers(clanid)		
		local clanLeadersView = UIElement:new( {	parent = clanView,
													pos = { 10, clanTopBar.size.h + 10 },
													size = { 200, clanView.size.h - clanTopBar.size.h - 20 },
													bgColor = {0,0,0,0.1},
													shapeType = ROUNDED,
													rounded = 10 } )
		local clanMembersView = UIElement:new( {	parent = clanView,
													pos = { clanLeadersView.size.w + 20, clanTopBar.size.h + 10 },
													size = { clanView.size.w - clanLeadersView.size.w - 30, clanView.size.h - clanTopBar.size.h - 20 },
													bgColor = {0,0,0,0.1},
													shapeType = ROUNDED,
													rounded = 10 } )
		local clanLeadersCaption = UIElement:new( {	parent = clanLeadersView,
													pos = {0, 0},
													size = {clanLeadersView.size.w, 25} } )
		clanLeadersCaption:addCustomDisplay(false, function()
			set_color(1,1,1,1)
			if (ClanData[clanid].leaders:match("%s")) then
				clanLeadersCaption:uiText("Leaders", clanLeadersCaption.pos.x, clanLeadersCaption.pos.y, FONTS.MEDIUM, CENTER)
			else
				clanLeadersCaption:uiText("Leader", clanLeadersCaption.pos.x, clanLeadersCaption.pos.y, FONTS.MEDIUM, CENTER)
			end
		end)
		local clanMembersCaption = UIElement:new( {	parent = clanMembersView,
													pos = {0, 0},
													size = {clanMembersView.size.w, 25} } )
		clanMembersCaption:addCustomDisplay(false, function()
			set_color(1,1,1,1)
			clanMembersCaption:uiText("Members", clanMembersCaption.pos.x, clanMembersCaption.pos.y, FONTS.MEDIUM, CENTER)
		end)
		local clanLeaders = UIElement:new( {	parent = clanLeadersView,
												pos = {10, clanLeadersCaption.size.h + 10},
												size = {clanLeadersView.size.w - 20, clanLeadersView.size.h - clanLeadersCaption.size.h - 20} } )
		local clanLeadersAll = textAdapt(ClanData[clanid].leaders, FONTS.MEDIUM, 1, 20)
		local clanLeadersList = {}
		for i = 1, #clanLeadersAll do
			if (i * 25 > clanLeaders.size.h) then
				break
			end
			clanLeadersList[i] = UIElement:new( {	parent = clanLeaders,
													pos = {0, (i-1)*25},
													size = {clanLeaders.size.w, 25},
													bgColor = {1,1,1,1},
													interactive = true,
													hoverColor = {0.8,0.8,0.8,1},
													pressedColor = {0.4,0.4,0.4,1} } )
			clanLeadersList[i]:addCustomDisplay(true, function()
				clanLeadersList[i]:setButtonColor()
				clanLeadersList[i]:uiText(clanLeadersAll[i], clanLeadersList[i].pos.x, clanLeadersList[i].pos.y, FONTS.MEDIUM)
			end)
			clanLeadersList[i]:addMouseHandlers(nil, function()
				open_url("http://forum.toribash.com/member.php?username="..clanLeadersAll[i])
			end, nil)
		end
		local clanMembers = UIElement:new( {	parent = clanMembersView,
												pos = {10, clanMembersCaption.size.h + 10},
												size = {clanMembersView.size.w - 20, clanMembersView.size.h - clanMembersCaption.size.h - 20} } )
		local clanMembersAll = textAdapt(ClanData[clanid].members, FONTS.MEDIUM, 1, 20)
		local clanMembersList = {}
		local memberPos = { x = 0, y = -20 }
		for i = 1, #clanMembersAll do
			memberPos.y = memberPos.y + 20
			if (memberPos.x + 270 > clanMembers.size.w and memberPos.y + 60 > clanMembers.size.h) then
				clanMembersList[i] = UIElement:new ( {	parent = clanMembers,
														pos = {-135, -40},
														size = {135, 40},
														bgColor = {1,1,1,.5},
														shapeType = ROUNDED,
														rounded = 10,
														interactive = true,
														hoverColor = {0.8,0.8,0.8,.5},
														pressedColor = {0.4,0.4,0.4,.5} } )
				clanMembersList[i]:addCustomDisplay(false, function()
					set_color(0.2,0.2,0.2,1)
					clanMembersList[i]:uiText("View All", clanMembersList[i].pos.x, clanMembersList[i].pos.y + 8, FONTS.MEDIUM, CENTER)
				end)
				clanMembersList[i]:addMouseHandlers(nil, function()
					open_url("http://forum.toribash.com/clan.php?clanid="..clanid)
				end, nil)
				break
			end--]]
			if (memberPos.y + 20 > clanMembers.size.h) then
				memberPos.x = memberPos.x + 135
				memberPos.y = 0
			end
			clanMembersList[i] = UIElement:new( {	parent = clanMembers,
													pos = {memberPos.x, memberPos.y},
													size = {135, 20},
													bgColor = {1,1,1,1},
													interactive = true,
													hoverColor = {0.8,0.8,0.8,1},
													pressedColor = {0.4,0.4,0.4,1} } )
			clanMembersList[i]:addCustomDisplay(true, function()
				clanMembersList[i]:setButtonColor()
				clanMembersList[i]:uiText(clanMembersAll[i], clanMembersList[i].pos.x, clanMembersList[i].pos.y, FONTS.MEDIUM, LEFT, 0.8)
			end)
			clanMembersList[i]:addMouseHandlers(nil, function()
				open_url("http://forum.toribash.com/member.php?username="..clanMembersAll[i])
			end, nil)
		end
		
		clanViewBackButton:addMouseHandlers(function() end,
			function()
				Clan:showClan(clanid)
				clanLeadersView:kill()
				clanMembersView:kill()
			end, function() end)
		tabName:addCustomDisplay(false, function()
			local clanNameStr = nil
			if (ClanData[clanid].isofficial == 1) then
				clanNameStr = "[" .. ClanData[clanid].clantag .. "] Clan Roster"
			else
				clanNameStr = "(" .. ClanData[clanid].clantag .. ") Clan Roster"
			end
			set_color(1,1,1,1)
			tabName:uiText(clanNameStr, tabName.pos.x, tabName.pos.y, FONTS.BIG, CENTER, 0.7)
			end)
	end
	

	function getClanId(player)
		local str = "[)\]]"
		local strMatch = string.find(player, str)
		
		if (strMatch) then
			player = string.sub(player, strMatch + 1)
		end
		
			local file = io.open("custom/" .. player .. "/item.dat", 'r', 60)
			if (file == nil) then
				err(ERR.playerFolderPerms)
				file:close()
			return false
		end
				
			for ln in file:lines() do
			if string.match(ln, "CLAN 0;") then
				local clanid = string.gsub(ln, "CLAN 0;", "")
					clanid = tonumber(clanid)
				file:close()
				return clanid
			end
		end
		err(ERR.playerFolderClan)
		file:close()
		return false
	end
	
	function Clan:drawVisuals()
		for i, v in pairs(UIVisualManager) do
			v:display()
		end
	end
end