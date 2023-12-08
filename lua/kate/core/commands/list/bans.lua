do
	kate.Commands:Register("ban", function(self, pl, args)
		local target = args.target
		local time = args.time
		local reason = args.reason

		local a_name = IsValid(pl) and pl:Name() or "Console"
		local a_id = IsValid(pl) and pl:SteamID64() or "None"

		kate.Ban(target, time, reason, a_name, a_id)

		do
			local msg = string.format("%s has banned %s for %s: %s",
				kate.GetExecuter(pl),
				kate.GetTarget(target),
				kate.ConvertTime(time),
				reason
			)

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
	kate.Commands:Register("unban", function(self, pl, args)
		local target = args.target

		kate.Unban(target)

		do
			local msg = string.format("%s has unbanned %s",
				kate.GetExecuter(pl),
				kate.GetTarget(target)
			)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Unban")
	:SetCategory("Punishment")
	:SetIcon("icon16/computer_add.png")
	:SetImmunity(5000)
	:SetArgs("Target")
end

do
	kate.Commands:Register("kick", function(self, pl, args)
		local target = args.target
		local reason = args.reason

		target:Kick(reason)

		do
			local msg = string.format("%s has kicked %s: %s",
				kate.GetExecuter(pl),
				kate.GetTarget(target),
				reason
			)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Kick")
	:SetCategory("Punishment")
	:SetIcon("icon16/door_out.png")
	:SetImmunity(1000)
	:SetOnlineTarget(true)
	:SetArgs("Target", "Reason")
end