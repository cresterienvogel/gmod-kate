do
	kate.Commands.Register("ban", function(self, pl, args)
		local target = args[1]
		if not target then
			kate.Message(pl, 2, "Target not found")
			return
		end

		local id = kate.SteamIDTo64(target)

		if not id then
			kate.Message(pl, 2, "Invalid target")
			return
		end

		if not args[2] then
			kate.Message(pl, 2, "Invalid time")
			return
		end

		local time_valid, time = kate.FormatTime(args[2])
		local reason = table.concat(args, " ", 3)

		if not time_valid then
			kate.Message(pl, 2, "Invalid time")
			return
		end

		if reason == "" then
			kate.Message(pl, 2, "Invalid reason")
			return
		end

		local a_name = IsValid(pl) and pl:Name() or "Console"
		local a_id = IsValid(pl) and pl:SteamID64() or "None"

		kate.Ban(id, time, reason, a_name, a_id)

		do
			local msg = kate.GetExecuter(pl) .. " has banned " .. kate.GetTarget(id) .. " for " .. kate.ConvertTime(time) .. " with reason " .. reason

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Ban")
	:SetCategory("Punishment")
	:SetIcon("icon16/computer_delete.png")
	:SetImmunity(1000)
	:SetArgs("Target", "Time", "Reason")
end

do
	kate.Commands.Register("unban", function(self, pl, args)
		local target = args[1]
		if not target then
			kate.Message(pl, 2, "Target not found")
			return
		end

		local id = kate.SteamIDTo64(target)
		if not id then
			kate.Message(pl, 2, "Invalid target")
			return
		end

		kate.Unban(id)

		do
			local msg = kate.GetExecuter(pl) .. " has unbanned " .. kate.GetTarget(id)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Unban")
	:SetCategory("Punishment")
	:SetIcon("icon16/computer_add.png")
	:SetImmunity(5000)
	:SetArgs("SteamID")
end

do
	kate.Commands.Register("kick", function(self, pl, args)
		local target = kate.FindPlayer(args[1])
		if not IsValid(target) then
			kate.Message(pl, 2, "Target not found")
			return
		end

		local reason = table.concat(args, " ", 2)

		if reason == "" then
			kate.Message(pl, 2, "Invalid reason")
			return
		end

		target:Kick(reason)

		do
			local msg = kate.GetExecuter(pl) .. " has kicked " .. kate.GetTarget(target) .. " with reason " .. reason

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Kick")
	:SetCategory("Punishment")
	:SetIcon("icon16/door_out.png")
	:SetImmunity(1000)
	:SetArgs("Target", "Reason")
end