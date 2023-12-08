do
	kate.Commands:Register("slay", function(self, pl, args)
		local target = args.target or pl

		target:Kill()

		do
			local msg = string.format("%s has slayed %s",
				kate.GetExecuter(pl),
				kate.GetTarget(target)
			)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Slay")
	:SetCategory("Kidding")
	:SetIcon("icon16/cross.png")
	:SetImmunity(2500)
	:SetOnlineTarget(true)
	:SetArgs("Target")
	:SetOptionalArgs("Target")
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

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Set model")
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
			local msg = string.format("%s has set %s model scale to %s",
				kate.GetExecuter(pl),
				scale,
				kate.GetTarget(target)
			)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Set scale")
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

		local frozen = target:IsFrozen()
		local toggle = frozen and "unfrozen" or "frozen"

		target:Freeze(not frozen)

		do
			local msg = string.format("%s has %s %s",
				kate.GetExecuter(pl),
				toggle,
				kate.GetTarget(target)
			)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Freeze")
	:SetCategory("Kidding")
	:SetIcon("icon16/status_offline.png")
	:SetImmunity(1000)
	:SetOnlineTarget(true)
	:SetArgs("Target")
	:SetOptionalArgs("Target")
end

do
	kate.Commands:Register("strip", function(self, pl, args)
		local target = args.target or pl
		local wep = args.weapon
		local stripped_weapon

		if wep then
			stripped_weapon = weapons.Get(wep) and weapons.Get(wep).PrintName or wep
			target:StripWeapon(wep)
			goto log
		end

		stripped_weapon = "all weapons"
		target:StripWeapons()

		::log::
		do
			local msg = string.format("%s has stripped %s from %s",
				kate.GetExecuter(pl),
				stripped_weapon,
				kate.GetTarget(target)
			)

			kate.Print(msg)
			kate.Message(kate.GetAdmins(), 3, msg)
		end
	end)
	:SetTitle("Strip")
	:SetCategory("Kidding")
	:SetIcon("icon16/gun.png")
	:SetImmunity(5000)
	:SetOnlineTarget(true)
	:SetArgs("Target", "Weapon")
	:SetOptionalArgs("Target", "Weapon")
end

do
	kate.Commands:Register("ignite", function(self, pl, args)
		local target = args.target or pl
		local time = args.time or 10
		local msg

		if target:IsOnFire() then
			msg = "%s has extinguished %s"
			target:Extinguish()
			goto log
		end

		msg = "%s has ignited %s for %s"
		target:Ignite(time)

		::log::
		do
			msg = string.format(msg,
				kate.GetExecuter(pl),
				kate.GetTarget(target),
				kate.ConvertTime(time)
			)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Ignite")
	:SetCategory("Kidding")
	:SetIcon("icon16/lightning.png")
	:SetImmunity(2500)
	:SetOnlineTarget(true)
	:SetArgs("Target", "Time")
	:SetOptionalArgs("Target", "Time")
end