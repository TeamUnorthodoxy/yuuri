local assets =
{
	Asset( "ANIM", "anim/yurik.zip" ),
	Asset( "ANIM", "anim/ghost_yurik_build.zip" ),
}

local skins =
{
	normal_skin = "yurik",
	ghost_skin = "ghost_yurik_build",
}

local base_prefab = "yurik"

local tags = {"YURIK", "CHARACTER"}

return CreatePrefabSkin("yurik_none",
{
	base_prefab = base_prefab, 
	skins = skins, 
	assets = assets,
	skin_tags = tags,
	
	build_name_override = "yurik",
	rarity = "Character",
})
