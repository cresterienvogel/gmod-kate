local vendor = include( 'sv_vendor.lua' )

hook.Add( 'PlayerAuthed', 'Kate_SetUserInfo', function( pl )
  if not IsValid( pl ) then
    return
  end

  vendor.LoadUserInfo( pl )
  vendor.LoadUserGroup( pl )
  vendor.LoadUserPunishments( pl )
end )

timer.Create( 'Kate_SaveUserInfo', 300, 0, vendor.SaveUsersPlaytime )
hook.Add( 'ShutDown', 'Kate_SaveUserInfo', vendor.SaveUsersPlaytime )
hook.Add( 'PlayerDisconnected', 'Kate_SaveUserInfo', vendor.SaveUserPlaytime )