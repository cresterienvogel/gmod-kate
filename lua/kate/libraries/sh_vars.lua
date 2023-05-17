kate.Vars = kate.Vars or {}

if SERVER then
	util.AddNetworkString("Kate Broadcast")
	util.AddNetworkString("Kate Broadcast Global")

	hook.Add("PlayerHasSpawned", "Kate Broadcast", function(pl)
		net.Start("Kate Broadcast Global")
			net.WriteTable(kate.Vars)
		net.Send(pl)
	end)

	hook.Add("EntityRemoved", "Kate Broadcast", function(ent)
		local id = ent:EntIndex()
		if not kate.Vars[id] then
			return
		end

		kate.Vars[id] = nil

		net.Start("Kate Broadcast")
			net.WriteInt(id, 15)
			net.WriteTable({})
		net.Broadcast()
	end)
else
	net.Receive("Kate Broadcast", function()
		local id = net.ReadInt(15)
		local tbl = net.ReadTable()

		if not tbl or table.IsEmpty(tbl) then
			kate.Vars[id] = nil
		else
			kate.Vars[id] = tbl
		end
	end)

	net.Receive("Kate Broadcast Global", function()
		kate.Vars = net.ReadTable()
	end)
end

local meta = FindMetaTable("Entity")

function meta:SetKateVar(name, value)
	local id = self:EntIndex()
	kate.Vars[id] = kate.Vars[id] or {}
	kate.Vars[id][name] = value

	if SERVER then
		net.Start("Kate Broadcast")
			net.WriteInt(id, 15)
			net.WriteTable(kate.Vars[id])
		net.Broadcast()
	end
end

function meta:GetKateVar(name)
	local id = self:EntIndex()
	return (kate.Vars[id] and kate.Vars[id][name]) or nil
end