local MakePlayerCharacter = require "prefabs/player_common"

local assets = {Asset("SCRIPT", "scripts/prefabs/player_common.lua")}
local prefabs = {}

-- Custom starting items
local start_inv = {"yurikmedicine", "yurikwater", "yurikfire", "yurikbattery", "yurikflashlight", "yurik_camera"}



-- When the character is revived from human
local function onbecamehuman(inst)
    
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "yurik_speed_mod", 1)
end

local function onbecameghost(inst)
    -- Remove speed modifier when becoming a ghost
    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "yurik_speed_mod")
end

-- inst.components.combat.externaldamagetakenmultipliers:SetModifier("易伤", 1.5)
-- inst.components.combat.externaldamagetakenmultipliers:RemoveModifier("易伤")

local function onmoisturedelta(inst, data)
    local moisture = data and data.new or inst.components.moisture.moisture
    -- Damage multiplier (optional)
    if moisture > 66 then
        inst.components.combat.damagemultiplier = 1.5
        inst.components.combat.externaldamagetakenmultipliers:SetModifier("easyhurt", 1.5)
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "yurik_speed_mod", 1.3)
    else
        if moisture > 33 then
            inst.components.combat.damagemultiplier = 1.25
            inst.components.combat.externaldamagetakenmultipliers:SetModifier("easyhurt", 1.25)
            inst.components.locomotor:SetExternalSpeedMultiplier(inst, "yurik_speed_mod", 1.2)
        else
            if moisture > 0 then
                inst.components.combat.damagemultiplier = 1.1
                inst.components.combat.externaldamagetakenmultipliers:RemoveModifier("easyhurt")
                inst.components.locomotor:SetExternalSpeedMultiplier(inst, "yurik_speed_mod", 1.1)
            else
                inst.components.combat.damagemultiplier = 1.0
                inst.components.combat.externaldamagetakenmultipliers:RemoveModifier("easyhurt")
                inst.components.locomotor:SetExternalSpeedMultiplier(inst, "yurik_speed_mod", 1)
            end
        end
    end
end

-- When loading or spawning the character
local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)
    inst:ListenForEvent("moisturedelta", onmoisturedelta)
    onmoisturedelta(inst)
    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
end

-- This initializes for both the server and client. Tags can be added here.
local common_postinit = function(inst)
    -- 潮湿不拖手（搬运）
    inst:AddTag("stronggrip")
    inst:AddTag("yuuri")
    -- Minimap icon
    inst.MiniMapEntity:SetIcon("yurik.tex")
    inst:AddTag("yurik_builder")

    inst._skill = net_ushortint(inst.GUID, "inst.skill", "skill_diraty")
    inst._skill:set(0)
end

-- This initializes for the server only. Components are added here.
local master_postinit = function(inst)
    -- 无潮湿脑残惩罚（搬运）
    inst.components.sanity.no_moisture_penalty = true

    inst.soundsname = "willow"

    inst.skill = 0

    inst.components.health:SetMaxHealth(75)
    inst.components.hunger:SetMax(150)
    inst.components.sanity:SetMax(250)

    -- 最喜欢的食物：万事屋红茶
    inst.components.foodaffinity:AddPrefabAffinity("yurikblacktea", TUNING.AFFINITY_15_CALORIES_TINY)

    -- Become waterproof?
    --inst:AddComponent("waterproofer")
    --inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_MED)

    -- Hunger rate (optional)
    inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE

    if inst.components.timer == nil then
        inst:AddComponent("timer")
    end  

    inst:ListenForEvent("timerdone", function(inst, data)--
        if data.name == "Skill1_Cd" and inst:HasTag("Skill1_Cd") then
              inst:RemoveTag("Skill1_Cd")                                                                                                                             
        end

        if data.name == "Skill2_Cd" and inst:HasTag("Skill2_Cd") then
              inst:RemoveTag("Skill2_Cd")                                                                                                                             
        end

        if data.name == "Skill3_Cd" and inst:HasTag("Skill3_Cd") then
              inst:RemoveTag("Skill3_Cd")                                                                                                                             
        end                   
    end)


    inst.OnLoad = onload
    inst.OnNewSpawn = onload

end

return MakePlayerCharacter("yurik", prefabs, assets, common_postinit, master_postinit, start_inv)


--[[
PERISH_ONE_DAY = 1*total_day_time*perish_warp,
PERISH_TWO_DAY = 2*total_day_time*perish_warp,
PERISH_SUPERFAST = 3*total_day_time*perish_warp,
PERISH_FAST = 6*total_day_time*perish_warp,
PERISH_FASTISH = 8*total_day_time*perish_warp,
PERISH_MED = 10*total_day_time*perish_warp,
PERISH_SLOW = 15*total_day_time*perish_warp,
PERISH_PRESERVED = 20*total_day_time*perish_warp,
PERISH_SUPERSLOW = 40*total_day_time*perish_warp,
]]