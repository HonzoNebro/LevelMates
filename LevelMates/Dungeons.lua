-- Dungeons.lua: the dungeons the group finder knows, with their card art: the fourteen of the Forever dungeon journal,
-- then Forever's five later new ones (15-19, Blizzard's ranges: news.blizzard.com article 24301455), then the classic
-- ones from 30 to 60 (20-31). Their ranges are provisional until checked in the game's journal: the minimum is the
-- Forever client's (LFGDungeons/ContentTuning, as SenseOS read it), the maximum the classic one; the Monastery's two
-- other wings keep their classic ranges. Names as the Forever client has them (1.60.1.70790); one Dire Maul there.
-- To add one, append a row here and add its DUNGEON_* name to both locale files (tests/policy.test.mjs checks that).
-- Ids 1-6 travel in messages (lfg, dun goals): never renumber them.
local _, ns = ...
local D = {}
ns.Dungeons = D

-- Card art: only the game's own loading screens (classic ones by path, Forever's new ones by file id), cropped to
-- the card. Nothing is copied from anyone; the textures already ship with the game.
-- Forever's ids (community listfile, camelot160/main): 7963775 loadscreen_camelot_dalaran, 7963777 _excavation,
-- 7963781 _oldironforge (Hall of Thanes), 7963782 _ruinsoflordaeron. The five later ones have no screen of their own in
-- the listfile (wowdev/wow-listfile, 2026-11-05): they use Forever's continent screens, 7963776 _easternkingdom and
-- 7963779 _kalimdor, until theirs is known.
local LS = "Interface\\Glues\\LoadingScreens\\"
local WIDE, TALL = { 0.02, 0.98, 0.25, 0.82 }, { 0.02, 0.98, 0.24, 0.82 }
local NEW = { 0, 1, 0.12, 0.88 }
local EK, KALIMDOR = 7963776, 7963779
-- Both Monastery wings are one instance in game, named without the wing (as ForeverDungeonJournal notes too).
local SM = { "Scarlet Monastery", "Monasterio Escarlata" }

