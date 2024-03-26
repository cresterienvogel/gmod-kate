concommand.Add( '_kate', function( pl, cmd, args )
  if args[1] == nil then
    return
  end

  cmd = args[1]
  table.remove( args, 1 )

  for k, v in ipairs( args ) do
    if ( string.upper( tostring( v ) ) == 'STEAM_0' ) and args[k + 4] then
      args[k] = table.concat( args, '', k, k + 4 )

      for _ = 1, 4 do
        table.remove( args, k + 1 )
      end

      break
    end
  end

  for k, v in ipairs( args ) do
    args[k] = string.sub( v, 1, 126 )
  end

  kate.RunCommand( pl, cmd, args )
end )