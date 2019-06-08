local HitMaster = {}

local optionEnable = Menu.AddOption({"Utility"}, "[HitMaster] Last Hit Enable", "On/Off")
local optionAwareness = Menu.AddOption({"Utility"}, "[HitMaster] Last Hit Awareness", "On/Off")
HitMaster.optionRoboFarm = Menu.AddOption({"Utility"}, "[HitMaster] Auto Last Hit", "On/Off")
local key = Menu.AddKeyOption({"Utility"}, "[HitMaster] Last Hit Key", Enum.ButtonCode.KEY_SPACE)

local targets = {}
local font = Renderer.LoadFont("Tahoma", 20, Enum.FontWeight.EXTRABOLD)

-- ....
local bot_active = false
local REMOVE_INACTIVE_EVERY = 2.0
local LAST_REMOVE_INACTIVE = 0.0
local NPC_INACTIVE_TIME = 2.3
local CREEP_MELEE_HULL_SIZE = 16
local CREEP_MELEE_ATTACK_RANGE = 100

-- HitMaster.attack_delay = 0
-- HitMaster.last_target = nil

local projective_speed = {
   npc_dota_hero_abaddon = 0,
   npc_dota_hero_abyssal_underlord = 0,
   npc_dota_hero_alchemist = 0,
   npc_dota_hero_ancient_apparition = 0,
   npc_dota_hero_antimage = 0,
   npc_dota_hero_arc_warden = 900,
   npc_dota_hero_axe = 0,
   npc_dota_hero_bane = 900,
   npc_dota_hero_batrider = 900,
   npc_dota_hero_beastmaster = 0,
   npc_dota_hero_bloodseeker = 0,
   npc_dota_hero_bounty_hunter = 0,
   npc_dota_hero_brewmaster = 0,
   npc_dota_hero_bristleback = 0,
   npc_dota_hero_broodmother = 0,
   npc_dota_hero_centaur = 0,
   npc_dota_hero_chaos_knight = 0,
   npc_dota_hero_chen = 1100,
   npc_dota_hero_clinkz = 900,
   npc_dota_hero_crystal_maiden = 900,
   npc_dota_hero_dark_seer = 0,
   npc_dota_hero_dazzle = 1200,
   npc_dota_hero_death_prophet = 1000,
   npc_dota_hero_disruptor = 1200,
   npc_dota_hero_doom_bringer = 0,
   npc_dota_hero_dragon_knight = 0,
   npc_dota_hero_drow_ranger = 1250,
   npc_dota_hero_earth_spirit = 0,
   npc_dota_hero_earthshaker = 0,
   npc_dota_hero_elder_titan = 0,
   npc_dota_hero_ember_spirit = 0,
   npc_dota_hero_enchantress = 900,
   npc_dota_hero_enigma = 900,
   npc_dota_hero_faceless_void = 0,
   npc_dota_hero_furion = 1125,
   npc_dota_hero_gyrocopter = 3000,
   npc_dota_hero_huskar = 1400,
   npc_dota_hero_invoker = 900,
   npc_dota_hero_jakiro = 1100,
   npc_dota_hero_juggernaut = 0,
   npc_dota_hero_keeper_of_the_light = 900,
   npc_dota_hero_kunkka = 0,
   npc_dota_hero_legion_commander = 0,
   npc_dota_hero_leshrac = 900,
   npc_dota_hero_lich = 900,
   npc_dota_hero_life_stealer = 0,
   npc_dota_hero_lina = 1000,
   npc_dota_hero_lion = 900,
   npc_dota_hero_lone_druid = 900,
   npc_dota_hero_luna = 900,
   npc_dota_hero_lycan = 0,
   npc_dota_hero_magnataur = 0,
   npc_dota_hero_medusa = 1200,
   npc_dota_hero_meepo = 0,
   npc_dota_hero_mirana = 900,
   npc_dota_hero_morphling = 1300,
   npc_dota_hero_naga_siren = 0,
   npc_dota_hero_necrolyte = 900,
   npc_dota_hero_nevermore = 1200,
   npc_dota_hero_night_stalker = 0,
   npc_dota_hero_nyx_assassin = 0,
   npc_dota_hero_obsidian_destroyer = 900,
   npc_dota_hero_ogre_magi = 0,
   npc_dota_hero_omniknight = 0,
   npc_dota_hero_oracle = 900,
   npc_dota_hero_phantom_assassin = 0,
   npc_dota_hero_phantom_lancer = 0,
   npc_dota_hero_phoenix = 1100,
   npc_dota_hero_puck = 900,
   npc_dota_hero_pudge = 0,
   npc_dota_hero_pugna = 900,
   npc_dota_hero_queenofpain = 1500,
   npc_dota_hero_rattletrap = 0,
   npc_dota_hero_razor = 2000,
   npc_dota_hero_riki = 0,
   npc_dota_hero_rubick = 1125,
   npc_dota_hero_sand_king = 0,
   npc_dota_hero_shadow_demon = 900,
   npc_dota_hero_shadow_shaman = 900,
   npc_dota_hero_shredder = 0,
   npc_dota_hero_silencer = 1000,
   npc_dota_hero_skeleton_king = 0,
   npc_dota_hero_skywrath_mage = 1000,
   npc_dota_hero_slardar = 0,
   npc_dota_hero_slark = 0,
   npc_dota_hero_sniper = 3000,
   npc_dota_hero_spectre = 0,
   npc_dota_hero_spirit_breaker = 0,
   npc_dota_hero_storm_spirit = 1100,
   npc_dota_hero_sven = 0,
   npc_dota_hero_techies = 900,
   npc_dota_hero_templar_assassin = 900,
   npc_dota_hero_terrorblade = 0,
   npc_dota_hero_tidehunter = 0,
   npc_dota_hero_tinker = 900,
   npc_dota_hero_tiny = 0,
   npc_dota_hero_treant = 0,
   npc_dota_hero_troll_warlord = 1200,
   npc_dota_hero_tusk = 0,
   npc_dota_hero_undying = 0,
   npc_dota_hero_ursa = 0,
   npc_dota_hero_vengefulspirit = 1500,
   npc_dota_hero_venomancer = 900,
   npc_dota_hero_viper = 1200,
   npc_dota_hero_visage = 900,
   npc_dota_hero_warlock = 1200,
   npc_dota_hero_weaver = 900,
   npc_dota_hero_windrunner = 1250,
   npc_dota_hero_winter_wyvern = 700,
   npc_dota_hero_wisp = 1200,
   npc_dota_hero_witch_doctor = 1200,
   npc_dota_hero_zuus = 1100,

   npc_dota_creep_badguys_ranged = 900,
    npc_dota_creep_badguys_ranged_upgraded = 900,
    npc_dota_creep_goodguys_ranged = 900,
    npc_dota_creep_goodguys_ranged_upgraded = 900,
    npc_dota_badguys_tower1_bot =  750,
    npc_dota_badguys_tower1_mid =  750,
    npc_dota_badguys_tower1_top =  750,
    npc_dota_badguys_tower2_bot =  750,
    npc_dota_badguys_tower2_mid =  750,
    npc_dota_badguys_tower2_top =  750,
    npc_dota_badguys_tower3_bot =  750,
    npc_dota_badguys_tower3_mid =  750,
    npc_dota_badguys_tower3_top =  750,
    npc_dota_badguys_tower4 =  750,
    npc_dota_goodguys_tower1_bot =  750,
    npc_dota_goodguys_tower1_mid =  750,
    npc_dota_goodguys_tower1_top =  750,
    npc_dota_goodguys_tower2_bot =  750,
    npc_dota_goodguys_tower2_mid =  750,
    npc_dota_goodguys_tower2_top =  750,
    npc_dota_goodguys_tower3_bot =  750,
    npc_dota_goodguys_tower3_mid =  750,
    npc_dota_goodguys_tower3_top =  750,
    npc_dota_goodguys_tower4 =  750,
    npc_dota_goodguys_siege = 1100,
    npc_dota_goodguys_siege_upgraded = 1100,
    npc_dota_badguys_siege = 1100,
    npc_dota_badguys_siege_upgraded = 1100,
}

