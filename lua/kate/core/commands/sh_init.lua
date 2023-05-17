kate.Commands = kate.Commands or {}
kate.Commands.Stored = kate.Commands.Stored or {}

local meta = {}
meta.__index = meta

function meta:GetName()
	return self.Name
end

function meta:SetTitle(title)
	self.Title = title
	return self
end

function meta:GetTitle()
	return self.Title
end

function meta:SetCategory(cat)
	self.Category = cat
	return self
end

function meta:GetCategory()
	return self.Category
end

function meta:SetImmunity(amt)
	self.Immunity = amt
	return self
end

function meta:SetVisible(bool)
	self.Visible = bool
	return self
end

function meta:GetVisible()
	return self.Visible
end

function meta:GetImmunity()
	return self.Immunity
end

function meta:SetIcon(icon)
	self.Icon = icon
	return self
end

function meta:GetIcon()
	return self.Icon
end

function meta:AddAlias(name)
	name = name:lower()

	kate.Commands.Stored[name] = table.Copy(self)
	kate.Commands.Stored[name].IsAlias = true

	return self
end

function meta:GetAlias()
	return self.IsAlias
end

function meta:SetArgs(...)
	for _, arg in ipairs({...}) do
		self.Args[#self.Args + 1] = arg
	end
	return self.Args
end

function meta:GetArgs()
	return self.Args
end

function kate.Commands.Register(name, callback)
	name = name:lower()

	local command = {
		Name = name,
		Title = name,
		Category = "Other",
		Icon = "icon16/pill.png",
		Immunity = 0,
		Args = {},
		IsAlias = false,
		Visible = true,
		Run = SERVER and callback or function() end
	}

	setmetatable(command, meta)
	kate.Commands.Stored[name] = command

	return command
end

concommand.Add(
	"kate",
	function(pl, cmd, args)
		if not args[1] then
			for c, data in pairs(kate.Commands.Stored) do
				if data:GetAlias() then
					continue
				end

				local _args = {}
				for i, arg in ipairs(data:GetArgs()) do
					_args[i] = "<" .. arg .. ">"
				end

				print("	" .. c .. " " .. table.concat(_args, " "))
			end
			return
		end

		RunConsoleCommand("_kate", unpack(args))
	end,
	function(cmd, str)
		cmd = string.Explode(" ", str)[2]:Trim()

		local stored = kate.Commands.Stored[cmd]
		if not stored then
			return
		end

		local args = {}
		for i, arg in ipairs(stored:GetArgs()) do
			args[i] = "<" .. arg .. ">"
		end

		return {"kate " .. cmd .. " " .. table.concat(args, " ")}
	end
)