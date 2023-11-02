local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local Badge = require "widgets/badge"

local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"  

local Yurik_Ui = Class(Badge, function(self, owner)
	Badge._ctor(self, "a", owner)

	--self.anim:GetAnimState():SetBank("health")
    --self.anim:GetAnimState():SetBuild("huixiang")
    	
  self.skill1 = self.underNumber:AddChild(ImageButton("images/ui/yurik_skill1.xml", "yurik_skill1.tex" ))
  self.skill1:SetScale(.6)
  self.skill1:SetPosition(-80, -330)
  self.skill1:SetOnClick(function()
      SendModRPCToServer(MOD_RPC["yurik_skill"]["yurik_skill"], 1)
  end)  

  self.skill2 = self.underNumber:AddChild(ImageButton("images/ui/yurik_skill2.xml", "yurik_skill2.tex" ))
  self.skill2:SetScale(.6)
  self.skill2:SetPosition(0, -330)
  self.skill2:SetOnClick(function()
      SendModRPCToServer(MOD_RPC["yurik_skill"]["yurik_skill"], 2)
  end)  

  self.skill3 = self.underNumber:AddChild(ImageButton("images/ui/yurik_skill3.xml", "yurik_skill3.tex" ))
  self.skill3:SetScale(.6)
  self.skill3:SetPosition(80, -330)
  self.skill3:SetOnClick(function()
      SendModRPCToServer(MOD_RPC["yurik_skill"]["yurik_skill"], 3)
  end)  

	self:StartUpdating()
end)


function Yurik_Ui:OnUpdate(dt)
   if self.owner then
      if self.owner:HasTag("Skill1_Cd") then
          self.skill1:SetClickable(false)
          self.skill1:SetImageNormalColour(1, 1, 1, 0.2)
      else
          self.skill1:SetClickable(true)        
          self.skill1:SetImageNormalColour(1, 1, 1, 1)          
      end 

      if self.owner:HasTag("Skill2_Cd") then
          self.skill2:SetClickable(false)        
          self.skill2:SetImageNormalColour(1, 1, 1, 0.2)
      else
          self.skill2:SetClickable(true)          
          self.skill2:SetImageNormalColour(1, 1, 1, 1)          
      end 

      if self.owner:HasTag("Skill3_Cd") then
          self.skill3:SetClickable(false)         
          self.skill3:SetImageNormalColour(1, 1, 1, 0.2)
      else
          self.skill3:SetClickable(true)         
          self.skill3:SetImageNormalColour(1, 1, 1, 1)           
      end 
   end        
end

return Yurik_Ui