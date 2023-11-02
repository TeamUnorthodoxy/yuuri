local assets =
{
    Asset("ANIM", "anim/yurikfire.zip"),
	
    Asset("ATLAS", "images/inventoryimages/yurikfire.xml"),
    Asset("IMAGE", "images/inventoryimages/yurikfire.tex"),

    Asset("ATLAS_BUILD", "images/inventoryimages/yurikfire.xml", 256)
}

local prefabs =
{
	"yurikfire_toxin",
}


local function oneaten(inst, eater)
    if eater.components.moisture then
        eater.components.moisture:DoDelta(-100)   
     end

	if eater.components.debuffable ~= nil and eater.components.health ~= nil and not eater.components.health:IsDead() and not eater:HasTag("plantkin") then
		eater.components.debuffable:AddDebuff("yurikfire_toxin", "yurikfire_toxin")
	end
end 

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("yurikfire")
    inst.AnimState:SetBuild("yurikfire")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("cattoy")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    ---------------------

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "yurikfire"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/yurikfire.xml"
    
	inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
    inst:AddComponent("tradable")

	inst:AddComponent("edible")  
    inst.components.edible.foodtype = FOODTYPE.GOODIES
    inst.components.edible.healthvalue = 3
    inst.components.edible.hungervalue = 3
    inst.components.edible.sanityvalue = 35
    inst.components.edible:SetOnEatenFn(oneaten)

    return inst

end

--local function DoT_OnTick(inst, target)
--	if target.components.talker ~= nil and target.components.health ~= nil and not target.components.health:IsDead() and target:HasTag("idle") then
--		target.components.talker:Say(GetString(target, "ANNOUNCE_FIRENETTLE_TOXIN"))
--	end
--end

local function buff_OnAttached(inst, target)
	inst.entity:SetParent(target.entity)
	inst.Transform:SetPosition(0, 0, 0)

    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)

	if target.components.temperature ~= nil then
		target.components.temperature:SetModifier("yurikfire_toxin", 30)
	end
   -- inst:DoPeriodicTask(10, DoT_OnTick, 5, target)
end

local function buff_OnDetached(inst, target)
	if target ~= nil and target:IsValid() and target.components.temperature ~= nil then
		target.components.temperature:RemoveModifier("yurikfire_toxin")

		--if target.components.talker ~= nil and target.components.health ~= nil and not target.components.health:IsDead() then
		--	target.components.talker:Say(GetString(target, "ANNOUNCE_FIRENETTLE_TOXIN_DONE"))
		--end
	end
    inst:Remove()
end

local function expire(inst)
	if inst.components.debuff ~= nil then
		inst.components.debuff:Stop()
	end
end

local function buff_OnExtended(inst)
	if inst.task ~= nil then
		inst.task:Cancel()
	end
	inst.task = inst:DoTaskInTime(120, expire)
end

local function OnSave(inst, data)
	if inst.task ~= nil then
		data.remaining = GetTaskRemaining(inst.task)
	end
end


local function OnLoad(inst, data)
    inst:ListenForEvent("eat", fn)
	if data ~= nil and data.remaining then
		if inst.task ~= nil then
			inst.task:Cancel()
		end
        inst.task = inst:DoTaskInTime(data.remaining, expire)	
	end
end

local function debuff_fn(anim)
	local inst = CreateEntity()

    if not TheWorld.ismastersim then
        --Not meant for client!
        inst:DoTaskInTime(0, inst.Remove)

        return inst
    end

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false)
    inst.entity:Hide()

    inst:AddTag("CLASSIFIED")

	inst:AddComponent("debuff")
	inst.components.debuff:SetAttachedFn(buff_OnAttached)
	inst.components.debuff:SetDetachedFn(buff_OnDetached)
	inst.components.debuff:SetExtendedFn(buff_OnExtended)
	inst.components.debuff.keepondespawn = true

	buff_OnExtended(inst)

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

	return inst
end

STRINGS.NAMES.YURIKFIRE = "清净之火"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.YURIKFIRE = [[知道什么叫暖气么]]
STRINGS.RECIPE_DESC.YURIKFIRE = [[知道什么叫暖气么]]

return Prefab("yurikfire", fn, assets,prefabs),
Prefab("yurikfire_toxin", debuff_fn, assets)