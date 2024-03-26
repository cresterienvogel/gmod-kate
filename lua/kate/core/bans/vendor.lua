return {
  Insert = function( info )
    local keys do
      keys = ''

      local handled = 0
      local total = table.Count( info )

      for k in pairs( info ) do
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
      local total = table.Count( info )

      for _, v in pairs( info ) do
        handled = handled + 1

        values = values .. ( ( type( v ) == 'string' ) and string.format( '%q', kate.DB:Escape( v ) ) or v )

        if handled ~= total then
          values = values .. ', '
        end
      end
    end

    local steamId64 = info['SteamID64']
    local reason = info['Reason']

    kate.DB:Query( string.format( 'INSERT INTO kate_bans ( %s ) VALUES ( %s );', keys, values ) )
      :SetOnSuccess( function()
        kate.Bans.Cache[steamId64] = info
        game.KickID( kate.SteamIDFrom64( steamId64 ), reason )
      end )
      :Start()
  end,
  Update = function( newInfo, oldInfo, callback )
    local values do
      values = ''

      local handled = 0
      local total = table.Count( newInfo )

      for k, v in pairs( newInfo ) do
        handled = handled + 1

        values = values .. ( k .. ' = ' )
        values = values .. ( ( type( v ) == 'string' ) and string.format( '%q', kate.DB:Escape( v ) ) or v )

        if handled ~= total then
          values = values .. ', '
        end
      end
    end

    local condition do
      condition = ''

      local handled = 0
      local total = table.Count( oldInfo )

      for k, v in pairs( oldInfo ) do
        handled = handled + 1

        condition = condition .. k .. ' = '
        condition = condition .. ( ( type( v ) == 'string' ) and string.format( '%q', kate.DB:Escape( v ) ) or v )

        if handled ~= total then
          condition = condition .. ' AND '
        end
      end
    end

    local steamId64 = oldInfo['SteamID64']

    kate.DB:Query( string.format( 'UPDATE kate_bans SET %s WHERE %s;', values, condition ) )
      :SetOnSuccess( function()
        if callback ~= nil then
          callback()

          return
        end

        for k, v in pairs( newInfo ) do
          kate.Bans.Cache[steamId64][k] = v
        end
      end )
      :Start()
  end
}