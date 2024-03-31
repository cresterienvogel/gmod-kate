concommand.Add( 'kate',
  function( _, cmd, args )
    if args[1] == nil then
      return
    end

    cmd = args[1]
    table.remove( args, 1 )

    for k, v in ipairs( args ) do
      if ( string.upper( tostring( v ) ) == 'STEAM_0' ) and ( args[k + 4] ~= nil ) then
        args[k] = table.concat( args, '', k, k + 4 )

        for _ = 1, 4 do
          table.remove( args, k + 1 )
        end

        break
      end
    end

    RunConsoleCommand( '_kate', cmd, unpack( args ) )
  end,
  function( tag, str )
    if not CLIENT then
      return
    end

    local args = kate.ExplodeQuotes( str )
    local argsCount = #args

    local ret = {}
    for k, v in pairs( kate.Commands.StoredCommands ) do
      if not LocalPlayer():HasFlag( v:GetFlag() ) then
        continue
      end

      local help = tag .. ' ' .. k
      if ( argsCount == 0 ) or ( ( argsCount ~= 0 ) and string.StartsWith( k, string.lower( args[1] ) ) ) then
        for _, param in ipairs( v:GetParams() ) do
          local paramObj = kate.Commands.StoredParams[param.Enum]
          help = help .. ' ' .. ( '<' .. paramObj:GetName() .. '>' )
        end

        ret[#ret + 1] = help
      end
    end

    return ( #ret > 0 ) and ret or { '<No results>' }
  end
)