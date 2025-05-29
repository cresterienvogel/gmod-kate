function kate.FindPlayer( context )
  if context == '' then
    return nil
  end

  for _, client in player.Iterator() do
    local bySteamId = client.SteamID( client ) == context
    local bySteamId64 = client.SteamID64( client ) == context
    local byAccountId = tostring( client.AccountID( client ) ) == context
    local byNick = string.find( string.lower( client.Nick( client ) ), string.lower( context ) ) ~= nil

    if bySteamId or bySteamId64 or byAccountId or byNick then
      return client
    end
  end

  return nil
end