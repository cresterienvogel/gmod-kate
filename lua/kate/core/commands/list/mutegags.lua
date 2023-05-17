local icons = {
	["Gag"] = "icon16/sound_delete.png",
	["Ungag"] = "icon16/sound_add.png",
	["Mute"] = "icon16/comments_delete.png",
	["Unmute"] = "icon16/comments_add.png"
}

for _, tag in ipairs({"Gag", "Mute"}) do
	local low_tag = tag:lower()

	do
		kate.Commands.Register(low_tag, function(self, pl, args)
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

			local a_id = IsValid(pl) and pl:SteamID64() or "Console"

			kate[tag](id, time, reason, a_id)

			do
				local msg = kate.GetExecuter(pl) .. " has run " .. low_tag .. " on " .. kate.GetTarget(id) .. " for " .. kate.ConvertTime(time) .. " with reason " .. reason

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
		kate.Commands.Register("un" .. low_tag, function(self, pl, args)
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

			kate["Un" .. low_tag](id)

			do
				local msg = kate.GetExecuter(pl) .. " has run un" .. low_tag .. " on " .. kate.GetTarget(id)

				kate.Print(msg)
				kate.Message(player.GetAll(), 3, msg)
			end
		end)
		:SetTitle("Un" .. low_tag)
		:SetCategory("Punishment")
		:SetIcon(icons["Un" .. low_tag])
		:SetImmunity(1000)
		:SetArgs("Target")
	end
end