-- 0.7.3: a guildmate's pin is a circle in their class colour with the round class icon inside and the name above,
-- in the class colour; a bundle is a gold circle with the count.
RAID_CLASS_COLORS.MAGE = { r = 0.25, g = 0.78, b = 0.92 }
STUB.Fire("ADDON_LOADED", "LevelMates")
local _, ns = ...
STUB.Fire("PLAYER_ENTERING_WORLD", true, false); STUB.Advance(1)
local C, GM, R = ns.Comm, ns.GuildMap, ns.Roster
STUB.guildMembers = { Tester = true, Mario = true, Ana = true, Luis = true, Eva = true, Pau = true }
R.InvalidateGuildRoster()
STUB.Receive("LVLM2", C.Encode("hb", { l = 30, z = 1412, c = "MAGE", x = 40, y = 50 }), "GUILD", "Mario Coldblade-Testrealm")
WorldMapFrame:Show(); WorldMapFrame:OnMapChanged()
local p
for _, q in ipairs(GM.pins) do if q:IsShown() then p = q end end
assert(p and p.ring, "a circle behind the icon")
local c = p.ring.vertexColor
assert(c and math.abs(c[1] - 0.25) < 0.01 and math.abs(c[2] - 0.78) < 0.01 and math.abs(c[3] - 0.92) < 0.01, "in the class colour")
assert(p.icon.texture == "Interface\\TargetingFrame\\UI-Classes-Circles" and p.icon.texcoord and p.icon.texcoord[1] == CLASS_ICON_TCOORDS.MAGE[1], "the round class icon")
assert(p.ring.w > p.icon.w, "the circle shows round the icon: " .. tostring(p.ring.w) .. " / " .. tostring(p.icon.w))
assert(p.label:IsShown() and p.label.text == "Mario" and p.label.color and math.abs(p.label.color[1] - 0.25) < 0.01, "first name above, in the class colour")
-- unknown class: a neutral circle, no error
STUB.Receive("LVLM2", C.Encode("hb", { l = 30, z = 1421, x = 10, y = 10 }), "GUILD", "Luis-Testrealm")
STUB.worldMapId = 1421; WorldMapFrame:OnMapChanged()
for _, q in ipairs(GM.pins) do if q:IsShown() then p = q end end
assert(p.mate == "Luis" and p.ring:IsShown(), "no class known: still a circle")
-- a bundle: gold circle, the count
for _, n in ipairs({ "Ana", "Eva", "Pau" }) do STUB.Receive("LVLM2", C.Encode("hb", { l = 30, z = 1421, c = "MAGE", x = 10, y = 10 }), "GUILD", n .. "-Testrealm") end
GM.Refresh()
local bundle
for _, q in ipairs(GM.pins) do if q:IsShown() and #(q.names or {}) > 1 then bundle = q end end
assert(bundle and bundle.count:IsShown() and bundle.count.text == "4" and bundle.ring.vertexColor[1] > 0.9 and bundle.ring.vertexColor[3] < 0.3, "gold circle with 4")
assert(not bundle.label:IsShown(), "no name on a bundle")
print("ok map_pin_style")
