local assets =
{
    Asset("ANIM", "anim/yurikwater.zip"),
	
    Asset("ATLAS", "images/inventoryimages/yurikwater.xml"),
    Asset("IMAGE", "images/inventoryimages/yurikwater.tex"),
    Asset("ATLAS_BUILD", "images/inventoryimages/yurikwater.xml", 256)
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("yurikwater")
    inst.AnimState:SetBuild("yurikwater")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("cattoy")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    ---------------------

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "yurikwater"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/yurikwater.xml"
    
	inst:AddComponent("stackable")
	
    inst:AddComponent("tradable")

    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(120)


	--inst.components.edible:SetOnEatenFn(function(inst,eater)  
	  --  if eater.components.moisture then
           --eater.components.moisture:DoDelta(50)   
        --end
      --end)

    return inst
end

STRINGS.NAMES.YURIKWATER = "御神水"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.YURIKWATER = [[日上山的治疗妹汁]]
STRINGS.RECIPE_DESC.YURIKWATER = [[日上山的治疗妹汁]]

return Prefab("yurikwater", fn, assets)