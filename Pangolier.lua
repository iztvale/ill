local sword= {}

sword.optionEnable = Menu.AddOption({ "Hero Specific","sword"}, "Enabled", "Auto sword")
sword.optionSword = Menu.AddKeyOption({ "Hero Specific","sword"}, "Sword Key", Enum.ButtonCode.KEY_P)

-- this will be set later (only once) inside of OnUpdate.
sword.swordRadius = 125
sword.swordLength = 1000
sword.dashLength = 900
sword.dashSpeed = 2000
sword.font = Renderer.LoadFont("Tahoma", 50, Enum.FontWeight.EXTRABOLD)

function sword.OnUpdate()
    if not Menu.IsEnabled(sword.optionEnable) then return end
    castSword()
end

function castSword()

    if not Menu.IsKeyDownOnce(sword.optionSword) then return end

    local myHero = Heroes.GetLocal()
    local player = Players.GetLocal();
    local skill = NPC.GetAbility(myHero, "pangolier_swashbuckle");
    if not skill then return end

    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    if not enemy then return end

    local x, y, vis = Renderer.WorldToScreen(Entity.GetAbsOrigin(enemy))
    Renderer.DrawTextCentered(sword.font, x, y, "Here", 1)

    local mousePos = Input.GetWorldCursorPos()
    local predictPos = sword.PredictPosition(enemy,Entity.GetAbsOrigin(myHero), Entity.GetAbsOrigin(enemy))
    Player.PrepareUnitOrders(player, 30, nil, mousePos, skill, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_HERO_ONLY, myHero, false, true)
    Player.PrepareUnitOrders(player, 30, nil, predictPos, skill, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_HERO_ONLY, myHero, false, true)
    Player.PrepareUnitOrders(player, 5, nil, mousePos, skill, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_HERO_ONLY, myHero, false, true)
end

function sword.PredictPosition(enemy, myHeroPos, mousePos)
    if NPC.IsRunning(enemy) then
        local distance = (mousePos - myHeroPos)
        distance =distance:Length2D()
        local duration = distance/sword.dashSpeed
        return sword.processHero(enemy, duration)
    end 
    
    return NPC.GetAbsOrigin(enemy)
end 

function sword.processHero(enemy, duration)
    local speed = NPC.GetMoveSpeed(enemy)
    local angle = Entity.GetRotation(enemy)
    local angleOffset = Angle(0, 45, 0)
    angle:SetYaw(angle:GetYaw() + angleOffset:GetYaw())
    local x,y,z = angle:GetVectors()
    local direction = x + y + z
    local name = NPC.GetUnitName(enemy)
    direction:SetZ(0)
    direction:Normalize()
    direction:Scale(speed*duration)

    local origin = NPC.GetAbsOrigin(enemy)
    return origin + direction
end 
-- function sword.OnPrepareUnitOrders(orders)
--     Log.Write(orders.order)
--     return true
-- end
return sword