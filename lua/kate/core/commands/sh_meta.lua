-- https://github.com/SuperiorServers/dash/blob/master/lua/dash/libraries/cmd.lua

kate.Commands = kate.Commands or {
  StoredCommands = {},
  StoredParams = {},
  AliasCommands = {},
  NumberUnits = {
    h = 100,
    k = 1000,
    mil = 1000000,
  },
  TimeUnits = {
    s = 1,
    mi = 60,
    h = 3600,
    d = 86400,
    w = 604800,
    mo = 2592000,
    y = 31536000
  }
}

local COMMAND = {}
COMMAND.__index = COMMAND

function kate.AddCommand( name, callback )
  local COMMAND_ID = string.gsub( string.lower( name ), ' ', '' )

  local NEW_COMMAND = {
    Id = COMMAND_ID,
    Name = name,
    Visible = true,
    Category = 'Other',
    Params = {},
    Callback = callback or function() end
  }

  setmetatable( NEW_COMMAND, COMMAND )
  kate.Commands.StoredCommands[COMMAND_ID] = NEW_COMMAND

  return NEW_COMMAND
end

function COMMAND:SetFlag( flag )
  self.Flag = flag

  return self
end

function COMMAND:AddParam( name, optional )
  local t = {
    Enum = name,
    Optional = optional or false
  }

  self.Params[#self.Params + 1] = t

  return self
end

function COMMAND:AddAlias( name )
  local ALIAS_ID = string.gsub( string.lower( name ), ' ', '' )

  kate.Commands.StoredCommands[ALIAS_ID] = self
  kate.Commands.AliasCommands[ALIAS_ID] = self:GetID()

  return self
end

function COMMAND:Run( caller, ... )
  return self.Callback( caller, ... )
end

function COMMAND:GetID()
  return self.Id
end

function COMMAND:GetFlag()
  return self.Flag
end

function COMMAND:GetName()
  return self.Name
end

function COMMAND:GetParams()
  return self.Params
end

local PARAM = {}
PARAM.__index = PARAM

function kate.AddParam( param )
  local PARAM_ID = string.upper( param )

  local NEW_PARAM = {
    Name = 'Unknown Param',
    ParseFunc = function() end
  }

  setmetatable( NEW_PARAM, PARAM )
  kate.Commands.StoredParams[PARAM_ID] = NEW_PARAM

  return NEW_PARAM
end

function PARAM:SetName( name )
  self.Name = name

  return self
end

function PARAM:SetParse( func )
  self.ParseFunc = func

  return self
end

function PARAM:GetName()
  return self.Name
end

function PARAM:Parse( ... )
  return self.ParseFunc( unpack( { ... } ) )
end