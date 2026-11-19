// Centauri rear USB-C panel mount
//
// Stack (outside = +Z):
//   frame sheet → PCB (against sheet) → 6.5 mm standoff well → plate
// The plate sits on the standoff tops and the central clamp presses the
// USB-C PCB against the frame. Port is vertical (jack rotated 90°).
//
// Rear sheet cutout is ~7.7 wide × 10.6 tall (clip relief on top) — USB-C
// fits vertical only; horizontal shell (~8.4) will not clear 7.7.
// M3 standoffs are NOT vertically centered on the cutout: caliper from
// standoff out to top edge (9.8) and bottom edge (5.6) → USB/clamp is
// shifted in Y so the port sits in the hole.
//
// Wiring note: solder only D+ / D- / Gnd (+5V only if intentional).
// Never bring the toolhead umbilical 24V onto the USB shell.
//
// Print: flip so locate pegs point +Z (no supports). PETG preferred.

/* [Part] */
part = "plate"; // ["plate", "preview"]

/* [Frame standoffs] */
// Outside caliper across both bosses
frame_outer = 22.1;
// Inside caliper between bosses
frame_inner = 13.7;
standoff_h  = 5.50;   // effective boss height
// Shallow locate pockets on the pad that sits on boss tops (0 = flat)
standoff_pocket_d = 1.0;
standoff_clear    = 0.30; // radial clearance on pocket OD

/* [Frame screws] */
frame_screw = "M3"; // ["M2", "M3", "M4"]
frame_cs    = true; // countersink on outer (+Z) face

/* [USB-C PCB] */
// Board outline (long axis = vertical when mounted)
pcb_w = 6.7;   // X
pcb_l = 20.1;  // Y
pcb_t = 1.5;   // Z — against frame; plate clamps its top face
pcb_clear = 0.25; // per-side around board for the clamp pillar
// How much the clamp face overlaps the PCB (inset from PCB edge)
pcb_press_inset = 0.4;

/* [USB-C locate pegs] */
// Outside / inside caliper across the two M2 holes (same method as frame)
flange_outer = 18.5;
flange_inner = 13.9;
// Pegs drop into the PCB's M2 holes — no flange screws; clamp does the holding
peg_d        = 1.85; // slightly under typical M2 hole (~2.0–2.2)
peg_h        = 1.1;  // < pcb_t so tips don't hit the frame
peg_tip_d    = 1.4;  // tapered lead-in
peg_tip_h    = 0.45;

/* [Rear panel cutout] */
// Sheet opening (USB-C vertical only — 7.7 is too tight horizontally)
cutout_w = 7.7;   // X — narrow axis
cutout_h = 10.6;  // Y — tall axis (clip relief is above this)
// Caliper on standoff, stretch vertically to cutout top / bottom edges
cutout_above_m3 = 9.8; // standoff → top edge
cutout_below_m3 = 5.6; // standoff → bottom edge

/* [USB-C port cutout] */
// Vertical port in the printed clamp (long axis along Y)
port_w = 3.5;  // X
port_l = 9.0;  // Y — must stay under cutout_h
port_clear = 0.35;

/* [Offsets] */
// Origin = M3 pair center. USB clamp shifts in Y to the cutout center.
use_cutout_clamp_y = true;
m3_off_x = 0;
m3_off_y = 0;
// Extra nudge on the clamp (added on top of derived Y when enabled)
clamp_off_x = 0;
clamp_off_y = 0;

/* [Plate] */
plate_margin = 1.8;  // mm beyond frame screw pads on the outer cap
plate_face_t = 3.0;  // solid above standoff tops (outer cap)
edge_chamfer = 0.6;

$fn = 64;

// --- screw presets ---
function screw_clearance(t) =
    t == "M2" ? 2.3 :
    t == "M3" ? 3.4 :
    t == "M4" ? 4.5 : 3.4;

function screw_head_d(t) =
    t == "M2" ? 4.4 :
    t == "M3" ? 6.3 :
    t == "M4" ? 8.4 : 6.3;

function screw_cs_ang(t) = 90;

frame_hole_d  = screw_clearance(frame_screw);
frame_cs_d    = screw_head_d(frame_screw);
frame_cs_ang  = screw_cs_ang(frame_screw);

// --- derived ---
frame_ctc   = (frame_outer + frame_inner) / 2;
standoff_od = (frame_outer - frame_inner) / 2;
flange_ctc  = (flange_outer + flange_inner) / 2;

// Vertical cutout center vs M3 line: more space above → positive Y
cutout_h_meas = cutout_above_m3 + cutout_below_m3;
cutout_cy     = (cutout_above_m3 - cutout_below_m3) / 2;

m3_x = m3_off_x;
m3_y = m3_off_y;

clamp_x = clamp_off_x;
clamp_y = (use_cutout_clamp_y ? cutout_cy : 0) + clamp_off_y;

// Skirt from PCB top up to standoff tops
skirt_h = standoff_h - pcb_t;
assert(skirt_h > 1.5, "standoff_h must be taller than pcb_t");
assert(peg_h + 0.05 < pcb_t, "peg_h must stay shorter than pcb_t");

plate_h = skirt_h + plate_face_t; // total printed height
// Model z=0 at PCB press face; standoff pad plane at z=skirt_h; outer at z=plate_h

pcb_press_w = pcb_w - 2 * pcb_press_inset;
pcb_press_l = pcb_l - 2 * pcb_press_inset;
clamp_w = pcb_w + 2 * pcb_clear;
clamp_l = pcb_l + 2 * pcb_clear;

// Outer cap stays a compact M3 bar — clamp pillar may stick out past it
pad_r   = frame_hole_d / 2 + plate_margin;
plate_x = frame_ctc + 2 * pad_r;
plate_y = max(frame_hole_d + 2 * plate_margin + 2.0, 8.0);

