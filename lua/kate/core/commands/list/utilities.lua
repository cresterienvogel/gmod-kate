do
	kate.Commands.Register("msg", function(self, pl, args)
		local target = kate.FindPlayer(args[1])
		if not IsValid(target) then
			kate.Message(pl, 2, "Target not found")
			return
		end

		local text = table.concat(args, " ", 2)
		if text == "" then
			kate.Message(pl, 2, "Invalid message")
			return
		end

		kate.Message(target, 3, text)

		do
			local msg = kate.GetExecuter(pl) .. " has sent a message to " .. kate.GetTarget(target) .. " with contents " .. text

			kate.Print(msg)
			kate.Message(kate.GetAdmins(), 3, msg)
		end
	end)
	:SetTitle("Message")
	:SetCategory("Utilities")
	:SetIcon("icon16/bell.png")
	:SetImmunity(1000)
	:AddAlias("message")
	:AddAlias("say")
	:AddAlias("asay")
	:SetArgs("Target", "Text")
end

do
	kate.Commands.Register("hp", function(self, pl, args)
		local target = kate.FindPlayer(args[1])
		if not IsValid(target) then
			kate.Message(pl, 2, "Target not found")
			return
		end

		local amt = args[2]
		if not amt or tonumber(amt) <= 0 then
			kate.Message(pl, 2, "Invalid amount")
			return
		end

		target:SetHealth(amt)

		do
			local msg = kate.GetExecuter(pl) .. " has set " .. amt .. " health to" .. kate.GetTarget(target)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Set health")
	:SetCategory("Utilities")
	:SetIcon("icon16/heart.png")
	:SetImmunity(2500)
	:AddAlias("sethp")
	:AddAlias("health")
	:AddAlias("sethealth")
	:SetArgs("Target", "Amount")
end

do
	kate.Commands.Register("ar", function(self, pl, args)
		local target = kate.FindPlayer(args[1])
		if not IsValid(target) then
			kate.Message(pl, 2, "Target not found")
			return
		end

		local amt = args[2]
		if not amt or tonumber(amt) <= 0 then
			kate.Message(pl, 2, "Invalid amount")
			return
		end

		target:SetArmor(amt)

		do
			local msg = kate.GetExecuter(pl) .. " has set " .. amt .. " armor to" .. kate.GetTarget(target)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Set armor")
	:SetCategory("Utilities")
	:SetIcon("icon16/shield.png")
	:SetImmunity(2500)
	:AddAlias("setar")
	:AddAlias("armor")
	:AddAlias("setarmor")
	:SetArgs("Target", "Amount")
end

do
	kate.Commands.Register("god", function(self, pl, args)
		local target = kate.FindPlayer(args[1])
		if not IsValid(target) then
			kate.Message(pl, 2, "Target not found")
			return
		end

		local god = target:HasGodMode()
		local typ = god and "disabled" or "enabled"
		target:GodEnable(not god)

		do
			local msg = kate.GetExecuter(pl) .. " has " .. typ .. " god to " .. kate.GetTarget(target)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("God")
	:SetCategory("Utilities")
	:SetIcon("icon16/pill.png")
	:SetImmunity(10000)
	:SetArgs("Target")
end

do
	kate.Commands.Register("cloak", function(self, pl, args)
		local target = kate.FindPlayer(args[1])
		if not IsValid(target) then
			kate.Message(pl, 2, "Target not found")
			return
		end

		local cloaked = target:GetKateVar("Cloak")
		local typ = target:GetKateVar("Cloak") and "disabled" or "enabled"

		target:SetKateVar("Cloak", not cloaked)
		target:SetNoDraw(not cloaked)

		for _, v in ipairs(target:GetWeapons()) do
			v:SetNoDraw(not cloaked)
		end

		for _, v in ipairs(ents.FindByClass("physgun_beam")) do
			if v:GetParent() == target then
				v:SetNoDraw(not cloaked)
			end
		end

		do
			kate.Message(pl, 1, "You've " .. typ .. " cloak to " .. kate.GetTarget(target))
			kate.Message(target, 3, kate.GetExecuter(pl) .. " has " .. typ .. " cloak to you")
		end
	end)
	:SetTitle("Cloak")
	:SetCategory("Utilities")
	:SetIcon("icon16/eye.png")
	:SetImmunity(1000)
	:SetArgs("Target")
end

do
	kate.Commands.Register("ammo", function(self, pl, args)
		local target = kate.FindPlayer(args[1])
		if not IsValid(target) then
			kate.Message(pl, 2, "Target not found")
			return
		end

		local amt = args[2]
		if not amt then
			kate.Message(pl, 2, "Invalid amount")
			return
		end

		local name = table.concat(args, " ", 3)
		if name == "" then
			name = "every ammotype registered"
			for ammo in pairs(game.GetAmmoTypes()) do
				pl:GiveAmmo(amt, ammo, true)
			end
		else
			local given = target:GiveAmmo(amt, name)
			if given == 0 then
				kate.Message(pl, 2, "Invalid ammotype")
				return
			end
		end

		do
			local msg = kate.GetExecuter(pl) .. " has added " .. amt .. " ammo of " .. name .. " to " .. kate.GetTarget(target)

			kate.Print(msg)
			kate.Message(player.GetAll(), 3, msg)
		end
	end)
	:SetTitle("Give ammo")
	:SetCategory("Utilities")
	:SetIcon("icon16/bomb.png")
	:SetImmunity(5000)
	:AddAlias("addammo")
	:AddAlias("giveammo")
	:AddAlias("am")
	:SetArgs("Target", "Amount", "Type")
end