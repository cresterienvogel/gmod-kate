function kate.Commands.Run(pl, cmd, args)
	cmd = cmd:lower()

	local stored = kate.Commands.Stored[cmd]
	if not stored then
		return
	end

	if IsValid(pl) and stored:GetImmunity() > pl:GetImmunity() then
		return
	end

	stored:Run(pl, args)
end

concommand.Add("_kate", function(pl, cmd, args)
	if not args[1] then
		return
	end

	cmd = args[1]:lower()
	if not kate.Commands.Stored[cmd] then
		kate.Message(pl, 2, "Command not found")
		return
	end

	local stored = kate.Commands.Stored[cmd]
	if not stored then
		return
	end

	if IsValid(pl) and (CurTime() < (pl.KateCommandDelay or 0)) then
		kate.Message(pl, 2, "Wait a bit")
		return
	end

	args[1] = nil
	args = table.ClearKeys(args)

	kate.Commands.Run(pl, cmd, args)

	if IsValid(pl) then
		pl.KateCommandDelay = CurTime() + 0.3
	end

	do
		local msg = kate.GetExecuter(pl) .. " has executed command " .. cmd

		if args[1] then
			msg = msg .. ' with args "' .. table.concat(args, '", "') .. '"'
		end

		kate.Print(msg)
	end
end)

hook.Add("PlayerSay", "Kate Commands", function(pl, text)
	if not text[1] then
		return
	end

	text = string.Trim(text)
	if text[1] ~= "!" then
		return
	end

	local args = {}
	text = text:sub(2)
	args = kate.ParseArgs(text)
	cmd = args[1]:lower()

	local stored = kate.Commands.Stored[cmd]
	if not stored then
		kate.Message(pl, 2, "Command not found")
		return
	end

	if CurTime() < (pl.KateCommandDelay or 0) then
		kate.Message(pl, 2, "Wait a bit")
		return
	end

	do
		args[1] = nil
		args = table.ClearKeys(args)

		local params = stored:GetArgs()
		if params[1] == "Target" then
			local arg = args[1]
			if arg then
				if arg == "me" or arg == "^" then
					args[1] = pl:SteamID64()
				end
			else
				args[1] = pl:SteamID64()
			end
		end
	end

	kate.Commands.Run(pl, cmd, args)
	pl.KateCommandDelay = CurTime() + 0.3

	do
		local msg = kate.GetExecuter(pl) .. " has executed command " .. cmd

		if args[1] then
			msg = msg .. ' with args "' .. table.concat(args, '", "') .. '"'
		end

		kate.Print(msg)
	end

	return ""
end)