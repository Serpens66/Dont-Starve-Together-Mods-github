name = "Food Queue"
description = "Adds a FoodQueue.\nThe last 6 eaten foods are stored in it and depending on the position in the queue, the food values are reduced.\nHighly Configurable."
author = "Nuckê, Serp"
version = "1.0.25"
forumthread = ""
api_version = 10
api_version_dst = 10
priority = 0
dont_starve_compatible = false
reign_of_giants_compatible = false
dst_compatible = true
client_only_mod = false
all_clients_require_mod = true
icon_atlas = "modicon.xml"
icon = "modicon.tex"

configuration_options = { 
    
    {
  		name = "affect_modchars",
        label = "Affect Mod-Characters?",
        hover = "If Yes, also mod-characters are changed by this mod.",
        options =
        {
            {description = "No", data = false, hover = "default"},
            {description = "Yes", data = true, hover = ""},
        },
        default = false,
  	},
    {
  		name = "1",
        label = "Food Multiplier 1",
        hover = "Food Values multiplier for food at queue position 1 (most recently eaten).",
        options =
        {
            {description = "0%", data = 0},
            {description = "5%", data = 0.05},
            {description = "10%", data = 0.10, hover = "default"},
            {description = "15%", data = 0.15},
            {description = "20%", data = 0.20},
            {description = "25%", data = 0.25},
            {description = "30%", data = 0.30},
            {description = "35%", data = 0.35},
            {description = "40%", data = 0.40},
            {description = "45%", data = 0.45},
            {description = "50%", data = 0.50},
            {description = "55%", data = 0.55},
            {description = "60%", data = 0.60},
            {description = "65%", data = 0.65},
            {description = "70%", data = 0.70},
            {description = "75%", data = 0.75},
            {description = "80%", data = 0.80},
            {description = "85%", data = 0.85},
            {description = "90%", data = 0.90},
            {description = "95%", data = 0.95},
            {description = "100%", data = 1.00},
        },
        default = 0.1,
  	},
    {
  		name = "2",
        label = "Food Multiplier 2",
        hover = "Food Values multiplier for food at queue position 2.",
        options =
        {
            {description = "0%", data = 0},
            {description = "5%", data = 0.05},
            {description = "10%", data = 0.10},
            {description = "15%", data = 0.15},
            {description = "20%", data = 0.20},
            {description = "25%", data = 0.25, hover = "default"},
            {description = "30%", data = 0.30},
            {description = "35%", data = 0.35},
            {description = "40%", data = 0.40},
            {description = "45%", data = 0.45},
            {description = "50%", data = 0.50},
            {description = "55%", data = 0.55},
            {description = "60%", data = 0.60},
            {description = "65%", data = 0.65},
            {description = "70%", data = 0.70},
            {description = "75%", data = 0.75},
            {description = "80%", data = 0.80},
            {description = "85%", data = 0.85},
            {description = "90%", data = 0.90},
            {description = "95%", data = 0.95},
            {description = "100%", data = 1.00},
        },
        default = 0.25,
  	},
    {
  		name = "3",
        label = "Food Multiplier 3",
        hover = "Food Values multiplier for food at queue position 3.",
        options =
        {
            {description = "0%", data = 0},
            {description = "5%", data = 0.05},
            {description = "10%", data = 0.10},
            {description = "15%", data = 0.15},
            {description = "20%", data = 0.20},
            {description = "25%", data = 0.25},
            {description = "30%", data = 0.30},
            {description = "35%", data = 0.35},
            {description = "40%", data = 0.40, hover = "default"},
            {description = "45%", data = 0.45},
            {description = "50%", data = 0.50},
            {description = "55%", data = 0.55},
            {description = "60%", data = 0.60},
            {description = "65%", data = 0.65},
            {description = "70%", data = 0.70},
            {description = "75%", data = 0.75},
            {description = "80%", data = 0.80},
            {description = "85%", data = 0.85},
            {description = "90%", data = 0.90},
            {description = "95%", data = 0.95},
            {description = "100%", data = 1.00},
        },
        default = 0.40,
  	},
    {
  		name = "4",
        label = "Food Multiplier 4",
        hover = "Food Values multiplier for food at queue position 4.",
        options =
        {
            {description = "0%", data = 0},
            {description = "5%", data = 0.05},
            {description = "10%", data = 0.10},
            {description = "15%", data = 0.15},
            {description = "20%", data = 0.20},
            {description = "25%", data = 0.25},
            {description = "30%", data = 0.30},
            {description = "35%", data = 0.35},
            {description = "40%", data = 0.40},
            {description = "45%", data = 0.45},
            {description = "50%", data = 0.50},
            {description = "55%", data = 0.55, hover = "default"},
            {description = "60%", data = 0.60},
            {description = "65%", data = 0.65},
            {description = "70%", data = 0.70},
            {description = "75%", data = 0.75},
            {description = "80%", data = 0.80},
            {description = "85%", data = 0.85},
            {description = "90%", data = 0.90},
            {description = "95%", data = 0.95},
            {description = "100%", data = 1.00},
        },
        default = 0.55,
  	},
    {
  		name = "5",
        label = "Food Multiplier 5",
        hover = "Food Values multiplier for food at queue position 5.",
        options =
        {
            {description = "0%", data = 0},
            {description = "5%", data = 0.05},
            {description = "10%", data = 0.10},
            {description = "15%", data = 0.15},
            {description = "20%", data = 0.20},
            {description = "25%", data = 0.25},
            {description = "30%", data = 0.30},
            {description = "35%", data = 0.35},
            {description = "40%", data = 0.40},
            {description = "45%", data = 0.45},
            {description = "50%", data = 0.50},
            {description = "55%", data = 0.55},
            {description = "60%", data = 0.60},
            {description = "65%", data = 0.65},
            {description = "70%", data = 0.70, hover = "default"},
            {description = "75%", data = 0.75},
            {description = "80%", data = 0.80},
            {description = "85%", data = 0.85},
            {description = "90%", data = 0.90},
            {description = "95%", data = 0.95},
            {description = "100%", data = 1.00},
        },
        default = 0.70,
  	},
    {
  		name = "6",
        label = "Food Multiplier 6",
        hover = "Food Values multiplier for food at queue position 6.",
        options =
        {
            {description = "0%", data = 0},
            {description = "5%", data = 0.05},
            {description = "10%", data = 0.10},
            {description = "15%", data = 0.15},
            {description = "20%", data = 0.20},
            {description = "25%", data = 0.25},
            {description = "30%", data = 0.30},
            {description = "35%", data = 0.35},
            {description = "40%", data = 0.40},
            {description = "45%", data = 0.45},
            {description = "50%", data = 0.50},
            {description = "55%", data = 0.55},
            {description = "60%", data = 0.60},
            {description = "65%", data = 0.65},
            {description = "70%", data = 0.70},
            {description = "75%", data = 0.75},
            {description = "80%", data = 0.80},
            {description = "85%", data = 0.85, hover = "default"},
            {description = "90%", data = 0.90},
            {description = "95%", data = 0.95},
            {description = "100%", data = 1.00},
        },
        default = 0.85,
  	},
    {
  		name = "basefood",
        label = "Processed Food",
        hover = "Handle processed food as the basefood?",
        options =
        {
            {description = "Unique", data = "", hover = "Every fooditem with a unique name adds an queue entry."},
            {description = "Spiced", data = "spiced", hover = "Spiced foods add the basefood to queue"},
            {description = "Cooked", data = "cooked", hover = "Cooked foods add the basefood to queue"},
            {description = "Seed", data = "seeds", hover = "Seeds add the basefood to queue"},
            {description = "Spiced,Cooked", data = "spiced_cooked", hover = "Spiced and Cooked foods add the basefood to queue"},
            {description = "Spiced,Seed", data = "spiced_seeds", hover = "Spiced foods and Seeds add the basefood to queue"},
            {description = "Cooked,Seed", data = "seeds_cooked", hover = "Cooked foods and Seeds add the basefood to queue"},
            {description = "Spiced,Cooked,Seed", data = "spiced_seeds_cooked", hover = "Spiced, Cooked foods and Seeds add the basefood to queue"},
        },
        default = "spiced_seeds_cooked",
  	},
    {
  		name = "handle_favorite",
        label = "Favorite Food?",
        hover = "How -favorite food- should be handled (hunger value and queue. Does not affect FoodType and FoodTag, only prefab.)",
        options =
        {
            {description = "FavNo", data = "favhunger_noqueue", hover = "-Favorite- hungervalue and never added to queue"},
            {description = "FavAdd", data = "favhunger_addqueue", hover = "-Favorite- hungervalue and added to queue"},
            {description = "DefNo", data = "defhunger_noqueue", hover = "Default hungervalue and never added to queue (default)"},
            {description = "DefAdd", data = "defhunger_addqueue", hover = "Default hungervalue and added to queue, just like any other food."},
        },
        default = "defhunger_noqueue",
  	},
    {
  		name = "reduce_negative",
        label = "Mult Negatives?",
        hover = "If Yes, also negative values will be multiplied, resulting in less negativity.",
        options =
        {
            {description = "No", data = false, hover = ""},
            {description = "Yes", data = true, hover = ""},
        },
        default = false,
  	},
    {
  		name = "NoCheaseValue",
        label = "No Chease Value",
        hover = "If enabled, food with a lower value in all stats (default values) is not added to foodqueue. Eg. to prevent flowers/ice to go into it.",
        options =
        {
            {description = "Off", data = false},
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5, hover = "default"},
            {description = "6", data = 6},
            {description = "7", data = 7},
            {description = "8", data = 8},
            {description = "9", data = 9},
            {description = "10", data = 10},
            {description = "12", data = 12},
            {description = "15", data = 15},
            {description = "20", data = 20},
            {description = "25", data = 25},
            {description = "30", data = 30},
        },
        default = 5,
  	},
    {
  		name = "replace_foodmemory",
        label = "Replace Foodmemory?",
        hover = "If Yes, the foodmemory from walry (and mod characters) is replaced by this queue.",
        options =
        {
            {description = "No", data = false, hover = ""},
            {description = "Yes", data = true, hover = ""},
        },
        default = false,
  	},
    {
  		name = "hide_widget",
        label = "Hide UI Widget",
        hover = "Display or hide the UI widget that shows the queue?",
        options =
        {
            {description = "No", data = false, hover = ""},
            {description = "Yes", data = true, hover = ""},
        },
        default = false,
  	},










}