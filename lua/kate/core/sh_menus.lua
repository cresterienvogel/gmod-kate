function kate.RegisterMenu(name)
	local tag = string.format("Kate %s", name)

	if SERVER then
		util.AddNetworkString(tag)
	else -- CLIENT
		local frame

		net.Receive(tag, function()
			if IsValid(frame) then
				frame:Remove()
			end

			local len = net.ReadUInt(32)
			local data = net.ReadData(len)

			data = util.JSONToTable(util.Decompress(data))

			frame = vgui.Create("KFrame")
			frame:SetSize(ScrW() / 1.5, ScrH() / 2)
			frame:SetTitle(tag)
			frame:Center()
			frame:MakePopup()

			do
				local records = vgui.Create("KPagePanel", frame)
				records:Dock(FILL)
				records:SetMaxPerPage(200)

				records:AddOption("Copy steamid32", function(id)
					SetClipboardText(util.SteamIDFrom64(id))
				end, "steamid")

				records:SetData(data)
				records:Build()
			end
		end)
	end
end

kate.RegisterMenu("Players")
kate.RegisterMenu("Bans")
kate.RegisterMenu("Gags")
kate.RegisterMenu("Mutes")