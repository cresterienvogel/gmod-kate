if SERVER then
	util.AddNetworkString("Kate Menu")
else
	local fr, qfr, pfr
	local showQuery, showPlayers

	showQuery = function(command, queries, pl)
		if IsValid(qfr) then
			qfr:Close()
		end

		local parent = IsValid(pfr) and pfr or fr

		qfr = vgui.Create("KQuery")
		qfr:SetTitle("Fill args for " .. kate.Commands.Stored[command]:GetTitle())
		qfr:SetSize(ScrW() / 4.5, ScrH() / 4)
		qfr:SetPos(parent:GetPos())
		qfr:MoveTo(parent:GetX() + qfr:GetWide() + 16, parent:GetY(), 0.1)

		if pl then
			qfr:SetPlayer(pl)
		end

		qfr:SetQueries(queries)

		qfr:SetFunction(function()
			local args = {"kate", command}

			if pl then
				local id = kate.SteamIDTo64(pl)
				if id then
					args[#args + 1] = id
				end
			end

			for query, val in pairs(qfr:GetQueries()) do
				args[#args + 1] = val
			end

			RunConsoleCommand(unpack(args))
		end)

		qfr:Build()

		qfr.Close = function(s)
			s:AlphaTo(0, 0.05)
			s:MoveTo(fr:GetX(), parent:GetY(), 0.1, 0, -1, function()
				s:Remove()
			end)
		end
	end

	showPlayers = function(data)
		do
			if IsValid(pfr) then
				pfr:Close()
			end

			if IsValid(qfr) then
				qfr:Close()
			end
		end

		local name = data:GetName()

		pfr = vgui.Create("DFrame")
		pfr:SetTitle("Choose player for " .. data:GetTitle())
		pfr:SetSize(ScrW() / 4.5, ScrH() / 4)
		pfr:SetPos(fr:GetPos())
		pfr:MoveTo(pfr:GetX() + pfr:GetWide() + 16, pfr:GetY(), 0.1)
		pfr:MakePopup(true)

		pfr.Close = function(s)
			if IsValid(qfr) then
				qfr:Close()
			end

			s:AlphaTo(0, 0.05)
			s:MoveTo(fr:GetX(), pfr:GetY(), 0.1, 0, -1, function()
				s:Remove()
			end)
		end

		local fill = vgui.Create("DPanel", pfr)
		fill:Dock(FILL)
		fill:DockMargin(2, 2, 2, 2)

		local scroll = vgui.Create("KScrollPanel", fill)
		scroll:Dock(LEFT)
		scroll:DockMargin(2, 2, 2, 2)
		scroll:SetWide(pfr:GetWide())

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
				else
					RunConsoleCommand("kate", name, pl:SteamID64())
				end
			end
		end
	end

	net.Receive("Kate Menu", function()
		if IsValid(fr) then
			return
		end

		fr = vgui.Create("DFrame")
		fr:SetTitle("Kate Menu")
		fr:SetSize(ScrW() / 4.5, ScrH() / 4)
		fr:SetPos(-fr:GetWide(), ScrH() / 2 - (fr:GetWide() / 2))
		fr:MoveTo(32, fr:GetY(), 0.1)
		fr:MakePopup(true)

		fr.Close = function(s)
			if IsValid(pfr) then
				pfr:Close()
			end

			s:AlphaTo(0, 0.05)
			s:MoveTo(-fr:GetWide(), fr:GetY(), 0.1, 0, -1, function()
				s:Remove()
			end)
		end

		local fill = vgui.Create("DPanel", fr)
		fill:Dock(FILL)
		fill:DockMargin(2, 2, 2, 2)

		do
			local cmds = kate.Commands.Stored

			local cats = {}
			for _, cmd in pairs(cmds) do
				local cat = cmd:GetCategory()
				if not cats[cat] then
					cats[cat] = true
				end
			end

			local scroll = vgui.Create("KScrollPanel", fill)
			scroll:Dock(LEFT)
			scroll:DockMargin(2, 2, 2, 2)
			scroll:SetWide(fr:GetWide())

			for category in pairs(cats) do
				local cat = vgui.Create("DCollapsibleCategory", scroll)
				cat:Dock(TOP)
				cat:SetLabel(category)

				local layout = vgui.Create("DIconLayout", cat)
				layout:Dock(FILL)
				layout:SetSpaceY(1)
				layout:SetSpaceX(1)

				for cmd, data in pairs(cmds) do
					if not data:GetVisible() or data:GetImmunity() > LocalPlayer():GetImmunity() or data:GetAlias() or data:GetCategory() ~= category then
						continue
					end

					local args = data:GetArgs()
					local name = data:GetName()

					local act = vgui.Create("DButton", layout)
					act:SetText(data:GetTitle())
					act:SetSize(fr:GetWide() / 4 - 5, 24)
					act:SetFont("Default")
					act:SetTooltip("kate " .. cmd)

					local icon = data:GetIcon()
					if icon then
						act:SetIcon(icon)
					end

					act.DoClick = function()
						if #args > 0 then
							if table.HasValue(args, "Target") then
								showPlayers(data)
							else
								showQuery(name, args)
							end
						else
							RunConsoleCommand("kate", name)
						end
					end

					act.DoRightClick = function()
						if #args > 0 then
							showQuery(name, args)
						else
							RunConsoleCommand("kate", data:GetName())
						end
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