local assets =
{
    Asset("ANIM", "anim/yurikblacktea.zip"),
	
    Asset("ATLAS", "images/inventoryimages/yurikblacktea.xml"),
    Asset("IMAGE", "images/inventoryimages/yurikblacktea.tex"),

    Asset("ATLAS_BUILD", "images/inventoryimages/yurikblacktea.xml", 256)
}

local prefabs =
{
	"yurikblacktea_buff","yurikblacktea_buff2"
}


local function oneaten(inst, eater)
    if eater.components.moisture then
        eater.components.moisture:DoDelta(-100)   
     end

	if eater.components.debuffable ~= nil and eater.components.health ~= nil and not eater.components.health:IsDead() and not eater:HasTag("plantkin") then
		eater.components.debuffable:AddDebuff("yurikblacktea_buff", "yurikblacktea_buff")
        --eater.components.debuffable:AddDebuff("yurikblacktea_buff2", "yurikblacktea_buff2")
	end
end 

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("yurikblacktea")
    inst.AnimState:SetBuild("yurikblacktea")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    ---------------------

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "yurikblacktea"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/yurikblacktea.xml"
    
	inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
    inst:AddComponent("tradable")

	inst:AddComponent("edible")  
    inst.components.edible.foodtype = FOODTYPE.GOODIES
    inst.components.edible.healthvalue = 10
    inst.components.edible.hungervalue = 15
    inst.components.edible.sanityvalue = 25
    inst.components.edible:SetOnEatenFn(oneaten)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    return inst

end

--local function DoT_OnTick(inst, target)
--	if target.components.talker ~= nil and target.components.health ~= nil and not target.components.health:IsDead() and target:HasTag("idle") then
--		target.components.talker:Say(GetString(target, "ANNOUNCE_FIRENETTLE_TOXIN"))
--	end
--end

local function OnTick(inst, target)
    if target.components.health ~= nil
        and not target.components.health:IsDead()
		and target.components.sanity ~= nil
        and not target:HasTag("playerghost") then
        target.components.sanity:DoDelta(TUNING.SWEETTEA_SANITY_DELTA)
    else
        inst.components.debuff:Stop()
    end
end



local function buff_OnAttached(inst, target)
	inst.entity:SetParent(target.entity)
	inst.Transform:SetPosition(0, 0, 0)
    inst.task = inst:DoPeriodicTask(TUNING.SWEETTEA_TICK_RATE, OnTick, nil, target)

    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)


    
	if target.components.temperature ~= nil then
		target.components.temperature:SetModifier("yurikblacktea_buff", 30)
	end
   -- inst:DoPeriodicTask(10, DoT_OnTick, 5, target)
end

local function buff_OnDetached(inst, target)
	if target ~= nil and target:IsValid() and target.components.temperature ~= nil then
		target.components.temperature:RemoveModifier("yurikblacktea_buff")

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

local function OnTick2(inst, target)
    if target.components.health ~= nil
        and not target.components.health:IsDead()
		and target.components.sanity ~= nil
        and not target:HasTag("playerghost") then
        target.components.sanity:DoDelta(TUNING.SWEETTEA_SANITY_DELTA)
    else
        inst.components.debuff:Stop()
    end
end

local function OnAttached2(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) --in case of loading
    inst.task = inst:DoPeriodicTask(TUNING.SWEETTEA_TICK_RATE, OnTick2, nil, target)
    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)
end

local function OnTimerDone2(inst, data)
    if data.name == "regenover" then
        inst.components.debuff:Stop()
    end
end

local function OnExtended2(inst, target)
    inst.components.timer:StopTimer("regenover")
    inst.components.timer:StartTimer("regenover", TUNING.SWEETTEA_DURATION)
    inst.task:Cancel()
    inst.task = inst:DoPeriodicTask(TUNING.SWEETTEA_TICK_RATE, OnTick, nil, target)
end

local function debuff_fn2()
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        --Not meant for client!
        inst:DoTaskInTime(0, inst.Remove)

        return inst
    end

    inst.entity:AddTransform()

    --Non-networked entity
    --inst.entity:SetCanSleep(false)
    inst.entity:Hide()
    inst.persists = false

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached2)
    inst.components.debuff:SetDetachedFn(inst.Remove)
    inst.components.debuff:SetExtendedFn(OnExtended2)
    inst.components.debuff.keepondespawn = true

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("regenover", TUNING.SWEETTEA_DURATION * 2)
    inst:ListenForEvent("timerdone", OnTimerDone2)

    return inst
end


STRINGS.NAMES.YURIKBLACKTEA = "万事屋红茶"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.YURIKBLACKTEA = [[温暖人心的密花姐秘制红茶]]
STRINGS.RECIPE_DESC.YURIKBLACKTEA = [[温暖人心的密花姐秘制红茶]]

return Prefab("yurikblacktea", fn, assets,prefabs),
Prefab("yurikblacktea_buff", debuff_fn, assets),
Prefab("yurikblacktea_buff2", debuff_fn2, assets)