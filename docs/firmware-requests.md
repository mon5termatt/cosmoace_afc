# ACE Pro Gen1 firmware requests (Klipper / CosmoACE hybrid)

Asks for custom ACE Pro (Gen1) firmware authors, ranked by payoff for host-driven
multi-color on Klipper (CosmoACE + AFC) with an external frame hub and toolhead
sensor.

**Topology:** four equal ACE→hub tubes into an n-1 collector (4-in-1) with a
filament sensor after the merge; one bowden hub→toolhead. Idle tip sits **parked
behind the hub** until `TOOL_LOAD`.

---

## Priority 1 (if only one feature)

**Disable or gate insert auto-preload**

- Config / flag / RPC: on spool insert, **do nothing** until the host commands
  feed/retract.
- Host then: feed to hub → retract clear → park tip behind merger → later
  `TOOL_LOAD`.

<details>
<summary><strong>Author response</strong></summary>

Preload happens because of **NFC parsing** (the unit rotates the spool to find
the chip). It is not an arbitrary tip advance.

With an n-1 collector + filament sensor, the best host-only approach is:

1. Wait until ACE reports the slot loaded
2. `start_feed_assist` on that slot
3. Stop assist when the collector sensor triggers

Gen1 has no onboard path sensor for this; the collector switch is external.

</details>

**Host takeaway:** do not expect preload to go away if NFC stays. CosmoACE hybrid
stages with feed-assist (or feed) until the frame hub sensor, then parks
`hub_clear_mm` behind it. Shared `dist_hub` for all four lanes; shared
`afc_bowden_length` for the single hub→toolhead tube.

---

<details>
<summary><strong>Priority 2</strong> — Report preload distance / tip estimate (if preload must stay)</summary>

- Include something like `preloaded_mm` (or absolute tip offset from slot exit)
  in slot/status JSON after insert preload finishes.
- Host can subtract that from commanded feeds and still use calibrated path
  lengths.

**Author response:** a length report is only a **guesstimate** and will be wrong
if the filament or motor slips. Not reliable enough to treat as ground truth.

**Host takeaway:** keep sensor-homed feeds; do not depend on estimated preload mm.

</details>

<details>
<summary><strong>Priority 3</strong> — Jam / slip feedback</summary>

- Report commanded mm vs actual moved mm, or motor stall / no-motion.
- Today a feed can “complete” while filament is stuck (e.g. crushed bowden), so
  the host thinks the tip advanced when it did not.

**Author response:** there is a **buffer jam** report (motor counted steps ×4 and
the buffer did not change). Actual moved mm is **not** a value ACE1 knows.

**Host takeaway:** surface / act on buffer-jam if exposed in status; do not expect
true encoder mm.

</details>

<details>
<summary><strong>Priority 4</strong> — Cleaner motion / slot state</summary>

- No `empty` ↔ `preload` ↔ `ready` flicker while the host is mid-feed.
- Sticky `busy` (or equivalent) until motion is truly idle.
- Reduces host-side debounce and false “slot not ready” handling.

**Author response:** should be possible.

</details>

<details>
<summary><strong>Priority 5</strong> — USB stability under feeder load</summary>

- Keep CDC / USB serial up while feeders run (avoid LPM / self-reset that drops
  the link).

**Author response:** ACE1 only has **two backside ports**. A disabled-watchdog
build was provided so the link can stay open without host heartbeats
(`heartbeat_s: 0` on CosmoACE).

**Clarification (our side):** “USB ports” meant the **printer** USB ports /
cable path into the Centauri (rear USB-C vs front / hub), not extra ports on
the ACE. Cable and printer-side routing still matter; the no-watchdog image
addresses ACE-side link drops from missed heartbeats.

</details>

<details>
<summary><strong>Nice to have</strong></summary>

1. **Host “park behind exit”** — RPC/command: retract N mm past a known
   reference (or “park clear of exit”) so the host does not invent park math.
2. **Documented “ignore stop until preload done” timeout** — if preload stays
   (NFC seek), publish how long / which conditions make stop/feed safe so
   orchestration is not guessing.

</details>

<details>
<summary><strong>Suggested issue title</strong></summary>

`Feature: sticky busy during NFC seek + expose buffer-jam; host uses collector sensor`

</details>

<details>
<summary><strong>Suggested follow-up one-liner</strong></summary>

> Thanks — we'll treat NFC seek as fixed and host-drive feed-assist until our
> n-1 collector sensor, then park behind the hub. Sticky busy through NFC and
> exposing the buffer-jam bit would still help; we won't rely on estimated mm.

</details>
