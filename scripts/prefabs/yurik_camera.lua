local assets = {Asset("ANIM", "anim/yurik_camera.zip"), 
                Asset("ANIM", "anim/swap_yurik_camera.zip"),

                Asset("ATLAS", "images/inventoryimages/yurik_camera.xml"),
                Asset("IMAGE", "images/inventoryimages/yurik_camera.tex"),

                Asset("ATLAS", "images/inventoryimages/yurik_camera_area.xml"),
                Asset("IMAGE", "images/inventoryimages/yurik_camera_area.tex"),
                Asset("ATLAS_BUILD", "images/inventoryimages/yurik_camera.xml", 256)
            }

local prefabs = {
    "yurik_ammo_rock_proj"
}

local PROJECTILE_DELAY = 2 * FRAMES

local function OnChange(inst)
   if inst:HasTag("AreaAtk") then
        inst:RemoveTag("AreaAtk")

        inst.components.inventoryitem.atlasname = "images/inventoryimages/yurik_camera.xml"
        inst.components.inventoryitem:ChangeImageName("yurik_camera")
   else
        inst:AddTag("AreaAtk")

        inst.components.inventoryitem.atlasname = "images/inventoryimages/yurik_camera_area.xml"
        inst.components.inventoryitem:ChangeImageName("yurik_camera_area")        
   end 
end

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_yurik_camera", "swap_yurik_camera")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    if inst.components.container ~= nil then
        inst.components.container:Close()
    end
end

local function OnProjectileLaunched(inst, attacker, target)
    if inst.components.container ~= nil then
        local ammo_stack = inst.components.container:GetItemInSlot(1)
        local item = inst.components.container:RemoveItem(ammo_stack, false)
        if item ~= nil then
            if item == ammo_stack then
                item:PushEvent("ammounloaded", {
                    slingshot = inst
                })
            end

            item:Remove()
        end
    end
end

local function OnAmmoLoaded(inst, data)
    if inst.components.weapon ~= nil then
        if data ~= nil and data.item ~= nil then
            inst.components.weapon:SetProjectile(data.item.prefab .. "_proj")
            data.item:PushEvent("ammoloaded", {
                slingshot = inst
            })
        end
    end
end

local function OnAmmoUnloaded(inst, data)
    if inst.components.weapon ~= nil then
        inst.components.weapon:SetProjectile(nil)
        if data ~= nil and data.prev_item ~= nil then
            data.prev_item:PushEvent("ammounloaded", {
                slingshot = inst
            })
        end
    end
end

local function ReticuleTargetFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    for r = 5, 0, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function ImpactFx(inst, target)
    if target ~= nil and target:IsValid() then
        local impactfx = SpawnPrefab("slingshotammo_hitfx_rock")
        impactfx.Transform:SetPosition(target.Transform:GetWorldPosition())
        inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/rock")
    end
end

