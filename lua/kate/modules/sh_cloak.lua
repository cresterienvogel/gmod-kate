if SERVER then
  local function cloakWeapons( pl, shouldDraw )
    for _, wep in pairs( pl:GetWeapons() ) do
      wep:SetNoDraw( shouldDraw )
    end

    local beams = ents.FindByClassAndParent( 'physgun_beam', pl )
    if beams == nil then
      return
    end

    for i = 1, #beams do
      beams[i]:SetNoDraw( shouldDraw )
    end
  end

  function kate.Cloak( pl, shouldCloak )
    if not IsValid( pl ) then
      return false
    end

    local canCloak, failReason = hook.Run( 'Kate::PlayerCanCloak', pl, shouldCloak )
    if canCloak == false then
      return false, failReason
    end

    pl:SetNetVar( 'Kate_Cloak', shouldCloak )
    pl:SetMoveType( shouldCloak and MOVETYPE_NOCLIP or MOVETYPE_WALK )
    pl:SetNoDraw( shouldCloak )
    pl:DrawWorldModel( not shouldCloak )
    pl:SetRenderMode( shouldCloak and RENDERMODE_TRANSALPHA or RENDERMODE_NORMAL )
    pl:Fire( 'alpha', shouldCloak and 0 or 255, 0 )

    cloakWeapons( pl, shouldCloak )

    return true
  end

  hook.Add( 'PlayerSpawn', 'Kate::Cloak', function( pl )
    pl:SetCustomCollisionCheck( true )
    pl:CollisionRulesChanged()

    local isCloaked = pl:GetNetVar( 'Kate_Cloak' )
    if not isCloaked then
      return
    end

    timer.Simple( 0, function()
      kate.Cloak( pl, isCloaked )
    end )
  end )

  hook.Add( 'PlayerSwitchWeapon', 'Kate::Cloak', function( pl )
    local isCloaked = pl:GetNetVar( 'Kate_Cloak' )
    if not isCloaked then
      return
    end

    timer.Simple( 0, function()
      cloakWeapons( pl, isCloaked )
    end )
  end )
end

hook.Add( 'ShouldCollide', 'Kate::DisableCloakCollision', function( ent1, ent2 )
  if ( not ent1:IsPlayer() ) or ( not ent2:IsPlayer() ) then
    return
  end

  local cloak1 = ent1:GetNetVar( 'Kate_Cloak' )
  local cloak2 = ent2:GetNetVar( 'Kate_Cloak' )

  local wep1 = ent1:GetActiveWeapon()
  local wep2 = ent2:GetActiveWeapon()

  local physgun1 = IsValid( wep1 ) and ( wep1:GetClass() == 'weapon_physgun' ) or false
  local physgun2 = IsValid( wep2 ) and ( wep2:GetClass() == 'weapon_physgun' ) or false

  local press1 = ent1:KeyDown( IN_ATTACK )
  local press2 = ent2:KeyDown( IN_ATTACK )

  local tr1 = ent1:GetEyeTrace()
  local tr2 = ent2:GetEyeTrace()

  local target1 = IsValid( tr1.Entity ) and ( tr1.Entity == ent2 ) or false
  local target2 = IsValid( tr2.Entity ) and ( tr2.Entity == ent1 ) or false

  if ( ent1:GetInfoNum( 'kate_physgun', 1 ) == 1 ) and ( cloak1 and physgun1 and press1 and target1 ) then
    return true
  end

  if ( ent2:GetInfoNum( 'kate_physgun', 1 ) == 1 ) and ( cloak2 and physgun2 and press2 and target2 ) then
    return true
  end

  if cloak1 or cloak2 then
    return false
  end
end )

hook.Add( 'Kate::PlayerCanNoclip', 'Kate::Cloak', function( pl, desired )
  if pl:GetNetVar( 'Kate_Cloak' ) and ( desired == false ) then
    return false
  end
end )