kate.AddCommand( 'Teleport', function( pl, target )
  if ( not IsValid( pl ) ) or ( pl == target ) then
    return
  end

  target:SetReturnPos( target:GetPos() )
  target:SetPos( pl:GetEyeTrace().HitPos )

  local phrase = function( showSteamId )
    return { 'LOG_TELEPORT', kate.GetActor( pl, showSteamId ), kate.GetTarget( target, showSteamId ) }
  end

  kate.Notify( kate.GetAdmins(), 3, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
  kate.Print( 3, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
end )
  :SetFlag( 'teleport' )
  :AddParam( 'PLAYER_ENTITY' )
  :AddAlias( 'tp' )
  :AddAlias( 'tele' )

kate.AddCommand( 'Bring', function( pl, target )
  if ( not IsValid( pl ) ) or ( pl == target ) then
    return
  end

  target:SetReturnPos( target:GetPos() )
  target:SetPos( kate.FindEmptyPos( pl:GetPos(), {}, 32, 32, Vector( 16, 16, 64 ) ) )

  local phrase = function( showSteamId )
    return { 'LOG_TELEPORT', kate.GetActor( pl, showSteamId ), kate.GetTarget( target, showSteamId ) }
  end

  kate.Notify( kate.GetAdmins(), 3, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
  kate.Print( 3, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
end )
  :SetFlag( 'teleport' )
  :AddParam( 'PLAYER_ENTITY' )

kate.AddCommand( 'Return', function( pl, target )
  if ( not IsValid( pl ) ) and ( target == nil ) then
    return
  end

  target = target or pl

  local pos = target:GetReturnPos()
  if pos == nil then
    local phrase = { 'LOG_RETURN_NOPOS', kate.GetTarget( target ) }
    kate.Notify( pl, 2, kate.GetPhrase( IsValid( pl ), unpack( phrase ) ) )

    return
  end

  target:SetPos( pos )
  target:SetReturnPos( nil )

  local phrase = function( showSteamId )
    return { 'LOG_RETURN', kate.GetActor( pl, showSteamId ), kate.GetTarget( target, showSteamId ) }
  end

  kate.Notify( kate.GetAdmins(), 3, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
  kate.Print( 3, kate.GetPhrase( false, 'LOG_RETURN', unpack( phrase( true ) ) ) )
end )
  :SetFlag( 'teleport' )
  :AddParam( 'PLAYER_ENTITY', true )