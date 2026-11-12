-- Weekly publication uses existing records; no signup or Discord automation.
STUB.Fire("ADDON_LOADED", "LevelMates")
local _, ns = ...
STUB.Fire("PLAYER_ENTERING_WORLD", true, false); STUB.Advance(30)
local M, S = ns.Meetups, ns.Sync
local ok, id = M.Create{ d = 5, at = M.Now() + 60, role = "T", note = "Bring water" }
assert(ok and id)
assert(not M.SetWeekly("missing", true))
assert(M.SetWeekly(id, true) and M.SetWeekly(id, true), "enable is idempotent")
assert(M.IsWeekly(id))
local guild = GetGuildInfo("player")
local ps = ns.char.weeklyRuns[guild]
local p = ps[id]
local expected = M.Now() + 60 + 7 * 1440
assert(p.next == expected and p.spec.note == "Bring water")
M.WeeklyTick()
assert(#M.List(5) == 1, "next week outside horizon: no early publication")
-- A fresh join belongs to this occurrence only.
STUB.guildMembers.Ana = true; ns.Roster.InvalidateGuildRoster()
STUB.Receive("LVLM2", ns.Comm.Encode("qj", { id = id .. "." .. ns.NameKey("Ana"), r = "H", v = GetServerTime(), e = GetServerTime() + 86400 }), "GUILD", "Ana-Testrealm")
assert(M.List(5)[1].joined.Ana == "H")
local discordCalls = 0
ns.Discord.Run = function() discordCalls = discordCalls + 1 end
STUB.Advance(60 * 60)
M.WeeklyTick(); M.WeeklyTick()
local nextId = p.current
assert(nextId ~= id and M.IsWeekly(nextId) and M.IsWeekly(id))
local nextRec = S.Get("qd", nextId)
assert(nextRec and nextRec.d.at == expected and nextRec.d.n == "Bring water" and nextRec.d.r == "T")
assert(not M.List(5)[2].joined.Ana, "signups are not copied")
assert(discordCalls == 0, "publication must not call Discord chat")
assert(#M.List(5) == 2, "repeated ticks cannot duplicate")
-- Replacing the settings table with a saved copy models a reload, not an in-game test.
local saved = {}; for k, v in pairs(ps) do saved[k] = v end
ns.char.weeklyRuns[guild] = saved
M.WeeklyTick(); assert(#M.List(5) == 2)
assert(M.Cancel(nextId) and not M.IsWeekly(nextId), "cancel current occurrence also stops recurrence")
-- Stopping repetition alone preserves already published occurrences.
assert(M.SetWeekly(id, true)); assert(M.SetWeekly(id, false)); assert(S.Get("qd", id))
-- No backlog after a long absence; stay inside the publication horizon.
assert(M.SetWeekly(id, true))
p = ns.char.weeklyRuns[guild][id]
STUB.now = STUB.now + 30 * 86400 -- offline interval: do not execute scheduled tickers
M.WeeklyTick()
assert(p.next > M.Now() and p.next <= M.Now() + 14 * 1440)
local future = M.List(5)
assert(#future == 1 and future[1].at >= M.Now() + 5)
assert(M.SetWeekly(future[1].id, false))
-- Pending occurrence: retry with its persisted id rather than create another one.
assert(M.SetWeekly(future[1].id, true))
p = ns.char.weeklyRuns[guild][future[1].id]
p.next = M.Now() + 60; p.pending = "retry001"
assert(M.Create{ d = 6, at = M.Now() + 90 })
M.WeeklyTick(); assert(not S.Get("qd", "retry001"), "capacity delays without losing the plan")
for _, m in ipairs(M.List(6)) do M.Cancel(m.id) end
M.WeeklyTick(); assert(S.Get("qd", "retry001") and p.current == "retry001")
M.WeeklyTick(); assert(#M.List(5) == 2)
-- Menu wiring on the main Groups card (also supports raids, not just dungeon cards).
local entries = {}
MenuUtil.CreateContextMenu = function(_, fn)
 fn(nil, { CreateTitle = function() end, CreateButton = function(_, text, cb) entries[text] = cb end })
end
local g
for _, v in ipairs(ns.Groups.List()) do if v.id == "retry001" then g = v end end
ns.Board.OpenGroupMembers(g)
assert(entries[ns.L.WEEKLY_OFF]); entries[ns.L.WEEKLY_OFF]()
assert(not M.IsWeekly("retry001"))
assert(M.SetWeekly("retry001", true))
local originalGuild = GetGuildInfo
GetGuildInfo = function() return "Another guild" end
M.WeeklyTick(); assert(not M.IsWeekly("retry001"), "guild settings are isolated")
GetGuildInfo = originalGuild
assert(M.IsWeekly("retry001"))
-- A foreign owner cannot be scheduled.
S.Store("qd").foreign1 = { t = "qd", id = "foreign1", o = "Ana", v = 1, e = GetServerTime() + 86400, d = { d = 5, at = M.Now() + 60 } }
assert(not M.SetWeekly("foreign1", true))
-- Stop-all is available even without a visible current card.
SlashCmdList.LEVELMATES("weekly stop")
assert(not next(ns.char.weeklyRuns[guild]))
assert(S.Get("qd", "retry001"), "stopping plans preserves published runs")
for _, m in ipairs(M.List()) do if m.by == ns.Me() then M.Cancel(m.id) end end
local made, raidId = M.Create{ d = 190, t = "Guild training", x = 10, c = "T1H2D7", role = "H", at = M.Now() + 60 }
assert(made)
-- A calendar week preserves the wall-clock hour across DST; do not add a fixed 604800 seconds.
local oldDate, oldTime = date, time
local sourceAt = S.Get("qd", raidId).d.at
local localDate = oldDate("*t", sourceAt * 60)
date = function(fmt, at) if fmt == "*t" and at == sourceAt * 60 then return localDate end; return oldDate(fmt, at) end
time = function(t)
 if type(t) == "table" then
  assert(t.day == localDate.day + 7 and t.hour == localDate.hour and t.min == localDate.min and t.isdst == nil)
  return sourceAt * 60 + 7 * 86400 + 3600 -- emulate autumn DST, since the harness clock is UTC
 end
 return oldTime()
end
assert(M.SetWeekly(raidId, true))
p = ns.char.weeklyRuns[guild][raidId]
assert(p.next == sourceAt + 7 * 1440 + 60)
date, time = oldDate, oldTime
p.next = M.Now() + 60
local ready = ns.Comm.IsReady
ns.Comm.IsReady = function() return false end
M.WeeklyTick(); assert(p.current == raidId, "sharing off: defer publication")
ns.Comm.IsReady = ready
M.WeeklyTick()
local r = S.Get("qd", p.current)
assert(r.d.t == "Guild training" and r.d.x == 10 and r.d.c == "T1H2D7" and r.d.r == "H", "raid configuration survives")
-- A saved pending id whose record was already committed is reconciled without a new qd.
p.pending, p.next = p.current, r.d.at
local before = #M.List()
M.WeeklyTick(); assert(#M.List() == before and p.pending == nil, "committed pending id is reused even at capacity")
