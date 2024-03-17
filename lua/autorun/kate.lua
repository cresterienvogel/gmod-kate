kate = kate or {}

if SERVER then
	require("mysqloo")
else
	CreateClientConVar("kate_touchplayers", "1", true, true, "Enable/disable whether you can pick up players with physgun", 0, 1)
end

function kate.Include(f, dir)
	local realm = string.lower(string.Left(f, 3))

	if SERVER and (realm == "sv_") then
		include(dir .. f)
	elseif realm == "cl_" then
		if SERVER then
			AddCSLuaFile(dir .. f)
		else
			include(dir .. f)
		end
	else
		if SERVER then
			AddCSLuaFile(dir .. f)
		end

		include(dir .. f)
	end
end

function kate.IncludeDir(dir, recursive)
	dir = dir .. "/"

	local files, dirs = file.Find(dir .. "*", "LUA")
	for _, v in ipairs(files) do
		kate.Include(v, dir)
	end

	if recursive then
		for _, v in ipairs(dirs) do
			kate.IncludeDir(dir .. v, true)
		end
	end
end

kate.IncludeDir("kate", true)