attackPointTable = {
    npc_dota_hero_abaddon = { 0.56, 0.41, 0 },
    npc_dota_hero_alchemist = { 0.35, 0.65, 0 },
    npc_dota_hero_antimage = { 0.45, 0.3, 1250 },
    npc_dota_hero_ancient_apparition = { 0.3, 0.6, 0 },
    npc_dota_hero_arc_warden = { 0.3, 0.7, 800 },
    npc_dota_hero_axe = { 0.5, 0.5, 0 },
    npc_dota_hero_bane = { 0.3, 0.7, 900 },
    npc_dota_hero_batrider = { 0.3, 0.54, 900 },
    npc_dota_hero_beastmaster = { 0.3, 0.7, 0 },
    npc_dota_hero_bloodseeker = { 0.43, 0.74, 0 },
    npc_dota_hero_bounty_hunter = { 0.59, 0.59, 0 },
    npc_dota_hero_brewmaster = { 0.35, 0.65, 0 },
    npc_dota_hero_bristleback = { 0.3, 0.3, 0 },
    npc_dota_hero_broodmother = { 0.4, 0.5, 0 },
    npc_dota_hero_centaur = { 0.3, 0.3, 0 },
    npc_dota_hero_chaos_knight = { 0.5, 0.5, 0 },
    npc_dota_hero_chen = { 0.5, 0.5, 1100 },
    npc_dota_hero_clinkz = { 0.7, 0.3, 900 },
    npc_dota_hero_rattletrap = { 0.33, 0.64, 0 },
    npc_dota_hero_crystal_maiden = { 0.55, 0, 900 },
    npc_dota_hero_dark_seer = { 0.59, 0.58, 0 },
    npc_dota_hero_dazzle = { 0.3, 0.3, 1200 },
    npc_dota_hero_death_prophet = { 0.56, 0.51, 1000 },
    npc_dota_hero_disruptor = { 0.4, 0.5, 1200 },
    npc_dota_hero_doom_bringer = { 0.5, 0.7, 0 },
    npc_dota_hero_dragon_knight = { 0.5, 0.5, 0 },
    npc_dota_hero_drow_ranger = { 0.7, 0.3, 1250 },
    npc_dota_hero_earth_spirit = { 0.35, 0.65, 0 },
    npc_dota_hero_earthshaker = { 0.467, 0.863, 0 },
    npc_dota_hero_elder_titan = { 0.35, 0.97, 0 },
    npc_dota_hero_ember_spirit = { 0.4, 0.3, 0 },
    npc_dota_hero_enchantress = { 0.3, 0.7, 900 },
    npc_dota_hero_enigma = { 0.4, 0.77, 900 },
    npc_dota_hero_faceless_void = { 0.5, 0.56, 0 },
    npc_dota_hero_gyrocopter = { 0.2, 0.97, 3000 },
    npc_dota_hero_huskar = { 0.4, 0.5, 1400 },
    npc_dota_hero_invoker = { 0.4, 0.7, 900 },
    npc_dota_hero_wisp = { 0.15, 0.4, 1200 },
    npc_dota_hero_jakiro = { 0.4, 0.5, 1100 },
    npc_dota_hero_juggernaut = { 0.33, 0.84, 0 },
    npc_dota_hero_keeper_of_the_light = { 0.3, 0.85, 900 },
    npc_dota_hero_kunkka = { 0.4, 0.3, 0 },
    npc_dota_hero_legion_commander = { 0.46, 0.64, 0 },
    npc_dota_hero_leshrac = { 0.4, 0.77, 900 },
    npc_dota_hero_lich = { 0.46, 0.54, 900 },
    npc_dota_hero_life_stealer = { 0.39, 0.44, 0 },
    npc_dota_hero_lina = { 0.75, 0.78, 1000 },
    npc_dota_hero_lion = { 0.43, 0.74, 1000 },
    npc_dota_hero_lone_druid = { 0.33, 0.53, 900 },
    npc_dota_hero_luna = { 0.46, 0.54, 900 },
    npc_dota_hero_lycan = { 0.55, 0.55, 0 },
    npc_dota_hero_magnataur = { 0.5, 0.84, 0 },
    npc_dota_hero_medusa = { 0.5, 0.6, 1200 },
    npc_dota_hero_meepo = { 0.38, 0.6, 0 },
    npc_dota_hero_mirana = { 0.3, 0.7, 900 },
    npc_dota_hero_morphling = { 0.45, 0.2, 0 },
    npc_dota_hero_monkey_king = { 0.5, 0.5, 1300 },
    npc_dota_hero_naga_siren = { 0.5, 0.5, 0 },
    npc_dota_hero_furion = { 0.4, 0.77, 1125 },
    npc_dota_hero_necrolyte = { 0.53, 0.47, 900 },
    npc_dota_hero_night_stalker = { 0.55, 0.55, 0 },
    npc_dota_hero_nyx_assassin = { 0.46, 0.54, 0 },
    npc_dota_hero_ogre_magi = { 0.3, 0.3, 0 },
    npc_dota_hero_omniknight = { 0.433, 0.567, 0 },
    npc_dota_hero_oracle = { 0.3, 0.7, 900 },
    npc_dota_hero_obsidian_destroyer = { 0.46, 0.54, 900 },
    npc_dota_hero_phantom_assassin = { 0.3, 0.7, 0 },
    npc_dota_hero_phantom_lancer = { 0.5, 0.5, 0 },
    npc_dota_hero_phoenix = { 0.35, 0.633, 1100 },
    npc_dota_hero_puck = { 0.5, 0.8, 900 },
    npc_dota_hero_pudge = { 0.5, 1.17, 0 },
    npc_dota_hero_pugna = { 0.5, 0.5, 900 },
    npc_dota_hero_queenofpain = { 0.56, 0.41, 1500 },
    npc_dota_hero_razor = { 0.3, 0.7, 2000 },
    npc_dota_hero_riki = { 0.3, 0.3, 0 },
    npc_dota_hero_rubick = { 0.4, 0.77, 1125 },
    npc_dota_hero_sand_king = { 0.53, 0.47, 0 },
    npc_dota_hero_shadow_demon = { 0.35, 0.5, 900 },
    npc_dota_hero_nevermore = { 0.5, 0.54, 1200 },
    npc_dota_hero_shadow_shaman = { 0.3, 0.5, 900 },
    npc_dota_hero_silencer = { 0.5, 0.5, 1000 },
    npc_dota_hero_skywrath_mage = { 0.4, 0.78, 1000 },
    npc_dota_hero_slardar = { 0.36, 0.64, 0 },
    npc_dota_hero_slark = { 0.5, 0.3, 0 },
    npc_dota_hero_sniper = { 0.17, 0.7, 3000 },
    npc_dota_hero_spectre = { 0.3, 0.7, 0 },
    npc_dota_hero_spirit_breaker = { 0.6, 0.3, 0 },
    npc_dota_hero_storm_spirit = { 0.5, 0.3, 1100 },
    npc_dota_hero_sven = { 0.4, 0.3, 0 },
    npc_dota_hero_techies = { 0.5, 0.5, 900 },
    npc_dota_hero_templar_assassin = { 0.3, 0.5, 900 },
    npc_dota_hero_terrorblade = { 0.3, 0.6, 0 },
    npc_dota_hero_tidehunter = { 0.6, 0.56, 0 },
    npc_dota_hero_shredder = { 0.36, 0.64, 0 },
    npc_dota_hero_tinker = { 0.35, 0.65, 900 },
    npc_dota_hero_tiny = { 0.49, 1, 0 },
    npc_dota_hero_treant = { 0.6, 0.4, 0 },
    npc_dota_hero_troll_warlord = { 0.3, 0.3, 1200 },
    npc_dota_hero_tusk = { 0.36, 0.64, 0 },
    npc_dota_hero_abyssal_underlord = { 0.45, 0.7, 0 },
    npc_dota_hero_undying = { 0.3, 0.3, 0 },
    npc_dota_hero_ursa = { 0.3, 0.3, 0 },
    npc_dota_hero_vengefulspirit = { 0.33, 0.64, 1500 },
    npc_dota_hero_venomancer = { 0.3, 0.7, 900 },
    npc_dota_hero_viper = { 0.33, 1, 1200 },
    npc_dota_hero_visage = { 0.46, 0.54, 900 },
    npc_dota_hero_warlock = { 0.3, 0.3, 1200 },
    npc_dota_hero_weaver = { 0.64, 0.36, 900 },
    npc_dota_hero_windrunner = { 0.4, 0.3, 1250 },
    npc_dota_hero_winter_wyvern = { 0.25, 0.8, 700 },
    npc_dota_hero_witch_doctor = { 0.4, 0.5, 1200 },
    npc_dota_hero_skeleton_king = { 0.56, 0.44, 0 },
    npc_dota_hero_zuus = { 0.633, 0.366, 1100 },

    -- creeps
    npc_dota_creep_badguys_melee = { 0.467, 0.533, 0 },
    npc_dota_creep_badguys_melee_upgraded ={ 0.467, 0.533, 0 },
    npc_dota_creep_badguys_ranged = { 0.5, 0.3, 500 },
    npc_dota_creep_badguys_ranged_upgraded = { 0.5, 0.3, 500 },
    npc_dota_creep_goodguys_melee = { 0.467, 0.533, 0 },
    npc_dota_creep_goodguys_melee_upgraded = { 0.467, 0.533, 0 },
    npc_dota_creep_goodguys_ranged = { 0.5, 0.3, 500 },
    npc_dota_creep_goodguys_ranged_upgraded = { 0.5, 0.3, 500 },
    npc_dota_goodguys_siege = { 0.7, 2.0, 690 },
    npc_dota_goodguys_siege_upgraded = { 0.7, 2.0, 690 },
    npc_dota_badguys_siege = { 0.7, 2.0, 690 },
    npc_dota_badguys_siege_upgraded = { 0.7, 2.0, 690 },

    npc_dota_badguys_tower1_bot = { 0.6, 0.4, 700 },
    npc_dota_badguys_tower1_mid = { 0.6, 0.4, 700 },
    npc_dota_badguys_tower1_top = { 0.6, 0.4, 700 },
    npc_dota_badguys_tower2_bot = { 0.6, 0.4, 700 },
    npc_dota_badguys_tower2_mid = { 0.6, 0.4, 700 },
    npc_dota_badguys_tower2_top = { 0.6, 0.4, 700 },
    npc_dota_badguys_tower3_bot = { 0.6, 0.4, 700 },
    npc_dota_badguys_tower3_mid = { 0.6, 0.4, 700 },
    npc_dota_badguys_tower3_top = { 0.6, 0.4, 700 },
    npc_dota_badguys_tower4 = { 0.6, 0.4, 700 },
    npc_dota_goodguys_tower1_bot = { 0.6, 0.4, 700 },
    npc_dota_goodguys_tower1_mid = { 0.6, 0.4, 700 },
    npc_dota_goodguys_tower1_top = { 0.6, 0.4, 700 },
    npc_dota_goodguys_tower2_bot = { 0.6, 0.4, 700 },
    npc_dota_goodguys_tower2_mid = { 0.6, 0.4, 700 },
    npc_dota_goodguys_tower2_top = { 0.6, 0.4, 700 },
    npc_dota_goodguys_tower3_bot = { 0.6, 0.4, 700 },
    npc_dota_goodguys_tower3_mid = { 0.6, 0.4, 700 },
    npc_dota_goodguys_tower3_top = { 0.6, 0.4, 700 },
    npc_dota_goodguys_tower4 = { 0.6, 0.4, 700 },

    npc_dota_neutral_caster = {0,0,0},
}

