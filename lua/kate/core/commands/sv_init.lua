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
	for k, arg in ipairs(commandArgs) do
		if table.HasValue(optionalArgs, arg) then
			continue
		end

		if not args[k] then
			local msg = string.format("%s not found", arg)
			kate.Message(pl, 2, msg)

			return false, msg
		end
	end

	-- validate
	for k, arg in ipairs(args) do
		local value, fail
		local argType = commandArgs[k]

		if kate.Commands.Validators[argType] then
			value, fail = kate.Commands.Validators[argType](pl, cmd, k, arg, args)

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
				local msg = argType .. " not found"
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
		local edited = string.Trim(commandArgs[k])
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