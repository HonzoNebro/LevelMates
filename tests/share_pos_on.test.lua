-- 0.7.2: "Share my position" is on by default, and turned on once for those who had the old default (off), with a line saying so.
LevelMatesDB = { version = 1, settings = { share = true, sharePos = false, rareNotices = true }, chars = {} }   -- an account from before
STUB.Fire("ADDON_LOADED", "LevelMates")
local _, ns = ...
local L = ns.L
assert(ns.DEFAULTS.sharePos == true, "on by default for a new install")
assert(ns.db.settings.sharePos == true, "turned on for an account that had it off")
assert(ns.db.posDefaultOn == true, "and remembered: only once")
STUB.Fire("PLAYER_ENTERING_WORLD", true, false); STUB.Advance(1)
local said = 0
for _, line in ipairs(STUB.printed) do if line:find(L.POS_NOW_ON, 1, true) then said = said + 1 end end
assert(said == 1, "told once in chat: " .. said)
assert(L.POS_NOW_ON:find(L.OPT_POS, 1, true), "the line names the option, to find it")
-- turned off afterwards: stays off, no second line
ns.db.settings.sharePos = false
ns.UpgradeSettings()
STUB.Fire("PLAYER_ENTERING_WORLD", false, true); STUB.Advance(1)
said = 0
for _, line in ipairs(STUB.printed) do if line:find(L.POS_NOW_ON, 1, true) then said = said + 1 end end
assert(ns.db.settings.sharePos == false and said == 1, "my later choice is kept, said only once")
-- the setting's own text no longer says "off by default"
assert(not L.OPT_POS_TT:lower():find("off by default", 1, true), "tooltip: " .. L.OPT_POS_TT)
print("ok share_pos_on")
