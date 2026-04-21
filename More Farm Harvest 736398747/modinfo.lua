
name = "More Farm Harvest"
description = "Harvesting a farm plant can randomly generate an extra harvest.\nDefault is 25% for one extra, and 5% for two extra."
author = "DarkXero,Serpens,Tykvesh"
version = "1.0.0"
forumthread = ""

api_version = 10

icon_atlas = "modicon.xml"
icon = "modicon.tex"

all_clients_require_mod = false
dst_compatible = true
server_filter_tags = {"Harvest"}

priority = 0

configuration_options =
{
    {
		name = "one_harvest",
		label = "One extra Chance",
		hover = "Chance for getting one extra harvest when harvesting farm plants.",
		options =	{
						{description = "5%", data = 0.05, hover = "\n"},
                        {description = "10%", data = 0.1, hover = "\n"},
                        {description = "15%", data = 0.15, hover = "\n"},
                        {description = "20%", data = 0.2, hover = "\n"},
                        {description = "25%", data = 0.25, hover = "Default"},
                        {description = "30%", data = 0.3, hover = "\n"},
                        {description = "35%", data = 0.35, hover = "\n"},
                        {description = "40%", data = 0.4, hover = "\n"},
                        {description = "45%", data = 0.45, hover = "\n"},
                        {description = "50%", data = 0.5, hover = "\n"},
                        {description = "55%", data = 0.55, hover = "\n"},
                        {description = "60%", data = 0.6, hover = "\n"},
                        {description = "65%", data = 0.65, hover = "\n"},
                        {description = "70%", data = 0.7, hover = "\n"},
                        {description = "75%", data = 0.75, hover = "\n"},
                        {description = "80%", data = 0.8, hover = "\n"},
                        {description = "85%", data = 0.85, hover = "\n"},
                        {description = "90%", data = 0.9, hover = "\n"},
                        {description = "95%", data = 0.95, hover = "\n"},
                        {description = "100%", data = 1, hover = "\n"},
					},
		default = 0.25,
	},
    {
		name = "two_harvest",
		label = "Two extra Chance",
		hover = "Chance for getting two extra harvest when harvesting farm plants.",
		options =	{
						{description = "0%", data = 0, hover = "\n"},
                        {description = "1%", data = 0.01, hover = "\n"},
                        {description = "2%", data = 0.02, hover = "\n"},
                        {description = "3%", data = 0.03, hover = "\n"},
                        {description = "5%", data = 0.05, hover = "Default"},
                        {description = "10%", data = 0.1, hover = "\n"},
                        {description = "15%", data = 0.15, hover = "\n"},
                        {description = "20%", data = 0.2, hover = "\n"},
                        {description = "25%", data = 0.25, hover = "\n"},
                        {description = "30%", data = 0.3, hover = "\n"},
                        {description = "35%", data = 0.35, hover = "\n"},
                        {description = "40%", data = 0.4, hover = "\n"},
                        {description = "45%", data = 0.45, hover = "\n"},
                        {description = "50%", data = 0.5, hover = "\n"},
                        {description = "55%", data = 0.55, hover = "\n"},
                        {description = "60%", data = 0.6, hover = "\n"},
                        {description = "65%", data = 0.65, hover = "\n"},
                        {description = "70%", data = 0.7, hover = "\n"},
                        {description = "75%", data = 0.75, hover = "\n"},
                        {description = "80%", data = 0.8, hover = "\n"},
                        {description = "85%", data = 0.85, hover = "\n"},
                        {description = "90%", data = 0.9, hover = "\n"},
                        {description = "95%", data = 0.95, hover = "\n"},
                        {description = "100%", data = 1, hover = "\n"},
					},
		default = 0.05,
	},
}