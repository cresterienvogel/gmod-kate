hook.Add( 'PhysgunPickup', 'Kate::HandlePhysgun', function( pl, ent )
  if ( not pl:HasFlag( 'physgun' ) ) or ( pl:GetInfoNum( 'kate_physgun', 1 ) == 0 ) then
    return
  end

  if ( not IsValid( ent ) ) or ( type( ent ) ~= 'Player' ) then
    return
  end

  if not kate.CanTarget( pl, ent ) then
    return
  end

  if hook.Run( 'Kate::CanPlayerPhysgun', pl ) == false then
    return
  end

  ent:Freeze( true )
  ent:SetMoveType( MOVETYPE_NOCLIP )
  ent:GodEnable()

  return true
end )

hook.Add( 'PhysgunDrop', 'Kate::HandlePhysgun', function( pl, ent )
  if ( not pl:HasFlag( 'physgun' ) ) or ( pl:GetInfoNum( 'kate_physgun', 1 ) == 0 ) then
    return
  end

  if ( not IsValid( ent ) ) or ( type( ent ) ~= 'Player' ) then
    return
  end

  ent:Freeze( false )
  ent:SetMoveType( MOVETYPE_WALK )
  ent:GodDisable()

  if not kate.CanTarget( pl, ent ) then
    return
  end

  if hook.Run( 'Kate::CanPlayerPhysgun', pl ) == false then
    return
  end

  timer.Simple( 0.001, function()
    if ( not IsValid( pl ) ) or ( not IsValid( ent ) ) then
      return
    end

    if pl:KeyDown( IN_ATTACK2 ) and ( not ent:IsFrozen() ) then
      ent:SetMoveType( MOVETYPE_NOCLIP )
      ent:Freeze( true )
      ent:SetVelocity( ent:GetVelocity() * -1 )
    end
  end )
end )