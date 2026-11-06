-- 0.7.3: the bot tag is on by default, so "No bot tag" must win over it (and over the guild's), or it does nothing.
STUB.Fire("ADDON_LOADED", "LevelMates")
local _, ns = ...
STUB.Fire("PLAYER_ENTERING_WORLD", true, false); STUB.Advance(30)
local DC, st = ns.Discord, ns.db.settings
assert(st.discordTag == true and DC.TagOn(), "a new account: tagged")
st.discordTagOff = true
assert(not DC.TagOn(), "No bot tag: no tag, though the tag is on")
st.discordTagOff = false
assert(DC.TagOn(), "and back")
print("ok tag_off_wins")
