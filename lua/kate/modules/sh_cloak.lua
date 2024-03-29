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

  function kate.Cloak( pl, shouldDraw )
    if not IsValid( pl ) then
      return
    end

    pl:SetNetVar( 'Kate_Cloak', shouldDraw )

    pl:SetMoveType( shouldDraw and MOVETYPE_NOCLIP or MOVETYPE_WALK )
    pl:SetNoDraw( shouldDraw )
    pl:DrawWorldModel( not shouldDraw )
    pl:SetRenderMode( shouldDraw and RENDERMODE_TRANSALPHA or RENDERMODE_NORMAL )
    pl:Fire( 'alpha', shouldDraw and 0 or 255, 0 )

    cloakWeapons( pl, shouldDraw )
  end

  hook.Add( 'PlayerSpawn', 'Kate_Cloak', function( pl )
    local isCloaked = pl:GetNetVar( 'Kate_Cloak' )
    if not isCloaked then
      return
    end

    timer.Simple( 0, function()
      kate.Cloak( pl, isCloaked )
    end )
  end )

  hook.Add( 'PlayerSwitchWeapon', 'Kate_Cloak', function( pl )
    local isCloaked = pl:GetNetVar( 'Kate_Cloak' )
    if not isCloaked then
      return
    end

    timer.Simple( 0, function()
      cloakWeapons( pl, isCloaked )
    end )
  end )
end

hook.Add( 'Kate_PlayerCanNoclip', 'Kate_Cloak', function( pl, desired )
  if pl:GetNetVar( 'Kate_Cloak' ) and ( desired == false ) then
    return false
  end
end )