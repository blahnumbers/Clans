-- daily login manager class

TC = 0
ITEM = 1

do
	LoginDaily = {}
	LoginDaily.__index = LoginDaily
	
	RewardData = {}
	
	-- Creates LoginDaily class and returns info on daily rewards
	function LoginDaily:create()
		local cln = {}
		setmetatable(cln, LoginDaily)
	
		local rewardClaimed = false
		
		return rewardClaimed
	end
	
	function LoginDaily:getRewardData()
		local data_types = { "reward_type", "tc_amount", "item" }
		local file = io.open("system/loginrewards.txt")
		if (file == nil) then
			file:close()
			return false
		end
		
		for ln in file:lines() do
			if string.match(ln, "^REWARD") then
				local segments = 5
				local data_stream = { ln:match(("([^\t]*)\t"):rep(segments)) }
				local days = tonumber(data_stream[2])
				RewardData[days - 1] = {}
				
				for i, v in ipairs(data_types) do
					if (i < 3) then
						RewardData[days - 1][v] = tonumber(data_stream[i + 2])
					else 
						RewardData[days - 1][v] = data_stream[i + 2]
					end
				end
			end
		end
		
		file:close()
	end
	
	function LoginDaily:showMain(available, days, timeleft)
		local nextTime = os.time() + timeleft
		
		if (days > 6) then
			days = days % 7
		end
		
		local loginViewBG = UIElement:new( {	pos = { WIN_W/2 - 374, WIN_H/2 - 164 },
												size = { 748, 328 },
												bgColor = {0,0,0,0.95},
												shapeType = ROUNDED,
												rounded = 25 } )
		local loginView = UIElement:new( {	parent = loginViewBG,
											pos = { 4, 4 },
											size = { loginViewBG.size.w - 8, loginViewBG.size.h - 8 },
											bgColor = {0.6,0,0,1},
											shapeType = loginViewBG.shapeType,
											rounded = 22.5,
											innerShadow = {0, 15},
											shadowColor = { {0,0,0,0}, {0.5,0,0,1} } } )
		local loginViewTitle = UIElement:new( {	parent = loginView,
												pos = {0, 7},
												size = {loginView.size.w, 50} } )
		loginViewTitle:addCustomDisplay(false, function()
			loginViewTitle:uiText("Daily Login Reward", nil, nil, FONTS.BIG, nil, 0.8, 0, 2)
		end)
		
		local dayRewardsView = UIElement:new( {	parent = loginView,
												pos = { 20, loginViewTitle.size.h + 20 },
												size = { loginView.size.w - 40, loginView.size.h - 190 } } )
		local dayReward = {}
		local dayRewardIcon = {}
		
		for i = 0, 6 do
			local iconMod = 0
			local rewFirst = 0
			local fontMod = 0.8
			local bgCol = {0,0,0,0.2}
			local bgImg = "torishop/icons/tc.tga"
			if (i == days) then
				if (i == 0) then
					rewFirst = dayRewardsView.size.w
				end
				iconMod = 20
				fontMod = 1
				bgCol = {0.8,0,0,1}
				
				local dayRewardCurrent = UIElement:new( {	parent = dayRewardsView,
															pos = { 3.5 + i * 100 - iconMod / 4 - rewFirst, -dayRewardsView.size.h - 1.5 - iconMod / 4},
															size = {103, dayRewardsView.size.h + 13},
															bgColor = {1,1,1,1},
															shapeType = ROUNDED,
															rounded = 12 } )
			end
			if (RewardData[i].reward_type == ITEM) then
				bgImg = "torishop/icons/" .. RewardData[i].item:lower() .. ".tga"
			end
			
			dayReward[i] = UIElement:new( {	parent = dayRewardsView,
											pos = { 5 + i * 100 - iconMod / 4, -dayRewardsView.size.h - iconMod / 4 },
											size = { 90 + iconMod / 2, dayRewardsView.size.h + iconMod / 2},
											bgColor = bgCol,
											shapeType = ROUNDED,
											rounded = 10 } )
			dayRewardIcon[i] = UIElement:new( {	parent = dayReward[i],
												pos = {13 - iconMod / 4, 13 - iconMod / 4},
												size = {64 + iconMod, 64 + iconMod},
												bgImage = bgImg } )
			dayReward[i]:addCustomDisplay(false, function()
				local str
				local yShift = 0
				if (RewardData[i].reward_type == ITEM) then
					str = RewardData[i].item
					yShift = 6 + iconMod * 0.5
				else 
					str = RewardData[i].tc_amount .. " TC"
				end
					
				dayReward[i]:uiText(str, nil, dayReward[i].pos.y + dayReward[i].size.h - 35 - yShift, FONTS.MEDIUM, nil, fontMod, 0, 1)
			end)
		end
		
		local rewardNextTime = UIElement:new( {	parent = loginView,
												pos = { 0, -110 },
												size = { loginView.size.w, 30 } } )
		rewardNextTime:addCustomDisplay(false, function()
			rewardNextTime:uiText(LoginDaily:getTime(nextTime - os.time(), available), nil, nil, nil, nil, nil, nil, 1)
		end)
		
		local rewardClaimBG = UIElement:new( {	parent = loginView,
												pos = { loginView.size.w / 2 - 153, -80 },
												size = { 306, 56 },
												bgColor = {0,0,0,0.5},
												shapeType = ROUNDED,
												rounded = 10 } )
		local rewardClaim = UIElement:new( {	parent = rewardClaimBG,
												pos = { 3, 3 },
												size = { rewardClaimBG.size.w - 6, rewardClaimBG.size.h - 6 },
												bgColor = { 1,0,0,0.5},
												shapeType = rewardClaimBG.shapeType,
												rounded = 8,
												interactive = available,
												hoverColor = { 1,0,0,0.6 },
												pressedColor = { 1,0,0,0.3 } } )
		rewardClaim:addCustomDisplay(false, function()
			local rewardClaimString = "Reward Claimed"
			if (available) then
				rewardClaimString = "Claim Reward"
			end
			rewardClaim:uiText(rewardClaimString, nil, rewardClaim.pos.y + 7, FONTS.BIG, nil, 0.55, nil, 2)
		end)
		rewardClaim:addMouseHandlers(function() end, function()
				local claimed = claim_reward()
				claimed = claimed:gsub("^REWARDS 0; ", "")
				claimed = claimed:gsub("%s%d.$", "")
				local claimedErr = claimed:gsub("^%d%s", "")
				claimed = claimed:gsub("%s%d$", "")
				claimed = tonumber(claimed)
				claimedErr = tonumber(claimedErr)
				rewardClaim:hide()
				rewardClaim.interactive = false
				rewardClaim:show()
				if (claimed == 0) then
					rewardClaim:addCustomDisplay(false, function()
						rewardClaim:uiText("Reward Claimed", nil, rewardClaim.pos.y + 13, FONTS.MEDIUM, nil, 1, nil, 1.5)
					end)
					available = false
				else
					local str
					if (claimedErr == 0) then
						str = " Error: no reward avaialble"
					elseif (claimedErr == 1) then
						str = "Timeout error"
					else 
						str = "Error claiming reward"
					end
					rewardClaim:addCustomDisplay(false, function()
						rewardClaim:uiText(str, nil, rewardClaim.pos.y + 13, FONTS.MEDIUM, nil, 0.95, nil, 1)
					end)
				end
			end, function() end)
		local quitButton = UIElement:new( {	parent = loginViewTitle,
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
				loginViewBG:kill()
				remove_hooks("dailyLoginVisual")
				--remove_hooks("uiMouseHandler")
				update_tc_balance()
			end, function() end)
	end
	
	function LoginDaily:getTime(timetonext, isClaimed)
		local returnval = ""
		local timeleft = 0
		if (math.floor(timetonext / 3600) > 1) then
			timetype = "hours"
			timeleft = math.floor(timetonext / 3600)
			timetonext = timetonext - timeleft * 3600
			returnval = timeleft .. " " .. timetype
		end
		if (math.floor(timetonext / 3600) == 1) then
			timetype = "hour"
			timeleft = math.floor(timetonext / 3600)
			timetonext = timetonext - timeleft * 3600
			returnval = timeleft .. " " .. timetype
		end
		if (math.floor(timetonext / 60) > 1) then
			timetype = "minutes"
			timeleft = math.floor(timetonext / 60)
			timetonext = timetonext - timeleft * 60
			returnval = returnval .. " " .. timeleft .. " " .. timetype
		end
		if (math.floor(timetonext / 60) == 1) then
			timetype = "minute"
			timeleft = math.floor(timetonext / 60)
			timetonext = timetonext - timeleft * 60
			returnval = returnval .. " " .. timeleft .. " " .. timetype
		end
		if (timetonext > 0) then 
			timetype = "seconds"
			returnval = returnval .. " " .. timetonext .. " " .. timetype
		end
		if (timetonext <= 0 and not isClaimed) then
			return "Reward will be available on next game launch"
		elseif (timetonext <= 0 and isClaimed) then
			return "Your reward expired! :("
		end
		
		if (not isClaimed) then
			return "Next reward in" .. returnval
		end
		return returnval .. " left to claim reward"
	end
	
	function LoginDaily:drawVisuals()
		for i, v in pairs(UIElementManager) do
			v:updatePos()
		end
		for i, v in pairs(UIVisualManager) do
			v:display()
		end
	end
										
end