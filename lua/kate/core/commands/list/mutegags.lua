local icons = {
	["Gag"] = "icon16/sound_delete.png",
	["Ungag"] = "icon16/sound_add.png",
	["Mute"] = "icon16/comments_delete.png",
	["Unmute"] = "icon16/comments_add.png"
}

for _, tag in ipairs({"Gag", "Mute"}) do
	local tagLower = string.lower(tag)

	do
		kate.Commands:Register(tagLower, function(self, pl, args)
			local target = args.target
			local time = args.time
			local reason = args.reason

			local adminId = IsValid(pl) and pl:SteamID64() or "Console"
			kate[tag](target, time, reason, adminId)

			do
				local msg = string.format("%s has run %s on %s for %s with reason %s",
					kate.GetExecuter(pl),
					tagLower,
					kate.GetTarget(target),
					kate.ConvertTime(time),
					reason
				)

				kate.Print(3, msg)
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
		kate.Commands:Register("un" .. tagLower, function(self, pl, args)
			local target = args.target
			local reason = args.reason

			local adminId = IsValid(pl) and pl:SteamID64() or "Console"
			kate["Un" .. tagLower](target, reason, adminId)

			do
				local msg = string.format("%s has run un%s on %s: %s",
					kate.GetExecuter(pl),
					tagLower,
					kate.GetTarget(target),
					reason
				)

				kate.Print(3, msg)
				kate.Message(player.GetAll(), 3, msg)
			end
		end)
		:SetTitle("Un" .. tagLower)
		:SetCategory("Punishment")
		:SetIcon(icons["Un" .. tagLower])
		:SetImmunity(1000)
		:SetArgs("Target", "Reason")
	end
end