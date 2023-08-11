do
	kate.Commands.Register("pingdb", function(self, pl, args)
		local db = kate.Data.DB

		local online = db:ping()
		if not online then
			db:connect()
		end

		do
			local msg = "You've just pinged a Kate Database, the current status is: " .. (online and "connected" or "disconnected") .. ", " .. (online and "everything is fine" or "reconnecting...")
			kate.Message(pl, 3, msg)
		end
	end)
	:SetTitle("Ping Kate DB")
	:SetCategory("Managment")
	:SetIcon("icon16/database_refresh.png")
	:SetImmunity(1000000)
end

do
	kate.Commands.Register("setrank", function(self, pl, args)
		local target = args[1]
		if not target then
			kate.Message(pl, 2, "Target not found")
			return
		end

		local id = kate.SteamIDTo64(target)
		target = kate.FindPlayer(id)

		local rank = args[2]
		local exp = args[3]
		local exp_in = args[4]

		local exp_valid, time = kate.FormatTime(exp)

		if not id then
			kate.Message(pl, 2, "Invalid target")
			return
		end

		local stored = kate.Ranks.Stored

		if not stored[rank] then
			kate.Message(pl, 2, "Rank not found")
			return
		end

		if exp_in and not stored[exp_in] then
			kate.Message(pl, 2, "Expiration rank not found")
			return
		end

		if exp and not exp_valid then
			kate.Message(pl, 2, "Invalid expiration time")
			return
		end

		if exp and time < 300 then
			kate.Message(pl, 2, "Expiration time shouln't be less than 5 minutes")
			return
		end

		if IsValid(pl) and stored[rank]:GetImmunity() >= pl:GetImmunity() then
			kate.Message(pl, 2, "Rank's immunity is higher or equal to yours")
			return
		end

		if IsValid(pl) and exp_in and stored[exp_in]:GetImmunity() >= pl:GetImmunity() then
			kate.Message(pl, 2, "Expiration rank's immunity is higher or equal to yours")
			return
		end

		if (IsValid(pl) and IsValid(target)) and (target:GetImmunity() >= pl:GetImmunity()) then
			kate.Message(pl, 2, "Target's immunity is higher or equal to yours")
			return
		end

		kate.Ranks.Set(id, rank, time, exp_in)

		do
			local msg = kate.GetExecuter(pl) .. " has set a " .. stored[rank]:GetTitle() .. " rank to " .. kate.GetTarget(id)

			if exp then
				msg = msg .. " with expiration in " .. kate.ConvertTime(time)
			end

			if exp_in then
				msg = msg .. " to " .. stored[exp_in]:GetTitle()
			end

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Set Rank")
	:SetCategory("Managment")
	:SetIcon("icon16/key_add.png")
	:SetImmunity(50000)
	:AddAlias("setgroup")
	:AddAlias("setusergroup")
	:AddAlias("setaccess")
	:AddAlias("setuser")
	:AddAlias("adduser")
	:SetArgs("Target", "Rank", "Expiration time", "Expiration rank")
end

do
	kate.Commands.Register("rcon", function(self, pl, args)
		if not args[1] then
			kate.Message(pl, 2, "No command to execute found")
			return
		end

		RunConsoleCommand(unpack(args))
	end)
	:SetTitle("RCON")
	:SetCategory("Managment")
	:SetIcon("icon16/computer.png")
	:SetImmunity(1000000)
	:SetArgs("Command")
end

do
	kate.Commands.Register("map", function(self, pl, args)
		local map = table.concat(args, "")
		if not map then
			kate.Message(pl, 2, "Invalid map")
			return
		end

		local maps = file.Find("maps/*", "GAME")
		for _, f in ipairs(maps) do
			if f == map .. ".bsp" then
				RunConsoleCommand(unpack(args))
				return
			end
		end

		kate.Message(pl, 2, "No map found")
	end)
	:SetTitle("Map")
	:SetCategory("Managment")
	:SetIcon("icon16/map.png")
	:SetImmunity(100000)
	:AddAlias("changelevel")
	:AddAlias("changemap")
	:SetArgs("Map")
end