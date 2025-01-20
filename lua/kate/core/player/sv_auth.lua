local vendor = include( 'sv_vendor.lua' )

hook.Add( 'PlayerAuthed', 'Kate::SetUserInfo', function( pl )
  vendor.LoadUserInfo( pl )
  vendor.LoadUserGroup( pl )
  vendor.LoadUserPunishments( pl )
end )

timer.Create( 'Kate::SaveUserInfo', 300, 0, vendor.SaveUsersPlaytime )
hook.Add( 'ShutDown', 'Kate::SaveUserInfo', vendor.SaveUsersPlaytime )
hook.Add( 'PlayerDisconnected', 'Kate::SaveUserInfo', vendor.SaveUserPlaytime )