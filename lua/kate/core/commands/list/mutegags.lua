local icons = {
	["Gag"] = "icon16/sound_delete.png",
	["Ungag"] = "icon16/sound_add.png",
	["Mute"] = "icon16/comments_delete.png",
	["Unmute"] = "icon16/comments_add.png"
}

for _, tag in ipairs({"Gag", "Mute"}) do
	local tag_lower = string.lower(tag)

	do
		kate.Commands:Register(tag_lower, function(self, pl, args)
			local target = args.target
			local time = args.time
			local reason = args.reason

			local admin_id = IsValid(pl) and pl:SteamID64() or "Console"

			kate[tag](target, time, reason, admin_id)

			do
				local msg = string.format("%s has run %s on %s for %s with reason %s",
					kate.GetExecuter(pl),
					tag_lower,
					kate.GetTarget(target),
					kate.ConvertTime(time),
					reason
				)

				kate.Print(msg)
				kate.Message(player.GetAll(), 3, msg)
			end
		end)
		:SetTitle(tag)
		:SetCategory("Punishment")
		:SetIcon(icons[tag])
		:SetImmunity(1000)
		:SetArgs("Target", "Time", "Reason")
	end

	do
		kate.Commands:Register("un" .. tag_lower, function(self, pl, args)
			local target = args.target
			local reason = args.reason

			local admin_id = IsValid(pl) and pl:SteamID64() or "Console"

			kate["Un" .. tag_lower](target, reason, admin_id)

			do
				local msg = string.format("%s has run un%s on %s: %s",
					kate.GetExecuter(pl),
					tag_lower,
					kate.GetTarget(target),
					reason
				)

				kate.Print(msg)
				kate.Message(player.GetAll(), 3, msg)
			end
		end)
		:SetTitle("Un" .. tag_lower)
		:SetCategory("Punishment")
		:SetIcon(icons["Un" .. tag_lower])
		:SetImmunity(1000)
		:SetArgs("Target", "Reason")
	end
end