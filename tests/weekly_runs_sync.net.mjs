// A recurring raid uses ordinary meetup transport; peers receive a distinct date with fresh signups.
import assert from 'node:assert/strict';
import { Net } from '../tools/lua-net.mjs';
const net = new Net(['Ana', 'Ben']);
net.advance(5);
net.run('Ana', `local _, ns = ...
 local ok, id = ns.Meetups.Create{ d = 190, t = "Guild raid", x = 10, c = "T1H2D7", role = "T", at = ns.Meetups.Now() + 60 }
 assert(ok and ns.Meetups.SetWeekly(id, true))`);
net.advance(5);
net.run('Ben', 'local _, ns = ...; assert(ns.Meetups.Join(ns.Meetups.List()[1].id, "H"))');
net.advance(5);
net.run('Ana', `local _, ns = ...
 local p; for _, v in pairs(ns.char.weeklyRuns[GetGuildInfo("player")]) do p = v end
 -- Force the publication boundary; calendar arithmetic is covered in weekly_runs.test.lua.
 p.next = ns.Meetups.Now() + 120
 ns.Meetups.WeeklyTick(); ns.Meetups.WeeklyTick()`);
net.advance(10);
assert.equal(net.run('Ben', `local _, ns = ...; local list = ns.Meetups.List()
 assert(#list == 2 and list[1].id ~= list[2].id)
 assert(list[1].joined.Ben == "H" and not list[2].joined.Ben)
 assert(list[2].size == 10 and list[2].caps.T == 1 and list[2].caps.H == 2 and list[2].t == "Guild raid")
 assert(not ns.Meetups.IsWeekly(list[2].id), "the private plan is not copied to peers")
 return true`), true);
console.log('ok tests/weekly_runs_sync.net.mjs');
