GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })

AddComponentAction("INVENTORY", "weapon", function(inst, doer, actions)
    if inst.prefab == "yurik_camera" and inst.replica.equippable:IsEquipped() then
        table.insert(actions, ACTIONS.CHANGE_EQUIP)
    end
end)

local CHANGE_EQUIP = Action({ priority = 10, mount_valid = false })
CHANGE_EQUIP.id = "CHANGE_EQUIP"    -- 这个操作的 id  EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
CHANGE_EQUIP.str = "切换"
CHANGE_EQUIP.fn = function(act)
    -- 这个操作执行时进行的功能函数
    local obj = act.invobject or act.target
    local doer = act.doer or nil
    if doer and obj and obj.components.equippable:IsEquipped() then
        obj:Change()
    end
    return true
end

AddAction(CHANGE_EQUIP) -- 向游戏注册一个动作

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.CHANGE_EQUIP, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.CHANGE_EQUIP, "doshortaction"))

ACTIONS.CASTAOE.strfn = function(act)
    return act.invobject ~= nil and string.upper(act.invobject.prefab) or nil
end

local CastAoe_StrFn_Old = ACTIONS.CASTAOE.strfn
ACTIONS.CASTAOE.strfn = function(act)
    if act.doer and act.doer:HasTag("yuuri") and act.doer._skill:value() and act.invobject and act.invobject.prefab == "yurik_camera" then
        --print(ThePlayer._skill:value())
        return "YURIK_CAMERA" .. act.doer._skill:value()
    end

    return CastAoe_StrFn_Old(act)
end

STRINGS.ACTIONS.CASTAOE.YURIK_CAMERA0 = "空技能"
STRINGS.ACTIONS.CASTAOE.YURIK_CAMERA1 = "强化镜头：零"
STRINGS.ACTIONS.CASTAOE.YURIK_CAMERA2 = "强化镜头：迟"
STRINGS.ACTIONS.CASTAOE.YURIK_CAMERA3 = "强化镜头：生"

AddStategraphState("wilson",
        State {
            name = "yurik_shoot",
            tags = { "attack", "notalking", "abouttoattack", "nopredict", "busy" },

            onenter = function(inst)
                local buffaction = inst:GetBufferedAction()
                local target = buffaction ~= nil and buffaction.target or nil
                local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                inst.components.locomotor:Stop()

                if not inst.components.inventory:EquipHasTag("yurik_camera") then
                    inst.sg:GoToState("idle")
                    return
                end

                inst.AnimState:SetDeltaTimeMultiplier(0.7)
                inst.AnimState:PlayAnimation("punch")
                inst.SoundEmitter:PlaySound("camera_sound/camera_sound/camera_sound")

                if target ~= nil then
                    inst.components.combat:BattleCry()
                    if target:IsValid() then
                        inst:FacePoint(target:GetPosition())
                        inst.sg.statemem.attacktarget = target
                    end
                end

                inst.sg.statemem.weapon = equip

                inst.sg:SetTimeout(20 * FRAMES)
            end,

            ontimeout = function(inst)
                inst.sg:RemoveStateTag("attack")
                inst.sg:AddStateTag("idle")
            end,

            timeline = {
                TimeEvent(14 * FRAMES, function(inst)
                    local weapon = inst.sg.statemem.weapon
                    inst:PerformBufferedAction()
                    if weapon and weapon:IsValid() and weapon.gunshootsound then
                        inst.SoundEmitter:PlaySound(weapon and weapon.gunshootsound)
                    end
                    inst.sg:RemoveStateTag("abouttoattack")
                end),

                TimeEvent(20 * FRAMES, function(inst)
                    inst.sg:RemoveStateTag("attack")
                end),

                TimeEvent(23 * FRAMES, function(inst)
                    inst:ClearBufferedAction()
                    inst.sg:GoToState("idle")
                end),
            },

            onexit = function(inst)
                inst.AnimState:SetDeltaTimeMultiplier(1)
            end,

            events = {
                EventHandler("animover", function(inst)
                    inst.sg:GoToState("idle")
                end),
            },
        }
)

AddStategraphState("wilson_client",
        State {
            name = "yurik_shoot",
            tags = { "attack", "notalking", "abouttoattack", "busy" },

            onenter = function(inst)
                if not inst.replica.inventory:EquipHasTag("yurik_camera") then
                    inst.sg:GoToState("idle")
                    --print("返回")
                    return
                end

                if inst.replica.combat ~= nil then
                    inst.replica.combat:StartAttack()
                end

                --inst.SoundEmitter:PlaySound("camera_sound/camera_sound/camera_sound")
                inst.components.locomotor:Stop()

                local buffaction = inst:GetBufferedAction()
                if buffaction ~= nil then
                    inst:PerformPreviewBufferedAction()

                    if buffaction.target ~= nil and buffaction.target:IsValid() then
                        inst:FacePoint(buffaction.target:GetPosition())
                        inst.sg.statemem.attacktarget = buffaction.target
                    end
                end

                inst.sg:SetTimeout(20 * FRAMES)
            end,

            ontimeout = function(inst)
                inst.sg:RemoveStateTag("attack")
                inst.sg:AddStateTag("idle")
            end,

            timeline = {

                TimeEvent(17 * FRAMES, function(inst)
                    inst.sg:RemoveStateTag("abouttoattack")
                    inst:ClearBufferedAction()
                end),
                TimeEvent(20 * FRAMES, function(inst)
                    inst.sg:RemoveStateTag("attack")
                end),
                TimeEvent(22 * FRAMES, function(inst)
                    inst:ClearBufferedAction()
                    inst.sg:GoToState("idle")
                end),

            },

            events = {
                EventHandler("animover", function(inst)
                    inst.sg:GoToState("idle")
                end),
            },

            onexit = function(inst)
                if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
                    inst.replica.combat:CancelAttack()
                end
            end,
        }
)

