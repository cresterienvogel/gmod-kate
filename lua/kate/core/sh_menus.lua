function kate.RegisterMenu(name)
	if SERVER then
		util.AddNetworkString("Kate " .. name)
	else
		local fr
		net.Receive("Kate " .. name, function()
			local len = net.ReadUInt(16)
			local data = net.ReadData(len)

			data = util.JSONToTable(util.Decompress(data))

			if IsValid(fr) then
				fr:Remove()
			end

			fr = vgui.Create("KFrame")
			fr:SetSize(ScrW() / 1.5, ScrH() / 2)
			fr:SetTitle("Kate " .. name)
			fr:Center()
			fr:MakePopup()

			do
				local records = vgui.Create("KPagePanel", fr)
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