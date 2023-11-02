local assets =
{
    Asset("ANIM", "anim/yurikbattery.zip"),
	
    Asset("ATLAS", "images/inventoryimages/yurikbattery.xml"),
    Asset("IMAGE", "images/inventoryimages/yurikbattery.tex"),
    Asset("ATLAS_BUILD", "images/inventoryimages/yurikbattery.xml", 256) 
} 

local function OnDropped(inst)
    inst.Light:Enable(true)
end

local function OnPickup(inst)
    inst.Light:Enable(false)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("yurikbattery")
    inst.AnimState:SetBuild("yurikbattery")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("lightbattery")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")
    
    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LANTERN_LIGHTTIME
    inst.components.fuel.fueltype = FUELTYPE.CAVE
    --inst.components.fuel.fueltype = "battery"

    MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "yurikbattery"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/yurikbattery.xml"

    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPickupFn(OnPickup)

    return inst
end

STRINGS.NAMES.YURIKBATTERY = "电池"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.YURIKBATTERY = [[一节更比十六节强]]
STRINGS.RECIPE_DESC.YURIKBATTERY = [[一节更比十六节强]]

return Prefab("yurikbattery", fn, assets)