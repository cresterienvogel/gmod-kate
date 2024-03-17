-- https://github.com/SuperiorServers/dash/blob/770bd90d77e077b2b1b975f517f815e9ff24d693/lua/dash/extensions/string.lua#L26
function kate.IsSteamID(id)
	if not id then
		return false
	end

	id = tostring(id)
	return tobool(string.match(id, "^STEAM_%d:%d:%d+$"))
end

-- https://github.com/SuperiorServers/dash/blob/770bd90d77e077b2b1b975f517f815e9ff24d693/lua/dash/extensions/string.lua#L30
function kate.IsSteamID64(id)
	if not id then
		return false
	end

	id = tostring(id)
	return tobool((utf8.len(id) == 17) and (string.sub(id, 1, 4) == "7656"))
end

function kate.SteamIDTo64(id)
	local pl = kate.FindPlayer(id)

	if IsValid(pl or id) and (pl or id):IsPlayer() then
		return (pl or id):SteamID64()
	end

	if kate.IsSteamID64(id) then
		return id
	end

	if kate.IsSteamID(id) then
		return util.SteamIDTo64(id)
	end

	return nil
end

function kate.SteamIDFrom64(id)
	local pl = kate.FindPlayer(id)

	if IsValid(pl or id) and (pl or id):IsPlayer() then
		return (pl or id):SteamID()
	end

	if kate.IsSteamID(id) then
		return id
	end

	if kate.IsSteamID64(id) then
		return util.SteamIDFrom64(id)
	end

	return nil
end