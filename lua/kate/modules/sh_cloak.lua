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

hook.Add( 'Kate::PlayerCanNoclip', 'Kate::Cloak', function( pl, desired )
  if pl:GetNetVar( 'Kate_Cloak' ) and ( desired == false ) then
    return false
  end
end )