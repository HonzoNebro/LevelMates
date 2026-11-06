-- GuildNotice.lua: the guild's info (the game's Guild Information text) said in guild chat by itself, every so often,
-- so whoever is online reads it without opening anything. Officers and the guild master who turn it on (off by
-- default); one of them sends it: the last time is shared between officers (`gi`), and a random wait before sending
-- lets the one who waits longer hear the other first.
-- The one place the addon writes in chat without a click (asked 2026-11-06). It is the guild's own chat, never a public
-- channel: tested in game that day, guild chat takes a line sent from a timer; public channels still need a click.
local _, ns = ...
local GN = {}
ns.GuildNotice = GN
local L, C, R = ns.L, ns.Comm, ns.Roster
GN.EVERY_CHOICES = { 30, 60, 120, 240 }   -- minutes
GN.MAX_LINES, GN.SETTLE, GN.JITTER = 5, 120, 20   -- messages per notice; seconds after entering the world; longest random wait
GN.PACE = 0.3   -- seconds between the lines of one notice

local function now() return (GetServerTime and GetServerTime()) or time() end
local function store()
	ns.db.guildNotice = ns.db.guildNotice or {}
	local k = ns.GuildKey()
	ns.db.guildNotice[k] = ns.db.guildNotice[k] or {}
	return ns.db.guildNotice[k]
end

-- On for the guild it was turned on in (its key), not for the character: changing guild never carries it over.
function GN.On()
	local k = ns.GuildKey()
	return ns.char ~= nil and k ~= "?" and ns.char.guildNotice == k
end
function GN.SetOn(on) if ns.char then ns.char.guildNotice = on and ns.GuildKey() or nil end end
function GN.Every()
	local n = ns.char and ns.char.guildNoticeEvery
	for _, c in ipairs(GN.EVERY_CHOICES) do if c == n then return n end end
	return 60
