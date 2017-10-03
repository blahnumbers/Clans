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
		local data_types = { "clanname", "clantag", "isofficial", "rank", "clanlevel", "clanxp", "members", "isfreeforall", "clantopach", "leaders" }
		local file = io.open("clans/clans.txt")
		if (file == nil) then
			err(ERR.clanDataEmpty)
			file:close()
			return false
		end
		
		for ln in file:lines() do
			if string.match(ln, "^CLAN") then
				local segments = 12
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
	
	-- Displays single clan data
	function Clan:showData(clanid)
		local clanLevelValue = ClanData[clanid].clanlevel
		local clanTopAch = ClanData[clanid].clantopach
		local clanViewBG = UIElement:new( {	pos = CLANVIEWLASTPOS or {WIN_W/4, WIN_H/4},
											size = {800, 450},
											bgColor = {.1,.1,.1,0.8},
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
		local clanView = UIElement:new( {	parent = clanViewBG,
											pos = {4,4},
											bgColor = {1,1,1,.6},
											size = {clanViewBG.size.w - 8, clanViewBG.size.h - 8},
											shapeType = clanViewBG.shapeType,
											rounded = clanViewBG.rounded / 3 * 2 } )
		local clanViewQuitButton = UIElement:new( {	parent = clanView,
													pos = {-45, 10},
													size = {35, 35},
													bgColor = {0.5,0.5,0.5,1},
													interactive = true,
													hoverColor = {0.6,0.4,0.4,1},
													pressedColor = {1,0.3,0.3,1},
													shapeType = ROUNDED,
													rounded = 10 } )
		clanViewQuitButton:addMouseHandlers(nil,
			function()
				remove_hooks("clanVisual")
				remove_hooks("uiMouseHandler")
				clanView:kill()
			end, nil)
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
		local clanName = UIElement:new( {	parent = clanView,
											pos = {10,10},
											size = {clanView.size.w - clanViewQuitButton.size.w - 25, 45} } )
		clanName:addCustomDisplay(false, function()
			local clanNameStr = nil
			if (ClanData[clanid].isofficial == 1) then
				clanNameStr = "[" .. ClanData[clanid].clantag .. "] " .. ClanData[clanid].clanname
			else
				clanNameStr = "(" .. ClanData[clanid].clantag .. ") " .. ClanData[clanid].clanname
			end
			set_color(0.1,0.1,0.1,1)
			clanName:uiText(clanNameStr, clanName.pos.x, clanName.pos.y, FONTS.BIG, CENTER, 0.7)
			end)
		local clanInfoView = UIElement:new( {	parent = clanView,
												pos = { 10, clanName.size.h + 15 },
												size = { clanView.size.w - 275, clanView.size.h - clanName.size.h - 25},
												bgColor = {0,0,0,0.1},
												shapeType = ROUNDED,
												rounded = 10 } )
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
		local xpBarProgress = (ClanData[clanid].clanxp - LevelData[clanLevelValue]) / (LevelData[clanLevelValue + 1] - LevelData[clanLevelValue])
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
		local clanMembersOutline = UIElement:new( {	parent = clanInfoView,
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
			clanMembers:uiText(ClanData[clanid].members, clanMembers.pos.x, clanMembers.pos.y + 35, FONTS.BIG, CENTER, 0.6)
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
		local clanTopAchIcon = UIElement:new( {	parent = clanTopAchievement,
												pos = {10, 8},
												size = {80,80},
												bgImage = "/clans/aid"..clanTopAch..".tga" } )
		local clanTopAchName = UIElement:new( {	parent = clanTopAchievement,
												pos = {100, 5},
												size = {clanTopAchievement.size.w - 110, 20} } )
		clanTopAchName:addCustomDisplay(false, function()
			set_color(1,1,1,1)
			clanTopAchName:uiText(AchievementData[clanTopAch].achname, clanTopAchName.pos.x, clanTopAchName.pos.y, FONTS.MEDIUM, CENTER)
		end)
		local clanTopAchDesc = UIElement:new( {	parent = clanTopAchievement,
												pos = {100, 30},
												size = {clanTopAchievement.size.w - 110, 66} } )
		clanTopAchDesc:addCustomDisplay(false, function()
			set_color(1,1,1,1)
			clanTopAchDesc:uiText(AchievementData[clanTopAch].achdesc, clanTopAchDesc.pos.x, clanTopAchDesc.pos.y, FONTS.SMALL, CENTER)
		end)
		local clanRank = UIElement:new( {	parent = clanView,
											pos = { -260, clanName.size.h + 15 },
											size = { 250, 50 },
											bgColor = {0,0,0,0.1},
											shapeType = ROUNDED,
											rounded = 10 } )
		clanRank:addCustomDisplay(false, function()
			set_color(1,1,1,1)
			clanRank:uiText("Rank "..ClanData[clanid].rank, clanRank.pos.x, clanRank.pos.y + 5, FONTS.BIG, CENTER, 0.6)
		end)
		local clanLogo = UIElement:new( {	parent = clanView,
											pos = { -260, clanName.size.h + clanRank.size.h + 20 },
											size = { 250, 250 },
											bgColor = {0,0,0,0.1},
											bgImage = "/clans/cid"..clanid.."logo.tga",
											shapeType = ROUNDED,
											rounded = 10 } )
		local clanJoin = UIElement:new( {	parent = clanView,
											pos = { -260, clanName.size.h + clanRank.size.h + clanLogo.size.h + 25 },
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