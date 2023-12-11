do
	kate.Commands:Register("menu", function(self, pl)
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
	kate.Commands:Register("players", function(self, pl)
		local query = kate.Data.DB:query("SELECT * FROM kate_users")

		query.onSuccess = function(_, data)
			for i, params in pairs(data) do
				for param, val in pairs(params) do
					if param == "first_join" then
						data[i][param] = os.date("%d %B %Y at %H:%M", val)
					end

					if param == "last_seen" then
						data[i][param] = os.date("%d %B %Y at %H:%M", val)
					end

					if param == "play_time" then
						local res = kate.ConvertTime(val)
						data[i][param] = (res ~= "∞") and res or "less than 5 minutes"
					end
				end
			end

			local cmp = util.Compress(util.TableToJSON(data))
			local len = #cmp

			net.Start("Kate Players")
				net.WriteUInt(len, 32)
				net.WriteData(cmp, len)
			net.Send(pl)
		end

		query:start()
	end)
	:SetTitle("Players")
	:SetCategory("Menus")
	:SetIcon("icon16/information.png")
	:SetImmunity(0)
	:AddAlias("playtime")
end

do
	kate.Commands:Register("bans", function(self, pl)
		local query = kate.Data.DB:query("SELECT * FROM kate_bans")

		query.onSuccess = function(_, data)
			for i, params in pairs(data) do
				for param, val in pairs(params) do
					if string.find(param, "time") then
						data[i][param] = os.date("%d %B %Y at %H:%M", val)
					end
				end
			end

			local cmp = util.Compress(util.TableToJSON(data))
			local len = #cmp

			net.Start("Kate Bans")
				net.WriteUInt(len, 32)
				net.WriteData(cmp, len)
			net.Send(pl)
		end

		query:start()
	end)
	:SetTitle("Bans")
	:SetCategory("Menus")
	:SetIcon("icon16/information.png")
	:SetImmunity(1000)
	:AddAlias("restrictions")
end

do
	for _, tag in ipairs({"Gag", "Mute"}) do
		local tagLower = string.lower(tag)
		local tbl = "kate_" .. tagLower .. "s"

		kate.Commands:Register(tagLower .. "s", function(self, pl)
			local query = kate.Data.DB:query("SELECT * FROM " .. tbl)

			query.onSuccess = function(_, data)
				for i, params in pairs(data) do
					for param, val in pairs(params) do
						if string.find(param, "time") then
							data[i][param] = os.date("%d %B %Y at %H:%M", val)
						end
					end
				end

				local cmp = util.Compress(util.TableToJSON(data))
				local len = #cmp

				net.Start("Kate " .. tag .. "s")
					net.WriteUInt(len, 32)
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