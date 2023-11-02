GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

local yurik_ui = require("widgets/yurik_ui")

local function AddYurik_Ui(self) 
  if self.owner and self.owner:HasTag("yurri") then
    self.yurik_ui = self:AddChild(yurik_ui(self.owner)) 
    
    self.owner:DoTaskInTime(0.5, function()
      local x1 ,y1,z1 = self.stomach:GetPosition():Get()
      local x2 ,y2,z2 = self.brain:GetPosition():Get()    
      local x3 ,y3,z3 = self.heart:GetPosition():Get()    
      if y2 == y1 or  y2 == y3 then
        self.yurik_ui:SetPosition(self.stomach:GetPosition() + Vector3(x1-x2-100, 300, 0))
        self.boatmeter:SetPosition(self.moisturemeter:GetPosition() + Vector3(x1-x2, 0, 0))
      else
        self.yurik_ui:SetPosition(self.stomach:GetPosition() + Vector3(x1-x3-100, 300, 0))
      end
      local s1 = self.stomach:GetScale().x
      local s2 = self.boatmeter:GetScale().x    
      local s3 = self.yurik_ui:GetScale().x 
  
      if s1 ~= s2 then
        self.boatmeter:SetScale(s1/s2,s1/s2,s1/s2)  --修改船的耐久值大小
      end

      if s1 ~= s3 then
        self.yurik_ui:SetScale(s1/s3,s1/s3,s1/s3)--避免wg的显示mod有问题修正一下大小
      end
    end)
  local old_SetGhostMode = self.SetGhostMode --死亡/复活 隐藏/显示
  function self:SetGhostMode(ghostmode,...)
    old_SetGhostMode(self,ghostmode,...)
    if ghostmode then   
      if self.yuuki_ui ~= nil then 
        self.yuuki_ui:Hide()
      end 
    else
      if self.yuuki_ui ~= nil then
        self.yuuki_ui:Show()
      end
    end
  end
  end
end

AddClassPostConstruct("widgets/statusdisplays", AddYurik_Ui)


local Item = {
   yurik_ammo14 = true,
   yurik_ammo61 = true,
   yurik_ammo90 = true,
   yurik_ammozero = true,

   yurik_camera = true,
   yurikmedicine = true,
   yurikwater = true,

   yurikfire = true,
   yurikbattery = true                    
}

local function draw(inst)
  if inst.components.drawable then
       local oldondrawnfn = inst.components.drawable.ondrawnfn or nil
       inst.components.drawable.ondrawnfn = function(inst, image, src)

         if oldondrawnfn ~= nil then
             oldondrawnfn(inst, image, src)
         end

         if image ~= nil and Item[image] ~= nil then
              inst.AnimState:OverrideSymbol("SWAP_SIGN", resolvefilepath("images/inventoryimages/"..image..".xml"), image..".tex")
         end
      end
   end
end

AddPrefabPostInit("minisign", draw)
AddPrefabPostInit("minisign_drawn", draw)