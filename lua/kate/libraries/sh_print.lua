kate.Status = {
	Color(133, 213, 196),
	Color(213, 85, 85),
	Color(216, 134, 234)
}

if SERVER then
	util.AddNetworkString("Kate Message")
end

if CLIENT then
	net.Receive("Kate Message", function()
		local st = net.ReadInt(3)
		local msg = net.ReadString()

		chat.AddText(kate.Status[st], "» ", color_white, msg)
	end)
end

function kate.Print(...)
	local text = table.concat({...}, " ")

	timer.Simple(0, function()
		MsgC(kate.Status[1], "[Kate] ", "[" .. os.date("%H:%M:%S", os.time()) .. "] ", color_white, text, "\n")
	end)
end

function kate.Message(recip, status, ...)
	local text = table.concat({...}, " ")

	timer.Simple(0, function()
		if not IsValid(recip) and not istable(recip) then
			kate.Print(text)
			return
		end

		if CLIENT then
			chat.AddText(kate.Status[status], "» ", color_white, text)
			return
		end

		net.Start("Kate Message")
			net.WriteInt(status, 3)
			net.WriteString(text)
		net.Send(recip)
	end)
end