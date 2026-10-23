local G = GLOBAL
local tiles = G.WORLD_TILES
local locks = G.LOCKS
local keys = G.KEYS
AddRoom("DocLearningRoom", {
    colour = { r = .3, g = .7, b = .3, a = .5 }, value = tiles.GRASS,
    contents = { distributepercent = .1, distributeprefabs = { grass = 1, flower = .5 },
        countstaticlayouts = { SimpleBase = 1 } },
})
AddTask("DocLearningTask", {
    locks = locks.NONE, keys_given = { keys.TIER1 },
    room_choices = { DocLearningRoom = 1 }, room_bg = tiles.GRASS,
    background_room = "BGGrass", colour = { r = .3, g = .7, b = .3, a = 1 },
})
AddTaskSetPreInit("default", function(taskset)
    if taskset.location ~= "forest" then return end
    for _, name in ipairs(taskset.tasks) do if name == "DocLearningTask" then return end end
    table.insert(taskset.tasks, "DocLearningTask")
end)
