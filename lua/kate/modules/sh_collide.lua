local function canPhysgun( pl, target, cloak )
  if not cloak then
    return false
  end

  local enabled = pl:GetInfoNum( 'kate_physgun', 1 )
  if enabled ~= 1 then
    return false
  end

  local wep = pl:GetActiveWeapon()
  if ( not IsValid( wep ) ) or ( wep:GetClass() ~= 'weapon_physgun' ) then
    return false
  end

  local press = pl:KeyDown( IN_ATTACK )
  if not press then
    return false
  end

  local tr = pl:GetEyeTrace()
  local ent = tr.Entity

  return IsValid( ent ) and ( ent == target )
end

hook.Add( 'ShouldCollide', 'Kate::DisableCloakCollision', function( ent1, ent2 )
  if ( not ent1:IsPlayer() ) or ( not ent2:IsPlayer() ) then
    return
  end

  local cloak1 = ent1:GetNetVar( 'Kate_Cloak' )
  local cloak2 = ent2:GetNetVar( 'Kate_Cloak' )

  if ( not cloak1 ) and ( not cloak2 ) then
    return
  end

  if canPhysgun( ent1, ent2, cloak1 ) then
    return true
  end

  if canPhysgun( ent2, ent1, cloak2 ) then
    return true
  end

  return false
end )