local cancel_attack_in = 0


function HitMaster.OnPrepareUnitOrders(orders)
    if not orders then return true end
    if orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_TRAIN_ABILITY then return true end

    if Menu.IsKeyDown(key) and bot_active then
        return false
    end

    return true
end


function HitMaster.OnUpdate()

    local myHero = Heroes.GetLocal()
    if not myHero then return end
    -- if HitMaster.last_target and NPC.IsAttacking(myHero) and Entity.GetHealth(HitMaster.last_target) <= 0 then
    --   HitMaster.attack_delay = 0
    --   HitMaster.last_target = nil
    -- end

    local origin = Entity.GetAbsOrigin(myHero)
    local target_origin = nil
    local hero_collision_size = 24
    local distance = 0
    local min_distance = 99999

    local deny_target = nil
    local target = nil
    local deny_attack_mode = 0
    local attack_mode = 0
    local wait = 0

    for i, item in pairs(targets) do
        npc = item[14]
        if item[13] > 0 and Entity.IsNPC(npc) and Entity.GetHealth(npc) > 0 and not Entity.IsDormant(npc) then
            if Entity.IsSameTeam(myHero, npc) then

                target_origin = Entity.GetAbsOrigin(npc)
                distance = (origin - target_origin):Length()
                distance = distance - hero_collision_size

                if distance < 1000 or distance < min_distance then
                    min_distance = distance
                    deny_target = npc
                    deny_attack_mode = item[13]
                    if item[18] then
                      wait = item[18]
                    else
                      wait = 0
                    end
                end

            end
        end
    end

    min_distance = 99999
    for i, item in pairs(targets) do
        npc = item[14]
        if item[13] > 0 and Entity.IsNPC(npc) and Entity.GetHealth(npc) > 0 and not Entity.IsDormant(npc) then
            if not Entity.IsSameTeam(myHero, npc) then

                target_origin = Entity.GetAbsOrigin(npc)
                distance = (origin - target_origin):Length()
                distance = distance - hero_collision_size

                if distance < 1000 or distance < min_distance then
                    min_distance = distance
                    target = npc
                    attack_mode = item[13]
                    if item[18] then
                      wait = item[18]
                    else
                      wait = 0
                    end
                end

            end
        end
    end

    bot_active = true
    if target == nil and deny_target == nil then
        bot_active = false
    end
    if bot_active and not (Menu.IsKeyDown(key) or Menu.IsEnabled(HitMaster.optionRoboFarm)) then
        bot_active = false
    end

    if not target and deny_target ~= nil then
        target = deny_target
        attack_mode = deny_attack_mode
    end

    -- if attack_mode == 2 then
    --   cancel_attack_in = curtime + 0.1 -- FIND LONGEST ATTACK IN ATTACKERS AND WAIT??
    -- end

    -- if wait and GameRules.GetGameTime() < wait then Log.Write(wait - GameRules.GetGameTime()) end

    if bot_active and target then

      -- if attack_mode == 2 and wait and GameRules.GetGameTime() < wait then
      --   bot_active = false
      --   return
      -- end

      if attack_mode >= 2 then
        local curtime = GameRules.GetGameTime()
        if curtime > cancel_attack_in then
          Player.AttackTarget(Players.GetLocal(), myHero, target)
          local increasedAS = NPC.GetIncreasedAttackSpeed(myHero)
          local attackTime = NPC.GetAttackTime(myHero)
          -- local movementSpeed = NPC.GetMoveSpeed(myHero)
          local attackPoint
          local attackBackSwing
          for i, v in pairs(attackPointTable) do
              if i == NPC.GetUnitName(myHero) then
                  attackPoint = v[1] / (1 + (increasedAS/100))
                  attackBackSwing = v[2] / (1 + (increasedAS/100))
                  break
              end
          end
          local swing_animation = attackPoint
          cancel_attack_in = curtime + swing_animation / 2
          -- cancel_attack_in = curtime + 0.15
        else
          Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_STOP, myHero, origin, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_HERO_ONLY)
        end
      end
      -- if HitMaster.attack_delay and GameRules.GetGameTime() < HitMaster.attack_delay then return end
      -- HitMaster.attack_delay = 0
      -- if attack_mode == 2 then
      --   -- GET ATTACKERS
      --   for i, item in pairs(targets) do
      --     npc = item[14]
      --     if Entity.IsNPC(npc) and item[15] == target and Entity.GetHealth(npc) > 0 then
      --       target_origin = Entity.GetAbsOrigin(npc)
      --       distance = (origin - target_origin):Length()
      --       distance = distance - hero_collision_size
      --       if distance < 1000 then
      --           min_distance = distance
      --           target = npc
      --           attack_mode = item[13]
      --       end
      --     end
      --   end
      --   Player.AttackTarget(Players.GetLocal(), myHero, target)
      -- else
      --   Player.AttackTarget(Players.GetLocal(), myHero, target)
      -- end
      -- HitMaster.last_target = target
      Player.AttackTarget(Players.GetLocal(), myHero, target)

        -- if attack_mode == 1 then
        --   Player.AttackTarget(Players.GetLocal(), myHero, target)
        -- else
        --   local curtime = GameRules.GetGameTime()
        --   if cancel_attack_in and curtime >= cancel_attack_in then
        --     Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_STOP, myHero, origin, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_HERO_ONLY)
        --     cancel_attack_in = 0
        --   else
        --     Player.AttackTarget(Players.GetLocal(), myHero, target)
        --     local increasedAS = NPC.GetIncreasedAttackSpeed(myHero)
        --     local attackTime = NPC.GetAttackTime(myHero)
        --     -- local movementSpeed = NPC.GetMoveSpeed(myHero)
        --     local attackPoint
        --     local attackBackSwing
        --     for i, v in pairs(attackPointTable) do
        --         if i == NPC.GetUnitName(myHero) then
        --             attackPoint = v[1] / (1 + (increasedAS/100))
        --             attackBackSwing = v[2] / (1 + (increasedAS/100))
        --             break
        --         end
        --     end
        --     local swing_animation = attackTime / 2--attackTime + attackPoint / 2
        --     cancel_attack_in = curtime + swing_animation
        --   end
        -- end
    end