local function NewAtk(sg)
    local old_handler = sg.actionhandlers[ACTIONS.ATTACK].deststate
    sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action)
        if inst.replica.inventory and inst.replica.inventory:EquipHasTag("yurik_camera") then
            return "yurik_shoot"

        else
            return old_handler(inst, action)
        end
    end
end

local function NewAtk_Client(sg)
    local old_handler = sg.actionhandlers[ACTIONS.ATTACK].deststate
    sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action)
        if inst.replica.inventory and inst.replica.inventory:EquipHasTag("yurik_camera") then
            return "yurik_shoot"

        else
            return old_handler(inst, action)
        end
    end
end

AddStategraphPostInit("wilson", NewAtk)
AddStategraphPostInit("wilson_client", NewAtk_Client)

AddStategraphPostInit("wilson", function(sg)
    local old_CASTAOE = sg.actionhandlers[ACTIONS.CASTAOE].deststate
    sg.actionhandlers[ACTIONS.CASTAOE].deststate = function(inst, action)
        local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local is_riding = inst.components.rider:IsRiding()

        if inst.components.inventory and inst.components.inventory:EquipHasTag("yurik_camera") and not is_riding then
            return "yurik_shoot"
        end
        return old_CASTAOE(inst, action)
    end
end)

AddStategraphPostInit("wilson_client", function(sg)
    local old_CASTAOE = sg.actionhandlers[ACTIONS.CASTAOE].deststate
    sg.actionhandlers[ACTIONS.CASTAOE].deststate = function(inst, action)
        local weapon = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local is_dead = inst.replica.health:IsDead()
        if inst.replica.inventory and inst.replica.inventory:EquipHasTag("yurik_camera") and not is_riding then
            return "yurik_shoot"
        end
        return old_CASTAOE(inst, action)
    end
end)

local function Yurik_Skill(inst, num)
    print(num)
    if inst.components.sanity and inst.components.sanity.current >= 80 then
        if num == 1 then
            inst:AddTag("Skill1_Cd")
            inst.components.timer:StartTimer("Skill1_Cd", 15)

        elseif num == 2 then
            inst:AddTag("Skill2_Cd")
            inst.components.timer:StartTimer("Skill2_Cd", 15)

        elseif num == 3 then
            inst:AddTag("Skill3_Cd")
            inst.components.timer:StartTimer("Skill3_Cd", 15)
        end

        inst.skill = num
        inst._skill:set(num)
        inst.components.sanity:DoDelta(-80)

    elseif inst.components.sanity and inst.components.sanity.current < 50 then
        inst.components.talker:Say("精神力不足！")
    end
end

AddModRPCHandler("yurik_skill", "yurik_skill", Yurik_Skill, num)

local function Yurri_Change(inst)
    if inst.components.inventory:EquipHasTag("yurik_camera") then
        local hand = inst ~= nil and inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
        if hand and hand.prefab == "yurik_camera" then
            hand:Change()
        end
    end
end

AddModRPCHandler("Yurri_Change", "Yurri_Change", Yurri_Change)

TheInput:AddKeyDownHandler(KEY_Z, function()
    local player = ThePlayer
    local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
    local IsHUDActive = screen and screen.name == "HUD"

    if player and player:HasTag("yuuri") and not player:HasTag("playerghost") and IsHUDActive then
        SendModRPCToServer(MOD_RPC["Yurri_Change"]["Yurri_Change"])
    end
end)


-- 灵石灯修改攻击范围

local function YuuriSpiritTorchRangeChange(inst)
    if inst.components.inventory:EquipHasTag("yuuri_spirit_torch") then
        local hand = inst ~= nil and inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
        if hand and hand.prefab == "yuuri_spirit_torch" then
            hand:Change()
        end
    end
end

AddModRPCHandler("YuuriSpiritTorchRangeChange", "YuuriSpiritTorchRangeChange", YuuriSpiritTorchRangeChange)

TheInput:AddKeyDownHandler(KEY_V, function()
    local player = ThePlayer
    local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
    local IsHUDActive = screen and screen.name == "HUD"

    if player and player:HasTag("yuuri") and not player:HasTag("playerghost") and IsHUDActive then
        SendModRPCToServer(MOD_RPC["YuuriSpiritTorchRangeChange"]["YuuriSpiritTorchRangeChange"])
    end
end)


