function kate.FindPlayer( info )
  if ( info == nil ) or ( info == '' ) then
    return nil
  end

  if IsValid( info ) and info:IsPlayer() then
    return info
  end

  for _, pl in ipairs( player.GetAll() ) do
    if tonumber( info ) == pl:UserID() then
      return pl
    end

    if info == pl:SteamID() then
      return pl
    end

    if info == pl:SteamID64() then
      return pl
    end

    if tostring( info ) == pl:Name() then
      return pl
    end

    if string.find( string.lower( pl:Name() ), string.lower( info ), 1, true ) then
      return pl
    end
  end

  return nil
end