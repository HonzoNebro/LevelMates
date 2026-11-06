-- 0.7.3: every feature switch is on by default, and turned on once for accounts that had the old default (off),
-- with one chat line naming them. A later "off" sticks; "No bot tag" (discordTagOff) keeps the personal tag off.
LevelMatesDB = { version = 1, posDefaultOn = true, chars = {}, settings = { share = true, sharePos = true,
	shareQuests = false, shareXp = false, shareRested = false, mapNames = false, levelBar = false, discordTag = false, discordTagOff = true } }
STUB.Fire("ADDON_LOADED", "LevelMates")
local _, ns = ...
local L, st = ns.L, ns.db.settings
local ON = { "shareQuests", "shareXp", "shareRested", "mapNames", "levelBar", "discordTag" }
for _, k in ipairs(ON) do assert(ns.DEFAULTS[k] == true, k .. " on by default") end
assert(ns.DEFAULTS.debug == false and ns.DEFAULTS.discordTagOff == false, "debug and the opt-out stay off")
for _, k in ipairs({ "shareQuests", "shareXp", "shareRested", "mapNames", "levelBar" }) do assert(st[k] == true, k .. " turned on") end
assert(st.discordTag == false, "the tag stays off for whoever said no to it")
STUB.Fire("PLAYER_ENTERING_WORLD", true, false); STUB.Advance(1)
local lines = {}
for _, line in ipairs(STUB.printed) do if line:find(L.ALL_NOW_ON:match("^[^%%]+"), 1, true) then lines[#lines + 1] = line end end
assert(#lines == 1, "one line: " .. #lines)
assert(lines[1]:find(L.OPT_QUESTS, 1, true) and lines[1]:find(L.OPT_LEVELBAR, 1, true) and not lines[1]:find(L.OPT_DISCORD_TAG, 1, true), "names what went on: " .. lines[1])
assert(ns.LevelBar == nil or ns.LevelBar.frame == nil or ns.LevelBar.frame:IsShown(), "the level bar shows")
-- turned off afterwards: stays off, no second line
st.shareQuests = false
ns.UpgradeSettings()
STUB.Fire("PLAYER_ENTERING_WORLD", false, true); STUB.Advance(1)
local again = 0
for _, line in ipairs(STUB.printed) do if line:find(L.ALL_NOW_ON:match("^[^%%]+"), 1, true) then again = again + 1 end end
assert(st.shareQuests == false and again == 1, "my later choice is kept, said once")
for _, k in ipairs({ "OPT_QUESTS_TT", "OPT_RESTED_TT" }) do assert(not L[k]:lower():find("off by default", 1, true), k) end
print("ok all_on")
