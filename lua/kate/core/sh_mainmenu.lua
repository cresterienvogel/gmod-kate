if SERVER then
	util.AddNetworkString("Kate Menu")
end

if CLIENT then
	local frame, frame_query, frame_player
	local showQuery, showPlayers

	showQuery = function(command, queries, pl)
		if IsValid(frame_query) then
			frame_query:Close()
		end

		local parent = IsValid(frame_player) and frame_player or frame

		frame_query = vgui.Create("KQuery")
		frame_query:SetTitle("Fill args for " .. kate.Commands.Stored[command]:GetTitle())
		frame_query:SetSize(ScrW() / 3.5, ScrH() / 3.5)
		frame_query:SetPos(parent:GetPos())
		frame_query:MoveTo(parent:GetX() + frame_query:GetWide() + 16, parent:GetY(), 0.1)

		frame_query:SetQueries(queries)

		frame_query:SetFunction(function()
			local args = {"kate", command}

			if pl then
				local id = kate.SteamIDTo64(pl)

				if id then
					args[#args + 1] = id
				end
			end

			for query, val in pairs(frame_query:GetQueries()) do
				args[#args + 1] = val
			end

			RunConsoleCommand(unpack(args))
		end)

		frame_query:Build()

		frame_query.Close = function(s)
			s:AlphaTo(0, 0.05)
			s:MoveTo(frame:GetX(), parent:GetY(), 0.1, 0, -1, function()
				s:Remove()
			end)
		end
	end

	showPlayers = function(data)
		if IsValid(frame_player) then
			frame_player:Close()
		end

		if IsValid(frame_query) then
			frame_query:Close()
		end

		local name = data:GetName()

		frame_player = vgui.Create("DFrame")
		frame_player:SetTitle("Choose player for " .. data:GetTitle())
		frame_player:SetSize(ScrW() / 3.5, ScrH() / 3.5)
		frame_player:SetPos(frame:GetPos())
		frame_player:MoveTo(frame_player:GetX() + frame_player:GetWide() + 16, frame_player:GetY(), 0.1)
		frame_player:MakePopup(true)

		frame_player.Close = function(s)
			if IsValid(frame_query) then
				frame_query:Close()
			end

			s:AlphaTo(0, 0.05)
			s:MoveTo(frame:GetX(), frame_player:GetY(), 0.1, 0, -1, function()
				s:Remove()
			end)
		end

		local fill = vgui.Create("DPanel", frame_player)
		fill:Dock(FILL)
		fill:DockMargin(2, 2, 2, 2)

		local scroll = vgui.Create("KScrollPanel", fill)
		scroll:Dock(LEFT)
		scroll:DockMargin(2, 2, 2, 2)
		scroll:SetWide(frame_player:GetWide())

		local layout = vgui.Create("DIconLayout", scroll)
		layout:Dock(FILL)
		layout:SetSpaceY(1)
		layout:SetSpaceX(1)

		local args = table.Copy(data:GetArgs())
		table.RemoveByValue(args, "Target")

		for _, pl in ipairs(player.GetAll()) do
			surface.SetFont("Default")
			local text = pl:Name()
			local text_w = surface.GetTextSize(text)

			local act = vgui.Create("DButton", layout)
			act:SetText(text)
			act:SetSize(text_w + 12, 24)
			act:SetFont("Default")
			act:SetTooltip(pl:GetTitle())

			act.DoClick = function()
				if #args > 0 then
					showQuery(name, args, pl)
					return
				end

				RunConsoleCommand("kate", name, pl:SteamID64())
			end
		end
	end

	net.Receive("Kate Menu", function()
		if IsValid(frame) then
			return
		end

		frame = vgui.Create("DFrame")
		frame:SetTitle("Kate Menu")
		frame:SetSize(ScrW() / 3.5, ScrH() / 3.5)
		frame:SetPos(-frame:GetWide(), ScrH() / 2 - (frame:GetWide() / 2))
		frame:MoveTo(32, frame:GetY(), 0.1)
		frame:MakePopup(true)

		frame.Close = function(s)
			if IsValid(frame_player) then
				frame_player:Close()
			end

			s:AlphaTo(0, 0.05)
			s:MoveTo(-frame:GetWide(), frame:GetY(), 0.1, 0, -1, function()
				s:Remove()
			end)
		end

		local fill = vgui.Create("DPanel", frame)
		fill:Dock(FILL)
		fill:DockMargin(2, 2, 2, 2)

		do
			local cmds, cats = kate.Commands.Stored, {}

			for _, cmd in pairs(cmds) do
				local cat = cmd:GetCategory()
				if not cats[cat] then
					cats[cat] = true
				end
			end

			local scroll = vgui.Create("KScrollPanel", fill)
			scroll:Dock(LEFT)
			scroll:DockMargin(2, 2, 2, 2)
			scroll:SetWide(frame:GetWide())

			for category in pairs(cats) do
				local cat = vgui.Create("DCollapsibleCategory", scroll)
				cat:Dock(TOP)
				cat:SetLabel(category)

				local layout = vgui.Create("DIconLayout", cat)
				layout:Dock(FILL)
				layout:SetSpaceY(1)
				layout:SetSpaceX(1)

				for cmd, data in pairs(cmds) do
					if (not data:GetVisible()) or (data:GetImmunity() > LocalPlayer():GetImmunity()) or data:GetAlias() or (data:GetCategory() ~= category) then
						continue
					end

					local args = data:GetArgs()
					local name = data:GetName()
					local icon = data:GetIcon()

					local act = vgui.Create("DButton", layout)
					act:SetText(data:GetTitle())
					act:SetSize(frame:GetWide() / 4 - 5, 24)
					act:SetFont("Default")
					act:SetTooltip("kate " .. cmd)

					if icon then
						act:SetIcon(icon)
					end

					act.DoClick = function()
						if #args > 0 then
							if table.HasValue(args, "Target") then
								showPlayers(data)
								return
							end

							showQuery(name, args)
							return
						end

						RunConsoleCommand("kate", name)
					end

					act.DoRightClick = function()
						if #args > 0 then
							showQuery(name, args)
							return
						end

						RunConsoleCommand("kate", data:GetName())
					end
				end

				cat:SetContents(layout)

				-- we don't need an empty category
				if #layout:GetChildren() == 0 then
					cat:Remove()
				end
			end
		end
	end)
end