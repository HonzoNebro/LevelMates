import assert from 'node:assert/strict';
import { Net } from '../tools/lua-net.mjs';
const net=new Net(['Ana','Ben','Cris']);
net.leave('Cris'); net.advance(5);
const id=net.run('Ana',`local _,ns=...; assert(ns.Meetups.Create{d=190,x=10,at=ns.Meetups.Now()+60,role="T"}); return ns.Meetups.List()[1].id`);
net.advance(5);
net.run('Ben',`local _,ns=...; assert(ns.Meetups.Join("${id}","H"))`); net.advance(5);
net.run('Ana',`local _,ns=...; assert(ns.RaidPlan.Enable("${id}")); assert(ns.RaidPlan.Assign("${id}","Ana","T",1)); assert(ns.RaidPlan.Assign("${id}","Ben","H",2))`);
net.advance(10);
assert.equal(net.run('Ben',`local _,ns=...; local s=ns.Meetups.Slots(ns.Meetups.List()[1]); assert(s.confirmed and s.groups.Ben==2 and s.T[1]=="Ana"); return true`),true);
// Forged assignment from a joiner cannot move the leader's composition.
net.run('Ben',`local _,ns=...; ns.Comm.Send("qz",{id="${id}."..ns.NameKey("Ben"),m="${id}",n="Ben",r="H",g=0,v=GetServerTime()+100,e=GetServerTime()+10000},"now")`);
net.advance(5);
assert.equal(net.run('Ana',`local _,ns=...; return ns.Meetups.Slots(ns.Meetups.List()[1]).groups.Ben`),2);
net.leave('Ana'); net.join('Cris');
net.run('Cris','local _,ns=...; ns.Roster.Announce()'); net.advance(30);
assert.equal(net.run('Cris',`local _,ns=...; local m=ns.Meetups.List()[1]; assert(m); local s=ns.Meetups.Slots(m); assert(s.confirmed and s.groups.Ben==2 and s.T[1]=="Ana"); return true`),true,'late login gets plan from a peer while creator is offline');
console.log('ok tests/raid_plan_sync.net.mjs');
