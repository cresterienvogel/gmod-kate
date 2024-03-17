do
	kate.Commands:Register("slay", function(self, pl, args)
		local target = args.target or pl
		local reason = args.reason

		target:Kill()

		do
			local text = "%s has slayed %s"
			if reason then
				text = text .. ": %s"
			end

			local msg = string.format(text,
				kate.GetExecuter(pl),
				kate.GetTarget(target),
				reason
			)

			kate.Print(3, msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Slay")
	:SetCategory("Kidding")
	:SetIcon("icon16/cross.png")
	:SetImmunity(2500)
	:SetOnlineTarget(true)
	:SetArgs("Target", "Reason")
	:SetOptionalArgs("Target", "Reason")
	:AddAlias("kill")
end

do
	kate.Commands:Register("model", function(self, pl, args)
		local target = args.target
		local model = args.model

		target:SetModel(model)

		do
			local msg = string.format("%s has set %s model to %s",
				kate.GetExecuter(pl),
				model,
				kate.GetTarget(target)
			)

			kate.Print(3, msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Model")
	:SetCategory("Kidding")
	:SetIcon("icon16/status_online.png")
	:SetImmunity(10000)
	:SetOnlineTarget(true)
	:SetArgs("Target", "Model")
	:AddAlias("setmodel")
end

do
	kate.Commands:Register("size", function(self, pl, args)
		local target = args.target or pl
		local scale = args.unsigned_amount or 1

		target:SetModelScale(scale)

		do
			local msg = string.format("%s has set model scale %s to %s",
				kate.GetExecuter(pl),
				scale,
				kate.GetTarget(target)
			)

			kate.Print(3, msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Scale")
	:SetCategory("Kidding")
	:SetIcon("icon16/arrow_up.png")
	:SetImmunity(10000)
	:SetOnlineTarget(true)
	:SetArgs("Target", "Unsigned Amount")
	:SetOptionalArgs("Target", "Unsigned Amount")
	:AddAlias("scale")
	:AddAlias("setscale")
	:AddAlias("setsize")
end

do
	kate.Commands:Register("freeze", function(self, pl, args)
		local target = args.target or pl
		local reason = args.reason

		local frozen = target:IsFrozen()
		local toggle = frozen and "unfrozen" or "frozen"

		target:Freeze(not frozen)

		do
			local text = "%s has %s %s"
			if reason then
				text = text .. ": %s"
			end

			local msg = string.format(text,
				kate.GetExecuter(pl),
				toggle,
				kate.GetTarget(target),
				reason
			)

			kate.Print(3, msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Freeze")
	:SetCategory("Kidding")
	:SetIcon("icon16/status_offline.png")
	:SetImmunity(1000)
	:SetOnlineTarget(true)
	:SetArgs("Target", "Reason")
	:SetOptionalArgs("Target", "Reason")
end

do
	kate.Commands:Register("strip", function(self, pl, args)
		local target = args.target or pl
		local weapon = args.weapon
		local reason = args.reason

		local strippedWep
		if weapon then
			strippedWep = weapons.Get(weapon) and weapons.Get(weapon).PrintName or weapon
			target:StripWeapon(weapon)

			goto log
		end

		strippedWep = "all weapons"
		target:StripWeapons()

		::log::
		do
			local text = "%s has stripped %s from %s"
			if reason then
				text = text .. ": %s"
			end

			local msg = string.format(text,
				kate.GetExecuter(pl),
				strippedWep,
				kate.GetTarget(target),
				reason
			)

			kate.Print(3, msg)
			kate.Message(kate.GetAdmins(), 3, msg)
		end
	end)
	:SetTitle("Strip")
	:SetCategory("Kidding")
	:SetIcon("icon16/gun.png")
	:SetImmunity(5000)
	:SetOnlineTarget(true)
	:SetArgs("Target", "Weapon", "Reason")
	:SetOptionalArgs("Target", "Weapon", "Reason")
end

do
	kate.Commands:Register("ignite", function(self, pl, args)
		local target = args.target or pl
		local time = args.time or 10
		local reason = args.reason

		local msg
		if target:IsOnFire() then
			msg = "%s has extinguished %s"
			target:Extinguish()
			goto log
		end

		msg = "%s has ignited %s for %s"
		if reason then
			msg = msg .. ": %s"
		end

		target:Ignite(time)

		::log::
		do
			msg = string.format(msg,
				kate.GetExecuter(pl),
				kate.GetTarget(target),
				kate.ConvertTime(time),
				reason
			)

			kate.Print(3, msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Ignite")
	:SetCategory("Kidding")
	:SetIcon("icon16/lightning.png")
	:SetImmunity(2500)
	:SetOnlineTarget(true)
	:SetArgs("Target", "Time", "Reason")
	:SetOptionalArgs("Target", "Time", "Reason")
end