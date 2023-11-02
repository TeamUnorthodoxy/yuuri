local assets = {Asset("ANIM", "anim/yurik_ammo61.zip"),
                Asset("ATLAS", "images/inventoryimages/yurik_ammo61.xml"),
                Asset("IMAGE", "images/inventoryimages/yurik_ammo61.tex"),
                Asset("ATLAS_BUILD", "images/inventoryimages/yurik_ammo61.xml", 256)
            }

local function no_aggro(attacker, target)
    local targets_target = target.components.combat ~= nil and target.components.combat.target or nil
    return targets_target ~= nil and targets_target:IsValid() and targets_target ~= attacker and attacker:IsValid() and
               (GetTime() - target.components.combat.lastwasattackedbytargettime) < 4 and
               (targets_target.components.health ~= nil and not targets_target.components.health:IsDead())
end

local function ImpactFx(inst, attacker, target)
    if target ~= nil and target:IsValid() then
        local impactfx = SpawnPrefab(inst.ammo_def.impactfx)
        impactfx.Transform:SetPosition(target.Transform:GetWorldPosition())
        inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/rock")
    end
end

local function OnAttack(inst, attacker, target)
    if target ~= nil and target:IsValid() and attacker ~= nil and attacker:IsValid() then
        ImpactFx(inst, attacker, target)
    end
end

local function OnPreHit(inst, attacker, target)
    target.components.combat.temp_disable_aggro = no_aggro(attacker, target)
end

local function OnHit(inst, attacker, target)
    if target ~= nil and target:IsValid() and target.components.combat ~= nil then
        target.components.combat.temp_disable_aggro = false
    end
    inst:Remove()
end

local function OnMiss(inst, owner, target)
    inst:Remove()
end

local function fn(item)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeProjectilePhysics(inst)

    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetBank("yurik_ammo61")
    inst.AnimState:SetBuild("yurik_ammo61")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("molebait")
    inst:AddTag("slingshotammo")
    inst:AddTag("reloaditem_ammo")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("reloaditem")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.ELEMENTAL
    inst.components.edible.hungervalue = 1
    inst:AddComponent("tradable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "yurik_ammo61"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/yurik_ammo61.xml"

    inst:AddComponent("bait")
    MakeHauntableLaunch(inst)

   -- local item_id = string.upper(item.id)
   -- STRINGS.NAMES[item_id] = item.name
   -- STRINGS.CHARACTERS.GENERIC.DESCRIBE[item_id] = item.desc
   -- STRINGS.RECIPE_DESC[item_id] = item.desc2

    return inst
end

-- 以下为子弹发射中的状态属性
local function no_aggro(attacker, target)
    local targets_target = target.components.combat ~= nil and target.components.combat.target or nil
    return targets_target ~= nil and targets_target:IsValid() and targets_target ~= attacker and attacker:IsValid() and
               (GetTime() - target.components.combat.lastwasattackedbytargettime) < 4 and
               (targets_target.components.health ~= nil and not targets_target.components.health:IsDead())
end

local function ImpactFx(inst, attacker, target)
    if target ~= nil and target:IsValid() then
        local impactfx = SpawnPrefab("slingshotammo_hitfx_rock")
        impactfx.Transform:SetPosition(target.Transform:GetWorldPosition())
        inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/rock")
    end
end

local exclude_tags = { "INLIMBO", "companion", "wall", "abigail", "shadowminion" }
if not TheNet:GetPVPEnabled() then
    table.insert(exclude_tags, "player")
end

local function AreaAtk(inst, owner, target, damage)
    if target ~= nil and target:IsValid() then
        local x, y, z = target.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 4, { "_combat" }, exclude_tags) 
        for i, ent in ipairs(ents) do
            if ent ~= target and ent ~= owner and owner.components.combat:IsValidTarget(ent) and
                (owner.components.leader ~= nil and not owner.components.leader:IsFollower(ent)) then
                    owner:PushEvent("onareaattackother", { target = ent, weapon = inst, stimuli = nil })
                    ent.components.combat:GetAttacked(owner, damage, inst, nil)
            end
        end
    end
end

local function OnAttack(inst, attacker, target)
    if target ~= nil and target:IsValid() and attacker ~= nil and attacker:IsValid() then
        ImpactFx(inst, attacker, target)

        if attacker.components.inventory and attacker.components.inventory:EquipHasTag("AreaAtk") then
             local damage = inst.components.weapon:GetDamage(attacker, target) or 30
             AreaAtk(inst, attacker, target, damage)
        end    
    end
end


local function OnPreHit(inst, attacker, target)
    target.components.combat.temp_disable_aggro = no_aggro(attacker, target)
end

local function OnHit(inst, attacker, target)
    if target ~= nil and target:IsValid() and target.components.combat ~= nil then
        target.components.combat.temp_disable_aggro = false
    end
    inst:Remove()
end

local function OnMiss(inst, owner, target)
    inst:Remove()
end

local function fn_proj(item)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    MakeProjectilePhysics(inst)

    inst.AnimState:SetBank("yurik_ammo61")
    inst.AnimState:SetBuild("yurik_ammo61")
    inst.AnimState:PlayAnimation("spin_loop", true)

    -- projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(34)
    inst.components.weapon:SetOnAttack(OnAttack)
    inst.components.weapon.GetDamage = function(self,attacker, target)
        local mult = (attacker and attacker.components.inventory and attacker.components.inventory:EquipHasTag("AreaAtk") and 0.5) or 1

        if attacker and target and (target:HasTag("nightmare") or target:HasTag("shadow") or target:HasTag("shadowchesspiece")) then
            if target.components.lootdropper then
                --target.components.lootdropper.GenerateLoot = function(...) return {} end
            end
            return 68 * mult 
        end
        return self.damage * mult 
    end

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(25)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(1.5)
    inst.components.projectile:SetOnHitFn(OnPreHit)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnMiss)
    inst.components.projectile.range = 30
    inst.components.projectile.has_damage_set = true

    return inst
end

local ammo_prefabs = {}
local ammo = {
    {
        id = "yurik_ammo61",
       -- damage = 34,
       -- name = "61式胶卷",
       -- desc = "绿色包装的中等胶卷",
       -- desc2 = "手感……凑合事吧"
    },
}

for _, v in ipairs(ammo) do
    table.insert(ammo_prefabs, Prefab(v.id, function()
        return fn(v)
    end, assets))
    table.insert(ammo_prefabs, Prefab(v.id .. "_proj", function()
        return fn_proj(v)
    end, assets))
end

STRINGS.NAMES.YURIK_AMMO61 = "61式胶卷"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.YURIK_AMMO61 = [[绿色包装的中等胶卷]]
STRINGS.RECIPE_DESC.YURIK_AMMO61 = [[绿色包装的中等胶卷]]


return unpack(ammo_prefabs)
