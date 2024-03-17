kate.Ranks = kate.Ranks or {}
kate.Ranks.Stored = kate.Ranks.Stored or {}

local meta = {}
meta.__index = meta

do
	function meta:SetImmunity(amt)
		self.Immunity = amt

		return self
	end

	function meta:GetImmunity()
		return self.Immunity
	end

	function meta:SetTitle(title)
		self.Title = title

		return self
	end

	function meta:GetTitle()
		return self.Title
	end
end

function kate.Ranks:Register(name)
	if name == nil then
		return nil
	end

	local rank = {
		Title = name,
		Immunity = 0
	}

	setmetatable(rank, meta)
	kate.Ranks.Stored[string.lower(name)] = rank

	return rank
end

function kate.Ranks:RegisterMeta(special)
	if not special then
		goto all
	end

	do
		local rank = kate.Ranks.Stored[special]
		if not rank then
			return
		end

		debug.getregistry()["Player"]["Is" .. rank.Title] = function(pl)
			return pl:GetImmunity() >= rank.Immunity
		end

		return
	end

	::all::
	for rank, data in pairs(kate.Ranks.Stored) do
		debug.getregistry()["Player"]["Is" .. data.Title] = function(pl)
			return pl:GetImmunity() >= data.Immunity
		end
	end
end

function kate.Ranks.CanTarget(pl, target)
	if not IsValid(target) then
		return false
	end

	if not IsValid(pl) then
		return true
	end

	return pl:GetImmunity() >= target:GetImmunity()
end

do
	kate.Ranks:Register("founder")
		:SetTitle("Founder")
		:SetImmunity(1000000)

	kate.Ranks:Register("supervisor")
		:SetTitle("Supervisor")
		:SetImmunity(100000)

	kate.Ranks:Register("overseer")
		:SetTitle("Overseer")
		:SetImmunity(50000)

	kate.Ranks:Register("observer")
		:SetTitle("Observer")
		:SetImmunity(25000)

	kate.Ranks:Register("superadmin")
		:SetTitle("SuperAdmin")
		:SetImmunity(10000)

	kate.Ranks:Register("admin")
		:SetTitle("Admin")
		:SetImmunity(5000)

	kate.Ranks:Register("supermoderator")
		:SetTitle("SuperModerator")
		:SetImmunity(2500)

	kate.Ranks:Register("moderator")
		:SetTitle("Moderator")
		:SetImmunity(1000)

	kate.Ranks:Register("user")
		:SetTitle("User")
		:SetImmunity(0)

	kate.Ranks:RegisterMeta()
end