end


function HitMaster.OnDraw()
    if not Menu.IsEnabled(optionAwareness) then return end

    local myHero = Heroes.GetLocal()
    if not myHero then return end
    if not Entity.IsAlive(myHero) then
        targets = {}
        return
    end

    local attackRange = NPC.GetAttackRange(myHero)
    if attackRange > 250 and (NPC.HasItem(myHero, "item_dragon_lance", true) or NPC.HasItem(myHero, "item_hurricane_pike", true)) then
      attackRange = attackRange + 140
    end
    if attackRange < 1000 then attackRange = 1000 end
    local radius = attackRange
    local creeps = NPC.GetUnitsInRadius(myHero, radius, Enum.TeamType.TEAM_BOTH)

    local origin = Entity.GetAbsOrigin(myHero)

    count = 0
    for k,v in pairs(targets) do
         count = count + 1
    end
    -- We want to know
    local curtime = GameRules.GetGameTime()


    -- DEBUG
    local HEALTH_LIST_LEN = 20
    local NEXT_UPDATE = 0.1
    local REINIT_IN = 6

    local REINIT_IN2 = 6
    local HEALTH_LIST_LEN2 = 10
    local NEXT_UPDATE2 = 0.5

    local REINIT_IN3 = 150
    local HEALTH_LIST_LEN3 = 20
    local NEXT_UPDATE3 = 0.01

    local counter = 0

    --- from foosAIO.lua
    local increasedAS = NPC.GetIncreasedAttackSpeed(myHero)
    local attackTime = NPC.GetAttackTime(myHero)
    -- local movementSpeed = NPC.GetMoveSpeed(myHero)
    local attackPoint
    local attackBackSwing
    for i, v in pairs(attackPointTable) do
        if i == NPC.GetUnitName(myHero) then
            attackPoint = v[1] / (1 + (increasedAS/100))
            attackBackSwing = v[2] / (1 + (increasedAS/100))
            break
        end
    end
    -- local idleTime = attackTime - attackPoint - attackBackSwing
    --- /from foosAIO.lua

    local bullet_speed = projective_speed[NPC.GetUnitName(myHero)]

    for i, npc in ipairs(creeps) do
        counter = counter + 1
        local oneHitDamage = HitMaster.GetOneHitDamageVersus(myHero, npc)

        -- find closest targets if too many
        local target_origin = Entity.GetAbsOrigin(npc)

        -- if (NPC.IsCreep(npc) or NPC.IsTower(npc) or NPC.IsHero(npc) or NPC.IsStructure(npc) or NPC.IsBarracks(npc)) and not Entity.IsDormant(npc) and Entity.IsAlive(npc) then
        if NPC.IsKillable(npc) and not Entity.IsDormant(npc) and Entity.IsAlive(npc) then

            npc_id = Entity.GetIndex(npc)
            local health = Entity.GetHealth(npc)

            local x, y, visible = Renderer.WorldToScreen(target_origin)
            local size = 15

            local distance = (origin - target_origin):Length()
            local hero_collision_size = 24
            distance = distance - hero_collision_size / 2

            if targets[npc_id] == nil then
                -- targets[npc] = {
                --     health_avg = health
                -- }
                targets[npc_id] = {
                    {curtime + NEXT_UPDATE}, {health}, {health}, {REINIT_IN}, -- TIMESTAMP, HEALTH_LIST, INITIAL_HEALTH, REINIT_IN
                    {curtime + NEXT_UPDATE2}, {health}, {health}, {REINIT_IN2},
                    {curtime + NEXT_UPDATE3}, {health}, {health}, {REINIT_IN3},
                    0, npc, 999999, health, nil, 0, 0, 0 -- 0, npc, ATTACK_TARGET#15, HIT_IN#16, HEALTH_PREDICTION#17, PROJECTILE#18, FORECAST_HP#19, ATTACKERS_COUNT#20
                }
            end

            --if not NPC.IsRanged(npc) then
            if NPC.IsAttacking(npc) then
              if NPC.IsRanged(npc) then
                if targets[npc_id][15] ~= nil then
                  --targets[npc_id][16] = curtime + HitMaster.HitDelay(npc, targets[npc_id][15])
                -- else
                --   if targets[npc_id][16] = 999
                end
              else
                local target_at = target_origin + Entity.GetRotation(npc):GetForward():Normalized():Scaled(CREEP_MELEE_ATTACK_RANGE + CREEP_MELEE_HULL_SIZE)
                target = HitMaster.GetTarget(npc, target_at)
                if target ~= nil then
                  targets[npc_id][15] = target
                  --if targets[npc_id][16] == 0 then
                  if curtime - targets[npc_id][16] >= 0 then
                      targets[npc_id][16] = curtime + HitMaster.HitDelay(npc, target)
                  end
                else
                  targets[npc_id][15] = nil
                  targets[npc_id][16] = 0
                end
              end
            else
              targets[npc_id][15] = nil
              targets[npc_id][16] = 999999
            end
            --end

            if curtime > targets[npc_id][1][1] then
                table.insert(targets[npc_id][2], health)
                table.insert(targets[npc_id][6], health)
                targets[npc_id][1][1] = curtime + NEXT_UPDATE
                targets[npc_id][5][1] = curtime + NEXT_UPDATE
                if REINIT_IN then
                    targets[npc_id][4][1] = targets[npc_id][4][1] - 1
                    if targets[npc_id][4][1] < 1 then
                        targets[npc_id][3][1] = health
                    end
                end
                if REINIT_IN2 then
                    targets[npc_id][8][1] = targets[npc_id][8][1] - 1
                    if targets[npc_id][8][1] < 1 then
                        targets[npc_id][7][1] = health
                    end
                end

                if REINIT_IN3 then
                    targets[npc_id][12][1] = targets[npc_id][12][1] - 1
                    if targets[npc_id][12][1] < 1 then
                        targets[npc_id][11][1] = health
                    end
                end
            end

            local len = #targets[npc_id][2]
            if len == HEALTH_LIST_LEN then
                table.remove(targets[npc_id][2], 1)
                len = len - 1
            end

            local len2 = #targets[npc_id][6]
            if len2 == HEALTH_LIST_LEN2 then
                table.remove(targets[npc_id][6], 1)
                len2 = len2 - 1
            end

            local len3 = #targets[npc_id][10]
            if len3 == HEALTH_LIST_LEN3 then
                table.remove(targets[npc_id][10], 1)
                len3 = len3 - 1
            end

            local temp = 0
            for health_i, health_data in ipairs(targets[npc_id][2]) do
                temp = temp + health_data
            end
            avg_health = temp / len
            avg_damage = targets[npc_id][3][1] - avg_health

            temp = 0
            for health_i, health_data in ipairs(targets[npc_id][6]) do
                temp = temp + health_data
            end
            avg_health2 = temp / len
            avg_damage2 = targets[npc_id][7][1] - avg_health

            temp = 0
            for health_i, health_data in ipairs(targets[npc_id][10]) do
                temp = temp + health_data
            end
            avg_health2 = temp / len
            avg_damage3 = targets[npc_id][11][1] - avg_health

            local attack_time_full = attackTime + attackPoint + NPC.GetTimeToFace(myHero, npc) - attackBackSwing -- + attackBackSwing
            if bullet_speed > 0 then
                bullet_speed = bullet_speed
                attack_time_full = attack_time_full + (distance / bullet_speed)
            end
            attack_time_full = attack_time_full

            targets[npc_id][17] = HitMaster.PredictHealth(npc, attack_time_full * 2, oneHitDamage, npc_id)

            local target_regen = NPC.GetHealthRegen(npc) * (attack_time_full) -- + 5 -- 5 damage to fix slow attacks (they need this 5 points!!)

            local dps = avg_damage / NEXT_UPDATE / 60
            local time_to_death = math.abs(health / dps)
            local time_to_above_dead = math.abs((health + target_regen - oneHitDamage) / dps)

            local dps2 = avg_damage2 / NEXT_UPDATE2 / 60
            local time_to_death2 = math.abs(health / dps2)
            local time_to_above_dead2 = math.abs((health + target_regen - oneHitDamage) / dps2)


            local dps3 = avg_damage3 / NEXT_UPDATE3 / 60
            local time_to_death3 = math.abs(health / dps3)
            local time_to_above_dead3 = math.abs((health + target_regen - oneHitDamage) / dps3)

            local health_persent = health * 100 / Entity.GetMaxHealth(npc)
            if Entity.IsSameTeam(myHero, npc) then
              if NPC.IsCreep(npc) and health_persent > 50.0 then
                oneHitDamage = 0
              end
              if NPC.IsTower(npc) and health_persent > 10.0 then
                oneHitDamage = 0
              end
              if NPC.IsHero(npc) and health_persent > 25.0 then
                oneHitDamage = 0
              elseif NPC.IsHero(npc) and not NPC.HasModifier(npc, "modifier_doom_bringer_doom") and not NPC.HasModifier(npc, "modifier_queenofpain_shadow_strike") and not NPC.HasModifier(npc, "modifier_venomancer_venomous_gale") then
                oneHitDamage = 0
              end
            end

            time_to_above_dead = (time_to_above_dead + time_to_above_dead2 + time_to_above_dead3) / 3 -- * ( oneHitDamage / (math.abs(dps + dps2) / 2))

            -- UNCOMMENT ALL LATER TODO!!!
            if targets[npc_id][16] then
              if targets[npc_id][16] - curtime >= 0 then
                if targets[npc_id][15] ~= nil then
                  if NPC.IsRanged(npc) then
                    -- targets[npc_id][16] = curtime + HitMaster.RangedHitDelay(npc, targets[npc_id][15])
                  else
                    targets[npc_id][16] = curtime + HitMaster.HitDelay(npc, targets[npc_id][15])
                  end
                else
                  targets[npc_id][16] = 0
                end
              end

              if Entity.IsSameTeam(myHero, npc) then
                Renderer.SetDrawColor(0, 255, 0, 150)
              else
                Renderer.SetDrawColor(255, 0, 0, 150)
              end
              -- Renderer.DrawText(font, x, y + 5, 1 + math.floor(health / (oneHitDamage + 1)), 1)
              if targets[npc_id][19] > 0 then
                Renderer.DrawText(font, x, y + 5, targets[npc_id][19], 1)
              end
            end

            if health <= oneHitDamage then
                Renderer.SetDrawColor(255, 0, 0, 150)
                Renderer.DrawFilledRect(x-size, y-size, 2*size, 2*size)
                targets[npc_id][13] = 1
            elseif targets[npc_id][17] <= oneHitDamage then
                Renderer.SetDrawColor(0, 255, 0, 150)
                Renderer.DrawFilledRect(x-size, y-size, 2*size, 2*size)
                targets[npc_id][13] = 2
            elseif targets[npc_id][19] > 0 and targets[npc_id][19] <= oneHitDamage then
                Renderer.SetDrawColor(0, 0, 255, 50)
                Renderer.DrawFilledRect(x-size, y-size, 2*size, 2*size)
                targets[npc_id][13] = 3
            elseif time_to_above_dead <= attack_time_full and targets[npc_id][17] <= oneHitDamage then
                Renderer.SetDrawColor(255, 255, 0, 150)
                Renderer.DrawFilledRect(x-size, y-size, 2*size, 2*size)
                targets[npc_id][13] = 1
            end
        end
    end

    if LAST_REMOVE_INACTIVE < curtime then
        LAST_REMOVE_INACTIVE = curtime + REMOVE_INACTIVE_EVERY
        for k, v in pairs(targets) do
            if curtime - v[1][1] > NPC_INACTIVE_TIME then
                targets[k] = nil
            end
        end
    end
