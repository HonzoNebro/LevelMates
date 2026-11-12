-- Opt-in authoritative planning for scheduled raids. Subgroups are a plan, not live roster moves.
local _, ns = ...
local P = {}; ns.RaidPlan = P
local M, S, C, L = ns.Meetups, ns.Sync, ns.Comm, ns.L
local function changed() ns.Fire("LM_MEETUPS_CHANGED") end
local function owns(id, owner) local r = S.Get("qd", id); return r and r.o == owner end
S.Define("qf", { class = "board", life = 8 * 86400, lane = "urgent", max = 20,
	fields = { on = C.V.int(1, 1) }, required = { "on" }, idOwner = owns, onChange = changed })
S.Define("qz", { class = "board", life = 8 * 86400, lane = "urgent", relayMax = 800,
	fields = { m = C.V.word(24), n = C.V.text(48), r = C.V.oneOf("T", "H", "D"), g = C.V.int(0, 8) }, required = { "m", "n", "r", "g" },
	accept = function(f, owner) return owns(f.m, owner) and f.id == f.m .. "." .. ns.NameKey(f.n) end,
	idOwner = function(id, owner) return owns(id:match("^([^%.]+)%."), owner) end, onChange = changed })
local function get(id)
	for _, m in ipairs(M.List()) do local a = ns.Activities.Get(m.d); if m.id == id and a and a.kind == "r" then return m end end
end
local function aid(id, name) return id .. "." .. ns.NameKey(name) end
local function active(m) local h = S.Get("qf", m.id); return h and h.o == m.by end
local function assignments(m)
	return S.List("qz", function(r) return r.d.m == m.id and r.o == m.by end)
end
function P.Layout(m, omit)
	local a = ns.Activities.Get(m.d)
	if not a or a.kind ~= "r" or not active(m) then return nil end
	local slots = { T = {}, H = {}, D = {}, A = {}, groups = {}, standby = {}, waiting = {}, confirmed = true }
	local groupCounts, seen = {}, {}
	local records = assignments(m)
	table.sort(records, function(a, b) return a.id < b.id end)
	for _, rec in ipairs(records) do
		local d = rec.d
		if d.n ~= omit and not seen[d.n] and m.caps[d.r] then
			seen[d.n] = true
			if d.g == 0 then slots.standby[d.n] = d.r
			elseif d.g <= math.ceil(m.size / 5) and #(slots[d.r]) < m.caps[d.r] and (groupCounts[d.g] or 0) < 5 then
				table.insert(slots[d.r], d.n); slots.groups[d.n] = d.g; groupCounts[d.g] = (groupCounts[d.g] or 0) + 1
			end
		end
	end
	local waiting = {}
	for _, role in ipairs({ "T", "H", "D" }) do for _, name in ipairs(slots[role]) do waiting[name] = false end end
	local function wait(name) if name ~= omit and slots.groups[name] == nil then waiting[name] = true end end
	wait(m.by)
	for name in pairs(m.joined or {}) do wait(name) end
	for _, rec in ipairs(records) do wait(rec.d.n) end
	for name, value in pairs(waiting) do if value then slots.waiting[#slots.waiting + 1] = name end end
	table.sort(slots.waiting)
	return slots, groupCounts
end
function P.Enable(id)
	local m, rec = get(id), S.Get("qd", id)
	if not m or m.by ~= ns.Me() then return false end
	return S.Put("qf", id, { on = 1, _exp = rec.e }) and true or false
end
function P.Assign(id, name, role, group)
	local m, rec = get(id), S.Get("qd", id)
	group = tonumber(group)
	if not m or m.by ~= ns.Me() or not active(m) or not C.V.text(48)(name) or not m.caps[role] or not group or group ~= math.floor(group) or group < 0 or group > math.ceil(m.size / 5) then return false end
	if name ~= m.by and not m.joined[name] and not ns.Roster.IsGuildmate(name) then return false end
	local slots, counts = P.Layout(m, name)
	if group > 0 and (#slots[role] >= m.caps[role] or (counts[group] or 0) >= 5) then ns.Say(L.RAID_PLAN_FULL); return false end
	local key = aid(id, name)
	local f = { id = key, v = GetServerTime(), e = rec.e, m = id, n = name, r = role, g = group }
	if not C.Encode("qz", f) then return false end
	return S.Put("qz", key, { m = id, n = name, r = role, g = group, _exp = rec.e }) and true or false
end
function P.Remove(id, name)
	local m = get(id)
	if not m or m.by ~= ns.Me() or type(name) ~= "string" then return false end
	return S.Remove("qz", aid(id, name)) and true or false
end
function P.Disable(id)
	local m = get(id)
	if not m or m.by ~= ns.Me() then return false end
	if not S.Remove("qf", id) then return false end
	for _, rec in ipairs(assignments(m)) do S.Remove("qz", rec.id) end
	return true
end
function P.Text(id)
	local m = get(id)
	if not m then return L.RAID_PLAN_HELP end
	local slots = P.Layout(m)
	local lines = { string.format(L.RAID_PLAN_TITLE, ns.Activities.Name(m.d, m.t), id), slots and L.RAID_PLAN_ACTIVE or L.RAID_PLAN_INACTIVE, L.RAID_PLAN_LIMITS }
	if slots then
		local names = {}; for name in pairs(slots.groups) do names[#names + 1] = name end
		table.sort(names, function(a, b) if slots.groups[a] ~= slots.groups[b] then return slots.groups[a] < slots.groups[b] end; return a < b end)
		for _, name in ipairs(names) do
			local role; for _, r in ipairs({ "T", "H", "D" }) do for _, n in ipairs(slots[r]) do if n == name then role = r end end end
			lines[#lines + 1] = string.format("%d · %s · %s", slots.groups[name], name, L["ROLE_" .. role])
		end
		for _, name in ipairs(slots.waiting) do lines[#lines + 1] = (slots.standby[name] and L.RAID_PLAN_STANDBY or L.RAID_PLAN_UNCONFIRMED) .. ": " .. name end
	end
	lines[#lines + 1] = L.RAID_PLAN_HELP
	return table.concat(lines, "\n")
end
function P.Open(id) ns.DiscordCopy.OpenText(P.Text(id)) end
ns.Slash("raidplan", function(rest)
	local action, id, tail = strtrim(rest or ""):match("^(%a+)%s+(%S+)%s*(.-)$")
	local ok
	if action == "enable" and tail == "" then ok = P.Enable(id)
	elseif action == "off" and tail == "" then ok = P.Disable(id)
	elseif action == "clear" then ok = P.Remove(id, tail)
	elseif action == "set" then local role, group, name = tail:match("^([THD])%s+(%d+)%s+(.+)$"); ok = P.Assign(id, name, role, group)
	else P.Open(strtrim(rest or "")); return end
	ns.Say(ok and L.RAID_PLAN_SAVED or L.RAID_PLAN_BAD)
end)
