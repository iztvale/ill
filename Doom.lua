local Doom = {}

Doom.optionEnable = Menu.AddOptionBool({"Hero Specific","Doom"},"Enabled",false)
Menu.AddMenuIcon({"Hero Specific", "Doom"}, "panorama/images/heroes/icons/npc_dota_hero_doom_bringer_png.vtex_c")
Doom.optionAutoDevour = Menu.AddOptionBool({"Hero Specific", "Doom"}, "Auto Devour", false)
Doom.optionAutoDoom = Menu.AddOptionBool({"Hero Specific", "Doom"}, "Auto Doom", false)
Doom.optionToggleKey = Menu.AddKeyOption({"Hero Specific", "Doom"}, "Auto Toggle Key", Enum.ButtonCode.KEY_S)
Doom.optionKey = Menu.AddKeyOption({"Hero Specific","Doom"},"Non-Ult Combo Key",Enum.ButtonCode.KEY_D)
Doom.optionKey2 = Menu.AddKeyOption({"Hero Specific","Doom"},"Ult Combo Key",Enum.ButtonCode.KEY_F)
Doom.optionBlink = Menu.AddOptionBool({"Hero Specific", "Doom" }, "Use Blink to Initiate", false)
Doom.optionMinimumBlinkRange = Menu.AddOptionSlider({"Hero Specific", "Doom"}, "Minimum Blink Range", 300, 1100, 500)
Doom.optionBlinkRange = Menu.AddOptionSlider({"Hero Specific", "Doom" }, "Set Safe Blink Initiation Range", 100, 500, 100)
--Skills Toggle Menu--
Doom.optionEnableScorched = Menu.AddOptionBool({"Hero Specific","Doom","Skills"},"Use Scorched Earth",false)
Doom.optionEnableInfernal = Menu.AddOptionBool({"Hero Specific","Doom","Skills"},"Use Infernal Blade",false)
Doom.optionEnableUlt = Menu.AddOptionBool({"Hero Specific","Doom","Skills"},"Use Doom Ult",false)
Doom.optionEnableCreepIceArmor = Menu.AddOptionBool({"Hero Specific","Doom","Skills"},"Use Creep Ice Armor",false)
Doom.optionEnableCreepKentStun = Menu.AddOptionBool({"Hero Specific","Doom","Skills"},"Use Creep Kent Stun",false)
Doom.optionEnableCreepManaburn = Menu.AddOptionBool({"Hero Specific","Doom","Skills"},"Use Creep Manaburn",false)
Doom.optionEnableCreepNet = Menu.AddOptionBool({"Hero Specific","Doom","Skills"},"Use Creep Net",false)
Doom.optionEnableCreepRockStun = Menu.AddOptionBool({"Hero Specific","Doom","Skills"},"Use Creep Rock Stun",false)
Doom.optionEnableCreepShock = Menu.AddOptionBool({"Hero Specific","Doom","Skills"},"Use Creep Lightning",false)
Doom.optionEnableCreepSWave = Menu.AddOptionBool({"Hero Specific","Doom","Skills"},"Use Creep Shock Wave",false)
Doom.optionEnableCreepTClap = Menu.AddOptionBool({"Hero Specific","Doom","Skills"},"Use Creep ThunderClap",false)
Doom.optionEnableProwlerStomp = Menu.AddOptionBool({"Hero Specific","Doom","Skills"},"Use Ancient Prowler Stomp",false)
Doom.optionEnableThunderFrenzy = Menu.AddOptionBool({"Hero Specific","Doom","Skills"},"Use Ancient Lizard Frenzy",false)
--Items Toggle Menu--
Doom.optionEnableHalberd = Menu.AddOptionBool({"Hero Specific","Doom","Items"},"Use Halberd",false)
Doom.optionEnableScythe = Menu.AddOptionBool({"Hero Specific","Doom","Items"},"Use Scythe",false)
Doom.optionEnableShadowBlade = Menu.AddOptionBool({"Hero Specific", "Doom","Items"},"Use Shadow Blade",false)
Doom.optionEnableShivas = Menu.AddOptionBool({"Hero Specific","Doom","Items"},"Use Shivas",false)
Doom.optionEnableSilverEdge = Menu.AddOptionBool({"Hero Specific", "Doom","Items"},"Use Silver Edge",false)
Doom.optionEnableUrn = Menu.AddOptionBool({"Hero Specific", "Doom", "Items"},"Use Urn of Shadows", false)
Doom.optionEnableVessel = Menu.AddOptionBool({"Hero Specific", "Doom", "Items"}, "Use Spirit Vessel", false)
Doom.optionEnableOrchid = Menu.AddOptionBool({"Hero Specific", "Doom", "Items"}, "Use Orchid", false)
Doom.optionEnableBlood = Menu.AddOptionBool({"Hero Specific", "Doom", "Items"}, "Use Bloodthorn", false)
Doom.optionEnableVeil = Menu.AddOptionBool({"Hero Specific", "Doom", "Items"}, "Use Veil of Discord", false)
Doom.optionEnableNullifier = Menu.AddOptionBool({"Hero Specific", "Doom", "Items"}, "Use Nullifier", false)

local AutoMode = false
local font = Renderer.LoadFont("Tahoma", 20, Enum.FontWeight.EXTRABOLD)

Doom.lastTick = 0
Doom.delay = 0
Doom.lastAttackTime = 0
Doom.lastAttackTime2 = 0
Doom.LastTarget = nil

function Doom.ResetGlobalVariables()
    Doom.lastTick = 0
	Doom.delay = 0
	Doom.lastAttackTime = 0
	Doom.lastAttackTime2 = 0
	Doom.LastTarget = nil
end

