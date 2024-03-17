do
	kate.Commands:Register("pingdb", function(self, pl, args)
		local db = kate.Data.DB
		if not db then
			return
		end

		local online = db:ping()
		if not online then
			db:connect()
		end

		kate.Message(pl, 3, string.format([[You've just pinged a Kate Database, the current status is: %s, %s]],
			online and "connected" or "disconnected",
			online and "everything is fine" or "reconnecting..."
		))
	end)
	:SetTitle("Ping Kate DB")
	:SetCategory("Managment")
	:SetIcon("icon16/database_refresh.png")
	:SetImmunity(1000000)
end

do
	kate.Commands:Register("setrank", function(self, pl, args)
		local target = args.target
		local rank = args.rank
		local expireTime = args.time
		local expireRank = args.expire_rank

		local stored = kate.Ranks.Stored
		local storedRank = stored[rank]
		local storedExpireRank = stored[expireRank]

		kate.Ranks.SetRank(target, rank, expireTime, expireRank)

		do
			local msg = "%s has set %s rank to %s"
			if expireTime then
				msg = msg .. " with expiration in %s"
			end

			if expireRank then
				msg = msg .. " to %s"
			end

			msg = string.format(msg,
				kate.GetExecuter(pl),
				storedRank:GetTitle(),
				kate.GetTarget(target),
				expireTime and kate.ConvertTime(expireTime) or nil,
				storedExpireRank and storedExpireRank:GetTitle() or nil
			)

			kate.Print(3, msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Set Rank")
	:SetCategory("Managment")
	:SetIcon("icon16/key_add.png")
	:SetImmunity(50000)
	:SetSelfRun(false)
	:SetArgs("Target", "Rank", "Time", "Expire Rank")
	:SetOptionalArgs("Time", "Expire Rank")
	:AddAlias("setgroup")
	:AddAlias("setusergroup")
	:AddAlias("setaccess")
	:AddAlias("setuser")
	:AddAlias("adduser")
end

do
	kate.Commands:Register("rcon", function(self, pl, args)
		RunConsoleCommand(args.executable)
	end)
	:SetTitle("RCON")
	:SetCategory("Managment")
	:SetIcon("icon16/computer.png")
	:SetImmunity(1000000)
	:SetArgs("Executable")
end

do
	kate.Commands:Register("map", function(self, pl, args)
		RunConsoleCommand("changelevel", args.map)
	end)
	:SetTitle("Map")
	:SetCategory("Managment")
	:SetIcon("icon16/map.png")
	:SetImmunity(100000)
	:SetArgs("Map")
	:AddAlias("changelevel")
	:AddAlias("changemap")
end