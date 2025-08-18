-- rules the project
kate.AddUserGroup( 'Founder' )
  :SetSuperAdmin( true )
  :SetRelevance( math.huge )
  :SetFlags( '*' )

-- rules the server
kate.AddUserGroup( 'Supervisor' )
  :SetSuperAdmin( true )
  :SetRelevance( 106 )
  :SetFlags( {
    'usergroup', 'ban', 'unban', 'kick',
    'teleport', 'health', 'armor', 'god',
    'cloak', 'ammo', 'message', 'mute',
    'gag', 'slay', 'model', 'freeze',
    'ignite', 'strip', 'physgun'
  } )

-- rules admins
kate.AddUserGroup( 'Overseer' )
  :SetSuperAdmin( true )
  :SetRelevance( 105 )
  :SetFlags( {
    'usergroup', 'ban', 'unban', 'kick',
    'teleport', 'health', 'armor', 'god',
    'cloak', 'ammo', 'message', 'mute',
    'gag', 'slay', 'model', 'freeze',
    'ignite', 'strip', 'physgun'
  } )

-- rules moderators
kate.AddUserGroup( 'Observer' )
  :SetSuperAdmin( true )
  :SetRelevance( 104 )
  :SetFlags( {
    'ban', 'unban', 'kick', 'teleport',
    'health', 'armor', 'god', 'cloak',
    'ammo', 'message', 'mute', 'gag',
    'slay', 'model', 'freeze', 'ignite',
    'strip', 'physgun'
  } )

kate.AddUserGroup( 'SuperAdmin' )
  :SetAdmin( true )
  :SetRelevance( 103 )
  :SetFlags( {
    'ban', 'unban', 'kick', 'teleport',
    'health', 'armor', 'god', 'cloak',
    'message', 'mute', 'gag', 'freeze',
    'strip', 'slay', 'ignite', 'physgun'
  } )

kate.AddUserGroup( 'Admin' )
  :SetAdmin( true )
  :SetRelevance( 102 )
  :SetFlags( {
    'ban', 'kick', 'teleport', 'cloak',
    'message', 'mute', 'gag', 'freeze',
    'strip', 'slay', 'ignite', 'physgun'
  } )

kate.AddUserGroup( 'SuperModerator' )
  :SetAdmin( true )
  :SetRelevance( 101 )
  :SetFlags( {
    'ban', 'kick', 'teleport', 'cloak',
    'message', 'mute', 'gag', 'freeze',
    'strip', 'physgun'
  } )

kate.AddUserGroup( 'Moderator' )
  :SetAdmin( true )
  :SetRelevance( 100 )
  :SetFlags( {
    'kick', 'teleport', 'cloak', 'message',
    'mute', 'gag', 'freeze', 'strip',
    'physgun'
  } )