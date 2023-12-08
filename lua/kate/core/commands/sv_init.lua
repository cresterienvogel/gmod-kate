function kate.Commands.Run(pl, cmd, args)
	cmd = string.lower(cmd)

	local stored = kate.Commands.Stored[cmd]

	-- validate command
	if not stored then
		return false, "Command not found"
	end

	-- check if player exists and he's immunity is higher than target's
	if IsValid(pl) and (stored:GetImmunity() > pl:GetImmunity()) then
		return false, "Command's immunity is higher than yours"
	end

	local collected = {}
	local formatted = {}

	local command_args = stored:GetArgs()
	local optional_args = stored:GetOptionalArgs()

	-- check if something is uncertain
	for k, arg in ipairs(command_args) do
		if table.HasValue(optional_args, arg) then
			continue
		end

		if not args[k] then
			local message = arg .. " not found"
			kate.Message(pl, 2, message)

			return false, message
		end
	end

	-- validate
	for k, arg in ipairs(args) do
		local value, fail
		local arg_type = command_args[k]

		if kate.Commands.Validators[arg_type] then
			value, fail = kate.Commands.Validators[arg_type](pl, cmd, k, arg, args)

			if not value then
				if fail then
					kate.Message(pl, 2, fail)
					return false, fail
				end

				return false
			end

			collected[k] = value
		else
			if (not arg) or (arg == "") then
				local msg = arg_type .. " not found"
				kate.Message(pl, 2, msg)

				return false, msg
			end

			value = string.Trim(table.concat(args, " ", k))
			collected[k] = value

			break
		end
	end

	-- format collected args
	for k, arg in ipairs(collected) do
		local edited = string.Trim(command_args[k])
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

	local msg = kate.GetExecuter(pl)

	cmd = string.lower(args[1])

	-- validate command
	if not kate.Commands.Stored[cmd] then
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

		local success, failure = kate.Commands.Run(pl, cmd, args)

		if not success then
			msg = msg .. " tried executing " .. cmd .. " command with failure: " .. string.lower(failure)
			goto log
		end

		msg = msg .. " has executed command " .. cmd

		if args[1] then
			msg = msg .. " with args \"" .. table.concat(args, "\", \"") .. "\""
		end
	end

	::log::
	kate.Print(msg)
end)

hook.Add("PlayerSay", "Kate Commands", function(pl, text)
	if not text[1] then
		return
	end

	local msg = kate.GetExecuter(pl)

	-- cut junk
	text = string.Trim(text)

	-- it should be a command, right?
	if text[1] ~= "!" then
		return
	end

	local args = {}
	text = string.sub(text, 2) -- cut prefix
	args = kate.ParseArgs(text) -- get args
	cmd = string.lower(args[1]) -- get command

	local stored = kate.Commands.Stored[cmd]

	-- validate command
	if not stored then
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

		if stored:GetSelfRun() and (params[1] == "Target") then
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
		local success, failure = kate.Commands.Run(pl, cmd, args)

		if not success then
			msg = msg .. " tried executing " .. cmd .. " command with failure: " .. string.lower(failure)
			goto log
		end

		msg = msg .. " has executed command " .. cmd

		if args[1] then
			msg = msg .. " with args \"" .. table.concat(args, "\", \"") .. "\""
		end
	end

	::log::
	kate.Print(msg)
	return ""
end)