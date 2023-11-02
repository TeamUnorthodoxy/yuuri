local assets=
{
    Asset("ANIM", "anim/yurikflashlight.zip"),
    Asset("ANIM", "anim/swap_yurikflashlight.zip"),
 
    Asset("ATLAS", "images/inventoryimages/yurikflashlight.xml"),
    Asset("IMAGE", "images/inventoryimages/yurikflashlight.tex"),
    Asset("ATLAS_BUILD", "images/inventoryimages/yurikflashlight.xml", 256)
}

local prefabs =
{
    "flashlight",
}

--[[local function fuelupdate(inst)
    if inst._light ~= nil then
        local fuelpercent = inst.components.fueled:GetPercent()
        inst._light.Light:SetIntensity(Lerp(.4, .6, fuelpercent))
        inst._light.Light:SetRadius(Lerp(3, 5, fuelpercent))
        inst._light.Light:SetFalloff(.9)
    end
end
]]
local function onremovelight(light)
    light._lantern._light = nil
end

local function stoptrackingowner(inst)
    if inst._owner ~= nil then
        inst:RemoveEventCallback("equip", inst._onownerequip, inst._owner)
        inst._owner = nil
    end
end

local function starttrackingowner(inst, owner)
    if owner ~= inst._owner then
        stoptrackingowner(inst)
        if owner ~= nil and owner.components.inventory ~= nil then
            inst._owner = owner
            inst:ListenForEvent("equip", inst._onownerequip, owner)
        end
    end
end

local function turnon(inst)
    --if not inst.components.fueled:IsEmpty() then
        --inst.components.fueled:StartConsuming()

        local owner = inst.components.inventoryitem.owner

        if inst._light == nil then
            inst._light = SpawnPrefab("flashlight")
            inst._light._lantern = inst
            inst:ListenForEvent("onremove", onremovelight, inst._light)
          --  fuelupdate(inst)

        end
        inst._light.entity:SetParent((owner or inst).entity)

        inst.AnimState:PlayAnimation("idle")

        inst.components.machine.ison = true
        inst:PushEvent("lantern_on")
    --end
end

local function turnoff(inst)
    stoptrackingowner(inst)

    --inst.components.fueled:StopConsuming()

    if inst._light ~= nil then
        inst._light:Remove()
    end

    inst.AnimState:PlayAnimation("idle")

    inst.components.machine.ison = false

    inst:PushEvent("lantern_off")
end

local function OnRemove(inst)
    if inst._light ~= nil then
        inst._light:Remove()
    end
    if inst._soundtask ~= nil then
        inst._soundtask:Cancel()
    end

end

local function ondropped(inst)
    turnoff(inst)
    turnon(inst)
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_yurikflashlight", "swap_yurikflashlight")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    local light = inst.entity:AddLight()
    light:SetFalloff(.6)
    light:SetIntensity(.9)
    light:SetRadius(10)
    light:Enable(true)
    light:SetColour(35/255, 35/255, 206/255)	
    inst.AnimState:SetBloomEffectHandle( "shaders/anim_haunted.ksh" )

    turnon(inst)

    --if inst.components.fueled:IsEmpty() then
    --
    --else
    --    turnon(inst)
    --end
end

local function onunequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")


    if inst.components.machine.ison then
        starttrackingowner(inst, owner)
    end

    --if inst.components.fueled:IsEmpty() then
    --
    --else
    --    turnoff(inst)
    --end
end

--local function nofuel(inst)
--    if inst.components.equippable:IsEquipped() and inst.components.inventoryitem.owner ~= nil then
--        local data =
--        {
--            prefab = inst.prefab,
--            equipslot = inst.components.equippable.equipslot,
--        }
--        turnoff(inst)
--        inst.components.inventoryitem.owner:PushEvent("torchranout", data)
--    else
--        turnoff(inst)
--    end
--end

--local function ontakefuel(inst)
--    if inst.components.equippable:IsEquipped() then
--        turnon(inst)
--    end
--end

--------------------------------------------------------------------------

local function OnLightWake(inst)
    if not inst.SoundEmitter:PlayingSound("loop") then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/lantern_LP", "loop")
    end
end

local function OnLightSleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

--------------------------------------------------------------------------

local function flashlightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    local light2 = inst.entity:AddLight()
    light2:SetFalloff(.6)
    light2:SetIntensity(.9)
    light2:SetRadius(9)
    light2:Enable(true)
    light2:SetColour(100/255, 100/255, 255/255)
  --  inst.Light:SetColour(100 / 255, 100 / 255, 150 / 255)


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.OnEntityWake = OnLightWake
    inst.OnEntitySleep = OnLightSleep

    return inst
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("yurikflashlight")
    inst.AnimState:SetBuild("yurikflashlight")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("light")

    MakeInventoryFloatable(inst, "med", 0.2, 0.65)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	
    inst.components.inventoryitem.imagename = "yurikflashlight"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/yurikflashlight.xml"
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(turnoff)
    inst.components.inventoryitem.keepondeath = true

    inst:AddComponent("equippable")
    inst.components.equippable.restrictedtag = "yurri"

    --inst:AddComponent("fueled")

    inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
    inst.components.machine.cooldowntime = 0

    --inst.components.fueled.fueltype = FUELTYPE.CAVE
    --
    --inst.components.fueled:InitializeFuelLevel(TUNING.LANTERN_LIGHTTIME*2)
    --inst.components.fueled:SetDepletedFn(nofuel)
    --inst.components.fueled:SetUpdateFn(fuelupdate)
    --inst.components.fueled:SetTakeFuelFn(ontakefuel)
    --inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
    --inst.components.fueled.accepting = true

    inst._light = nil

    MakeHauntableLaunch(inst)

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst.OnRemoveEntity = OnRemove

	inst:AddTag("shadow")

    inst._onownerequip = function(owner, data)
        if data.item ~= inst and
            (   data.eslot == EQUIPSLOTS.HANDS or
                (data.eslot == EQUIPSLOTS.BODY and data.item:HasTag("heavy"))
            ) then
            turnoff(inst)
        end
    end


    return inst
end


STRINGS.NAMES.YURIKFLASHLIGHT = "核能手电筒"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.YURIKFLASHLIGHT = [[质量过于神奇]]
STRINGS.RECIPE_DESC.YURIKFLASHLIGHT = [[质量过于神奇]]

return  Prefab("yurikflashlight", fn, assets,prefabs),
  Prefab("flashlight", flashlightfn)