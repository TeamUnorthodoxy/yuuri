local assets =
{
    Asset("ANIM", "anim/yurikmedicine.zip"),
	
    Asset("ATLAS", "images/inventoryimages/yurikmedicine.xml"),
    Asset("IMAGE", "images/inventoryimages/yurikmedicine.tex"),
    Asset("ATLAS_BUILD", "images/inventoryimages/yurikmedicine.xml", 256)
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("yurikmedicine")
    inst.AnimState:SetBuild("yurikmedicine")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("cattoy")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    ---------------------

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "yurikmedicine"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/yurikmedicine.xml"
    
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst:AddComponent("tradable")
 
    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(45)

    return inst
end

STRINGS.NAMES.YURIKMEDICINE = "万叶丸"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.YURIKMEDICINE = [[日上山的治疗小药丸]]
STRINGS.RECIPE_DESC.YURIKMEDICINE = [[日上山的治疗小药丸]]

return Prefab("yurikmedicine", fn, assets)