kate.AddCommand( 'RCON', function( pl, cmd )
  local args = string.Explode( ' ', cmd )
  RunConsoleCommand( args[1], unpack( args, 2 ) )

  local phrase = { 'LOG_RCON', kate.GetActor( pl, true ), cmd }
  kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase ) ) )
  kate.Notify( pl, LOG_SUCCESS, kate.GetPhrase( IsValid( pl ), 'LOG_RCON_SENT' ) )
end )
 :SetFlag( 'lua' )
 :AddParam( 'STRING' )

kate.AddCommand( 'Run Server', function( pl, code )
  RunString( code )

  local phrase = { 'LOG_LUA_SERVER', kate.GetActor( pl, true ), code }
  kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase ) ) )
  kate.Notify( pl, LOG_SUCCESS, kate.GetPhrase( IsValid( pl ), 'LOG_LUA_SENT' ) )
end )
 :SetFlag( 'lua' )
 :AddParam( 'STRING' )
 :AddAlias( 'RS' )

kate.AddCommand( 'Run Client', function( pl, target, code )
  target:SendLua( code )

  local phrase = { 'LOG_LUA_CLIENT', kate.GetActor( pl, true ), kate.GetTarget( target, true ), code }
  kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase ) ) )
  kate.Notify( pl, LOG_SUCCESS, kate.GetPhrase( IsValid( pl ), 'LOG_LUA_SENT' ) )
end )
 :SetFlag( 'lua' )
 :AddParam( 'PLAYER_ENTITY' )
 :AddParam( 'STRING' )
 :AddAlias( 'RC' )

kate.AddCommand( 'Run Clients', function( pl, code )
  BroadcastLua( code )

  local phrase = { 'LOG_LUA_CLIENTS', kate.GetActor( pl, true ), code }
  kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase ) ) )
  kate.Notify( pl, LOG_SUCCESS, kate.GetPhrase( IsValid( pl ), 'LOG_LUA_SENT' ) )
end )
 :SetFlag( 'lua' )
 :AddParam( 'STRING' )
 :AddAlias( 'RCS' )