end


function HitMaster.OnProjectile(projectile) 
    if not projectile or not projectile.source or not projectile.target then return end
    if not projectile.isAttack then return end

    local myHero = Heroes.GetLocal()
    if projectile.source == myHero or Entity.IsDormant(projectile.source) then return end

    local npc = projectile.source
    if (not Entity.IsNPC(npc) and not NPC.IsHero(npc)) or Entity.GetHealth(npc) <= 0 then return end
    local target = projectile.target
    local npc_id = Entity.GetIndex(npc)

    -- HitMaster.Event(projectile.source, projectile.target)
    if targets[npc_id] ~= nil and NPC.IsKillable(target) then --(Entity.IsNPC(target) or NPC.IsHero(target)) then
      local curtime = GameRules.GetGameTime()
      targets[npc_id][15] = target
      targets[npc_id][16] = curtime + HitMaster.RangedHitDelay(npc, target, projectile.moveSpeed)-- curtime + HitMaster.RangedHitDelay(npc, target) -- + 1.0
      -- targets[npc_id][18] = projectile.origin
      -- Log.Write(HitMaster.RangedHitDelay(npc, target))
      -- if targets[npc_id][16] - curtime >= 0 then
      --   targets[npc_id][16] = curtime + HitMaster.HitDelay(npc, target) -- + 0.2 -- WTF??
      -- end
    end
