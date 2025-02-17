kate.AddCommand( 'Mute',
  function( pl, target, time, reason )
    local steamId64 = kate.TargetToSteamID64( target )
    if steamId64 == nil then
      return
    end

    local args = {}
    args.MuteReason = reason
    args.MuteGiver = IsValid( pl ) and pl:SteamID64() or 'Console'
    args.MuteTime = os.time()
    args.UnMuteTime = ( time ~= 0 ) and ( os.time() + time ) or 0

    kate.Mute( steamId64, args )

    local phrase = function( showSteamId )
      return ( time ~= 0 ) and {
        'LOG_MUTE', kate.GetActor( pl, showSteamId ), kate.GetTarget( steamId64, showSteamId ), os.date( '%d.%m.%y (%H:%M)', args.UnMuteTime ), reason } or {
        'LOG_MUTE_PERMA', kate.GetActor( pl, showSteamId ), kate.GetTarget( steamId64, showSteamId ), reason }
    end

    kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end )
  :SetFlag( 'mute' )
  :AddParam( 'PLAYER_STEAMID' )
  :AddParam( 'TIME' )
  :AddParam( 'STRING' )

kate.AddCommand( 'UnMute',
  function( pl, target )
    local steamId64 = kate.TargetToSteamID64( target )
    if steamId64 == nil then
      return
    end

    kate.UnMute( steamId64 )

    local phrase = function( showSteamId )
      return { 'LOG_UNMUTE', kate.GetActor( pl, showSteamId ), kate.GetTarget( steamId64, showSteamId ) }
    end

    kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end )
  :SetFlag( 'mute' )
  :AddParam( 'PLAYER_STEAMID' )

kate.AddCommand( 'Gag',
  function( pl, target, time, reason )
    local steamId64 = kate.TargetToSteamID64( target )
    if steamId64 == nil then
      return
    end

    local args = {}

    args.GagReason = reason
    args.GagGiver = IsValid( pl ) and pl:SteamID64() or 'Console'
    args.GagTime = os.time()
    args.UnGagTime = ( time ~= 0 ) and ( os.time() + time ) or 0

    kate.Gag( steamId64, args )

    local phrase = function( showSteamId )
      return ( time ~= 0 ) and {
        'LOG_GAG', kate.GetActor( pl, showSteamId ), kate.GetTarget( steamId64, showSteamId ), os.date( '%d.%m.%y (%H:%M)', args.UnGagTime ), reason } or {
        'LOG_GAG_PERMA', kate.GetActor( pl, showSteamId ), kate.GetTarget( steamId64, showSteamId ), reason }
    end

    kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end )
  :SetFlag( 'gag' )
  :AddParam( 'PLAYER_STEAMID' )
  :AddParam( 'TIME' )
  :AddParam( 'STRING' )

kate.AddCommand( 'UnGag',
  function( pl, target )
    local steamId64 = kate.TargetToSteamID64( target )
    if steamId64 == nil then
      return
    end

    kate.UnGag( steamId64 )

    local phrase = function( showSteamId )
      return { 'LOG_UNGAG', kate.GetActor( pl, showSteamId ), kate.GetTarget( steamId64, showSteamId ) }
    end

    kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end )
  :SetFlag( 'gag' )
  :AddParam( 'PLAYER_STEAMID' )