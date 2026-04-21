name = "Physics-Based Spacing"
author = "Kitty Cat, Serp"
version = "1.01"
description = "This mod changes structure spacing to be based on physics size. Serp: Made sure blocking is only reduced, never increased."
forumthread = ""

api_version = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = true
forge_compatible = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

priority = -308

server_filter_tags = {"maya", "tighter placement", "physics-based spacing", "less placement blocking", "realistic placement"}


--[[
	Changelog:

		1.0
			Released!

		1.01
			Fixed a crash caused by certain modded prefabs being unable to properly load in
]]

configuration_options = {}