function Doom.OnUpdate()
	local myHero = Heroes.GetLocal()
    if not myHero then return end
    
    if not Menu.IsEnabled(Doom.optionEnable) then return true end
	if Menu.IsKeyDown(Doom.optionKey) then
    Doom.Combo()
	end
	
	if not Menu.IsEnabled(Doom.optionEnable) then return true end
	if Menu.IsKeyDown(Doom.optionKey2) then
    Doom.UltCombo()
	end
	
	if Menu.IsKeyDownOnce(Doom.optionToggleKey) then
    	AutoMode = not AutoMode
	end

	if Menu.IsEnabled(Doom.optionAutoDoom) and AutoMode then
    	Doom.AutoDoom(myHero)
	end
	
	if Menu.IsEnabled(Doom.optionAutoDevour) and AutoMode then
    	Doom.AutoDevourRanged(myHero)
	end
	
	if not Engine.IsInGame() then
	Doom.ResetGlobalVariables()
	end
end	

function Doom.castPrediction(myHero, enemy, adjustmentVariable)

	if not myHero then return end
	if not enemy then return end

	local enemyRotation = Entity.GetRotation(enemy):GetVectors()
		enemyRotation:SetZ(0)
    	local enemyOrigin = NPC.GetAbsOrigin(enemy)
		enemyOrigin:SetZ(0)

	if enemyRotation and enemyOrigin then
			if not NPC.IsRunning(enemy) then
				return enemyOrigin
			else return enemyOrigin:__add(enemyRotation:Normalized():Scaled(Doom.GetMoveSpeed(enemy) * adjustmentVariable))
			end
	end
end

function Doom.GetMoveSpeed(enemy)

	if not enemy then return end

	local base_speed = NPC.GetBaseSpeed(enemy)
	local bonus_speed = NPC.GetMoveSpeed(enemy) - NPC.GetBaseSpeed(enemy)
	local modifierHex
    	local modSheep = NPC.GetModifier(enemy, "modifier_sheepstick_debuff")
    	local modLionVoodoo = NPC.GetModifier(enemy, "modifier_lion_voodoo")
    	local modShamanVoodoo = NPC.GetModifier(enemy, "modifier_shadow_shaman_voodoo")

	if modSheep then
		modifierHex = modSheep
	end
	if modLionVoodoo then
		modifierHex = modLionVoodoo
	end
	if modShamanVoodoo then
		modifierHex = modShamanVoodoo
	end

	if modifierHex then
		if math.max(Modifier.GetDieTime(modifierHex) - GameRules.GetGameTime(), 0) > 0 then
			return 140 + bonus_speed
		end
	end

    	if NPC.HasModifier(enemy, "modifier_invoker_ice_wall_slow_debuff") then 
		return 100 
	end

	if NPC.HasModifier(enemy, "modifier_invoker_cold_snap_freeze") or NPC.HasModifier(enemy, "modifier_invoker_cold_snap") then
		return (base_speed + bonus_speed) * 0.5
	end

	if NPC.HasModifier(enemy, "modifier_spirit_breaker_charge_of_darkness") then
		local chargeAbility = NPC.GetAbility(enemy, "spirit_breaker_charge_of_darkness")
		if chargeAbility then
			local specialAbility = NPC.GetAbility(enemy, "special_bonus_unique_spirit_breaker_2")
			if specialAbility then
				 if Ability.GetLevel(specialAbility) < 1 then
					return Ability.GetLevel(chargeAbility) * 50 + 550
				else
					return Ability.GetLevel(chargeAbility) * 50 + 1050
				end
			end
		end
	end
			
    	return base_speed + bonus_speed
end

function Doom.isHeroChannelling(myHero)

	if not myHero then return true end

	if NPC.IsChannellingAbility(myHero) then return true end
	if NPC.HasModifier(myHero, "modifier_teleporting") then return true end

	return false
end

function Doom.heroCanCastItems(myHero)

	if not myHero then return false end
	if not Entity.IsAlive(myHero) then return false end

	if NPC.IsStunned(myHero) then return false end
	if NPC.HasModifier(myHero, "modifier_bashed") then return false end
	if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then return false end	
	if NPC.HasModifier(myHero, "modifier_eul_cyclone") then return false end
	if NPC.HasModifier(myHero, "modifier_obsidian_destroyer_astral_imprisonment_prison") then return false end
	if NPC.HasModifier(myHero, "modifier_shadow_demon_disruption") then return false end	
	if NPC.HasModifier(myHero, "modifier_invoker_tornado") then return false end
	if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_HEXED) then return false end
	if NPC.HasModifier(myHero, "modifier_legion_commander_duel") then return false end
	if NPC.HasModifier(myHero, "modifier_axe_berserkers_call") then return false end
	if NPC.HasModifier(myHero, "modifier_winter_wyvern_winters_curse") then return false end
	if NPC.HasModifier(myHero, "modifier_bane_fiends_grip") then return false end
	if NPC.HasModifier(myHero, "modifier_bane_nightmare") then return false end
	if NPC.HasModifier(myHero, "modifier_faceless_void_chronosphere_freeze") then return false end
	if NPC.HasModifier(myHero, "modifier_enigma_black_hole_pull") then return false end
	if NPC.HasModifier(myHero, "modifier_magnataur_reverse_polarity") then return false end
	if NPC.HasModifier(myHero, "modifier_pudge_dismember") then return false end
	if NPC.HasModifier(myHero, "modifier_shadow_shaman_shackles") then return false end
	if NPC.HasModifier(myHero, "modifier_techies_stasis_trap_stunned") then return false end
	if NPC.HasModifier(myHero, "modifier_storm_spirit_electric_vortex_pull") then return false end
	if NPC.HasModifier(myHero, "modifier_tidehunter_ravage") then return false end
	if NPC.HasModifier(myHero, "modifier_windrunner_shackle_shot") then return false end
	if NPC.HasModifier(myHero, "modifier_item_nullifier_mute") then return false end

	return true	
end

