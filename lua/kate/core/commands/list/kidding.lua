do
	kate.Commands.Register("slay", function(self, pl, args)
		local target = kate.FindPlayer(args[1])
		if not IsValid(target) then
			kate.Message(pl, 2, "Target not found")
			return
		end

		target:Kill()

		do
			local msg = kate.GetExecuter(pl) .. " has slayed " .. kate.GetTarget(target)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Slay")
	:SetCategory("Kidding")
	:SetIcon("icon16/cross.png")
	:SetImmunity(2500)
	:AddAlias("kill")
	:SetArgs("Target")
end

do
	kate.Commands.Register("model", function(self, pl, args)
		local target = kate.FindPlayer(args[1])
		if not IsValid(target) then
			kate.Message(pl, 2, "Target not found")
			return
		end

		local model = args[2]
		if not (model and util.IsValidModel(model)) then
			kate.Message(pl, 2, "Invalid model")
			return
		end

		target:SetModel(model)

		do
			local msg = kate.GetExecuter(pl) .. " has set " .. model .. " model to " .. kate.GetTarget(target)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Set model")
	:SetCategory("Kidding")
	:SetIcon("icon16/status_online.png")
	:SetImmunity(10000)
	:AddAlias("setmodel")
	:SetArgs("Target", "Model")
end

do
	kate.Commands.Register("size", function(self, pl, args)
		local target = kate.FindPlayer(args[1])
		if not IsValid(target) then
			kate.Message(pl, 2, "Target not found")
			return
		end

		local scale = args[2]
		if not scale then
			kate.Message(pl, 2, "Invalid scale")
			return
		end

		target:SetModelScale(scale)

		do
			local msg = kate.GetExecuter(pl) .. " has set " .. scale .. " model scale to " .. kate.GetTarget(target)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Set scale")
	:SetCategory("Kidding")
	:SetIcon("icon16/arrow_up.png")
	:SetImmunity(10000)
	:AddAlias("scale")
	:AddAlias("setscale")
	:AddAlias("setsize")
	:SetArgs("Target", "Scale")
end

do
	kate.Commands.Register("freeze", function(self, pl, args)
		local target = kate.FindPlayer(args[1])
		if not IsValid(target) then
			kate.Message(pl, 2, "Target not found")
			return
		end

		local frozen = target:IsFrozen()
		local typ = frozen and "unfrozen" or "frozen"
		target:Freeze(not frozen)

		do
			local msg = kate.GetExecuter(pl) .. " has " .. typ .. " " .. kate.GetTarget(target)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Freeze")
	:SetCategory("Kidding")
	:SetIcon("icon16/status_offline.png")
	:SetImmunity(1000)
	:SetArgs("Target")
end

do
	kate.Commands.Register("strip", function(self, pl, args)
		local target = kate.FindPlayer(args[1])
		if not IsValid(target) then
			kate.Message(pl, 2, "Target not found")
			return
		end

		local typ
		local wep = args[2]
		if wep then
			if not target:HasWeapon(wep) then
				kate.Message(pl, 2, "Target has no such weapon")
				return
			end
			target:StripWeapon(wep)
			typ = weapons.Get(wep) and weapons.Get(wep).PrintName or wep
		else
			target:StripWeapons()
			typ = "all weapons"
		end

		do
			local msg = kate.GetExecuter(pl) .. " stripped " .. typ .. " from " .. kate.GetTarget(target)

			kate.Print(msg)
			kate.Message(kate.GetAdmins(), 3, msg)
		end
	end)
	:SetTitle("Strip")
	:SetCategory("Kidding")
	:SetIcon("icon16/gun.png")
	:SetImmunity(5000)
	:SetArgs("Target")
end

do
	kate.Commands.Register("ignite", function(self, pl, args)
		local target = kate.FindPlayer(args[1])
		if not IsValid(target) then
			kate.Message(pl, 2, "Target not found")
			return
		end

		local msg
		if target:IsOnFire() then
			msg = kate.GetExecuter(pl) .. " has extinguished " .. kate.GetTarget(target)

			target:Extinguish()
		else
			if not args[2] then
				kate.Message(pl, 2, "Invalid time")
				return
			end

			local time_valid, time = kate.FormatTime(args[2])

			if not time_valid then
				kate.Message(pl, 2, "Invalid time")
				return
			end

			msg = kate.GetExecuter(pl) .. " has ignited " .. kate.GetTarget(target) .. " for " .. kate.ConvertTime(time)

			target:Ignite(time)
		end

		do
			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Ignite")
	:SetCategory("Kidding")
	:SetIcon("icon16/lightning.png")
	:SetImmunity(2500)
	:SetArgs("Target", "Time")
end