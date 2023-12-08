function kate.RegisterMenu(name)
	if SERVER then
		util.AddNetworkString("Kate " .. name)
	end

	if CLIENT then
		local frame

		net.Receive("Kate " .. name, function()
			local len = net.ReadUInt(32)
			local data = net.ReadData(len)

			data = util.JSONToTable(util.Decompress(data))

			if IsValid(frame) then
				frame:Remove()
			end

			frame = vgui.Create("KFrame")
			frame:SetSize(ScrW() / 1.5, ScrH() / 2)
			frame:SetTitle("Kate " .. name)
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