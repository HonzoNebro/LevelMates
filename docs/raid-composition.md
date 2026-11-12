# Leader-confirmed raid composition

A scheduled raid's members menu has **Raid lineup and subgroup plan**, which
opens a copyable plan with its meetup ID. Without a plan, existing tentative
join-order placement applies. The scheduled raid's creator can opt into explicit
confirmations and assign members using that ID:

```
/lm raidplan enable abc12345
/lm raidplan set abc12345 T 1 Leader
/lm raidplan set abc12345 H 2 Healer
/lm raidplan set abc12345 D 0 Reserve
/lm raidplan abc12345
```

Replace the sample ID/names. Roles are T/H/D; groups are 1–2 for 10 players,
1–4 for 20, 1–8 for 40, with five confirmed members per subgroup. Group **0** is
explicit standby and consumes no confirmed role or subgroup capacity. The activity's
configured role capacities apply across all subgroups. Moving a member checks
capacity after removing that member's old seat. Invalid/full assignments leave
the previous assignment intact.

Enabling starts with **no confirmed members**, including the leader; explicitly
assign everyone. Existing joins without a confirmation remain unconfirmed.
The creator may also plan a named guildmate who has not joined with the addon.
`/lm raidplan clear <ID> Name` removes an assignment; a remaining signup is still
unconfirmed. `/lm raidplan off <ID>` removes the plan and its assignments and
restores ordinary tentative placement. Re-enabling starts empty. Cancelling or
expiring the underlying meetup makes its plan inactive.

Updated clients' group cards/counts/invites use the confirmed lineup when enabled.
Standby and unconfirmed names are listed outside the confirmed slots. The copy
report shows planned subgroups. This is planning only: no live roster moves,
raid-role API changes, automated invites or chat actions. Actual game subgroups
still need manual changes by an authorized raid leader.

## Sync and compatibility

`qf` is the leader-owned opt-in header, `qz` one leader-owned assignment per member
and meetup. They reuse the existing record/sync transport, expire with their
meetup and relay to late logins even when the creator is offline. Parent `qd`
precedes both in the sync type ordering. Receivers verify the source meetup owner
and member-derived assignment ID. Members cannot overwrite the leader's plan.
Role/group caps are enforced in the displayed layout as well as assignment input.
No changes to existing qd/qj/qm schemas. Dungeons retain their existing lineup.

Older clients ignore these record types and still show tentative join-order
placement; they cannot treat this plan as authoritative. Use updated clients for
official confirmation. Transport restrictions can delay reception. The plan is
separate for each occurrence; it is not an automatic signup/confirmation for a
recurring series. Participant-controlled standby/decline responses and live
subgroup application are not part of this delivery.

## Validation

Run `npm test`. `tests/raid_plan.test.lua` covers role/subgroup limits, standby,
manual names, moves, removals, disable/re-enable, creator permissions, commands,
cancellation and preserving dungeon behavior. `tests/raid_plan_sync.net.mjs`
checks shared placement, a forged joiner update and late-login peer relay while
the creator is offline.

**No in-game tests performed.** On WoW Forever, verify the group-card/copy-dialog
layout in English and Spanish, role counts and Invite All's confirmed-only list,
standby/unconfirmed distinction, normal logout/reload and reception on another
updated guild client. Compare actual raid subgroups manually; this feature does
not move players in the live raid.
