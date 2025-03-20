local phrases = {
  BAN_DETAILS = 'Вы забанены: %s\n\nЗабанил: %s %s\nДата разбана: %s в %s\nДата бана: %s в %s',
  BAN_DETAILS_PERMA = 'Вы забанены навечно: %s\n\nЗабанил: %s (%s)\nДата бана: %s в %s',

  LOG_KICK = '%s кикнул %s: %s',
  LOG_SLAY = '%s убил %s',
  LOG_MODEL = '%s установил модель %s на %s',
  LOG_SIZE = '%s установил размер модели %s на %s',
  LOG_HEALTH = '%s установил %s %s здоровья',
  LOG_ARMOR = '%s установил %s %s брони',
  LOG_MESSAGE = '%s отправил сообщение %s: %s',
  LOG_RCON_SENT = 'RCON команда запущена',

  LOG_GOTO = '%s телепортировался к %s',
  LOG_TELEPORT = '%s телепортировал %s',
  LOG_RETURN = '%s вернул %s',
  LOG_RETURN_NOPOS = '%s не имеет позиции для возврата',

  LOG_AMMO = '%s выдал %s %s патрон типа %s',
  LOG_AMMO_ALL = '%s выдал %s %s патрон каждого типа',

  LOG_CLOAK = '%s включил невидимость для %s',
  LOG_CLOAK_MESSAGE = '%s включил вам невидимость',
  LOG_UNCLOAK = '%s выключил невидимость для %s',
  LOG_UNCLOAK_MESSAGE = '%s выключил вам невидимость',

  LOG_GOD = '%s выдал бессмертие %s',
  LOG_UNGOD = '%s забрал бессмертие у %s',

  LOG_FREEZE = '%s заморозил %s',
  LOG_UNFREEZE = '%s разморозил %s',

  LOG_IGNITE = '%s поджёг %s на %s секунд',
  LOG_UNIGNITE = '%s потушил %s',

  LOG_STRIP = '%s забрал %s у %s',
  LOG_STRIP_ALL = '%s забрал всё оружие у %s',

  LOG_LUA_SENT = 'Код запущен',

  LOG_UNBAN = '%s разбанил %s по причине: %s',
  LOG_BAN_PERMA = '%s забанил навечно %s: %s',
  LOG_BAN = '%s забанил %s до %s по причине: %s',

  LOG_UNMUTE = '%s снял мут %s по причине: %s',
  LOG_UNMUTE_AUTO = 'С %s был снят мут по истечению наказания',
  LOG_MUTE_PERMA = '%s замутил навечно %s по причине: %s',
  LOG_MUTE = '%s замутил %s до %s по причине: %s',

  LOG_UNGAG = '%s снял мут голосового чата %s по причине: %s',
  LOG_UNGAG_AUTO = 'С %s был снят мут голосового чата по истечению наказания',
  LOG_GAG_PERMA = '%s замутил навечно %s в голосовом чате по причине: %s',
  LOG_GAG = '%s замутил %s в голосовом чате до %s по причине: %s',

  LOG_SETGROUP_TIME_GROUP = '%s установил %s ранг %s до %s с истеканием в %s',
  LOG_SETGROUP_TIME = '%s установил %s ранг %s до %s',
  LOG_SETGROUP = '%s установил %s ранг %s',

  LOG_HIGHER_TARGET = '%s попытался использовать команду %s на вас',

  ERROR_MUTE_PERMA = 'Ваш текстовый чат ограничен навсегда',
  ERROR_MUTE = 'Ваш текстовый чат ограничен до %s',

  ERROR_GAG_PERMA = 'Ваш голосовой чат ограничен навсегда',
  ERROR_GAG = 'Ваш голосовой чат ограничен до %s',

  ERROR_COMMAND_COOLDOWN = 'Пожалуйста, подождите немного!',
  ERROR_COMMAND_NOACCESS = 'У вас нет доступа к команде %s!',

  ERROR_MISSING_PARAM = 'Не хватает аргумента #%s: %s',

  ERROR_HIGHER_TARGET = 'Ранг %s выше чем ваш!',
  ERROR_HIGHER_USERGROUP = 'Ранг %s выше чем ваш нынешний!',
  ERROR_HIGHER_EXPIRED_USERGROUP = 'Истекающий ранг %s выше чем %s!',

  ERROR_INVALID_COMMAND = 'Команда не найдена: %s',
  ERROR_INVALID_MODEL = 'Модель не найдена: %s',
  ERROR_INVALID_AMMOTYPE = 'Тип патронов не найден: %s',
  ERROR_INVALID_USERGROUP = 'Ранг не найден: %s',
  ERROR_INVALID_SWEP = 'Оружие не найдено: %s',
  ERROR_INVALID_PLAYER = 'Игрок не найден: %s',
  ERROR_INVALID_NUMBER = 'Некорректное число: %s',
  ERROR_INVALID_TIME = 'Некорректное время: %s',

  ADMIN = 'Администратор',
  SENT_TO = 'Отправлено'
}

for phrase, translation in pairs( phrases ) do
  kate.AddPhrase( 'ru', phrase, translation )
end