end
-- What to say: "info" (the guild info, by default), "motd" (the game's message of the day), "both" (that one first) or
-- "text" (the officer's own, written in the Recruit tab and kept per guild; not shared with the other officers).
GN.WHAT_CHOICES = { "info", "motd", "both", "text" }
GN.TEXT_MAX = 250   -- letters
function GN.What()
	local w = ns.char and ns.char.guildNoticeWhat
	for _, c in ipairs(GN.WHAT_CHOICES) do if c == w then return w end end
	return "info"
end
function GN.Last() return store().last end   -- { at = seconds, by = name }
function GN.Wait()
	local l = store().last
	if not l then return 0 end
	return math.max(0, GN.Every() * 60 - (now() - l.at))
end

-- What is said: the chosen text's lines that say something, without codes ("|n" is a line break), each line in
-- messages of at most 255 bytes broken between words, and at most GN.MAX_LINES messages in all.
local function wrap(line, out)
	while #line > 255 and #out < GN.MAX_LINES do
		local cut = ns.CutUtf8(line, 255)
		local space = cut:match("^.*() ")
		if space and space > 1 then cut = line:sub(1, space - 1) end
		out[#out + 1] = (cut:gsub("%s+$", ""))
		line = (line:sub(#cut + 1):gsub("^%s+", ""))
	end
	if line ~= "" and #out < GN.MAX_LINES then out[#out + 1] = line end
end
local function infoText()
	local ok, info = pcall(function() return GetGuildInfoText and GetGuildInfoText() end)
	info = ok and ns.Plain(info) or nil
	return type(info) == "string" and info or ""
end
-- The game's message of the day comes only with its GUILD_MOTD event (at login, or when it changes): asking for it
-- (C_GuildInfo.GetMOTD) is a blocked action on Forever. Kept per guild, so a /reload does not lose it.
local motdEv = CreateFrame("Frame")
motdEv:RegisterEvent("GUILD_MOTD")
motdEv:SetScript("OnEvent", function(_, _, text)
	text = ns.Plain(text)
	if type(text) ~= "string" then return end
	if ns.db and ns.GuildKey() ~= "?" then store().motd = text; GN.earlyMotd = nil else GN.earlyMotd = text end   -- before the guild is known: kept until it is
end)
local function motdText()
	if not ns.db or ns.GuildKey() == "?" then return "" end
	if GN.earlyMotd then store().motd = GN.earlyMotd; GN.earlyMotd = nil end
	local m = store().motd
	return type(m) == "string" and m or ""
end

function GN.Text() local t = ns.db and ns.GuildKey() ~= "?" and store().text; return type(t) == "string" and t or "" end
function GN.SetText(text)
	if not ns.db or ns.GuildKey() == "?" then return false end
	local clean = tostring(text or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|", ""):gsub("%c", " ")
	store().text = ns.CutUtf8(strtrim(clean), GN.TEXT_MAX * 4)
	ns.Fire("LM_RECRUIT_CHANGED")
	return true
end

function GN.Lines()
	local what, out = GN.What(), {}
	local parts = {}
	if what == "text" then parts[1] = GN.Text() end
	if what == "motd" or what == "both" then parts[#parts + 1] = motdText() end
	if what == "info" or what == "both" then parts[#parts + 1] = infoText() end
	local info = table.concat(parts, "\n")
	info = info:gsub("|n", "\n"):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|H.-|h(.-)|h", "%1"):gsub("|T.-|t", ""):gsub("|", "")
	for line in (info .. "\n"):gmatch("([^\n]*)\n") do
		line = line:gsub("%c", " "):gsub("^%s+", ""):gsub("%s+$", "")
		if line ~= "" then wrap(line, out) end
		if #out >= GN.MAX_LINES then break end
	end
	return out
end

-- Never in combat or in an instance: that is when the game holds chat (its own lockdown flag reads true all the time on
-- Forever, so it cannot tell; see ns.SendChat). The notice waits for the next turn instead.
local function free() return not ((InCombatLockdown and InCombatLockdown()) or (IsInInstance and IsInInstance())) end
local function ready() return GN.On() and R.IAmOfficer() and now() >= (GN.readyAt or 0) and GN.Wait() == 0 and free() end

-- Said: the wait starts for every officer.
local function said()
	store().last = { at = now(), by = ns.Me() }
	C.Send("gi", { t = now() }, "now")
	ns.Fire("LM_RECRUIT_CHANGED")
end

-- After the random wait: still due (nobody else said it meanwhile, still out of combat)? Then the lines, a moment apart.
-- Refused by the game before the first line: not said, the next turn tries again.
function GN.Send()
	GN.pending = false
	if not ready() then return end
	local lines = GN.Lines()
	if #lines == 0 then return end
	if not ns.SendChat(lines[1], "GUILD") then return end
	said()
	for i = 2, #lines do C_Timer.After((i - 1) * GN.PACE, function() ns.SendChat(lines[i], "GUILD") end) end
end

function GN.Tick()
	if GN.pending or not ready() then return end
	GN.pending = true
	C_Timer.After(math.random(0, GN.JITTER), GN.Send)
end

C.OnMessage("gi", function(f, name)
	if not R.IsOfficer(name) then return end
	local at = f.t
	if at > now() + 60 then return end
	local l = store().last
	if not l or at > l.at then store().last = { at = at, by = name }; ns.Fire("LM_RECRUIT_CHANGED") end
end)

-- Officers tell a newcomer when it was last said, so a fresh login does not say it again at once.
ns.On("LM_HELLO_ANSWERED", function()
	if not R.IAmOfficer() then return end
	local l = store().last
	if l and now() - l.at < GN.EVERY_CHOICES[#GN.EVERY_CHOICES] * 60 then C.Send("gi", { t = l.at }) end
end)

ns.On("LM_WORLD", function()
	GN.readyAt = now() + GN.SETTLE   -- time to hear the others' last time first
	if not GN.ticker then GN.ticker = C_Timer.NewTicker(30, GN.Tick) end
end)
