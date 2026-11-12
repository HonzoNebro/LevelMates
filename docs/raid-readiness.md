# Personal raid preparation

`/lm raidready 101` opens a copyable personal preparation snapshot for Molten Core.
Use 102 for Onyxia, 103 for ZG, 104 for BWL, 105/106 for AQ20/AQ40, 107 for Naxx,
108/109 for the catalogue's custom raids, or 190 for a free-named raid activity.
The catalogue is not evidence a raid is open on your realm.

Configure your own requirements explicitly; the addon does not prescribe
consumables or infer access from your gear:

```
/lm raidready access 101 yes
/lm raidready items 101 13446:10,13444:5
/lm raidready 101
```

The example numbers are item IDs/counts, not a recommendation for a particular
raid or class. Replace them with your guild's requirements. `items 101 clear`
clears them. At most 20 distinct items, IDs 1–999999, required counts 1–999.
Malformed or duplicate entries reject the entire replacement. Settings belong to
the character, guild key and raid activity; they persist with SavedVariables.

Access is a **self-report** (`yes`, `no`, `unknown`), dated and expired after seven
days. It is not a quest/key/attunement API verdict. Item counts use carried
inventory with bank/reagent/account-bank/charge-counting flags disabled.
Missing, protected, throwing or invalid API values display **Unknown**, including
when no item requirements have been configured. No inventory, buff, aura or
combat data is read from other players.

Lockouts list all raid entries that the client reports as locked or extended,
with the API's remaining seconds. They are labelled **cached**: no automatic
mapping between activity IDs and instance names, no request/response freshness
claim, and no "ready" verdict from an empty cache. Open the game's Raid Info,
refresh it and review the target raid and realm rules manually. The snapshot is
not refreshed after it opens; run the command again when needed. API calls are
skipped in combat or if combat state cannot be read safely.

The report is local, uses the existing copy dialog and sends no addon/chat
messages. Share the text only if you choose. Existing `/lm raidprobe` remains the
separate explicit test for the realm's addon-message transport restrictions.
This first readiness delivery does not implement guild-wide checks or hardcoded
attunement rules for WoW Forever.

## API basis and verification limits

The API contracts were inspected in the client UI source mirror:
[raid info consumer](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_RaidFrame/Mainline/RaidFrame.lua)
and [generated item API documentation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/ItemDocumentation.lua).
These describe the general client API; Forever availability is checked at runtime,
and unknowns remain unknown. The addon prefers `C_Item.GetItemCount`, with legacy
`GetItemCount` as a fallback when the modern function is absent.

Run `npm ci --prefix tools --ignore-scripts` and `npm test`. The focused
`tests/raid_readiness.test.lua` covers invalid configuration, atomic replacement,
missing/protected/throwing APIs, zero inventory, cached/extended/empty lockouts,
combat, attestation expiry, guild scoping, slash commands and the copy report.

**No in-game tests have been performed.** Manual WoW Forever checks:

1. Configure one carried item and one missing item, open the report and compare
   counts with bags (including bank-only items as a control).
2. Compare cached rows with the game's Raid Info, including an extended lockout.
3. Try missing client APIs or restricted values where the realm exposes them;
   verify Unknown rather than a pass. Repeat outside and during combat.
4. Check English/Spanish copy-dialog layout and multiline instructions.
5. Set access, reload, and confirm it is labelled self-reported. Confirm other
   characters/guilds do not inherit these requirements.
