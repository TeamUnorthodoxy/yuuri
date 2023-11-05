local modName = "yurik"
local modNameUp = "YURIK"

PrefabFiles = { "yurik",
                "yurik_none",
                "spiritbolt",
                "yurikflashlight",
                "yurikmedicine",
                "yurikwater",
                "yurikfire",
                "yurikbattery",
                "yurik_camera",
                "yuuri_spirit_torch",
                "yurik_ammo14",
                "yurik_ammo61",
                "yurik_ammo90",
                "yurik_ammozero",
                "yurik_waterprojectiles",
                "yurikblacktea" }
-- "yurikblacktea"
Assets = { Asset("IMAGE", "images/saveslot_portraits/yurik.tex"), Asset("ATLAS", "images/saveslot_portraits/yurik.xml"),

           Asset("IMAGE", "images/selectscreen_portraits/yurik.tex"),
           Asset("ATLAS", "images/selectscreen_portraits/yurik.xml"),

           Asset("IMAGE", "images/selectscreen_portraits/yurik_silho.tex"),
           Asset("ATLAS", "images/selectscreen_portraits/yurik_silho.xml"), Asset("IMAGE", "bigportraits/yurik.tex"),
           Asset("ATLAS", "bigportraits/yurik.xml"), Asset("IMAGE", "images/map_icons/yurik.tex"),
           Asset("ATLAS", "images/map_icons/yurik.xml"), Asset("IMAGE", "images/avatars/avatar_yurik.tex"),
           Asset("ATLAS", "images/avatars/avatar_yurik.xml"), Asset("IMAGE", "images/avatars/avatar_ghost_yurik.tex"),
           Asset("ATLAS", "images/avatars/avatar_ghost_yurik.xml"),

           Asset("IMAGE", "images/avatars/self_inspect_yurik.tex"),
           Asset("ATLAS", "images/avatars/self_inspect_yurik.xml"), Asset("IMAGE", "images/names_yurik.tex"),
           Asset("ATLAS", "images/names_yurik.xml"), Asset("IMAGE", "bigportraits/yurik_none.tex"),
           Asset("ATLAS", "bigportraits/yurik_none.xml"), Asset("ATLAS", "images/hud/yuriktab.xml"),
           Asset("IMAGE", "images/hud/yuriktab.tex"),

           Asset("ATLAS", "images/ui/yurik_skill1.xml"),
           Asset("ATLAS", "images/ui/yurik_skill2.xml"),
           Asset("ATLAS", "images/ui/yurik_skill3.xml"),

           Asset("SOUNDPACKAGE", "sound/camera_sound.fev"), --ThePlayer
           Asset("SOUND", "sound/camera_sound.fsb")
}

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local resolvefilepath = GLOBAL.resolvefilepath

local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local Recipe = GLOBAL.Recipe
local TECH = GLOBAL.TECH

modimport("scripts/mains/yurik_ui.lua")
modimport("scripts/mains/yurik_sg.lua")

GLOBAL.PREFAB_SKINS["yurik"] = {
    "yurik_none",
}

STRINGS.SKIN_NAMES.yurik_none = "不来方夕莉"

-- Yuri Tab

local yuriktab = AddRecipeTab("Yuri's Tab", 996, "images/hud/yuriktab.xml", "yuriktab.tex", "yurik_builder")

AddRecipe("yurikblacktea",
        { GLOBAL.Ingredient("firenettles", 1), GLOBAL.Ingredient("ice", 2), GLOBAL.Ingredient("honey", 1) },
        yuriktab, TECH.NONE, nil, nil, nil, nil, "yurik_builder", "images/inventoryimages/yurikblacktea.xml",
        "yurikblacktea.tex")

AddRecipe("yurikwaterballoon",
        { GLOBAL.Ingredient("ice", 2), GLOBAL.Ingredient("mosquitosack", 1) },
        yuriktab, TECH.NONE, nil, nil, nil, nil, "yurik_builder", "images/inventoryimages/yurikwaterballoon.xml",
        "yurikwaterballoon.tex")

AddRecipe("yurikmedicine",
        { GLOBAL.Ingredient("petals", 1), GLOBAL.Ingredient("honey", 1), GLOBAL.Ingredient("berries", 1) }, yuriktab,
        TECH.NONE, nil, nil, nil, 2, "yurik_builder", "images/inventoryimages/yurikmedicine.xml", "yurikmedicine.tex")

AddRecipe("yurikwater",
        { GLOBAL.Ingredient("ice", 5), GLOBAL.Ingredient("petals", 1), GLOBAL.Ingredient("spidergland", 2) }, yuriktab,
        TECH.NONE, nil, nil, nil, 2, "yurik_builder", "images/inventoryimages/yurikwater.xml", "yurikwater.tex")

