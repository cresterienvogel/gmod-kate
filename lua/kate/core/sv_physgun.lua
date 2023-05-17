hook.Add("PhysgunPickup", "Kate PhysgunPickup", function(pl, ent)
	if not pl:IsAdmin() or not pl:GetInfoNum("kate_touchplayers", 1) then
		return
	end

	if not (IsValid(ent) and ent:GetClass() == "player") then
		return
	end

	if ent:GetImmunity() > pl:GetImmunity() then
		return
	end

	ent:Freeze(true)
	ent:SetMoveType(MOVETYPE_NOCLIP)
	ent:GodEnable()

	return true
end)

hook.Add("PhysgunDrop", "Kate PhysgunDrop", function(pl, ent)
	if not IsValid(ent) or ent:GetClass() ~= "player" then
		return
	end

	ent:SetMoveType(MOVETYPE_WALK)
	ent:GodDisable()
	ent:Freeze(false)

	if ent:GetImmunity() > pl:GetImmunity() then
		return
	end

	timer.Simple(0.001, function()
		if not IsValid(pl) or not IsValid(ent) then
			return
		end

		if not (pl:KeyDown(IN_ATTACK2) and IsValid(ent) and not ent:IsFrozen()) then
			return
		end

		ent:SetMoveType(pl:KeyDown(IN_ATTACK2) and MOVETYPE_NOCLIP or MOVETYPE_WALK)
		ent:Freeze(true)
		ent:SetVelocity(ent:GetVelocity() * -1)
	end)
end)