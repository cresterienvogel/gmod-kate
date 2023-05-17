do
	kate.Commands.Register("menu", function(self, pl)
		net.Start("Kate Menu")
		net.Send(pl)
	end)
	:SetTitle("Menu")
	:SetCategory("Menus")
	:SetIcon("icon16/information.png")
	:SetVisible(false)
	:SetImmunity(0)
end

do
	kate.Commands.Register("players", function(self, pl)
		local query = kate.Data.DB:query("SELECT * FROM kate_users")

		query.onSuccess = function(_, data)
			for i, params in pairs(data) do
				for param, val in pairs(params) do
					if param == "joined" or param == "seen" then
						data[i][param] = os.date("%d %B %Y", val)
					end

					if param == "playtime" then
						local res = kate.ConvertTime(val)
						data[i][param] = res ~= "∞" and res or "less than 5 minutes"
					end
				end
			end

			local cmp = util.Compress(util.TableToJSON(data))
			local len = #cmp

			net.Start("Kate Players")
				net.WriteUInt(len, 16)
				net.WriteData(cmp, len)
			net.Send(pl)
		end

		query:start()
	end)
	:SetTitle("Players")
	:SetCategory("Menus")
	:AddAlias("playtime")
	:SetIcon("icon16/information.png")
	:SetImmunity(0)
end

do
	kate.Commands.Register("bans", function(self, pl)
		local query = kate.Data.DB:query("SELECT * FROM kate_bans")

		query.onSuccess = function(_, data)
			for i, params in pairs(data) do
				for param, val in pairs(params) do
					if param:find("ban_time") then
						data[i][param] = os.date("%d %B %Y", val)
					end
				end
			end

			local cmp = util.Compress(util.TableToJSON(data))
			local len = #cmp

			net.Start("Kate Bans")
				net.WriteUInt(len, 16)
				net.WriteData(cmp, len)
			net.Send(pl)
		end

		query:start()
	end)
	:SetTitle("Bans")
	:SetCategory("Menus")
	:AddAlias("restrictions")
	:SetIcon("icon16/information.png")
	:SetImmunity(1000)
end

do
	for _, tag in ipairs({"Gag", "Mute"}) do
		local low_tag = tag:lower()
		local tbl = "kate_" .. low_tag .. "s"

		kate.Commands.Register(low_tag .. "s", function(self, pl)
			local query = kate.Data.DB:query("SELECT * FROM " .. tbl)

			query.onSuccess = function(_, data)
				for i, params in pairs(data) do
					for param, val in pairs(params) do
						if param == "expire_time" then
							data[i][param] = os.date("%d %B %Y", val)
						end
					end
				end

				local cmp = util.Compress(util.TableToJSON(data))
				local len = #cmp

				net.Start("Kate " .. tag .. "s")
					net.WriteUInt(len, 16)
					net.WriteData(cmp, len)
				net.Send(pl)
			end

			query:start()
		end)
		:SetTitle(tag .. "s")
		:SetCategory("Menus")
		:SetIcon("icon16/information.png")
		:SetImmunity(1000)
	end
end