local function OnSpell(inst, doer, pos)
    if doer == nil or (doer and doer.skill == nil) then return end
    if doer and doer.skill and doer.skill == 0 then
        doer.components.talker:Say("没有对应技能")
        return
    end 

    local self = doer.components.combat
    local ammo_stack = inst.components.container:GetItemInSlot(1)
    local item = inst.components.container:RemoveItem(ammo_stack, false)

    local item_proj = (item ~= nil and item.prefab and SpawnPrefab(item.prefab.."_proj")) or nil

    local range = 5
    local x, y, z = pos:Get()
    local ents = TheSim:FindEntities(x, 0, z, range, nil, { "NOCLICK", "INLIMBO", "FX", "fire" })
    for k, v in ipairs(ents) do
        if v then
            if doer.skill == 1 and v and v.components.combat and not v:HasTag("player") then
               if item and item_proj and item_proj.components.weapon then
                   ImpactFx(inst, v)

                   local damage = item_proj.components.weapon:GetDamage(doer, v) or 30
                   local resultDamage = damage
                   * (self.damagemultiplier or 1)
                   * self.externaldamagemultipliers:Get()
                   + (self.damagebonus or 0)

                   v.components.combat:GetAttacked(doer, resultDamage * 4, inst, nil)
               end  

            elseif doer.skill == 2 then
               if item and item_proj and item_proj.components.weapon and v and v.components.combat then
                   ImpactFx(inst, v)

                   local damage = item_proj.components.weapon:GetDamage(doer, v) or 30
                   local resultDamage = damage
                   * (self.damagemultiplier or 1)
                   * self.externaldamagemultipliers:Get()
                   + (self.damagebonus or 0)

                   v.components.combat:GetAttacked(doer, resultDamage * 0.5, inst, nil)
               end  

               if v.components.freezable and not v:HasTag("player") then 
                   v.components.freezable:AddColdness(8)
               end    

               local fx = SpawnPrefab("icespike_fx_1")
               fx.Transform:SetScale(2, 2, 2)
               fx.Transform:SetPosition(x, 0, z)

               local fx = SpawnPrefab("icespike_fx_1")
               fx.Transform:SetScale(2, 2, 2)
               fx.Transform:SetPosition(x-2, 0, z)

               local fx = SpawnPrefab("icespike_fx_2")
               fx.Transform:SetScale(2, 2, 2)
               fx.Transform:SetPosition(x+2, 0, z)

               local fx = SpawnPrefab("icespike_fx_3")
               fx.Transform:SetScale(2, 2, 2)
               fx.Transform:SetPosition(x, 0, z-2)

               local fx = SpawnPrefab("icespike_fx_4")
               fx.Transform:SetScale(2, 2, 2)
               fx.Transform:SetPosition(x, 0, z+2)

            elseif doer.skill == 3 and v.components.health then  -- 
               if item and v and v.components.combat and not v:HasTag("player") then
               if item and item_proj and item_proj.components.weapon and v and v.components.combat then
                   local damage = item_proj.components.weapon:GetDamage(doer, v) or 30
                   local resultDamage = damage
                   * (self.damagemultiplier or 1)
                   * self.externaldamagemultipliers:Get()
                   + (self.damagebonus or 0)

                   ImpactFx(inst, v)
                   v.components.combat:GetAttacked(doer, resultDamage * 1, inst, nil)
               end  

               elseif v:HasTag("player") then
                   local fx = SpawnPrefab("ghostlyelixir_fastregen_dripfx")
                   fx.Transform:SetPosition(v.Transform:GetWorldPosition()) 

                   v.components.health:DoDelta(v.components.health.maxhealth * 0.7)     
               end  
            end       
        end
    end

    if item then
        item:Remove()
    end    

    if item_proj then
        item_proj:Remove()
    end  

    doer.skill = 0 
    doer._skill:set(0)  
end

local floater_swap_data = {
    sym_build = "swap_yurik_camera"
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small", 0.05, {0.75, 0.5, 0.75})

    inst.AnimState:SetBank("yurik_camera")
    inst.AnimState:SetBuild("yurik_camera")
    inst.AnimState:PlayAnimation("idle")

    --inst:AddTag("rangedweapon")
    --inst:AddTag("slingshot")
    inst:AddTag("weapon")
    inst:AddTag("yurik_camera")

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetRange(16)
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe"
    inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true   
    inst.components.aoetargeting.alwaysvalid = true 

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = function(inst)
            inst.replica.container:WidgetSetup("slingshot")
        end
        return inst
    end

    inst.Change = OnChange

    inst:AddComponent("inspectable")

    inst:AddComponent("hln_aoespell")
    inst.components.aoespell = inst.components.hln_aoespell
    inst.components.aoespell:SetSpellFn(OnSpell)
    inst.components.aoespell.ispassableatallpoints = true
    inst:RegisterComponentActions("aoespell")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "yurik_camera"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/yurik_camera.xml"
    inst.components.inventoryitem.keepondeath = true
    
    inst:AddComponent("equippable")
    inst.components.equippable.restrictedtag = "yurri"
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(TUNING.SLINGSHOT_DISTANCE, TUNING.SLINGSHOT_DISTANCE_MAX)
    inst.components.weapon:SetOnProjectileLaunched(OnProjectileLaunched)
    inst.components.weapon:SetProjectile(nil)
    -- inst.components.weapon:SetProjectile("yurik_arrow")
    inst.components.weapon:SetProjectileOffset(1)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("slingshot")
    inst.components.container.canbeopened = false
    inst:ListenForEvent("itemget", OnAmmoLoaded)
    inst:ListenForEvent("itemlose", OnAmmoUnloaded)

    -- MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    -- MakeSmallPropagator(inst)
    MakeHauntableLaunch(inst)

    return inst
end

STRINGS.NAMES.YURIK_CAMERA = "除灵相机"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.YURIK_CAMERA = [[麻生邦彦制造]]
STRINGS.RECIPE_DESC.YURIK_CAMERA = [[麻生邦彦制造]]

return Prefab("common/inventory/yurik_camera", fn, assets, prefabs)