function Doom.IsInAbilityPhase(myHero)

	if not myHero then return false end

	local myAbilities = {}

	for i= 0, 10 do
		local ability = NPC.GetAbilityByIndex(myHero, i)
		if ability and Entity.IsAbility(ability) and Ability.GetLevel(ability) > 0 then
			table.insert(myAbilities, ability)
		end
	end

	if #myAbilities < 1 then return false end

	for _, v in ipairs(myAbilities) do
		if v then
			if Ability.IsInAbilityPhase(v) then
				return true
			end
		end
	end

	return false
end

function Doom.Debugger(time, npc, ability, order)

	if not Menu.IsEnabled(Doom.optionEnable) then return end
	--Log.Write(tostring(time) .. " " .. tostring(NPC.GetUnitName(npc)) .. " " .. tostring(ability) .. " " .. tostring(order))
end

function Doom.GenericMainAttack(myHero, attackType, target, position)
	
	if not myHero then return end
	if not target and not position then return end

	if Doom.isHeroChannelling(myHero) == true then return end
	if Doom.heroCanCastItems(myHero) == false then return end
	if Doom.IsInAbilityPhase(myHero) == true then return end

	if Menu.IsEnabled(Doom.optionEnable) then
		if target ~= nil then
			Doom.GenericAttackIssuer(attackType, target, position, myHero)
		end
	else
		Doom.GenericAttackIssuer(attackType, target, position, myHero)
	end
end

function Doom.GenericAttackIssuer(attackType, target, position, npc)

	if not npc then return end
	if not target and not position then return end
	if os.clock() - Doom.lastAttackTime2 < 0.5 then return end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET" then
		if target ~= nil then
			if target ~= Doom.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, target, Vector(0, 0, 0), ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				Doom.LastTarget = target
				Doom.Debugger(GameRules.GetGameTime(), npc, "attack", "DOTA_UNIT_ORDER_ATTACK_TARGET")
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE" then
		if position ~= nil then
			if not NPC.IsAttacking(npc) or not NPC.IsRunning(npc) then
				if position:__tostring() ~= Doom.LastTarget then
					Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
					Doom.LastTarget = position:__tostring()
					Doom.Debugger(GameRules.GetGameTime(), npc, "attackMove", "DOTA_UNIT_ORDER_ATTACK_MOVE")
				end
			end
		end
	end

	if attackType == "Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION" then
		if position ~= nil then
			if position:__tostring() ~= Doom.LastTarget then
				Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, target, position, ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, npc)
				Doom.LastTarget = position:__tostring()
				Doom.Debugger(GameRules.GetGameTime(), npc, "move", "DOTA_UNIT_ORDER_MOVE_TO_POSITION")
			end
		end
	end

	if target ~= nil then
		if target == Doom.LastTarget then
			if not NPC.IsAttacking(npc) then
				Doom.LastTarget = nil
				Doom.lastAttackTime2 = os.clock()
				return
			end
		end
	end

	if position ~= nil then
		if position:__tostring() == Doom.LastTarget then
			if not NPC.IsRunning(npc) then
				Doom.LastTarget = nil
				Doom.lastAttackTime2 = os.clock()
				return
			end
		end
	end
end

function Doom.castLinearPrediction(myHero, enemy, adjustmentVariable)

	if not myHero then return end
	if not enemy then return end

	local enemyRotation = Entity.GetRotation(enemy):GetVectors()
		enemyRotation:SetZ(0)
    	local enemyOrigin = NPC.GetAbsOrigin(enemy)
		enemyOrigin:SetZ(0)


	local cosGamma = (NPC.GetAbsOrigin(myHero) - enemyOrigin):Dot2D(enemyRotation:Scaled(100)) / ((NPC.GetAbsOrigin(myHero) - enemyOrigin):Length2D() * enemyRotation:Scaled(100):Length2D())

		if enemyRotation and enemyOrigin then
			if not NPC.IsRunning(enemy) then
				return enemyOrigin
			else return enemyOrigin:__add(enemyRotation:Normalized():Scaled(Doom.GetMoveSpeed(enemy) * adjustmentVariable * (1 - cosGamma)))
		end
	end
end

function Doom.OnDraw()
    local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_doom_bringer" then return end
    if not AutoMode then return end
    if not Menu.IsEnabled(Doom.optionAutoDevour) then return end
    -- Draw text when Auto Doom is Active --
    local x, y = Renderer.GetScreenSize()
    if x == 1920 and y == 1080 then
		x, y = 1150, 910
	elseif x== 1600 and y == 900 then
		x, y = 950, 755
	elseif x== 1366 and y == 768 then
		x, y = 805, 643
	elseif x==1280 and y == 720 then
		x, y = 752, 600
	elseif x==1280 and y == 1024 then
		x, y = 800, 860
	elseif x==1440 and y == 900 then
		x, y = 870, 755
	elseif x== 1680 and y == 1050 then
		x, y = 1025, 885
	end
    Renderer.SetDrawColor(0, 255, 0, 255)
    Renderer.DrawText(font, x, y, "Auto", 1)
end