end


function HitMaster.RangedHitDelay(npc, target, speed)
  local attack_time = 0
  -- local projective_collision = NPC.GetProjectileCollisionSize(npc)
  -- local entity_collision = NPC.GetHullRadius(npc)
  -- local target_collision = NPC.GetHullRadius(target)
  local distance = (Entity.GetAbsOrigin(npc) - Entity.GetAbsOrigin(target)):Length() -- + 12 + 12 -- HERO_COLLISION/2 + AVG_CREEP_COLLISION
  -- distance = distance + (entity_collision + target_collision) / 2 - (projective_collision / 2) --distance - ((entity_collision) + (target_collision / 2)) - (projective_collision / 2)
  -- local unit_name = NPC.GetUnitName(npc)
  -- for i, v in pairs(projective_speed) do
  --     if i == unit_name then
  --         attack_time = attack_time + (distance / v)
  --         break
  --     end
  -- end
  return (distance / speed)
end

function HitMaster.HitDelay(source, target)

    local increasedAS = NPC.GetIncreasedAttackSpeed(source)
    local attackTime = NPC.GetAttackTime(source)
    local attackPoint
    local attackBackSwing
    local unit_name = NPC.GetUnitName(source)

    for i, v in pairs(attackPointTable) do
        if i == unit_name then
            attackPoint = v[1] / (1 + (increasedAS/100))
            attackBackSwing = v[2] / (1 + (increasedAS/100))
            break
        end
    end

    if attackPoint == nil then
        Log.Write('nil attackPoint for'..unit_name)
    end

    local totalLatency = (NetChannel.GetAvgLatency(Enum.Flow.FLOW_INCOMING) + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING)) * 2
    local attack_time = attackTime + attackPoint + NPC.GetTimeToFace(source, target) + totalLatency + attackBackSwing
    -- HIT HAPPENS AT attackPoint!!!!!

    if Entity.GetHealth(source) > 0 and (NPC.IsRanged(source) or NPC.IsTower(source)) then
        local distance = (Entity.GetAbsOrigin(source) - Entity.GetAbsOrigin(target)):Length() -- + 12 -- HERO_COLLISION/2
        for i, v in pairs(projective_speed) do
            if i == unit_name then
                attack_time = attack_time + (distance / v)
                break
            end
        end
    end

    if NPC.IsRanged(source) then
      attack_time = attack_time -- * 2
    end

    -- if HitMaster.saved_time then -- I DID NOT GET IF IT WORKS..
    --     attack_time = attack_time - HitMaster.saved_time
    -- end

    return attack_time