echo(str(
    "frame CTC=", frame_ctc, " standoff OD≈", standoff_od,
    " h=", standoff_h,
    " | cutout ", cutout_w, "x", cutout_h,
    " meas H=", cutout_h_meas, " center Y=", cutout_cy,
    " | m3 at ", m3_x, ",", m3_y,
    " | clamp at ", clamp_x, ",", clamp_y,
    " | plate ", plate_x, " x ", plate_y, " x ", plate_h
));

module countersink_z(hole_d, head_d, ang, from_z) {
    cs_h = (head_d - hole_d) / 2 / tan(ang / 2);
    translate([0, 0, from_z - cs_h])
        cylinder(d1 = hole_d, d2 = head_d, h = cs_h + 0.05);
}

module plate_profile_2d() {
    offset(r = edge_chamfer)
        offset(delta = -edge_chamfer)
            square([plate_x, plate_y], center = true);
}

module clamp_profile_2d() {
    offset(r = 0.5)
        offset(delta = -0.5)
            square([clamp_w, clamp_l], center = true);
}

// Locating peg for a PCB M2 hole — protrudes below press face (−Z)
module pcb_locate_peg() {
    shaft_h = max(0.05, peg_h - peg_tip_h);
    // Root into the clamp solid so the peg isn't a zero-thickness join
    translate([0, 0, -shaft_h])
        cylinder(d = peg_d, h = shaft_h + 0.6);
    translate([0, 0, -peg_h])
        cylinder(d1 = peg_tip_d, d2 = peg_d, h = peg_tip_h + 0.02);
}

module clamp_assembly() {
    // Everything that moves with clamp_off_* (pillar, pegs, port)
    union() {
        linear_extrude(height = plate_h)
            clamp_profile_2d();

        for (sy = [-1, 1])
            translate([0, sy * flange_ctc / 2, 0])
                pcb_locate_peg();
    }
}

module clamp_cuts() {
    // Port aperture follows the pillar offset (wires exit the PCB rear)
    translate([0, 0, -0.05])
        linear_extrude(height = plate_h + 0.1)
            offset(r = 0.5)
                offset(delta = -0.5)
                    square([port_w + 2 * port_clear, port_l + 2 * port_clear],
                           center = true);
}

module mount_plate() {
    difference() {
        union() {
            // Compact M3 bar on the standoff tops
            translate([m3_x, m3_y, skirt_h])
                linear_extrude(height = plate_face_t)
                    plate_profile_2d();

            // PCB clamp pillar — shifted in Y to the cutout center
            translate([clamp_x, clamp_y, 0])
                clamp_assembly();
        }

        translate([clamp_x, clamp_y, 0])
            clamp_cuts();

        // Frame M3 — horizontal on X (through cap into bosses)
        translate([m3_x, m3_y, 0])
            for (sx = [-1, 1])
                translate([sx * frame_ctc / 2, 0, skirt_h - 0.05]) {
                    cylinder(d = frame_hole_d, h = plate_face_t + 0.1);
                    if (frame_cs)
                        countersink_z(frame_hole_d, frame_cs_d, frame_cs_ang,
                                      skirt_h + plate_face_t + 0.05);
                }

        // Locate pockets on underside of cap (boss tops)
        if (standoff_pocket_d > 0)
            translate([m3_x, m3_y, 0])
                for (sx = [-1, 1])
                    translate([sx * frame_ctc / 2, 0, skirt_h - 0.05])
                        cylinder(d = standoff_od + 2 * standoff_clear,
                                 h = standoff_pocket_d + 0.05);
    }
}

// Ghost assembly for preview — frame at z=-pcb_t … plate as modeled
module ghost_jack() {
    // Shift so preview matches real stack: PCB bottom on frame at z=-pcb_t
    // Plate model z=0 = PCB top.
    frame_z = -pcb_t;

    // Frame sheet snippet
    color([0.35, 0.35, 0.4, 0.35])
        translate([0, 0, frame_z - 0.75])
            cube([max(plate_x, cutout_w) + 16, max(plate_y, cutout_h) + 16, 1.5],
                 center = true);

    // Rear cutout ghost centered on the USB clamp (vertical port only)
    color([0.1, 0.1, 0.12, 0.55])
        translate([clamp_x, clamp_y, frame_z - 0.75])
            cube([cutout_w, cutout_h, 1.6], center = true);

    // Standoffs on the M3 line (not vertically centered on the cutout)
    color([0.5, 0.5, 0.55, 0.4])
        translate([m3_x, m3_y, 0])
            for (sx = [-1, 1])
                translate([sx * frame_ctc / 2, 0, frame_z + standoff_h / 2])
                    cylinder(d = standoff_od, h = standoff_h, center = true);

    translate([clamp_x, clamp_y, 0]) {
        // PCB against frame, under the standoff height
        color([0.2, 0.55, 0.35, 0.5])
            translate([0, 0, frame_z + pcb_t / 2])
                cube([pcb_w, pcb_l, pcb_t], center = true);

        // Port shell through plate / outward (vertical)
        color([0.75, 0.75, 0.8, 0.55])
            translate([0, 0, plate_h + 1.0])
                cube([2.6, 8.4, 6.0], center = true);

        // PCB hole ghosts (pegs seat here)
        color([0.1, 0.1, 0.1, 0.45])
            for (sy = [-1, 1])
                translate([0, sy * flange_ctc / 2, frame_z + pcb_t / 2])
                    cylinder(d = 2.1, h = pcb_t + 0.2, center = true);
    }
}

if (part == "plate")
    mount_plate();
else if (part == "preview") {
    mount_plate();
    ghost_jack();
}
