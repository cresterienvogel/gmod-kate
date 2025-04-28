function kate.RunCommand( pl, cmd, args )
  local cmdObj = kate.Commands.StoredCommands[cmd]
  if cmdObj == nil then
    hook.Run( 'Kate::OnCommandError', pl, nil, 'ERROR_INVALID_COMMAND', { cmd } )

    return false
  end

  local flag = cmdObj:GetFlag()
  if IsValid( pl ) and ( flag ~= nil ) and ( not pl:HasFlag( flag ) ) then
    hook.Run( 'Kate::OnCommandError', pl, cmdObj, 'ERROR_COMMAND_NOACCESS', { cmdObj:GetName() } )

    return false
  end

  for i = 1, #args do
    if ( string.upper( tostring( args[i] ) ) == 'STEAM_0' ) and ( args[i + 4] ) then
      args[i] = table.concat( args, '', i, i + 4 )

      for _ = 1, 4 do
        table.remove( args, i + 1 )
      end

      break
    end
  end

  for k, v in ipairs( args ) do
    args[k] = string.sub( v, 1, 126 )
  end

  local canRun = hook.Run( 'Kate::CanRunCommand', pl, cmdObj, args )
  if canRun == false then
    return false
  end

  if IsValid( pl ) and pl:IsPlayer() then
    if CurTime() < ( pl.KateDelay or 0 ) then
      hook.Run( 'Kate::OnCommandError', pl, cmdObj, 'ERROR_COMMAND_COOLDOWN' )

      return false
    end

    pl.KateDelay = CurTime() + 1
  end

  local canParse, parsedArgs = kate.Parse( pl, cmdObj, table.concat( args, ' ' ) )
  if not canParse then
    return false
  end

  hook.Run( 'Kate::OnCommandRun', pl, cmdObj, parsedArgs, cmdObj:Run( pl, unpack( parsedArgs ) ) )

  return true
end