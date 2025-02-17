kate.AddCommand( 'Slay',
  function( pl, target )
    target:Kill()

    local phrase = function( showSteamId )
      return { 'LOG_SLAY', kate.GetActor( pl, showSteamId ), kate.GetTarget( target, showSteamId ) }
    end

    kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end )
  :SetFlag( 'slay' )
  :AddParam( 'PLAYER_ENTITY' )
  :AddAlias( 'Kill' )

kate.AddCommand( 'Model',
  function( pl, target, model )
    target:SetModel( model )

    local phrase = function( showSteamId )
      return { 'LOG_MODEL', kate.GetActor( pl, showSteamId ), kate.GetTarget( target, showSteamId ), model }
    end

    kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end )
  :SetFlag( 'model' )
  :AddParam( 'PLAYER_ENTITY' )
  :AddParam( 'MODEL' )
  :AddAlias( 'Set Model' )
  :AddAlias( 'MDL' )

kate.AddCommand( 'Size',
  function( pl, target, size )
    target:SetModelScale( size or 1 )

    local phrase = function( showSteamId )
      return { 'LOG_SIZE', kate.GetActor( pl, showSteamId ), kate.GetTarget( target, showSteamId ), size }
    end

    kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end )
  :SetFlag( 'model' )
  :AddParam( 'PLAYER_ENTITY' )
  :AddParam( 'NUMBER', true )
  :AddAlias( 'Set Size' )
  :AddAlias( 'Set Scale' )
  :AddAlias( 'Scale' )

kate.AddCommand( 'Freeze',
  function( pl, target )
    local isFrozen = target:IsFrozen()
    target:Freeze( not isFrozen )

    local phrase = function( showSteamId )
      return isFrozen and {
        'LOG_UNFREEZE', kate.GetActor( pl, showSteamId ), kate.GetTarget( target, showSteamId ) } or {
        'LOG_FREEZE', kate.GetActor( pl, showSteamId ), kate.GetTarget( target, showSteamId ) }
    end

    kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end )
  :SetFlag( 'freeze' )
  :AddParam( 'PLAYER_ENTITY' )

kate.AddCommand( 'Ignite',
  function( pl, target, time )
    local isIgnited = target:IsOnFire()
    if isIgnited then
      target:Extinguish()
    else
      target:Ignite( time or 60 )
    end

    local phrase = function( showSteamId )
      return isIgnited and {
        'LOG_UNIGNITE', kate.GetActor( pl, showSteamId ), kate.GetTarget( target, showSteamId ) } or {
        'LOG_IGNITE', kate.GetActor( pl, showSteamId ), kate.GetTarget( target, showSteamId ), time }
    end

    kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end )
  :SetFlag( 'ignite' )
  :AddParam( 'PLAYER_ENTITY' )
  :AddParam( 'TIME', true )

kate.AddCommand( 'Strip',
  function( pl, target, swep )
    if swep ~= nil then
      pl:StripWeapon( swep.Class )
    else
      pl:StripWeapons()
    end

    local phrase = function( showSteamId )
      return ( swep ~= nil ) and {
        'LOG_STRIP', kate.GetActor( pl, showSteamId ), swep.PrintName or swep.Class, kate.GetTarget( target, showSteamId ) } or {
        'LOG_STRIP_ALL', kate.GetActor( pl, showSteamId ), kate.GetTarget( target, showSteamId ) }
    end

    kate.Notify( player.GetAll(), LOG_COMMON, kate.GetPhrase( true, unpack( phrase( false ) ) ) )
    kate.Print( LOG_COMMON, kate.GetPhrase( false, unpack( phrase( true ) ) ) )
  end )
  :SetFlag( 'strip' )
  :AddParam( 'PLAYER_ENTITY' )
  :AddParam( 'SWEP', true )