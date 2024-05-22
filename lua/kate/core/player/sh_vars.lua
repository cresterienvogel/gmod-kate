nw.Register( 'Kate_Location' )
  :Write( net.WriteString )
  :Read( net.ReadString )
  :SetGlobal()

nw.Register( 'Kate_FirstJoin' )
  :Write( net.WriteUInt, 31 )
  :Read( net.ReadUInt, 31 )
  :SetLocalPlayer()

nw.Register( 'Kate_LastJoin' )
  :Write( net.WriteUInt, 31 )
  :Read( net.ReadUInt, 31 )
  :SetLocalPlayer()

nw.Register( 'Kate_SessionStarted' )
  :Write( net.WriteUInt, 31 )
  :Read( net.ReadUInt, 31 )
  :SetLocalPlayer()

nw.Register( 'Kate_Playtime' )
  :Write( net.WriteUInt, 31 )
  :Read( net.ReadUInt, 31 )
  :SetLocalPlayer()

nw.Register( 'Kate_ExpireUserGroup' )
  :Write( net.WriteString )
  :Read( net.ReadString )
  :SetLocalPlayer()

nw.Register( 'Kate_ExpireUserGroupTime' )
  :Write( net.WriteUInt, 31 )
  :Read( net.ReadUInt, 31 )
  :SetLocalPlayer()

nw.Register( 'Kate_Mentor' )
  :Write( net.WriteString )
  :Read( net.ReadString )
  :SetLocalPlayer()

nw.Register( 'Kate_Cloak' )
  :Write( net.WriteBool )
  :Read( net.ReadBool )
  :SetLocalPlayer()