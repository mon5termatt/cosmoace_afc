# USB-C rear panel mount (Centauri)

Printable clamp that uses the Centauri’s **two horizontal M3 frame standoffs**
and holds a **panel USB-C jack rotated 90°** so the port is **vertical**.

Source: [`usb_c_rear_mount.scad`](usb_c_rear_mount.scad)  
STLs: `usb_c_rear_mount.stl`, `usb_c_rear_mount_offset.stl`

---

## Why vertical

The rear sheet cutout is about **7.7 mm wide × 10.6 mm tall**. A horizontal
USB-C shell (~8.4 mm) will not clear the width; a vertical port fits.

---

## Stack (outside = +Z)

```
frame sheet → USB-C PCB (against sheet) → standoff well → printed plate
```

The plate sits on the standoff tops. A central clamp presses the PCB against
the frame. Pegs drop into the PCB’s M2 holes (no flange screws required).

---

## Frame measurements (calipers)

| What | Value | Notes |
|---|---|---|
| Outer width across both standoffs | **22.1 mm** | Outside caliper |
| Inner width between standoffs | **13.7 mm** | Inside caliper |
| Derived M3 center-to-center | **17.9 mm** | `(22.1 + 13.7) / 2` |
| Derived standoff OD | **~4.2 mm** | `(22.1 - 13.7) / 2` — pocket size, not load-bearing |
| Effective standoff height | **5.5 mm** | In SCAD as `standoff_h` (plan draft used ~6.5) |
| Screws | **M3** | Clearance ~3.4 mm, optional countersink |

M3 holes on the plate: **X = ±8.95 mm** (half of 17.9).

### Cutout vs M3 line (not centered)

Caliper from a standoff, stretch vertically to the cutout edges:

| Edge | Distance from M3 |
|---|---|
| Top of cutout | **9.8 mm** |
| Bottom of cutout | **5.6 mm** |

Derived cutout height check: `9.8 + 5.6 = 15.4` (sheet opening height used in
SCAD is **10.6 mm** for the aperture; the 9.8/5.6 pair shifts the USB clamp
in **Y** so the port sits in the hole).

Cutout center offset from M3 line:

\[
Y = (9.8 - 5.6) / 2 = \mathbf{+2.1\ \text{mm}}
\]

---

## USB-C jack / PCB measurements

| What | Value | Notes |
|---|---|---|
| PCB size | **6.7 × 20.1 × 1.5 mm** | Long axis = vertical when mounted |
| M2 flange holes inner | **13.9 mm** | Inside caliper |
| M2 flange holes outer | **~18.5 mm** | Outside caliper |
| Derived M2 CTC | **16.2 mm** | `(13.9 + 18.5) / 2` |
| Locate pegs | **Ø1.85 × 1.1 mm** | Into PCB holes; no flange screws |
| Port cutout in plate | **3.5 × 9.0 mm** | Vertical; + print clearance |

PCB: short side (**6.7**) along **X**, long side (**20.1**) along **Y**.  
M2 / pegs on **Y** at ±8.1 mm.

---

## Mechanical layout

```
Frame M3 pair (horizontal CTC 17.9)
        │
        ▼
 Printed clamp plate ──► USB-C opening vertical
        ▲
 USB-C PCB (+ locate pegs stacked vertical)
```

- **XY:** M3 pair on X; USB clamp shifted in Y to cutout center.
- **Z:** PCB against sheet; plate on standoff tops; clamp presses PCB.
- Screw length must clear the plate face and still engage the M3 bosses.

---

## Print / fit notes

- Prefer **PETG**. Flip so locate pegs point **+Z** (usually no supports).
- Dry-fit: nudge Customizer params (`frame_outer` / `frame_inner`,
  `standoff_h`, `cutout_*`, `clamp_off_*`) after first print.
- OpenSCAD `part = "preview"` shows ghost frame, standoffs, and jack.

---

## Wiring (safety)

Solder only **D+ / D− / Gnd** (+5 V only if intentional).  
**Never** bring the toolhead umbilical **24 V** onto the USB shell.

---

## Out of scope

- Filling / matching an old Microfit cutout exactly — enlarge plate margins
  in Customizer if the sheet hole is larger than the jack.
- Electrical isolation beyond the header note above.