function Doom.AutoDevourRanged(myHero)
    	
	if not myHero then return end
	local Devour = NPC.GetAbility(myHero, "doom_bringer_devour")
	if not Devour then return end
	local mana = NPC.GetMana(myHero)
	if NPC.HasModifier(myHero, "modifier_doom_bringer_devour") then return end
	if not Ability.IsReady(Devour) or not Ability.IsCastable(Devour, mana) then return end
	if not Entity.GetUnitsInRadius(myHero,300,Enum.TeamType.TEAM_ENEMY) then return end
	for _, creeps in ipairs(Entity.GetUnitsInRadius(myHero, 300, Enum.TeamType.TEAM_ENEMY)) do
		if creeps and Entity.IsNPC(creeps) and not Entity.IsHero(creeps) and
		NPC.IsCreep(creeps) and Entity.IsAlive(creeps) and not Entity.IsDormant(creeps) and not NPC.IsWaitingToSpawn(creeps) and not Entity.IsSameTeam(myHero, creeps) then
			if NPC.GetUnitName(creeps) == "npc_dota_goodguys_siege" or NPC.GetUnitName(creeps) == "npc_dota_goodguys_siege_upgraded" or NPC.GetUnitName(creeps) == "npc_dota_goodguys_siege_upgraded_mega" or NPC.GetUnitName(creeps) == "npc_dota_badguys_siege" or NPC.GetUnitName(creeps) == "npc_dota_badguys_siege_upgraded" or NPC.GetUnitName(creeps) == "npc_dota_badguys_siege_upgraded_mega" or NPC.GetUnitName(creeps) == "npc_dota_creep_badguys_ranged" or NPC.GetUnitName(creeps) == "npc_dota_creep_badguys_ranged_upgraded" or NPC.GetUnitName(creeps) == "npc_dota_creep_badguys_ranged_upgraded_mega" or NPC.GetUnitName(creeps) == "npc_dota_creep_goodguys_ranged" or NPC.GetUnitName(creeps) == "npc_dota_creep_goodguys_ranged_upgraded" or NPC.GetUnitName(creeps) == "npc_dota_creep_goodguys_ranged_upgraded_mega" and NPC.GetUnitName(creeps) ~= nil then
				Ability.CastTarget(Devour, creeps) return
			end
		end
	end
end

function Doom.AutoDoom(myHero)
	local Ult = NPC.GetAbility(myHero, "doom_bringer_doom")
	local mana = NPC.GetMana(myHero)
	if not myHero then return end

	if not Menu.IsEnabled(Doom.optionAutoDoom) then return end

	if not Ult then return end
	if not Ability.IsCastable(Ult, mana) then return end


	for i = 1, Heroes.Count() do
		local enemy = Heroes.Get(i)
		if enemy and Entity.IsHero(enemy) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 550) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_enigma" and not NPC.IsIllusion(enemy) then
			if Entity.IsAlive(enemy) then
				local blackHole = NPC.GetAbility(enemy, "enigma_black_hole")
				
				if blackHole and Ability.IsInAbilityPhase(blackHole) or Ability.IsChannelling(blackHole) then
					if Ability.IsReady(Ult) and not NPC.IsLinkensProtected(enemy) then 
					Ability.CastTarget(Ult, enemy)
					return end
				end
			end
		end
				
		if enemy and Entity.IsHero(enemy) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 550) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_sand_king" and not NPC.IsIllusion(enemy) then
			if Entity.IsAlive(enemy) then
				local epicenter = NPC.GetAbility(enemy, "sandking_epicenter")
				
				if epicenter and Ability.IsChannelling(epicenter) then
					if Ability.IsReady(Ult) and not NPC.IsLinkensProtected(enemy) then 
					Ability.CastTarget(Ult, enemy) 
					return end
				end
			end
		end
				
		if enemy and Entity.IsHero(enemy) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 550) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_witch_doctor" and not NPC.IsIllusion(enemy) then
			if Entity.IsAlive(enemy) then
				local deathward = NPC.GetAbility(enemy, "witch_doctor_death_ward")
				
				if deathward and Ability.IsInAbilityPhase(deathward) or Ability.IsChannelling(deathward) then
					if Ability.IsReady(Ult) and not NPC.IsLinkensProtected(enemy) then 
					Ability.CastTarget(Ult, enemy) 
					return end
				end
			end
		end
				
		if enemy and Entity.IsHero(enemy) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 550) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_crystal_maiden" and not NPC.IsIllusion(enemy) then
			if Entity.IsAlive(enemy) then
				local freezing = NPC.GetAbility(enemy, "crystal_maiden_freezing_field")
				
				if freezing and Ability.IsInAbilityPhase(freezing) or Ability.IsChannelling(freezing) then
					if Ability.IsReady(Ult) and not NPC.IsLinkensProtected(enemy) then 
					Ability.CastTarget(Ult, enemy) 
					return end
				end
			end
		end
				
		if enemy and Entity.IsHero(enemy) and NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 550) and not Entity.IsSameTeam(myHero, enemy) and not Entity.IsDormant(enemy) and NPC.GetUnitName(enemy) == "npc_dota_hero_bane" and not NPC.IsIllusion(enemy) then
			if Entity.IsAlive(enemy) then
				local grip = NPC.GetAbility(enemy, "bane_fiends_grip")
				
				if grip and Ability.IsInAbilityPhase(grip) or Ability.IsChannelling(grip) then
					if Ability.IsReady(Ult) and not NPC.IsLinkensProtected(enemy) then 
					Ability.CastTarget(Ult, enemy) 
					return end
				end
			end
		end
	end
end

function Doom.Combo()
if not Menu.IsKeyDown(Doom.optionKey) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_doom_bringer" then return end
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    if not enemy then return end
    local enemyPos = Entity.GetAbsOrigin(enemy) 
    local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)

--Ability Calls--	
    local Scorched = NPC.GetAbility(myHero, "doom_bringer_scorched_earth")
    local Infernal = NPC.GetAbility(myHero, "doom_bringer_infernal_blade")
    local CreepIceArmor = NPC.GetAbility(myHero, "ogre_magi_frost_armor")
    local CreepKentStun = NPC.GetAbility(myHero, "centaur_khan_war_stomp")
    local CreepManaburn = NPC.GetAbility(myHero, "satyr_soulstealer_mana_burn")
    local CreepNet = NPC.GetAbility(myHero, "dark_troll_warlord_ensnare")
    local CreepRockStun = NPC.GetAbility(myHero, "mud_golem_hurl_boulder")
	local CreepShock = NPC.GetAbility(myHero, "harpy_storm_chain_lightning") --Cheap Dagon--
	local CreepSWave = NPC.GetAbility(myHero, "satyr_hellcaller_shockwave") --Input Prediction--
	local CreepTClap = NPC.GetAbility(myHero, "polar_furbolg_ursa_warrior_thunder_clap")
	local ProwlerStomp = NPC.GetAbility(myHero, "spawnlord_master_stomp")
	local ThunderFrenzy = NPC.GetAbility(myHero, "big_thunder_lizard_frenzy")
    

