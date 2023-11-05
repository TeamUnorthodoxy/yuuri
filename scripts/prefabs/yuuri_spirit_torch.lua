--MIT License
--
--Copyright (c) 2023 TeamUnorthodoxy
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

---
--- Spirit Torch from Choshiro Kirishima
---
--- @author LiLittleCat
--- @since 2023-11-04
--- @version 2.0.0
---

local assets = {
    Asset("ANIM", "anim/yuuri_spirit_torch.zip"),
    Asset("ANIM", "anim/swap_yuuri_spirit_torch.zip"),
    -- 近战模式武器图标
    Asset("ATLAS", "images/inventoryimages/yuuri_spirit_torch.xml"),
    Asset("IMAGE", "images/inventoryimages/yuuri_spirit_torch.tex"),
    Asset("ATLAS_BUILD", "images/inventoryimages/yuuri_spirit_torch.xml", 256),
    -- 远程模式武器图标
    Asset("ATLAS", "images/inventoryimages/yuuri_spirit_torch2.xml"),
    Asset("IMAGE", "images/inventoryimages/yuuri_spirit_torch2.tex"),
    Asset("ATLAS_BUILD", "images/inventoryimages/yuuri_spirit_torch2.xml", 256),
}

local prefabs = {
    "yuuri_spirit_torch",
    "flashlight"
}

local function StopTrackingOwner(inst)
    if inst._owner ~= nil then
        inst:RemoveEventCallback("equip", inst._onownerequip, inst._owner)
        inst._owner = nil
    end
end

local function StartTrackingOwner(inst, owner)
    if owner ~= inst._owner then
        StopTrackingOwner(inst)
        if owner ~= nil and owner.components.inventory ~= nil then
            inst._owner = owner
            inst:ListenForEvent("equip", inst._onownerequip, owner)
        end
    end
end

local function OnRemove(inst)
    if inst._light ~= nil then
        inst._light:Remove()
    end
    if inst._soundtask ~= nil then
        inst._soundtask:Cancel()
    end
end

local function OnRemoveLight(light)
    light._lantern._light = nil
end

local function TurnOn(inst)
    --if not inst.components.fueled:IsEmpty() then
    --inst.components.fueled:StartConsuming()

    local owner = inst.components.inventoryitem.owner

    if inst._light == nil then
        inst._light = SpawnPrefab("flashlight")
        inst._light._lantern = inst
        inst:ListenForEvent("onremove", OnRemoveLight, inst._light)
        --  fuelupdate(inst)
    end
    inst._light.entity:SetParent((owner or inst).entity)
    inst.AnimState:PlayAnimation("idle")
    inst.components.machine.ison = true
    inst:PushEvent("lantern_on")
    --end
end

local function TurnOff(inst)
    StopTrackingOwner(inst)
    --inst.components.fueled:StopConsuming()
    if inst._light ~= nil then
        inst._light:Remove()
    end
    inst.AnimState:PlayAnimation("idle")
    inst.components.machine.ison = false
    inst:PushEvent("lantern_off")
end

local function OnDropped(inst)
    TurnOff(inst)
    TurnOn(inst)
end

-- 近战攻击数值，范围和伤害
meleeAtk = {
    range = 2,
    damage = 85
}

-- 远程攻击数值，范围和伤害
rangeAtk = {
    range = 6,
    damage = 34
}

local function CreateNewWeapon(inst, damage, range)
    inst:RemoveComponent("weapon")
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(damage)
    inst.components.weapon:SetRange(range, range)
    --inst.components.weapon:SetOnProjectileLaunched(OnProjectileLaunched)
    inst.components.weapon:SetProjectile(nil)
    -- inst.components.weapon:SetProjectile("yurik_arrow")
    inst.components.weapon:SetProjectileOffset(1)
    inst.components.weapon.GetDamage = function(self, attacker, target)
        if attacker and target and (target:HasTag("nightmare") or target:HasTag("shadow") or target:HasTag("shadowchesspiece")) then
            if target.components.lootdropper then
                --target.components.lootdropper.GenerateLoot = function(...) return {} end
            end
            return self.damage * 2
        end
        return self.damage
    end
end

local function OnChangeAtk(inst)
    if inst ~= nil then
        if inst.components.weapon.damage == meleeAtk.damage then
            -- 近战切远程
            CreateNewWeapon(inst, rangeAtk.damage, rangeAtk.range)
            inst.components.inventoryitem.atlasname = "images/inventoryimages/yuuri_spirit_torch2.xml"
            inst.components.inventoryitem:ChangeImageName("yuuri_spirit_torch2")
        else
            -- 远程切近战
            CreateNewWeapon(inst, meleeAtk.damage, meleeAtk.range)
            inst.components.inventoryitem.atlasname = "images/inventoryimages/yuuri_spirit_torch.xml"
            inst.components.inventoryitem:ChangeImageName("yuuri_spirit_torch")
        end
    end
end

local function OnEquip(inst, owner)
    --local skin_build = inst:GetSkinBuild()
    --if skin_build ~= nil then
    --    owner:PushEvent("equipskinneditem", inst:GetSkinName())
    --    owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_yuuri_spirit_torch", inst.GUID, "swap_yuuri_spirit_torch")
    --else
    --    owner.AnimState:OverrideSymbol("swap_object", "swap_yuuri_spirit_torch", "swap_yuuri_spirit_torch")
    --end
    --owner.AnimState:Show("ARM_carry")
    --owner.AnimState:Hide("ARM_normal")

    owner.AnimState:OverrideSymbol("swap_object", "swap_yuuri_spirit_torch", "swap_yuuri_spirit_torch")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    local light = inst.entity:AddLight()
    light:SetFalloff(.6)
    light:SetIntensity(.9)
    light:SetRadius(1)
    light:Enable(true)
    light:SetColour(35 / 255, 35 / 255, 206 / 255)
    inst.AnimState:SetBloomEffectHandle("shaders/anim_haunted.ksh")

    TurnOn(inst)

    --if inst.components.fueled:IsEmpty() then
    --
    --else
    --    turnon(inst)
    --end
