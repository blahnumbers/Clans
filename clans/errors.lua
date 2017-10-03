-- errors class

do
	ERR = 	{	playerFolderPerms = "^36Clans ^07:: Failed to load player's clan, please download player's customs first ^07and verify folder permissions",
				playerFolderClan = "^36Clans ^07:: Failed to read player's clan, please verify you're using the latest ^07version of Toribash",
				clanDataEmpty = "^36Clans ^07:: Failed to load clans' info, please verify cache integrity and folder permissions",
				clanLevelDataEmpty = "^36Clans ^07:: Failed to load levels data, please verify cache integrity and folder permissions",
				clanAchievementDataEmpty = "^36Clans ^07:: Failed to load clan achievements data, please verify cache integrity and folder permissions",
				UIElementEmpty = "^36UIManager ^07:: Element not found",
				UIMouseHandlerEmpty = "^36UIMouseHandler ^07:: Element not found",
			}
			
	function err(str)
		echo(str)
	end
end