--Item Calls--
    local Blink  = NPC.GetItem(myHero, "item_blink", true)
    local Halberd  = NPC.GetItem(myHero, "item_heavens_halberd", true)
    local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
    local Scythe = NPC.GetItem(myHero, "item_sheepstick", true)
    local ShadowBlade = NPC.GetItem(myHero, "item_invis_sword", true)
    local Shivas = NPC.GetItem(myHero, "item_shivas_guard", true)
    local SilverEdge = NPC.GetItem(myHero, "item_silver_edge", true)
    local orchid = NPC.GetItem(myHero, "item_orchid", true)
    local blood = NPC.GetItem(myHero, "item_bloodthorn", true)
    local Urn = NPC.GetItem(myHero, "item_urn_of_shadows", true)
    local Vessel = NPC.GetItem(myHero, "item_spirit_vessel", true)
    local veil = NPC.GetItem(myHero, "item_veil_of_discord", true)
    local nullifier = NPC.GetItem(myHero, "item_nullifier", true)
--Ability Ranges--
    local InfernalRange = 150
    local FrenzyRange = 900
    local NetRange = 550
    local IceArmorRange = 800
  	local KentStunRadius = 225
  	local ManaBurnRange = 600
  	local ProwlerStompRange = 275
  	local RockStunRange = 800
  	local ScorchedRadius = 550
  	local ShockRange = 900
  	local SWaveRange = 700
  	local CreepTClapRadius = 275
  	
  	
--Item Ranges--
  	local BlinkRange = 1200
  	local HalberdRange = 575
  	local ScytheRange = 900
  	local ShivasRadius = 900
	
	if not NPC.IsEntityInRange(myHero, enemy, Menu.GetValue(Doom.optionMinimumBlinkRange)) then
		if enemy and not NPC.IsIllusion(enemy) and Doom.CanCastSpellOn2(enemy) then
       		if Blink and Menu.IsEnabled(Doom.optionBlink) and Ability.IsReady(Blink) and NPC.IsEntityInRange(myHero, enemy, BlinkRange - 150 + Menu.GetValue(Doom.optionBlinkRange)) then
         		Ability.CastPosition(Blink, (Entity.GetAbsOrigin(enemy) + (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(enemy)):Normalized():Scaled(Menu.GetValue(Doom.optionBlinkRange)))) return
      		end
      	end
    end
	
	if Doom.CanCastSpellOn2(myHero) and not NPC.IsIllusion(myHero) then
		if ThunderFrenzy and Ability.IsReady(ThunderFrenzy) and Menu.IsEnabled(Doom.optionEnableThunderFrenzy) and Ability.IsCastable(ThunderFrenzy, mana) then
			if NPC.IsAttacking(myHero) then
				Ability.CastTarget(ThunderFrenzy, myHero) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_stunned") and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_HEXED) then
		if CreepKentStun and Ability.IsReady(CreepKentStun) and Menu.IsEnabled(Doom.optionEnableCreepKentStun) and Ability.IsCastable(CreepKentStun, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), KentStunRadius) then
				Ability.CastNoTarget(CreepKentStun) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if Urn and Ability.IsReady(Urn) and Item.GetCurrentCharges(Urn) > 0 and Menu.IsEnabled(Doom.optionEnableUrn) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 950) then
				Ability.CastTarget(Urn, enemy) return
			end
		end
	end

	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if Vessel and Ability.IsReady(Vessel) and Item.GetCurrentCharges(Vessel) > 0 and Menu.IsEnabled(Doom.optionEnableVessel) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 950) then
				Ability.CastTarget(Vessel, enemy) return
			end
		end
	end

	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if orchid and Ability.IsReady(orchid) and Ability.IsCastable(orchid,mana) and Menu.IsEnabled(Doom.optionEnableOrchid) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 900) then
				Ability.CastTarget(orchid, enemy) return
			end
		end
	end

	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if blood and Ability.IsReady(blood) and Ability.IsCastable(blood, mana) and Menu.IsEnabled(Doom.optionEnableBlood) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 900) then
				Ability.CastTarget(blood, enemy) return
			end
		end
	end

	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if veil and Ability.IsReady(veil) and Ability.IsCastable(veil, mana) and Menu.IsEnabled(Doom.optionEnableVeil) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 1000) then
				Ability.CastPosition(veil, Entity.GetAbsOrigin(enemy)) return
			end
		end
	end

	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if nullifier and Ability.IsReady(nullifier) and Ability.IsCastable(nullifier, mana) and Menu.IsEnabled(Doom.optionEnableNullifier) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 600) then
				Ability.CastTarget(nullifier, enemy) return
			end
		end
	end

	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if CreepManaburn and Ability.IsReady(CreepManaburn) and Menu.IsEnabled(Doom.optionEnableCreepManaburn) and Ability.IsCastable(CreepManaburn, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ManaBurnRange) then
				Ability.CastTarget(CreepManaburn, enemy) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if CreepShock and Ability.IsReady(CreepShock) and Menu.IsEnabled(Doom.optionEnableCreepShock) and Ability.IsCastable(CreepShock, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ShockRange) then
				Ability.CastTarget(CreepShock, enemy) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_stunned") and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_HEXED) then
		if CreepRockStun and Ability.IsReady(CreepRockStun) and Menu.IsEnabled(Doom.optionEnableCreepRockStun) and Ability.IsCastable(CreepRockStun, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), RockStunRange) then
				Ability.CastTarget(CreepRockStun, enemy) return
			end
		end
	end
			     
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_ROOTED) then
		if CreepNet and Ability.IsReady(CreepNet) and Menu.IsEnabled(Doom.optionEnableCreepNet) and Ability.IsCastable(CreepNet, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), NetRange) then
				Ability.CastTarget(CreepNet, enemy) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(myHero) and not NPC.IsIllusion(myHero) and not NPC.HasModifier(myHero, "modifier_ogre_magi_frost_armor") then
		if CreepIceArmor and Ability.IsReady(CreepIceArmor) and Menu.IsEnabled(Doom.optionEnableCreepIceArmor) and Ability.IsCastable(CreepIceArmor, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 400) then
				Ability.CastTarget(CreepIceArmor, myHero) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if CreepSWave and Ability.IsReady(CreepSWave) and Menu.IsEnabled(Doom.optionEnableCreepSWave) and Ability.IsCastable(CreepSWave, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), SWaveRange) then
				local SWavePrediction = Ability.GetCastPoint(CreepSWave) + (Entity.GetAbsOrigin(enemy):__sub(Entity.GetAbsOrigin(myHero)):Length2D() / 900) + (NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2)
				Ability.CastPosition((CreepSWave), Doom.castLinearPrediction(myHero, enemy, SWavePrediction)) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if ProwlerStomp and Ability.IsReady(ProwlerStomp) and Menu.IsEnabled(Doom.optionEnableProwlerStomp) and Ability.IsCastable(ProwlerStomp, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ProwlerStompRange) then
				Ability.CastNoTarget(ProwlerStomp) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if CreepTClap and Ability.IsReady(CreepTClap) and Menu.IsEnabled(Doom.optionEnableCreepTClap) and Ability.IsCastable(CreepTClap, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), CreepTClapRadius) then
				Ability.CastNoTarget(CreepTClap) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(myHero) and not NPC.IsIllusion(myHero) then
		if Scorched and Ability.IsReady(Scorched) and Menu.IsEnabled(Doom.optionEnableScorched) and Ability.IsCastable(Scorched, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ScorchedRadius) then
				Ability.CastNoTarget(Scorched) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(myHero) and not NPC.IsIllusion(myHero) then
		if ShadowBlade and Ability.IsReady(ShadowBlade) and Menu.IsEnabled(Doom.optionEnableShadowBlade) and Ability.IsCastable(ShadowBlade, mana) then
			if NPC.IsAttacking(myHero) then
				Ability.CastNoTarget(ShadowBlade) return
			end
		end
	end
		
	if Doom.CanCastSpellOn2(myHero) and not NPC.IsIllusion(myHero) then
		if SilverEdge and Ability.IsReady(SilverEdge) and Menu.IsEnabled(Doom.optionEnableSilverEdge) and Ability.IsCastable(SilverEdge, mana) then
			if NPC.IsAttacking(myHero) then
				Ability.CastNoTarget(SilverEdge) return
			end
		end
	end
		
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if Infernal and Ability.IsReady(Infernal) and Menu.IsEnabled(Doom.optionEnableInfernal) and Ability.IsCastable(Infernal, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 250) then
				if NPC.HasItem(myHero, "item_invis_sword", true) or NPC.HasItem(myHero, "item_silver_edge", true) then
					if ShadowBlade and Ability.IsReady(ShadowBlade) or SilverEdge and Ability.IsReady(SilverEdge) then
				    	if NPC.HasModifier(myHero, "modifier_item_invisibility_edge_windwalk") or NPC.HasModifier(myHero, "modifier_item_silver_edge_windwalk") then
							Ability.CastTarget(Infernal, enemy) return
						end
					else
						Ability.CastTarget(Infernal, enemy) return
					end
				else
					Ability.CastTarget(Infernal, enemy) return
				end
			end
		end
	end
		
	if Doom.CanCastSpellOn2(myHero) and not NPC.IsIllusion(myHero) then
		if Shivas and Ability.IsReady(Shivas) and Menu.IsEnabled(Doom.optionEnableShivas) and Ability.IsCastable(Shivas, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 800) then
				Ability.CastNoTarget(Shivas) return
			end
		end
	end
		
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_item_sheepstick") then
		if Scythe and Ability.IsReady(Scythe) and Menu.IsEnabled(Doom.optionEnableScythe) and Ability.IsCastable(Scythe, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ScytheRange) then
				Ability.CastTarget(Scythe, enemy) return
			end
		end
	end
		
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_item_sheepstick") then
		if Halberd and Ability.IsReady(Halberd) and Menu.IsEnabled(Doom.optionEnableHalberd) and Ability.IsCastable(Halberd, mana) then
			if NPC.IsAttacking(enemy) then
				Ability.CastTarget(Halberd, enemy) return
			end
		end
	end
			
    Doom.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return
