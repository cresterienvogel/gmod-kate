local phrases = {
  DATABASE_CONNECTION_SUCCESS = 'Database connection successfully established',
  DATABASE_CONNECTION_ERROR = 'Database connection error: %s',

  BAN_DETAILS = 'You\'re banned: %s\n\nBanned by: %s %s\nUnban date: %s at %s\nBan date: %s at %s',
  BAN_DETAILS_PERMA = 'You\'re permabanned: %s\n\nBanned by: %s (%s)\nBan date: %s at %s',

  LOG_RCON = '%s sent RCON command: %s',
  LOG_KICK = '%s kicked %s with reason: %s',
  LOG_SLAY = '%s slayed %s',
  LOG_MODEL = '%s set model of %s to %s',
  LOG_SIZE = '%s set model scale of %s to %s',
  LOG_HEALTH = '%s set %s health to %s',
  LOG_ARMOR = '%s set %s armor to %s',
  LOG_MESSAGE = '%s sent message to %s: %s',
  LOG_RCON_SENT = 'RCON command run',

  LOG_GOTO = '%s teleported to %s',
  LOG_TELEPORT = '%s teleported %s',
  LOG_RETURN = '%s returned %s',
  LOG_RETURN_NOPOS = '%s has no return position',

  LOG_AMMO = '%s gave %s %s %s ammotype',
  LOG_AMMO_ALL = '%s gave %s %s of every ammotype',

  LOG_CLOAK = '%s enabled cloak for %s',
  LOG_CLOAK_MESSAGE = '%s enabled cloak for you',
  LOG_UNCLOAK = '%s disabled cloak for %s',
  LOG_UNCLOAK_MESSAGE = '%s disabled cloak for you',

  LOG_GOD = '%s enabled god mode for %s',
  LOG_UNGOD = '%s disabled god mode for %s',

  LOG_FREEZE = '%s froze %s',
  LOG_UNFREEZE = '%s unfroze %s',

  LOG_IGNITE = '%s ignited %s for %s seconds',
  LOG_UNIGNITE = '%s extinguished %s',

  LOG_STRIP = '%s stripped %s from %s',
  LOG_STRIP_ALL = '%s stripped %s',

  LOG_LUA_SENT = 'Code run',
  LOG_LUA_SERVER = '%s run code on server: %s',
  LOG_LUA_CLIENT = '%s run code on %s: %s',
  LOG_LUA_CLIENTS = '%s run code on clients: %s',

  LOG_UNBAN = '%s unbanned %s with reason: %s',
  LOG_BAN = '%s banned %s until %s with reason: %s',
  LOG_BAN_PERMA = '%s permabanned %s: %s',

  LOG_UNMUTE = '%s unmuted %s with reason: %s',
  LOG_UNMUTE_AUTO = '%s has been unmuted since the mute time out',
  LOG_MUTE = '%s muted %s until %s with reason: %s',
  LOG_MUTE_PERMA = '%s permamuted %s with reason: %s',

  LOG_UNGAG = '%s ungagged %s with reason: %s',
  LOG_UNGAG_AUTO = '%s has been ungagged since the gag time out',
  LOG_GAG = '%s gagged %s until %s with reason: %s',
  LOG_GAG_PERMA = '%s permagagged %s with reason: %s',

  LOG_SETGROUP_TIME_GROUP = '%s set rank of %s to %s with expiration until %s to %s',
  LOG_SETGROUP_TIME = '%s set rank of %s to %s with expiration until %s',
  LOG_SETGROUP = '%s set rank of %s to %s',

  LOG_HIGHER_TARGET = '%s tried to use %s command on you',

  ERROR_MUTE_PERMA = 'You are permamuted',
  ERROR_MUTE = 'You are muted until %s',

  ERROR_GAG_PERMA = 'You are permagagged',
  ERROR_GAG = 'You are gagged until %s',

  ERROR_COMMAND_COOLDOWN = 'Please, wait a bit!',
  ERROR_COMMAND_NOACCESS = 'You have no access to %s command!',

  ERROR_MISSING_PARAM = 'Missing argument #%s: %s',

  ERROR_HIGHER_TARGET = '%s has higher rank than yours!',
  ERROR_HIGHER_USERGROUP = '%s rank is higher than your current one!',
  ERROR_HIGHER_EXPIRED_USERGROUP = '%s expire rank is higher than %s!',

  ERROR_INVALID_COMMAND = 'Invalid command: %s',
  ERROR_INVALID_MODEL = 'Could not find model: %s',
  ERROR_INVALID_AMMOTYPE = 'Could not find ammo type: %s',
  ERROR_INVALID_USERGROUP = 'Could not find rank: %s',
  ERROR_INVALID_SWEP = 'Could not find SWEP: %s',
  ERROR_INVALID_PLAYER = 'Could not find player: %s',
  ERROR_INVALID_NUMBER = 'Invalid number: %s',
  ERROR_INVALID_TIME = 'Invalid time: %s',

  ERROR_SELF_MESSAGE = 'You can\'t message yourself',

  ADMIN = 'Administrator',
  PLAYER = 'Player',
  SENT_TO = 'Sent to'
}

for phrase, translation in pairs( phrases ) do
  kate.AddPhrase( 'eu', phrase, translation )
end