local assets =
{
    Asset("ANIM", "anim/spiritbolt.zip"),
}

local function common(anim, bloom)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("projectile")
    inst.AnimState:SetBuild("spiritbolt")
    inst.AnimState:PlayAnimation(anim, true)
    if bloom ~= nil then
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end

    inst:AddTag("projectile")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()
	
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(30)
    inst.components.projectile:SetOnHitFn(inst.Remove)
    inst.components.projectile:SetOnMissFn(inst.Remove)
	
    return inst
end

local function ice()
    return common("ice_spin_loop")
end

local function fire()
    return common("spiritbolt_spin_loop", "shaders/anim.ksh")
end

return Prefab("common/inventory/ice_projectile", ice, assets), 
       Prefab("common/inventory/spiritbolt", fire, assets)