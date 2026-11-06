STUB.Fire("ADDON_LOADED", "LevelMates")
local _, ns = ...
local D, L = ns.Dungeons, ns.L
assert(#D.list == 31, "thirty-one dungeons: " .. #D.list)
local seen = {}
for _, d in ipairs(D.list) do
	assert(not seen[d.id] and d.id >= 1 and d.id <= 31, "unique ids")
	seen[d.id] = true
	assert(type(L[d.key]) == "string" and L[d.key] ~= "", "named: " .. d.key)
	assert(d.min < d.max, "a level range")
end
assert(D.Name(5) == "The Deadmines" and D.Name(8) == "The Stockade" and D.Get(14).min == 33 and D.Get(14).max == 41, "known rows")
-- Forever's five later dungeons (Blizzard's ranges), appended: ids 15-19
assert(D.Name(15) == "The Drowned City" and D.Get(15).min == 35 and D.Get(15).max == 40, "the Drowned City")
assert(D.Name(16) == "Krol'dok Stronghold" and D.Get(16).min == 40 and D.Get(16).max == 45, "Krol'dok")
assert(D.Name(17) == "Alcaz Prison" and D.Get(17).min == 48 and D.Get(17).max == 53, "Alcaz")
assert(D.Name(18) == "Blackmaw Hold" and D.Get(18).min == 55 and D.Get(18).max == 60, "Blackmaw")
assert(D.Name(19) == "Shaper's Terrace" and D.Get(19).min == 58 and D.Get(19).max == 60, "Shaper's Terrace")
assert(D.Fits(19, 60) and not D.Fits(19, 57), "level 60 fits the last one")
-- the classic ones from 30 to 60 (provisional ranges: the client's minimum, the classic maximum), appended: ids 20-31
local classic = { [20] = { "Razorfen Downs", 34, 46 }, [21] = { "Scarlet Monastery: Armory", 32, 42 }, [22] = { "Scarlet Monastery: Cathedral", 35, 45 },
	[23] = { "Uldaman", 35, 51 }, [24] = { "Zul'Farrak", 42, 54 }, [25] = { "Maraudon", 42, 55 }, [26] = { "Temple of Atal'Hakkar", 45, 56 },
	[27] = { "Blackrock Depths", 48, 60 }, [28] = { "Lower Blackrock Spire", 53, 60 }, [29] = { "Dire Maul", 54, 60 }, [30] = { "Stratholme", 55, 60 },
	[31] = { "Scholomance", 57, 60 } }
for id, row in pairs(classic) do
	assert(D.Name(id) == row[1] and D.Get(id).min == row[2] and D.Get(id).max == row[3], "classic row " .. id .. ": " .. D.Name(id))
end
assert(D.Matches(21, "Scarlet Monastery") and D.Matches(22, "Monasterio Escarlata"), "the Monastery's wings share its instance name")
local sorted = D.Sorted()
for i = 2, #sorted do
	local a, b = sorted[i - 1], sorted[i]
	assert(a.min < b.min or a.min == b.min and (a.max < b.max or a.max == b.max and a.id < b.id), "by level")
end
local tex, coords = D.Art(2)
assert(tex == "Interface\\Glues\\LoadingScreens\\LoadScreenRagefireChasm" and coords[3] == 0.25, "game loading screen, cropped")
assert(D.Art(8) == 131870, "file ids work too")
-- only the game's own art: Forever's loading screens for its new dungeons, the Monastery screen for the Library
assert(D.Art(1) == 7963781 and D.Art(3) == 7963782, "Forever's own loading screens")
assert(D.Art(15) == 7963776 and D.Art(16) == 7963776, "no screen of their own yet: Forever's Eastern Kingdoms screen")
assert(D.Art(17) == 7963779 and D.Art(18) == 7963779 and D.Art(19) == 7963779, "and Forever's Kalimdor screen")
assert(D.Art(20) == "Interface\\Glues\\LoadingScreens\\LoadScreenRazorfenDowns" and D.Art(30) == "Interface\\Glues\\LoadingScreens\\LoadScreenStrathome", "classic screens (Stratholme's name has Blizzard's typo)")
assert(D.Art(14) == "Interface\\Glues\\LoadingScreens\\LoadScreenScarletHalls", "the Library uses the Scarlet Halls screen")
for _, d in ipairs(D.list) do
	local tex = D.Art(d.id)
	assert(tex and not tostring(tex):find("AddOns", 1, true), "never another addon's files: " .. d.key)
end