end

function Doom.UltCombo()
if not Menu.IsKeyDown(Doom.optionKey2) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_doom_bringer" then return end
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY) 
    if not enemy then return end
    local enemyPos = Entity.GetAbsOrigin(enemy)
    local mousePos = Input.GetWorldCursorPos()
    local mana = NPC.GetMana(myHero)
	
--Ability Calls--	
    local Scorched = NPC.GetAbility(myHero, "doom_bringer_scorched_earth")
    local Infernal = NPC.GetAbility(myHero, "doom_bringer_infernal_blade")
    local Ult = NPC.GetAbility(myHero, "doom_bringer_doom")
    local CreepIceArmor = NPC.GetAbility(myHero, "ogre_magi_frost_armor")
    local CreepKentStun = NPC.GetAbility(myHero, "centaur_khan_war_stomp")
    local CreepManaburn = NPC.GetAbility(myHero, "satyr_soulstealer_mana_burn")
    local CreepNet = NPC.GetAbility(myHero, "dark_troll_warlord_ensnare")
    local CreepRockStun = NPC.GetAbility(myHero, "mud_golem_hurl_boulder")
	local CreepShock = NPC.GetAbility(myHero, "harpy_storm_chain_lightning") --Cheap Dagon--
	local CreepSWave = NPC.GetAbility(myHero, "satyr_hellcaller_shockwave") --Input Prediction--
	local CreepTClap = NPC.GetAbility(myHero, "polar_furbolg_ursa_warrior_thunder_clap")
	local ProwlerStomp = NPC.GetAbility(myHero, "spawnlord_master_stomp")
	local ThunderFrenzy = NPC.GetAbility(myHero, "big_thunder_lizard_frenzy")
    

