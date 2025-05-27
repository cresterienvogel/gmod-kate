local DATA = {
  number = {
    write = net.WriteUInt,
    read = net.ReadUInt,
    opt = 31,
    type = 'INT NOT NULL'
  },
  string = {
    write = net.WriteString,
    read = net.ReadString,
    type = 'TEXT NOT NULL'
  },
  bool = {
    write = net.WriteBool,
    read = net.ReadBool,
    type = 'BIT ( 1 ) NOT NULL'
  }
}

local VENDOR = {}

function VENDOR.CreateTable( name, columns )
  local content = ''

  do
    local handled = 0
    local total = table.Count( columns )

    for k, v in pairs( columns ) do
      handled = handled + 1
      content = content .. ( string.format( '%s %s', k, ( DATA[v] ~= nil ) and DATA[v].type or DATA.string.type ) )

      if handled ~= total then
        content = content .. ', '
      end
    end
  end

  kate.DB:Query( string.format( 'CREATE TABLE IF NOT EXISTS kate_punishments_%s ( SteamID64 VARCHAR ( 17 ) PRIMARY KEY, %s );',
    string.gsub( string.lower( name ), ' ', '_' ), content
  ) ):Start()
end

function VENDOR.RegisterVars( columns, vars )
  for name in pairs( vars ) do
    local data = DATA[columns[name]]
    if data == nil then
      continue
    end

    nw.Register( 'Kate_' .. name )
      :Write( data.write, data.opt )
      :Read( data.read, data.opt )
      :SetPlayer()
  end
end

function VENDOR.RegisterPunishment( name, columns )
  local PUNISHMENT = {}
  PUNISHMENT.Cache = {}

  PUNISHMENT.LoadCache = function()
    PUNISHMENT.Cache = {}

    kate.DB:Query( string.format( 'SELECT * FROM kate_punishments_%s;', string.gsub( string.lower( name ), ' ', '_' ) ) )
      :SetOnSuccess( function( _, info )
        for _, data in ipairs( info ) do
          PUNISHMENT.Cache[data['SteamID64']] = data
        end
      end )
      :Start()
  end

  PUNISHMENT.LoadPlayerCache = function( pl )
    local steamId64 = pl:SteamID64()
    PUNISHMENT.Cache[steamId64] = nil

    kate.DB:Query( string.format( 'SELECT * FROM kate_punishments_%s WHERE SteamID64 = %q;', string.gsub( string.lower( name ), ' ', '_' ), steamId64 ) )
      :SetOnSuccess( function( _, info )
        if info[1] == nil then
          return
        end

        PUNISHMENT.Cache[steamId64] = info[1]
      end )
      :Start()
  end

  PUNISHMENT.LoadPlayersCache = function()
    for _, pl in player.Iterator() do
      if pl:IsBot() then
        continue
      end

      PUNISHMENT.LoadPlayerCache( pl )
    end
  end

  PUNISHMENT.Punish = function( steamId64, info )
    local tbl = string.gsub( string.lower( name ), ' ', '_' )

    kate.DB:Query( string.format( 'DELETE FROM kate_punishments_%s WHERE SteamID64 = %q;', tbl, steamId64 ) )
      :SetOnSuccess( function()
        local keys do
          keys = ''

          local handled = 0
          local total = table.Count( columns )

          for k in pairs( columns ) do
            handled = handled + 1
            keys = keys .. k

            if handled ~= total then
              keys = keys .. ', '
            end
          end
        end

        local values do
          values = ''

          local handled = 0
          local total = table.Count( columns )

          for k in pairs( columns ) do
            handled = handled + 1
            values = values .. ( ( type( info[k] ) == 'string' ) and string.format( '%q', kate.DB:Escape( info[k] ) ) or info[k] )

            if handled ~= total then
              values = values .. ', '
            end
          end
        end

        kate.DB:Query( string.format( 'INSERT INTO kate_punishments_%s ( SteamID64, %s ) VALUES ( %q, %s );', tbl, keys, steamId64, values ) )
          :SetOnSuccess( function()
            PUNISHMENT.Cache[steamId64] = info
            hook.Run( 'Kate::' .. name .. 'Created', steamId64, info )

            local target = kate.FindPlayer( steamId64 )
            if not IsValid( target ) then
              return
            end

            for column, value in pairs( info ) do
              if nw.Vars['Kate_' .. column] ~= nil then
                target:SetNetVar( 'Kate_' .. column, value )
              end
            end

            hook.Run( 'Kate::Player' .. name, target, info )
          end )
          :Start()
      end )
      :Start()
  end

  PUNISHMENT.Penalize = function( steamId64, info )
    kate.DB:Query( string.format( 'DELETE FROM kate_punishments_%s WHERE SteamID64 = %q;', string.gsub( string.lower( name ), ' ', '_' ), steamId64 ) )
      :SetOnSuccess( function()
        PUNISHMENT.Cache[steamId64] = nil
        hook.Run( 'Kate::' .. name .. 'Removed', steamId64, info )

        local target = kate.FindPlayer( steamId64 )
        if not IsValid( target ) then
          return
        end

        for column in pairs( columns ) do
          if nw.Vars['Kate_' .. column] ~= nil then
            target:SetNetVar( 'Kate_' .. column, nil )
          end
        end

        hook.Run( 'Kate::PlayerUn' .. name, target, info )
      end )
      :Start()
  end

  kate.Punishments.Stored[name] = PUNISHMENT

  kate[name] = PUNISHMENT.Punish
  kate['Un' .. name] = PUNISHMENT.Penalize

  return PUNISHMENT
end

return VENDOR