do
	kate.Commands:Register("msg", function(self, pl, args)
		local target = args.target or pl
		local text = args.message

		kate.Message(target, 3, string.format("You've got a message from admin: %s", text))

		do
			local msg = string.format("%s has sent a message to %s: %s",
				kate.GetExecuter(pl),
				kate.GetTarget(target),
				text
			)

			kate.Print(msg)
			kate.Message(kate.GetAdmins(), 3, msg)
		end
	end)
	:SetTitle("Message")
	:SetCategory("Utilities")
	:SetIcon("icon16/bell.png")
	:SetImmunity(1000)
	:SetOnlineTarget(true)
	:SetArgs("Target", "Message")
	:AddAlias("message")
	:AddAlias("say")
	:AddAlias("asay")
end

do
	kate.Commands:Register("hp", function(self, pl, args)
		local target = args.target or pl
		local amt = args.amount or target:GetMaxHealth()

		target:SetHealth(amt)

		do
			local msg = string.format("%s has set %s health to %s",
				kate.GetExecuter(pl),
				amt,
				kate.GetTarget(target)
			)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Set health")
	:SetCategory("Utilities")
	:SetIcon("icon16/heart.png")
	:SetImmunity(2500)
	:SetOnlineTarget(true)
	:SetArgs("Target", "Amount")
	:SetOptionalArgs("Target", "Amount")
	:AddAlias("sethp")
	:AddAlias("health")
	:AddAlias("sethealth")
end

do
	kate.Commands:Register("ar", function(self, pl, args)
		local target = args.target or pl
		local amt = args.amount or target:GetMaxArmor()

		target:SetArmor(amt)

		do
			local msg = string.format("%s has set %s armor to %s",
				kate.GetExecuter(pl),
				amt,
				kate.GetTarget(target)
			)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Set armor")
	:SetCategory("Utilities")
	:SetIcon("icon16/shield.png")
	:SetImmunity(2500)
	:SetOnlineTarget(true)
	:SetArgs("Target", "Amount")
	:SetOptionalArgs("Target", "Amount")
	:AddAlias("setar")
	:AddAlias("armor")
	:AddAlias("setarmor")
end

do
	kate.Commands:Register("god", function(self, pl, args)
		local target = args.target or pl

		local god = target:HasGodMode()
		local toggle = toggle and "disabled" or "enabled"

		target:GodEnable(not god)

		do
			local msg = string.format("%s has %s god to %s",
				kate.GetExecuter(pl),
				toggle,
				kate.GetTarget(target)
			)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("God")
	:SetCategory("Utilities")
	:SetIcon("icon16/pill.png")
	:SetImmunity(10000)
	:SetOnlineTarget(true)
	:SetArgs("Target")
	:SetOptionalArgs("Target")
end

do
	kate.Commands:Register("cloak", function(self, pl, args)
		local target = args.target or pl
		local shouldCloak = not target:GetCloak()
		local toggle = shouldCloak and "enabled" or "disabled"

		target:SetCloak(shouldCloak)
		kate.CloakPlayer(pl, shouldCloak)

		do
			kate.Message(pl, 1, string.format("You've %s cloak to %s", toggle, kate.GetTarget(target)))

			if target ~= pl then
				kate.Message(target, 3, string.format("%s has %s cloak to you", kate.GetExecuter(pl), toggle))
			end
		end
	end)
	:SetTitle("Cloak")
	:SetCategory("Utilities")
	:SetIcon("icon16/eye.png")
	:SetImmunity(1000)
	:SetOnlineTarget(true)
	:SetArgs("Target")
	:SetOptionalArgs("Target")
end

do
	kate.Commands:Register("ammo", function(self, pl, args)
		local target = args.target or pl
		local amt = args.amount or 100
		local ammotype = args.ammotype

		local ammoTypeGiven

		if ammotype then
			ammoTypeGiven = game.GetAmmoTypes()[ammotype]

			pl:GiveAmmo(amt, ammotype, true)

			goto log
		else
			ammoTypeGiven = "every ammotype registered"

			for ammo in pairs(game.GetAmmoTypes()) do
				pl:GiveAmmo(amt, ammo, true)
			end

			goto log
		end

		::log::
		do
			local msg = string.format("%s has added %s ammo of %s to %s",
				kate.GetExecuter(pl),
				amt,
				ammoTypeGiven,
				kate.GetTarget(target)
			)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Give ammo")
	:SetCategory("Utilities")
	:SetIcon("icon16/bomb.png")
	:SetImmunity(5000)
	:SetOnlineTarget(true)
	:SetArgs("Target", "Amount", "AmmoType")
	:SetOptionalArgs("Target", "Amount",  "AmmoType")
	:AddAlias("addammo")
	:AddAlias("giveammo")
	:AddAlias("am")
end