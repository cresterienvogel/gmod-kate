function kate.Commands.Run(pl, cmd, args)
	cmd = string.lower(cmd)

	local stored = kate.Commands.Stored[cmd]
	if not stored then -- validate command
		return false, "Command not found"
	end

	-- check if player exists and he's immunity is higher than target's
	if IsValid(pl) and (stored:GetImmunity() > pl:GetImmunity()) then
		return false, "Command's immunity is higher than yours"
	end

	local collected = {}
	local formatted = {}

	local commandArgs = stored:GetArgs()
	local optionalArgs = stored:GetOptionalArgs()

	-- check if something is uncertain
	for i, arg in ipairs(commandArgs) do
		if table.HasValue(optionalArgs, arg) then
			continue
		end

		if not args[i] then
			local msg = string.format("%s not found", arg)
			if IsValid(pl) then
				kate.Message(pl, 2, msg)
			end

			return false, msg
		end
	end

	-- validate
	for i, arg in ipairs(args) do
		local value, fail
		local argType = commandArgs[i]

		local argValidator = kate.Commands.Validators[argType]
		if argValidator then
			value, fail = argValidator:Validate(pl, cmd, i, arg, args)
			if not value then
				if fail then
					if IsValid(pl) then
						kate.Message(pl, 2, fail)
					end

					return false, fail
				end

				return false
			end

			collected[i] = value
		else
			if (not arg) or (arg == "") then
				local msg = string.format("%s not found", argType)

				if IsValid(pl) then
					kate.Message(pl, 2, msg)
				end

				return false, msg
			end

			value = string.Trim(table.concat(args, " ", i))
			collected[i] = value
			break
		end
	end

	-- format collected args
	for i, arg in ipairs(collected) do
		local edited = string.Trim(commandArgs[i])
		edited = string.lower(edited)
		edited = string.Replace(edited, " ", "_")

		formatted[edited] = arg
	end

	stored:Run(pl, formatted)
	return true
end

concommand.Add("_kate", function(pl, cmd, args)
	if not args[1] then
		return
	end

	cmd = string.lower(args[1])

	local status = 1
	local msg = kate.GetExecuter(pl)

	-- validate command
	local stored = kate.Commands.Stored[cmd]
	if not stored then
		kate.Message(pl, 2, "Command not found")
		return
	end

	-- manage delay
	if IsValid(pl) then
		if CurTime() < (pl.KateCommandDelay or 0) then
			kate.Message(pl, 2, "Wait a bit")
			return
		end

		pl.KateCommandDelay = CurTime() + 0.3
	end

	-- run command
	do
		args[1] = nil
		args = table.ClearKeys(args)

		local cmdTitle = stored:GetTitle() or cmd

		local success, failReason = kate.Commands.Run(pl, cmd, args)
		if not success then
			msg, status = string.format("%s tried to execute the %s command, but failed: %s", msg, cmdTitle, string.lower(failReason)), 2
			goto log
		end

		msg = string.format("%s executed %s command", msg, cmdTitle)
		if args[1] then
			msg = string.format("%s with args \"%s\"", msg, table.concat(args, "\", \""))
		end
	end

	::log::
	kate.Print(status, msg)
end)

hook.Add("PlayerSay", "Kate Commands", function(pl, text)
	if not text[1] then
		return
	end

	local status = 1
	local msg = kate.GetExecuter(pl)

	-- cut junk
	text = string.Trim(text)
	if text[1] ~= "!" then -- it should be a command, right?
		return
	end

	local args, cmd = {}
	text = string.sub(text, 2) -- cut prefix
	args = kate.ParseArgs(text) -- get args
	cmd = string.lower(args[1]) -- get command

	local stored = kate.Commands.Stored[cmd]
	if not stored then -- validate command
		kate.Message(pl, 2, "Command not found")
		return
	end

	-- check delay
	do
		if CurTime() < (pl.KateCommandDelay or 0) then
			kate.Message(pl, 2, "Wait a bit")
			return
		end

		pl.KateCommandDelay = CurTime() + 0.3
	end

	-- manage args
	do
		args[1] = nil
		args = table.ClearKeys(args)

		-- make it e-e-e-easy
		local params = stored:GetArgs()
		if params[1] == "Target" then
			local arg = args[1]
			if arg then
				if (arg == "me") or (arg == "^") then
					args[1] = pl:SteamID64()
				end
			else
				args[1] = pl:SteamID64()
			end
		end
	end

	do
		local cmdTitle = stored:GetTitle() or cmd

		local success, failReason = kate.Commands.Run(pl, cmd, args)
		if not success then
			msg, status = string.format("%s tried to execute the %s command, but failed: %s", msg, cmdTitle, string.lower(failReason)), 2
			goto log
		end

		msg = string.format("%s executed %s command", msg, cmdTitle)
		if args[1] then
			msg = string.format("%s with args \"%s\"", msg, table.concat(args, "\", \""))
		end
	end

	::log::
	kate.Print(status, msg)
	return ""
end)