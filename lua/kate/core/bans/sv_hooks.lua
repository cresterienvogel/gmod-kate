hook.Add( 'CheckPassword', 'Kate::HandleBans', function( steamId64 )
  local cached = kate.Bans.Cache[steamId64]
  if cached == nil then
    return
  end

  local unbanTime = cached['UnbanTime']
  if ( unbanTime ~= 0 ) and ( os.time() > unbanTime ) then
    kate.Unban( steamId64, {
      ['Reason'] = 'Time out'
    } )

    return
  end

  local adminSteamId64 = ( cached['AdminSteamID64'] ~= '<Console>' ) and
    ( '(' .. util.SteamIDFrom64( cached['AdminSteamID64'] ) .. ')' ) or
    ''

  if unbanTime == 0 then
    return false, kate.GetPhrase( true, 'BAN_DETAILS_PERMA',
      cached['Reason'],
      cached['AdminName'],
      adminSteamId64,
      os.date( '%d.%m.%Y', cached['BanTime'] ),
      os.date( '%H:%M:%S', cached['BanTime'] )
    )
  end

  return false, kate.GetPhrase( true, 'BAN_DETAILS',
    cached['Reason'],
    cached['AdminName'],
    adminSteamId64,
    os.date( '%d.%m.%Y', cached['UnbanTime'] ),
    os.date( '%H:%M:%S', cached['UnbanTime'] ),
    os.date( '%d.%m.%Y', cached['BanTime'] ),
    os.date( '%H:%M:%S', cached['BanTime'] )
  )
end )