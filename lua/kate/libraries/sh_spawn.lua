local meta = FindMetaTable("Player")

if SERVER then
	hook.Add("PlayerInitialSpawn", "Kate Spawn", function(pl, transition)
		local tag = "Kate Spawn %s"
		tag = tag:format(pl:SteamID())

		hook.Add("SetupMove", tag, function(_pl, _, mvc)
			if not IsValid(_pl) or pl ~= _pl or mvc:IsForced() then
				return
			end

			hook.Run("PlayerHasSpawned", pl, transition)
			hook.Remove("SetupMove", tag)
			pl:SetKateVar("Spawned", true)
		end)
	end)
end

function meta:HasSpawned()
	if not IsValid(self) then
		return false
	end

	return tobool(self:GetKateVar("Spawned"))
end