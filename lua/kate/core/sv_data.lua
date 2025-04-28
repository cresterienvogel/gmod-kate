kate.DB = kate.DB or SickQL:New(
  'MySQLOO', -- Data vendor ( MySQLOO/TMySQL/SQLite )
  '127.0.0.1', -- IP Address
  3306, -- Port
  'root', -- User
  '', -- Password
  'kate' -- Table
)

function kate.DB:OnConnected()
  kate.Print( LOG_SUCCESS, kate.GetPhrase( false, 'DATABASE_CONNECTION_SUCCESS' ) )

  self:Query( [[
    CREATE TABLE IF NOT EXISTS kate_users
      (
        SteamID64 VARCHAR ( 17 ) PRIMARY KEY,
        Name TEXT NOT NULL,
        FirstJoin INT NOT NULL,
        LastJoin INT NOT NULL,
        Playtime INT NOT NULL,
        IP VARCHAR ( 15 ) NOT NULL
      );
    ]] )
    :Start()

  self:Query(
    [[ CREATE TABLE IF NOT EXISTS kate_usergroups
      (
        SteamID64 VARCHAR ( 17 ) PRIMARY KEY,
        UserGroup TINYTEXT NOT NULL,
        ExpireGroup TINYTEXT NOT NULL,
        ExpireTime INT NOT NULL,
        AdminSteamID64 VARCHAR ( 17 ) NOT NULL
      );
    ]] )
    :Start()

  self:Query( [[
    CREATE TABLE IF NOT EXISTS kate_bans
      (
        SteamID64 VARCHAR ( 17 ) NOT NULL,
        Name TEXT NOT NULL,
        IP VARCHAR ( 15 ) NOT NULL,
        Reason TEXT NOT NULL,
        BanTime INT NOT NULL,
        UnbanTime INT NOT NULL,
        AdminSteamID64 VARCHAR ( 17 ) NOT NULL,
        AdminName TEXT NOT NULL,
        AdminIP VARCHAR ( 15 ) NOT NULL
      );
    ]] )
    :Start()
end

function kate.DB:OnConnectionFailed( errorMsg )
  kate.Print( LOG_ERROR, kate.GetPhrase( false, 'DATABASE_CONNECTION_ERROR', errorMsg ) )
end

kate.DB:Connect()