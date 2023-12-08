function kate.CloakWeapons(pl, bool)
	if not IsValid(pl) then
		return
	end

	for _, wep in pairs(pl:GetWeapons()) do
		wep:SetNoDraw(bool)
	end

	local beams = ents.FindByClassAndParent("physgun_beam", pl)

	if beams then
		for i = 1, #beams do
			beams[i]:SetNoDraw(bool)
		end
	end
end

function kate.CloakPlayer(pl, bool)
	if not IsValid(pl) then
		return
	end

	pl:SetMoveType(bool and MOVETYPE_NOCLIP or MOVETYPE_WALK)
	pl:SetNoDraw(bool)
	pl:DrawWorldModel(not bool)
	pl:SetRenderMode(bool and RENDERMODE_TRANSALPHA or RENDERMODE_NORMAL)
	pl:Fire("alpha", bool and 0 or 255, 0)

	kate.CloakWeapons(pl, bool)
end

hook.Add("PlayerSpawn", "Kate Cloak PlayerSpawn", function(pl)
	local cloaked = pl:GetCloak()

	if not cloaked then
		return
	end

	timer.Simple(0, function()
		kate.CloakPlayer(pl, cloaked)
		kate.CloakWeapons(pl, cloaked)
	end)
end)

hook.Add("PlayerSwitchWeapon", "Kate Cloak PlayerSwitchWeapon", function(pl)
	local cloaked = pl:GetCloak()

	if not cloaked then
		return
	end

	timer.Simple(0, function()
		kate.CloakWeapons(pl, cloaked)
	end)
end)