--Item Calls--
    local Blink  = NPC.GetItem(myHero, "item_blink", true)
    local Halberd  = NPC.GetItem(myHero, "item_heavens_halberd", true)
    local Lens = NPC.GetItem(myHero, "item_aether_lens", true)
    local Scythe = NPC.GetItem(myHero, "item_sheepstick", true)
    local ShadowBlade = NPC.GetItem(myHero, "item_invis_sword", true)
    local Shivas = NPC.GetItem(myHero, "item_shivas_guard", true)
    local SilverEdge = NPC.GetItem(myHero, "item_silver_edge", true)
    local orchid = NPC.GetItem(myHero, "item_orchid", true)
    local blood = NPC.GetItem(myHero, "item_bloodthorn", true)
    local Urn = NPC.GetItem(myHero, "item_urn_of_shadows", true)
    local Vessel = NPC.GetItem(myHero, "item_spirit_vessel", true)
    local veil = NPC.GetItem(myHero, "item_veil_of_discord", true)
    local nullifier = NPC.GetItem(myHero, "item_nullifier", true)
--Ability Ranges--
    local InfernalRange = 150
    local FrenzyRange = 900
    local NetRange = 550
    local IceArmorRange = 800
  	local KentStunRadius = 225
  	local ManaBurnRange = 600
  	local ProwlerStompRange = 275
  	local RockStunRange = 800
  	local ScorchedRadius = 550
  	local ShockRange = 900
  	local SWaveRange = 700
  	local CreepTClapRadius = 275
  	local UltRange = 550
  	
  	