end


function HitMaster.PredictHealth(source, time, damage, target_index)
    local curtime = GameRules.GetGameTime()
    local health = Entity.GetHealth(source)
    -- local attacked_for_time_health = health
    local totalLatency = (NetChannel.GetAvgLatency(Enum.Flow.FLOW_INCOMING) + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING)) / 2
    time = time + totalLatency
    local target_regen = (NPC.GetHealthRegen(source) * (time)) -- fix slow attacks (but not for 100%)
    -- health = health + target_regen
    -- for i, item in pairs(HitMaster.targets) do
    -- HitMaster.attack_delay = 0

    local myHero = Heroes.GetLocal()
      local increasedAS = NPC.GetIncreasedAttackSpeed(myHero)
      local attackTime = NPC.GetAttackTime(myHero)
      -- local movementSpeed = NPC.GetMoveSpeed(myHero)
      local attackPoint
      local attackBackSwing
      for i, v in pairs(attackPointTable) do
          if i == NPC.GetUnitName(myHero) then
              attackPoint = v[1] / (1 + (increasedAS/100))
              attackBackSwing = v[2] / (1 + (increasedAS/100))
              break
          end
      end
      local attackTime = NPC.GetAttackTime(myHero)
      local idleTime = attackTime - attackPoint - attackBackSwing

    local attacking_npc = {}
    local prehit_health = health
    for i, item in pairs(targets) do
      npc = item[14]
    -- for i = 1, hitmaster_targets-1 do
    --     item = HitMaster.targets[i]
        --npc = item[ENUM_NPC_SOURCE]
      -- if Entity.IsNPC(npc) and item[15] == source and Entity.GetHealth(npc) > 0 then
      if item[15] == source then
          local attacker_time = item[16] - curtime
          if NPC.IsRanged(npc) and attacker_time >= 0 and attacker_time <= time and Entity.GetHealth(npc) > 0 then
            -- local distance = (Entity.GetAbsOrigin(item[15]) - item[18]):Length() -- + 12 -- HERO_COLLISION/2
            -- local fly_time = 0
            -- for i, v in pairs(projective_speed) do
            --     if i == unit_name then
            --         fly_time = (distance / v)
            --         break
            --     end
            -- end
            -- if fly_time <= time then
            --   health = health - HitMaster.GetOneHitDamageVersus(npc, source)
            -- end
            hit_damage = HitMaster.GetOneHitDamageVersus(npc, source)
            health = health - hit_damage
            -- if HitMaster.HitDelay(npc, source) >= time / 2 then
              -- attacked_for_time_health = attacked_for_time_health - hit_damage
            -- end
            attacking_npc[npc_id] = {
              attacker_time, hit_damage, npc, i
            }
            -- if HitMaster.attack_delay < curtime + attacker_time then
            --   HitMaster.attack_delay = curtime + attacker_time
            -- end
          else
            -- if item[16] - curtime <= 0 then  -- targets[npc_id][16] - curtime
            if item[16] >= curtime and attacker_time >= 0 and attacker_time <= time and Entity.GetHealth(npc) > 0 then
              -- health = health - HitMaster.GetOneHitDamageVersus(npc, source)
              hit_damage = HitMaster.GetOneHitDamageVersus(npc, source)
              health = health - hit_damage
              -- if HitMaster.HitDelay(npc, source) >= time / 2 then
                -- attacked_for_time_health = attacked_for_time_health - hit_damage
              -- end
              -- attacking_npc[npc_id] = {
              --   attacker_time, hit_damage, npc, i
              -- }
              -- if attacker_time <= time then
              --   health = health - 
              --   -- health = health - (( attacker_time / time ) * HitMaster.GetOneHitDamageVersus(npc, source))
              --   -- HitMaster.saved_time =  curtime - item[16] - time
              --   -- if attacker_time / time >= 2 then
              --   --   health = health - HitMaster.GetOneHitDamageVersus(npc, source)
              --   -- end
              -- else
              --   health = health - (( attacker_time / time ) * HitMaster.GetOneHitDamageVersus(npc, source))
              -- end
            end
          end
      end
    end

    -- REWORK IT TO MAKE MORE CLEVER! TODO
    if health <= damage then
      local min_time = nil
      local index = nil
      table.sort(attacking_npc, HitMaster.sort_by_damage)
      for i, item in pairs(attacking_npc) do
        if health + item[2] > damage  then
          if min_time ~= nil then
            if min_time < item[1] then
              min_time = item[1]
              index = i
            end
          else
            min_time = item[1]
            index = i
          end
        end
      end

      if min_time then
        -- HitMaster.attack_delay = curtime + min_time
        -- targets[index][18] = curtime + min_time - (attackPoint * 0.5 + idleTime / 2)
        -- if attackPoint > min_time then
        --   min_time = min_time - attackPoint
        -- else
        --   min_time = min_time
        -- end
        min_time = min_time + (NetChannel.GetAvgLatency(Enum.Flow.FLOW_INCOMING) + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING)) / 2
        if NPC.IsRanged(myHero) then
          targets[index][18] = curtime + min_time * 1.5 -- - (attackTime + attackPoint * 0.98)
        else
          targets[index][18] = curtime + min_time * 1.5 -- - (attackPoint * 0.97) - NPC.GetTimeToFace(myHero, npc)
        end
        targets[target_index][13] = 2
      end
    else
      damage_for_time = prehit_health - health -- attacked_for_time_health
      if NPC.IsRanged(myHero) and health - damage_for_time <= damage and targets[target_index][18] < curtime and targets[target_index][20] == #attacking_npc then
      -- if attacked_for_time_health - damage_for_time <= damage and targets[target_index][20] == #attacking_npc then
        -- local multiplier = 0.1
        -- if not NPC.IsRanged(myHero) then
        --   multiplier = 1.0
        -- end
        local min_time = 0
        table.sort(attacking_npc, HitMaster.sort_by_damage)
        for i, item in pairs(attacking_npc) do
          min_time = min_time + item[1]
        end
        min_time = min_time / #attacking_npc

        targets[target_index][19] = health - damage_for_time
        targets[target_index][18] = curtime + min_time - attackTime-- time * multiplier --attackTime + NPC.GetTimeToFace(myHero, npc) + attackPoint * 0.85
        targets[target_index][20] = #attacking_npc
        targets[target_index][13] = 3
      end
    end
    return health -- * 1.45
