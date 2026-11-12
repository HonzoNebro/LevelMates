# Weekly run planning

On your scheduled group's card, open the members menu and choose **Repeat weekly**.
The calendar meetup menu has the same action. This works for raids, dungeons and
other scheduled activities. Each occurrence is a normal meetup with its own ID,
reminder and fresh signups; no protocol extension or peer update is required.

The plan belongs to the creator's character and guild. It retains the activity,
custom name, size, role capacities, creator's role and note. It does not retain
joiners, manual placements, kicks or Discord announcements. Other characters do
not inherit the plan. It is not a server-side calendar series.

The creator must be logged in with addon sharing enabled. Every 30 seconds, the
existing meetup ticker publishes the next date once it is within seven days.
The existing limits (two live meetups per creator, ten per guild) still apply;
a full board delays publication and the ticker retries. Missed weeks are skipped
without publishing a backlog. The next date uses the creator's local calendar
(day + 7), preserving the wall-clock hour through daylight-saving changes.
Changing the computer's timezone after enabling repetition is not supported;
stop and recreate the plan in the desired timezone.

Choose **Stop weekly repetition** on the current occurrence (or original source
while its card remains) to stop future publication. Cancelling that occurrence
also stops its plan. Already published other occurrences remain independent.
`/lm weekly` reports the number of plans in the current guild;
`/lm weekly stop` stops all of them, even if no card remains visible. To change
a series' configuration, stop it and enable repetition on a new configured run.
Plans persist with normal character SavedVariables, including their next date
and pending occurrence ID. Ordinary `/reload` or a normal logout saves them;
an OS/client crash before SavedVariables are written can lose unsaved changes.

No chat, whispers, invites, rolls or Discord messages are automated. Normal addon
record transport and its restrictions still apply: a locally created record is
not proof every guildmate has received it.

## Validation

`npm ci --prefix tools --ignore-scripts` then `npm test` runs the repository suite.
`node tools/run-lua-test.mjs LevelMates tests/weekly_runs.test.lua` covers repeated
ticks, saved settings, pending-ID recovery, capacity, missed weeks, role and note
preservation, fresh signups, guild isolation, ownership, menus, stopping,
sharing-off and calendar-week/DST construction. The DST case simulates the clock
conversion; the harness is not the WoW client.

In-game validation has **not** been performed for this change. On WoW Forever:

1. Create a scheduled raid with custom size/roles; enable repetition from its card.
2. Reload and verify the menu offers stopping it and `/lm weekly` reports it.
3. With a second guild client, verify that the next occurrence arrives within the
   horizon and has no old signups. Fill capacity first to verify delayed retry.
4. Stop repetition and cancel the current occurrence in separate trials. Confirm
   future publication stops and independently published occurrences remain.
5. Verify English/Spanish labels, menu layout, local-clock behavior, sharing off,
   instance transport restrictions and that no automatic Discord line appears.

This first delivery provides weekly publication only. Raid leader confirmations,
explicit standby choices and per-subgroup assignment are separate changes.