--Item Ranges--
  	local BlinkRange = 1200
  	local HalberdRange = 575
  	local ScytheRange = 900
  	local ShivasRadius = 900
	
	if not NPC.IsEntityInRange(myHero, enemy, Menu.GetValue(Doom.optionMinimumBlinkRange)) then
		if enemy and not NPC.IsIllusion(enemy) and Doom.CanCastSpellOn2(enemy) then
       		if Blink and Menu.IsEnabled(Doom.optionBlink) and Ability.IsReady(Blink) and NPC.IsEntityInRange(myHero, enemy, BlinkRange - 150 + Menu.GetValue(Doom.optionBlinkRange)) then
         		Ability.CastPosition(Blink, (Entity.GetAbsOrigin(enemy) + (Entity.GetAbsOrigin(myHero) - Entity.GetAbsOrigin(enemy)):Normalized():Scaled(Menu.GetValue(Doom.optionBlinkRange)))) return
      		end
      	end
    end
	
	if Doom.CanCastSpellOn2(myHero) and not NPC.IsIllusion(myHero) then
		if ThunderFrenzy and Ability.IsReady(ThunderFrenzy) and Menu.IsEnabled(Doom.optionEnableThunderFrenzy) and Ability.IsCastable(ThunderFrenzy, mana) then
			if NPC.IsAttacking(myHero) then
				Ability.CastTarget(ThunderFrenzy, myHero) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if Urn and Ability.IsReady(Urn) and Item.GetCurrentCharges(Urn) > 0 and Menu.IsEnabled(Doom.optionEnableUrn) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 950) then
				Ability.CastTarget(Urn, enemy) return
			end
		end
	end

	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if Vessel and Ability.IsReady(Vessel) and Item.GetCurrentCharges(Vessel) > 0 and Menu.IsEnabled(Doom.optionEnableVessel) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 950) then
				Ability.CastTarget(Vessel, enemy) return
			end
		end
	end

	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if orchid and Ability.IsReady(orchid) and Ability.IsCastable(orchid,mana) and Menu.IsEnabled(Doom.optionEnableOrchid) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 900) then
				Ability.CastTarget(orchid, enemy) return
			end
		end
	end

	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if blood and Ability.IsReady(blood) and Ability.IsCastable(blood, mana) and Menu.IsEnabled(Doom.optionEnableBlood) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 900) then
				Ability.CastTarget(blood, enemy) return
			end
		end
	end

	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if veil and Ability.IsReady(veil) and Ability.IsCastable(veil, mana) and Menu.IsEnabled(Doom.optionEnableVeil) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 1000) then
				Ability.CastPosition(veil, Entity.GetAbsOrigin(enemy)) return
			end
		end
	end

	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if nullifier and Ability.IsReady(nullifier) and Ability.IsCastable(nullifier, mana) and Menu.IsEnabled(Doom.optionEnableNullifier) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 600) then
				Ability.CastTarget(nullifier, enemy) return
			end
		end
	end

	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_stunned") and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_HEXED) then
		if CreepKentStun and Ability.IsReady(CreepKentStun) and Menu.IsEnabled(Doom.optionEnableCreepKentStun) and Ability.IsCastable(CreepKentStun, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), KentStunRadius) then
				Ability.CastNoTarget(CreepKentStun) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if CreepManaburn and Ability.IsReady(CreepManaburn) and Menu.IsEnabled(Doom.optionEnableCreepManaburn) and Ability.IsCastable(CreepManaburn, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ManaBurnRange) then
				Ability.CastTarget(CreepManaburn, enemy) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if CreepShock and Ability.IsReady(CreepShock) and Menu.IsEnabled(Doom.optionEnableCreepShock) and Ability.IsCastable(CreepShock, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ShockRange) then
				Ability.CastTarget(CreepShock, enemy) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_stunned") and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_HEXED) then
		if CreepRockStun and Ability.IsReady(CreepRockStun) and Menu.IsEnabled(Doom.optionEnableCreepRockStun) and Ability.IsCastable(CreepRockStun, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), RockStunRange) then
				Ability.CastTarget(CreepRockStun, enemy) return
			end
		end
	end
			     
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasState(enemy, Enum.ModifierState.MODIFIER_STATE_ROOTED) then
		if CreepNet and Ability.IsReady(CreepNet) and Menu.IsEnabled(Doom.optionEnableCreepNet) and Ability.IsCastable(CreepNet, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), NetRange) then
				Ability.CastTarget(CreepNet, enemy) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(myHero) and not NPC.IsIllusion(myHero) and not NPC.HasModifier(myHero, "modifier_ogre_magi_frost_armor") then
		if CreepIceArmor and Ability.IsReady(CreepIceArmor) and Menu.IsEnabled(Doom.optionEnableCreepIceArmor) and Ability.IsCastable(CreepIceArmor, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 400) then
				Ability.CastTarget(CreepIceArmor, myHero) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if CreepSWave and Ability.IsReady(CreepSWave) and Menu.IsEnabled(Doom.optionEnableCreepSWave) and Ability.IsCastable(CreepSWave, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), SWaveRange) then
				local SWavePrediction = Ability.GetCastPoint(CreepSWave) + (Entity.GetAbsOrigin(enemy):__sub(Entity.GetAbsOrigin(myHero)):Length2D() / 900) + (NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) * 2)
				Ability.CastPosition((CreepSWave), Doom.castLinearPrediction(myHero, enemy, SWavePrediction)) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if ProwlerStomp and Ability.IsReady(ProwlerStomp) and Menu.IsEnabled(Doom.optionEnableProwlerStomp) and Ability.IsCastable(ProwlerStomp, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ProwlerStompRange) then
				Ability.CastNoTarget(ProwlerStomp) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if CreepTClap and Ability.IsReady(CreepTClap) and Menu.IsEnabled(Doom.optionEnableCreepTClap) and Ability.IsCastable(CreepTClap, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), CreepTClapRadius) then
				Ability.CastNoTarget(CreepTClap) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(myHero) and not NPC.IsIllusion(myHero) then
		if Scorched and Ability.IsReady(Scorched) and Menu.IsEnabled(Doom.optionEnableScorched) and Ability.IsCastable(Scorched, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ScorchedRadius) then
				Ability.CastNoTarget(Scorched) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(myHero) and not NPC.IsIllusion(myHero) then
		if ShadowBlade and Ability.IsReady(ShadowBlade) and Menu.IsEnabled(Doom.optionEnableShadowBlade) and Ability.IsCastable(ShadowBlade, mana) then
			if NPC.IsAttacking(myHero) then
				Ability.CastNoTarget(ShadowBlade) return
			end
		end
	end
		
	if Doom.CanCastSpellOn2(myHero) and not NPC.IsIllusion(myHero) then
		if SilverEdge and Ability.IsReady(SilverEdge) and Menu.IsEnabled(Doom.optionEnableSilverEdge) and Ability.IsCastable(SilverEdge, mana) then
			if NPC.IsAttacking(myHero) then
				Ability.CastNoTarget(SilverEdge) return
			end
		end
	end
	
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) then
		if Infernal and Ability.IsReady(Infernal) and Menu.IsEnabled(Doom.optionEnableInfernal) and Ability.IsCastable(Infernal, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 250) then
				if NPC.HasItem(myHero, "item_invis_sword", true) or NPC.HasItem(myHero, "item_silver_edge", true) then
					if ShadowBlade and Ability.IsReady(ShadowBlade) or SilverEdge and Ability.IsReady(SilverEdge) then
				    	if NPC.HasModifier(myHero, "modifier_item_invisibility_edge_windwalk") or NPC.HasModifier(myHero, "modifier_item_silver_edge_windwalk") then
							Ability.CastTarget(Infernal, enemy) return
						end
					else
						Ability.CastTarget(Infernal, enemy) return
					end
				else
					Ability.CastTarget(Infernal, enemy) return
				end
			end
		end
	end
	
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) and not NPC.IsLinkensProtected(enemy) then
		if Ult and Ability.IsReady(Ult) and Menu.IsEnabled(Doom.optionEnableUlt) and Ability.IsCastable(Ult, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), UltRange) then
				Ability.CastTarget(Ult, enemy) return
			end
		end
	end
		
	if Doom.CanCastSpellOn2(myHero) and not NPC.IsIllusion(myHero) then
		if Shivas and Ability.IsReady(Shivas) and Menu.IsEnabled(Doom.optionEnableShivas) and Ability.IsCastable(Shivas, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), 800) then
				Ability.CastNoTarget(Shivas) return
			end
		end
	end
		
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_item_sheepstick") then
		if Scythe and Ability.IsReady(Scythe) and Menu.IsEnabled(Doom.optionEnableScythe) and Ability.IsCastable(Scythe, mana) then
			if NPC.IsPositionInRange(myHero, Entity.GetAbsOrigin(enemy), ScytheRange) then
				Ability.CastTarget(Scythe, enemy) return
			end
		end
	end
		
	if Doom.CanCastSpellOn2(enemy) and not NPC.IsIllusion(enemy) and not NPC.HasModifier(enemy, "modifier_item_sheepstick") then
		if Halberd and Ability.IsReady(Halberd) and Menu.IsEnabled(Doom.optionEnableHalberd) and Ability.IsCastable(Halberd, mana) then
			if NPC.IsAttacking(enemy) then
				Ability.CastTarget(Halberd, enemy) return
			end
		end
	end
			
    Doom.GenericMainAttack(myHero, "Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET", enemy, nil) return
end

function Doom.SleepReady(sleep)

	if (os.clock() - Doom.lastTick) >= sleep then
		return true
	end
	return false
end

function Doom.makeDelay(sec)

	Doom.delay = sec + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING)
	Doom.lastTick = os.clock() 
end

function Doom.CanCastSpellOn(npc)
	if Entity.IsDormant(npc) or not Entity.IsAlive(npc) then return false end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then return false end

	return true
end
function Doom.CanCastSpellOn2(npc)
	if Entity.IsDormant(npc) or not Entity.IsAlive(npc) then return false end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_MAGIC_IMMUNE) then return false end
	if NPC.HasState(npc, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then return false end

	return true
end
return Doom