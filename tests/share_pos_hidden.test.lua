-- 0.7.2: someone with "Appear on the board" off sends nothing at all, so the "you now share your position" line would be false: not said.
LevelMatesDB = { version = 1, settings = { share = false, sharePos = false }, chars = {} }
STUB.Fire("ADDON_LOADED", "LevelMates")
local _, ns = ...
STUB.Fire("PLAYER_ENTERING_WORLD", true, false); STUB.Advance(1)
assert(ns.db.settings.sharePos == true and ns.db.posDefaultOn == true, "turned on all the same, for when they appear again")
for _, line in ipairs(STUB.printed) do assert(not line:find(ns.L.POS_NOW_ON, 1, true), "not told: " .. line) end
print("ok share_pos_hidden")
