-- https://github.com/SuperiorServers/dash/blob/770bd90d77e077b2b1b975f517f815e9ff24d693/lua/dash/extensions/string.lua#L26
function kate.IsSteamID( info )
  return ( type( info ) == 'string' ) and string.match( info, '^STEAM_%d:%d:%d+$' )
end

-- https://github.com/SuperiorServers/dash/blob/770bd90d77e077b2b1b975f517f815e9ff24d693/lua/dash/extensions/string.lua#L30
function kate.IsSteamID64( info )
  return ( type( info ) == 'string' ) and ( utf8.len( info ) == 17 ) and ( string.sub( info, 1, 4 ) == '7656' )
end

function kate.SteamIDTo64( info )
  local pl = ( IsValid( info ) and ( type( info ) == 'Player' ) ) and info or kate.FindPlayer( info )

  if IsValid( pl ) then
    return pl:SteamID64()
  end

  if kate.IsSteamID64( info ) then
    return info
  end

  if kate.IsSteamID( info ) then
    return util.SteamIDTo64( info )
  end

  return nil
end

function kate.SteamIDFrom64( info )
  local pl = ( IsValid( info ) and ( type( info ) == 'Player' ) ) and info or kate.FindPlayer( info )

  if IsValid( pl ) then
    return pl:SteamID()
  end

  if kate.IsSteamID( info ) then
    return info
  end

  if kate.IsSteamID64( info ) then
    return util.SteamIDFrom64( info )
  end

  return nil
end

function kate.TargetToSteamID64( target )
  if IsValid( target ) then
    return target:SteamID64()
  end

  if kate.IsSteamID64( target ) then
    return target
  end

  if kate.IsSteamID( target ) then
    return kate.SteamIDTo64( target )
  end

  return nil
end