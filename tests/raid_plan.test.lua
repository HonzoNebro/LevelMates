STUB.Fire("ADDON_LOADED", "LevelMates")
local _, ns = ...
STUB.guildMembers = { Tester=true, Ana=true, Ben=true, Cris=true, Dani=true, Eva=true, Feli=true, Gina=true }
STUB.Fire("PLAYER_ENTERING_WORLD", true, false); STUB.Advance(30)
ns.Roster.InvalidateGuildRoster()
local M, P = ns.Meetups, ns.RaidPlan
assert(M.Create{d=190,x=10,at=M.Now()+60,role="T"})
local m=M.List()[1]; local id=m.id
assert(not M.Slots(m).confirmed)
assert(P.Enable(id) and M.Slots(m).confirmed and M.Count(m)==0, "explicit confirmations replace tentative placement")
assert(P.Assign(id,"Tester","T",1) and P.Assign(id,"Ana","H",1))
assert(P.Assign(id,"Ben","D",1) and P.Assign(id,"Cris","D",1) and P.Assign(id,"Dani","D",1))
assert(not P.Assign(id,"Eva","D",1), "five per subgroup")
assert(P.Assign(id,"Eva","D",2) and P.Assign(id,"Feli","D",2))
assert(not P.Assign(id,"Gina","D",2), "role cap applies across subgroups")
assert(P.Assign(id,"Gina","D",0), "standby does not consume a role or subgroup")
local s=M.Slots(m)
assert(#s.D==5 and s.standby.Gina=="D" and s.groups.Eva==2 and s.waiting[1]=="Gina")
assert(not P.Assign(id,"Stranger","D",0) and not P.Assign(id,"Ana","H",3) and not P.Assign(id,"Ana","A",1))
assert(not P.Assign(id,nil,"H",1) and not P.Assign(id,"Ana","H",-1))
assert(P.Assign(id,"Ana","H",2), "a move omits the existing seat when checking capacity")
assert(P.Remove(id,"Ben") and M.Count(m)==6)
local text=P.Text(id)
assert(text:find(ns.L.RAID_PLAN_STANDBY,1,true) and text:find("Gina",1,true))
assert(P.Disable(id) and not M.Slots(m).confirmed and not next(M.Slots(m).groups or {}))
assert(P.Enable(id) and M.Count(m)==0, "disabling removes assignments")
local oldMe=ns.Me; ns.Me=function() return "Ana" end
assert(not P.Enable(id) and not P.Assign(id,"Ana","H",1) and not P.Disable(id))
ns.Me=oldMe
SlashCmdList.LEVELMATES("raidplan set "..id.." T 1 Tester")
assert(M.Count(m)==1)
local opened; ns.DiscordCopy.OpenText=function(t) opened=t end
SlashCmdList.LEVELMATES("raidplan "..id)
assert(opened:find(id,1,true))
assert(M.Create(5,M.Now()+90))
assert(not P.Enable(M.List(5)[1].id), "raid plans do not change dungeon placement")
assert(M.Cancel(id) and not P.Assign(id,"Ana","H",1))