AddRecipe("yurikfire",
        { GLOBAL.Ingredient("petals", 1), GLOBAL.Ingredient("cutreeds", 1), GLOBAL.Ingredient("cutgrass", 2) }, yuriktab,
        TECH.NONE, nil, nil, nil, 5, "yurik_builder", "images/inventoryimages/yurikfire.xml", "yurikfire.tex")

AddRecipe("yurikflashlight",
        { GLOBAL.Ingredient("nightmarefuel", 4), GLOBAL.Ingredient("bluegem", 1), GLOBAL.Ingredient("goldnugget", 2) },
        yuriktab, TECH.NONE, nil, nil, nil, nil, "yurik_builder", "images/inventoryimages/yurikflashlight.xml",
        "yurikflashlight.tex")

AddRecipe("yuuri_spirit_torch",
        { GLOBAL.Ingredient("moonglass", 3), GLOBAL.Ingredient("moonrocknugget", 2), GLOBAL.Ingredient("dragon_scales", 1) },
        yuriktab, TECH.NONE, nil, nil, nil, nil, "yurik_builder", "images/inventoryimages/yuuri_spirit_torch.xml",
        "yuuri_spirit_torch.tex")

AddRecipe("yurik_camera",
        { GLOBAL.Ingredient("nightmarefuel", 4), GLOBAL.Ingredient("redgem", 1), GLOBAL.Ingredient("goldnugget", 2) },
        yuriktab, TECH.NONE, nil, nil, nil, nil, "yurik_builder", "images/inventoryimages/yurik_camera.xml",
        "yurik_camera.tex")

AddRecipe("yurikbattery",
        { GLOBAL.Ingredient("potato", 1), GLOBAL.Ingredient("goldnugget", 1) },
        yuriktab, TECH.NONE, nil, nil, nil, 2, "yurik_builder",
        "images/inventoryimages/yurikbattery.xml", "yurikbattery.tex")

AddRecipe("yurik_ammo14", { GLOBAL.Ingredient("cutgrass", 3) }, yuriktab, TECH.NONE, nil, nil, nil, 30,
        "yurik_builder", "images/inventoryimages/yurik_ammo14.xml", "yurik_ammo14.tex")

AddRecipe("yurik_ammo61", { GLOBAL.Ingredient("goldnugget", 3) }, yuriktab, TECH.NONE, nil, nil, nil, 30,
        "yurik_builder", "images/inventoryimages/yurik_ammo61.xml", "yurik_ammo61.tex")

AddRecipe("yurik_ammo90", { GLOBAL.Ingredient("nightmarefuel", 3) }, yuriktab, TECH.NONE, nil, nil, nil, 30,
        "yurik_builder", "images/inventoryimages/yurik_ammo90.xml", "yurik_ammo90.tex")

AddRecipe("yurik_ammozero", { GLOBAL.Ingredient("nightmarefuel", 3), GLOBAL.Ingredient("thulecite_pieces", 3), GLOBAL.Ingredient("goldnugget", 3) }, yuriktab, TECH.NONE, nil, nil, nil, 30,
        "yurik_builder", "images/inventoryimages/yurik_ammozero.xml", "yurik_ammozero.tex")

-- The character select screen lines
STRINGS.CHARACTER_TITLES.yurik = "除灵师"
STRINGS.CHARACTER_NAMES.yurik = "不来方夕莉"
STRINGS.CHARACTER_DESCRIPTIONS.yurik = "*伤害系数随雨露值提升而提升，但遭受伤害随之提升\n*精神不受湿度影响\n*武器不会因潮湿而脱手\n*偏爱万事屋红茶"
STRINGS.CHARACTER_QUOTES.yurik = "\"密花姐……\""

-- Custom speech strings
STRINGS.CHARACTERS.yurik = require "speech_yurik"

-- 生存几率
STRINGS.CHARACTER_SURVIVABILITY[modName] = "渺茫"

-- 选人界面人物三维显示
TUNING[modNameUp .. "_HEALTH"] = 75
TUNING[modNameUp .. "_HUNGER"] = 150
TUNING[modNameUp .. "_SANITY"] = 250

-- The character's name as appears in-game 
STRINGS.NAMES.YURIK = "Yuri"

AddMinimapAtlas("images/map_icons/yurik.xml")

TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.YURIK = { "yurik_camera", "yurikflashlight" }

TUNING.STARTING_ITEM_IMAGE_OVERRIDE["yurik_camera"] = {
    atlas = "images/inventoryimages/yurik_camera.xml",
    image = "yurik_camera.tex"
}

TUNING.STARTING_ITEM_IMAGE_OVERRIDE.yurikflashlight = {
    atlas = "images/inventoryimages/yurikflashlight.xml",
    image = "yurikflashlight.tex",
}


-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("yurik", "FEMALE")

