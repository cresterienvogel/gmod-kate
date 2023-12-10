if SERVER then
	util.AddNetworkString("Kate Menu")
end

if CLIENT then
	local frame, frameQuery, framePlayer
	local showQuery, showPlayers

	showQuery = function(command, queries, pl)
		if IsValid(frameQuery) then
			frameQuery:Close()
		end

		local parent = IsValid(framePlayer) and framePlayer or frame

		frameQuery = vgui.Create("KQuery")
		frameQuery:SetTitle(string.format("Fill args for %s", kate.Commands.Stored[command]:GetTitle()))
		frameQuery:SetSize(ScrW() / 3.5, ScrH() / 3.5)
		frameQuery:SetPos(parent:GetPos())
		frameQuery:MoveTo(parent:GetX() + frameQuery:GetWide() + 16, parent:GetY(), 0.1)

		frameQuery:SetQueries(queries)

		frameQuery:SetFunction(function()
			local args = {"kate", command}

			if pl then
				local id = kate.SteamIDTo64(pl)

				if id then
					args[#args + 1] = id
				end
			end

			for query, val in pairs(frameQuery:GetQueries()) do
				args[#args + 1] = val
			end

			RunConsoleCommand(unpack(args))
		end)

		frameQuery:Build()

		frameQuery.Close = function(s)
			s:AlphaTo(0, 0.05)
			s:MoveTo(frame:GetX(), parent:GetY(), 0.1, 0, -1, function()
				s:Remove()
			end)
		end
	end

	showPlayers = function(data)
		if IsValid(framePlayer) then
			framePlayer:Close()
		end

		if IsValid(frameQuery) then
			frameQuery:Close()
		end

		local name = data:GetName()

		framePlayer = vgui.Create("DFrame")
		framePlayer:SetTitle(string.format("Choose player for %s", data:GetTitle()))
		framePlayer:SetSize(ScrW() / 3.5, ScrH() / 3.5)
		framePlayer:SetPos(frame:GetPos())
		framePlayer:MoveTo(framePlayer:GetX() + framePlayer:GetWide() + 16, framePlayer:GetY(), 0.1)
		framePlayer:MakePopup(true)

		framePlayer.Close = function(s)
			if IsValid(frameQuery) then
				frameQuery:Close()
			end

			s:AlphaTo(0, 0.05)
			s:MoveTo(frame:GetX(), framePlayer:GetY(), 0.1, 0, -1, function()
				s:Remove()
			end)
		end

		local fill = vgui.Create("DPanel", framePlayer)
		fill:Dock(FILL)
		fill:DockMargin(2, 2, 2, 2)

		local scroll = vgui.Create("KScrollPanel", fill)
		scroll:Dock(LEFT)
		scroll:DockMargin(2, 2, 2, 2)
		scroll:SetWide(framePlayer:GetWide())

		local layout = vgui.Create("DIconLayout", scroll)
		layout:Dock(FILL)
		layout:SetSpaceY(1)
		layout:SetSpaceX(1)

		local args = table.Copy(data:GetArgs())
		table.RemoveByValue(args, "Target")

		for _, pl in ipairs(player.GetAll()) do
			surface.SetFont("Default")
			local text = pl:Name()
			local textWidth = surface.GetTextSize(text)

			local act = vgui.Create("DButton", layout)
			act:SetText(text)
			act:SetSize(textWidth + 12, 24)
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
			if IsValid(framePlayer) then
				framePlayer:Close()
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
					act:SetTooltip(string.format("kate %s", cmd))

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