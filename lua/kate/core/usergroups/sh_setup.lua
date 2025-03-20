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
    'ignite', 'strip'
  } )

-- rules admins
kate.AddUserGroup( 'Overseer' )
  :SetAdmin( true )
  :SetRelevance( 105 )
  :SetFlags( {
    'usergroup', 'ban', 'unban', 'kick',
    'teleport', 'health', 'armor', 'god',
    'cloak', 'ammo', 'message', 'mute',
    'gag', 'slay', 'model', 'freeze',
    'ignite', 'strip'
  } )

-- rules moderators
kate.AddUserGroup( 'Observer' )
  :SetAdmin( true )
  :SetRelevance( 104 )
  :SetFlags( {
    'ban', 'unban', 'kick', 'teleport',
    'health', 'armor', 'god', 'cloak',
    'ammo', 'message', 'mute', 'gag',
    'slay', 'model', 'freeze', 'ignite',
    'strip'
  } )

kate.AddUserGroup( 'SuperAdmin' )
  :SetAdmin( true )
  :SetRelevance( 103 )
  :SetFlags( {
    'ban', 'unban', 'kick', 'teleport',
    'health', 'armor', 'god', 'cloak',
    'message', 'mute', 'gag', 'freeze',
    'strip', 'slay', 'ignite'
  } )

kate.AddUserGroup( 'Admin' )
  :SetAdmin( true )
  :SetRelevance( 102 )
  :SetFlags( {
    'ban', 'kick', 'teleport', 'cloak',
    'message', 'mute', 'gag', 'freeze',
    'strip', 'slay', 'ignite'
  } )

kate.AddUserGroup( 'SuperModerator' )
  :SetAdmin( true )
  :SetRelevance( 101 )
  :SetFlags( {
    'ban', 'kick', 'teleport', 'cloak',
    'message', 'mute', 'gag', 'freeze',
    'strip'
  } )

kate.AddUserGroup( 'Moderator' )
  :SetAdmin( true )
  :SetRelevance( 100 )
  :SetFlags( {
    'kick', 'teleport', 'cloak', 'message',
    'mute', 'gag', 'freeze', 'strip'
  } )