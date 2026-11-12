-- Read-only personal raid preparation. No combat data, inspections, messages or automatic verdict.
local _, ns = ...
local RR = {}
ns.RaidReadiness = RR
local L = ns.L
RR.ACCESS_LIFE, RR.MAX_ITEMS = 7 * 86400, 20
local function raid(id) local a = ns.Activities.Get(tonumber(id)); return a and a.kind == "r" and a.id end
local function profile(id)
	local guild = ns.GuildKey()
	ns.char.raidPreparation = ns.char.raidPreparation or {}
	ns.char.raidPreparation[guild] = ns.char.raidPreparation[guild] or {}
	local ps = ns.char.raidPreparation[guild]
	ps[id] = ps[id] or {}
	return ps[id]
end
local function plain(v, kind)
	v = ns.Plain(v)
	if type(v) == kind then return v end
end
local function number(v)
	v = plain(v, "number")
	if v and v == v and v >= 0 and v < math.huge and v == math.floor(v) then return v end
end
function RR.SetAccess(id, value)
	id = raid(id)
	if not id or (value ~= "yes" and value ~= "no" and value ~= "unknown") then return false end
	local p = profile(id); p.access, p.accessAt = value, time()
	return true
end
-- Validate a complete replacement first. Never partially change a profile on invalid input.
function RR.SetItems(id, text)
	id = raid(id)
	if not id or type(text) ~= "string" then return false end
	text = strtrim(text)
	local items, seen = {}, {}
	if strtrim(text) ~= "" and strtrim(text) ~= "clear" then
		if text:sub(1, 1) == "," or text:sub(-1) == "," or text:find(",%s*,") then return false end
		for piece in text:gmatch("[^,]+") do
			local item, count = piece:match("^%s*(%d+):(%d+)%s*$")
			item, count = tonumber(item), tonumber(count)
			if not item or item < 1 or item > 999999 or not count or count < 1 or count > 999 or seen[item] or #items >= RR.MAX_ITEMS then return false end
			seen[item] = true; items[#items + 1] = { id = item, required = count }
		end
		if #items == 0 then return false end
	end
	profile(id).items = items
	return true
end
function RR.Lockouts()
	local out = { status = "unknown", rows = {} }
	if type(GetNumSavedInstances) ~= "function" or type(GetSavedInstanceInfo) ~= "function" then return out end
	local ok, n = pcall(GetNumSavedInstances)
	n = ok and number(n)
	if not n or n > 100 or n ~= math.floor(n) then return out end
	for i = 1, n do
		local good, name, _, reset, _, locked, extended, _, isRaid = pcall(GetSavedInstanceInfo, i)
		name, reset, locked, extended, isRaid = plain(name, "string"), number(reset), plain(locked, "boolean"), plain(extended, "boolean"), plain(isRaid, "boolean")
		if not good or not name or not reset or locked == nil or extended == nil or isRaid == nil then return out end
		if isRaid and (locked or extended) then out.rows[#out.rows + 1] = { name = name, reset = math.floor(reset), extended = extended } end
	end
	out.status = "cached" -- even an empty client cache does not prove raid eligibility
	return out
end
function RR.Snapshot(id)
	id = raid(id)
	if not id then return nil end
	local p = profile(id)
	local out = { id = id, at = time(), access = "unknown", items = {}, lockouts = { status = "unknown", rows = {} } }
	-- All API reads are refused in combat, including checks invoked by slash commands.
	local okCombat, combat = false, nil
	if type(UnitAffectingCombat) == "function" then okCombat, combat = pcall(UnitAffectingCombat, "player") end
	if not okCombat or ns.Plain(combat) ~= false then out.combat = true; return out end
	if p.accessAt and out.at >= p.accessAt and out.at - p.accessAt <= RR.ACCESS_LIFE then out.access, out.accessAt = p.access, p.accessAt end
	out.lockouts = RR.Lockouts()
	local get = C_Item and C_Item.GetItemCount or GetItemCount
	for _, item in ipairs(p.items or {}) do
		local ok, count = false, nil
		if type(get) == "function" then ok, count = pcall(get, item.id, false, false, false, false) end
		count = ok and number(count) or nil
		out.items[#out.items + 1] = { id = item.id, required = item.required, count = count,
			status = count == nil and "unknown" or count >= item.required and "enough" or "missing" }
	end
	return out
end
function RR.Text(id)
	local s = RR.Snapshot(id)
	if not s then return L.READY_HELP end
	local lines = { string.format(L.READY_TITLE, ns.Activities.Name(s.id), date("%d/%m/%Y %H:%M", s.at)), L.READY_PERSONAL }
	if s.combat then lines[#lines + 1] = L.READY_COMBAT; return table.concat(lines, "\n") end
	lines[#lines + 1] = L.READY_ACCESS .. ": " .. (L["READY_" .. s.access:upper()] or L.READY_UNKNOWN) .. (s.accessAt and (" · " .. date("%d/%m %H:%M", s.accessAt)) or "")
	lines[#lines + 1] = L.READY_LOCKOUTS .. ": " .. (s.lockouts.status == "cached" and L.READY_CACHED or L.READY_UNKNOWN)
	for _, r in ipairs(s.lockouts.rows) do lines[#lines + 1] = string.format("  %s · %ds%s", ns.Activities.CleanName(r.name), r.reset, r.extended and (" · " .. L.READY_EXTENDED) or "") end
	lines[#lines + 1] = L.READY_ITEMS
	if #s.items == 0 then lines[#lines + 1] = L.READY_UNCONFIGURED end
	for _, item in ipairs(s.items) do lines[#lines + 1] = string.format("  #%d: %s/%d · %s", item.id, item.count == nil and "?" or tostring(item.count), item.required, L["READY_" .. item.status:upper()]) end
	lines[#lines + 1] = L.READY_LIMITS
	lines[#lines + 1] = L.READY_HELP
	return table.concat(lines, "\n")
end
ns.Slash("raidready", function(rest)
	local action, id, value = strtrim(rest or ""):match("^(%a+)%s+(%d+)%s+(.+)$")
	if action then
		local ok = action == "access" and RR.SetAccess(id, value) or action == "items" and RR.SetItems(id, value)
		ns.Say(ok and L.READY_SAVED or L.READY_HELP)
	else ns.DiscordCopy.OpenText(RR.Text(tonumber(strtrim(rest or "")))) end
end)