D.list = {
	{ id = 1,  key = "DUNGEON_HALL_OF_THANES",      min = 13, max = 20, art = 7963781, coords = NEW },
	{ id = 2,  key = "DUNGEON_RAGEFIRE_CHASM",      min = 13, max = 18, art = LS .. "LoadScreenRagefireChasm", coords = WIDE },
	{ id = 3,  key = "DUNGEON_RUINS_OF_LORDAERON",  min = 15, max = 22, art = 7963782, coords = NEW },
	{ id = 4,  key = "DUNGEON_WAILING_CAVERNS",     min = 15, max = 24, art = LS .. "LoadScreenWailingCaverns", coords = WIDE },
	{ id = 5,  key = "DUNGEON_DEADMINES",           min = 17, max = 26, art = LS .. "LoadScreenDeadmines", coords = WIDE },
	{ id = 6,  key = "DUNGEON_SHADOWFANG_KEEP",     min = 20, max = 30, art = LS .. "LoadScreenShadowFangKeep", coords = TALL },
	{ id = 7,  key = "DUNGEON_BLACKFATHOM_DEEPS",   min = 24, max = 32, art = LS .. "LoadScreenBlackFathomDeeps", coords = WIDE },
	{ id = 8,  key = "DUNGEON_STOCKADE",            min = 24, max = 32, art = 131870, coords = TALL },
	{ id = 9,  key = "DUNGEON_EXCAVATION_WETLANDS", min = 26, max = 33, art = 7963777, coords = NEW },
	{ id = 10, key = "DUNGEON_DALARAN",             min = 28, max = 33, art = 7963775, coords = NEW },
	{ id = 11, key = "DUNGEON_GNOMEREGAN",          min = 29, max = 38, art = LS .. "LoadScreenGnomeregan", coords = TALL },
	{ id = 12, key = "DUNGEON_RAZORFEN_KRAUL",      min = 29, max = 38, art = 131865, coords = { 0.02, 0.98, 0.20, 0.62 } },   -- its scene sits high; lower down it washes out
	{ id = 13, key = "DUNGEON_SM_GRAVEYARD",        min = 30, max = 38, art = LS .. "LoadScreenScarletMonastery2", coords = TALL, instance = SM },
	{ id = 14, key = "DUNGEON_SM_LIBRARY",          min = 33, max = 41, art = LS .. "LoadScreenScarletHalls", coords = TALL, instance = SM },
	{ id = 15, key = "DUNGEON_DROWNED_CITY",        min = 35, max = 40, art = EK, coords = NEW },
	{ id = 16, key = "DUNGEON_KROLDOK_STRONGHOLD",  min = 40, max = 45, art = EK, coords = NEW },
	{ id = 17, key = "DUNGEON_ALCAZ_PRISON",        min = 48, max = 53, art = KALIMDOR, coords = NEW },
	{ id = 18, key = "DUNGEON_BLACKMAW_HOLD",       min = 55, max = 60, art = KALIMDOR, coords = NEW },
	{ id = 19, key = "DUNGEON_SHAPERS_TERRACE",     min = 58, max = 60, art = KALIMDOR, coords = NEW },
	{ id = 20, key = "DUNGEON_RAZORFEN_DOWNS",      min = 34, max = 46, art = LS .. "LoadScreenRazorfenDowns", coords = WIDE },
	{ id = 21, key = "DUNGEON_SM_ARMORY",           min = 32, max = 42, art = LS .. "LoadScreenScarletMonastery2", coords = TALL, instance = SM },
	{ id = 22, key = "DUNGEON_SM_CATHEDRAL",        min = 35, max = 45, art = LS .. "LoadScreenScarletMonastery2", coords = TALL, instance = SM },
	{ id = 23, key = "DUNGEON_ULDAMAN",             min = 35, max = 51, art = LS .. "LoadScreenUldaman", coords = WIDE },
	{ id = 24, key = "DUNGEON_ZULFARRAK",           min = 42, max = 54, art = LS .. "LoadScreenZulFarrak", coords = WIDE },
	{ id = 25, key = "DUNGEON_MARAUDON",            min = 42, max = 55, art = LS .. "LoadScreenMaraudon", coords = WIDE },
	{ id = 26, key = "DUNGEON_SUNKEN_TEMPLE",       min = 45, max = 56, art = LS .. "LoadScreenSunkenTemple", coords = WIDE },
	{ id = 27, key = "DUNGEON_BLACKROCK_DEPTHS",     min = 48, max = 60, art = LS .. "LoadScreenBlackrockDepths", coords = WIDE },
	{ id = 28, key = "DUNGEON_LOWER_BLACKROCK",      min = 53, max = 60, art = LS .. "LoadScreenBlackrockSpire", coords = WIDE },
	{ id = 29, key = "DUNGEON_DIRE_MAUL",           min = 54, max = 60, art = LS .. "LoadScreenDireMaul", coords = WIDE },
	{ id = 30, key = "DUNGEON_STRATHOLME",          min = 55, max = 60, art = LS .. "LoadScreenStrathome", coords = WIDE },   -- sic: the game's file name
	{ id = 31, key = "DUNGEON_SCHOLOMANCE",         min = 57, max = 60, art = LS .. "LoadScreenScholomance", coords = WIDE },
}

local byId = {}
for _, d in ipairs(D.list) do byId[d.id] = d end

function D.Get(id) return byId[id] end
function D.Name(id) local d = byId[id]; return d and ns.L[d.key] or ("#" .. tostring(id)) end
function D.Fits(id, level) local d = byId[id]; return d ~= nil and type(level) == "number" and level >= d.min and level <= d.max end

-- Whether the instance name the game reports (GetInstanceInfo) is this dungeon: its own name or one of its
-- in-game instance names (the Monastery wings share one).
function D.Matches(id, instanceName)
	local d = byId[id]
	if not d or not instanceName then return false end
	if instanceName == D.Name(id) then return true end
	for _, n in ipairs(d.instance or {}) do if n == instanceName then return true end end
	return false
end

-- By level range, for the cards.
function D.Sorted()
	local out = {}
	for _, d in ipairs(D.list) do out[#out + 1] = d end
	table.sort(out, function(a, b)
		if a.min ~= b.min then return a.min < b.min end
		if a.max ~= b.max then return a.max < b.max end
		return a.id < b.id
	end)
	return out
end

-- The card's texture (path or file id) and crop; nil when there is none to show.
function D.Art(id)
	local d = byId[id]
	if not d then return nil end
	return d.art, d.coords
end
