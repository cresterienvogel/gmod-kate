kate.AddCommand( 'Ban',
  function( pl, target, time, reason )
    local steamId64 = kate.TargetToSteamID64( target )
    if steamId64 == nil then
      return
    end

    local args = {}
    args.Reason = reason

    if time ~= 0 then
      args.UnbanTime = os.time() + time
    end

    if IsValid( pl ) then
      args.AdminSteamID64 = pl:SteamID64()
      args.AdminName = pl:Name()
      args.AdminIP = kate.StripPort( pl:IPAddress() )
    end

    if IsValid( target ) then
      args.Name = target:Name()
      args.IP = kate.StripPort( target:IPAddress() )

      kate.Ban( steamId64, args )
    else
      kate.Database
        :Query( string.format( 'SELECT Name, IP FROM kate_users WHERE SteamID64 = %q', steamId64 ) )
        :SetOnSuccess( function( _, info )
          if info[1] then
            args.Name = info[1].Name
            args.IP = info[1].IP
          end

          kate.Ban( steamId64, args )
        end )
        :Start()
    end

    local phrase = function( showSteamId )
      return ( args.UnbanTime ~= nil ) and {
        'LOG_BAN', kate.GetActor( pl, showSteamId ), kate.GetTarget( steamId64, showSteamId ), os.date( '%d.%m.%y (%H:%M)', args.UnbanTime ), reason } or {
        'LOG_BAN_PERMA', kate.GetActor( pl, showSteamId ), kate.GetTarget( steamId64, showSteamId ), reason }
    end

    kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end )
  :SetFlag( 'ban' )
  :AddParam( 'PLAYER_STEAMID' )
  :AddParam( 'TIME' )
  :AddParam( 'STRING' )

kate.AddCommand( 'UnBan',
  function( pl, target, reason )
    local steamId64 = kate.TargetToSteamID64( target )
    if steamId64 == nil then
      return
    end

    local args = {}
    args.Reason = reason

    if IsValid( pl ) then
      args.AdminSteamID64 = pl:SteamID64()
      args.AdminName = pl:Name()
      args.AdminIP = kate.StripPort( pl:IPAddress() )
    end

    kate.Unban( steamId64, args )

    local phrase = function( showSteamId )
      return { 'LOG_UNBAN', kate.GetActor( pl, showSteamId ), kate.GetTarget( steamId64, showSteamId ), reason }
    end

    kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end )
  :SetFlag( 'unban' )
  :AddParam( 'PLAYER_STEAMID' )
  :AddParam( 'STRING' )

kate.AddCommand( 'Kick',
  function( pl, target, reason )
    if not IsValid( target ) then
      return
    end

    target:Kick( reason )

    local phrase = function( showSteamId )
      return { 'LOG_KICK', kate.GetActor( pl, showSteamId ), kate.GetTarget( target, showSteamId ), reason }
    end

    kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end )
  :SetFlag( 'kick' )
  :AddParam( 'PLAYER_ENTITY' )
  :AddParam( 'STRING' )