end

local function OnUnEquip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    if inst.components.machine.ison then
        StartTrackingOwner(inst, owner)
    end

    --if inst.components.fueled:IsEmpty() then
    --
    --else
    --    turnoff(inst)
    --end
end

local function OnTimerDone(inst, data)
    if data.name == "repair" then
        local finiteuses = inst.components.finiteuses
        if finiteuses:GetUses() ~= finiteuses.total then
            finiteuses:Repair(1)
        end
        -- 重启计时器
        inst.components.timer:StartTimer("repair", 5)
    end
end

local function SetupComponents(inst)
    inst:AddComponent("equippable")
    inst.components.equippable.restrictedtag = "yuuri"
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnEquip)
    CreateNewWeapon(inst, meleeAtk.damage, meleeAtk.range)
end

local function DisableComponents(inst)
    inst:RemoveComponent("equippable")
    inst:RemoveComponent("weapon")
end

local FLOAT_SCALE_BROKEN = { 1, 0.7, 1 }
local FLOAT_SCALE = { 1, 0.4, 1 }

local function OnIsBrokenDirty(inst)
    if inst.isbroken:value() then
        inst.components.floater:SetSize("small")
        inst.components.floater:SetVerticalOffset(0.05)
        inst.components.floater:SetScale(FLOAT_SCALE_BROKEN)
    else
        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.05)
        inst.components.floater:SetScale(FLOAT_SCALE)
    end
end

local SWAP_DATA_BROKEN = { bank = "yuuri_spirit_torch", anim = "broken" }
local SWAP_DATA = { sym_build = "yuuri_spirit_torch", sym_name = "swap_yuuri_spirit_torch" }

local function SetIsBroken(inst, isbroken)
    if isbroken then
        inst.components.floater:SetBankSwapOnFloat(false, nil, SWAP_DATA_BROKEN)
    else
        inst.components.floater:SetBankSwapOnFloat(true, -17.5, SWAP_DATA)
    end
    inst.isbroken:set(isbroken)
    OnIsBrokenDirty(inst)
end

local function OnBroken(inst)
    if inst.components.equippable ~= nil then
        DisableComponents(inst)
        inst.AnimState:PlayAnimation("broken")
        SetIsBroken(inst, true)
        inst:AddTag("broken")
        inst.components.inspectable.nameoverride = "BROKEN_FORGEDITEM"
    end
end

local function OnRepaired(inst)
    if inst.components.equippable == nil then
        SetupComponents(inst)
        inst.blade1.AnimState:SetFrame(0)
        inst.blade2.AnimState:SetFrame(0)
        inst.AnimState:PlayAnimation("idle", true)
        SetIsBroken(inst, false)
        inst:RemoveTag("broken")
        inst.components.inspectable.nameoverride = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    --inst.AnimState:SetBank("yuuri_spirit_torch")
    --inst.AnimState:SetBuild("yuuri_spirit_torch")
    inst.AnimState:SetBank("yuuri_spirit_torch")
    inst.AnimState:SetBuild("yuuri_spirit_torch")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("light")

    MakeInventoryFloatable(inst, "med", 0.2, 0.65)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false

    inst.Change = OnChangeAtk

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "yuuri_spirit_torch"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/yuuri_spirit_torch.xml"
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(TurnOff)
    inst.components.inventoryitem.keepondeath = true

    inst:AddComponent("equippable")
    inst.components.equippable.restrictedtag = "yuuri"
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnEquip)

    inst.OnRemoveEntity = OnRemove

    inst:AddComponent("machine")
    inst.components.machine.turnonfn = TurnOn
    inst.components.machine.turnofffn = TurnOff
    inst.components.machine.cooldowntime = 0

    inst:AddTag("weapon")
    inst:AddTag("yuuri_spirit_torch")

    CreateNewWeapon(inst, meleeAtk.damage, meleeAtk.range)

    -- 开启耐久
    local finiteuses = inst:AddComponent("finiteuses")
    finiteuses:SetMaxUses(TUNING.NIGHTSWORD_USES)
    finiteuses:SetUses(TUNING.NIGHTSWORD_USES)
    -- 定时修复
    inst:AddComponent("timer")
    inst.components.timer:StartTimer("repair", 5)
    inst:ListenForEvent("timerdone", OnTimerDone)
    -- 破损不消失
    MakeForgeRepairable(inst, nil, OnBroken, OnRepaired)

    -- 灯
    inst._light = nil

    MakeHauntableLaunch(inst)

    inst._onownerequip = function(owner, data)
        if data.item ~= inst and
                (data.eslot == EQUIPSLOTS.HANDS or
                        (data.eslot == EQUIPSLOTS.BODY and data.item:HasTag("heavy"))
                ) then
            TurnOff(inst)
        end
    end

    return inst

end

STRINGS.NAMES.YUURI_SPIRIT_TORCH = "灵石灯"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.YUURI_SPIRIT_TORCH = [[雾岛长四郎使用过的武器]]
STRINGS.RECIPE_DESC.YUURI_SPIRIT_TORCH = [[雾岛长四郎使用过的武器]]

return Prefab("yuuri_spirit_torch", fn, assets, prefabs)