end

function HitMaster.sort_by_damage(a, b)
  return a[2] < b[2]
end

function HitMaster.GetTarget(source, origin)

    local creeps = NPC.GetUnitsInRadius(source, CREEP_MELEE_ATTACK_RANGE + CREEP_MELEE_HULL_SIZE, Enum.TeamType.TEAM_ENEMY)
    if not creeps or #creeps <= 0 then return nil end
    local creeps_count = #creeps

    if creeps_count == 1 then return creeps[1] end

    local min_distance = CREEP_MELEE_ATTACK_RANGE + CREEP_MELEE_HULL_SIZE
    local closest_creep = nil
    for i = 1, creeps_count-1 do
        local pos = Entity.GetAbsOrigin(creeps[i])
        -- local mid = origin:__add(pos):Scaled(0.5)
        local distance = (pos - origin):Length()
        if distance <= min_distance then
            min_distance = distance
            closest_creep = creeps[i]
        end
    end

    return closest_creep

end

function HitMaster.GetOneHitDamageVersus(myHero, npc)
    if not myHero or not npc then return 0 end

    local damage = NPC.GetDamageMultiplierVersus(myHero, npc) * NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(npc) -- * 0.946

    -- if NPC.GetUnitName(myHero) == "npc_dota_hero_invoker" and Invoker.GetInstances(myHero) ~= "EEE" then
    --  local E = NPC.GetAbility(myHero, "invoker_exort")
    --  local extra_damage = 12 * Ability.GetLevel(E)
    --  damage = damage + extra_damage
    -- end
    if Heroes.GetLocal() == myHero then
      return damage - 5
    end
    return damage
end

return HitMaster
