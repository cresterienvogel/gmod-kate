net.Receive( 'Kate::CacheUserGroups', function()
  local bytes = net.ReadUInt( 16 )
  local comp = net.ReadData( bytes )
  local json = util.Decompress( comp )
  local cache = util.JSONToTable( json )

  local safe = {}
  for steamId, userGroup in pairs( cache ) do
    local steamId64 = util.SteamIDTo64( steamId )
    safe[steamId64] = userGroup
  end

  kate.UserGroups.Cache = safe
end )