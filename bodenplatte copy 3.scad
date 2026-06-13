// bodenplatte.scad
// Side profile: two right triangles sharing a vertical 6 mm edge.
// Red triangle:  top edge 6 mm, vertical edge 6 mm, 90deg between them, hypotenuse y.
// Green triangle: bottom edge 150 mm, vertical edge 6 mm, hypotenuse x (long taper to the tip).
// All units in millimeters.

// ---------- Parameters ----------
base_length = 150;  // bottom edge of the green triangle (V -> tip)
height      = 6;    // shared vertical edge between the two triangles
top_length  = 6;    // horizontal top edge of the red triangle (A -> P)
depth       = 240;  // extrusion depth of the part

orientation = "print";  // "print" = base_length edge on the floor, "cnc" = x edge (long taper face) on the floor

tread        = "raised"; // texture on the x face: "none" | "raised" (checker bumps, for 3D print) | "grooves" (V-grid, for CNC)
tread_height = 1;         // bump height / groove depth
tread_pitch  = 16;        // grid spacing of the pattern
rib_length   = 12;        // raised rib: length
rib_width    = 2.5;       // raised rib: width (must stay > 2 * tread_height)
tread_margin = 40;        // untextured zone at the thin tip (part is thinner than the pattern depth there); 0 = full coverage

draft_mode  = false;             // fast render while developing
$fn         = draft_mode ? 30 : 60;

// ---------- Computed (the missing values from the sketch) ----------
x = sqrt(base_length * base_length + height * height); // long taper edge
y = sqrt(top_length * top_length + height * height);   // red hypotenuse
taper_angle = atan(height / base_length);              // slope of the x edge, ~2.29 deg
face_x0     = -height * sin(taper_angle);              // left end of the x face in cnc frame (thick end)

echo(str("x (long taper edge) = ", x, " mm"));
echo(str("y (red hypotenuse)  = ", y, " mm"));

// ---------- Profile (side view, origin at V = bottom of the shared edge) ----------
//  A(-top_length, height) ---- P(0, height)
//        \                      |\____
//       y \                     |6    ‾‾‾‾----____ x
//          \                    |                 ‾‾‾‾----____
//           ‾‾‾‾--- V(0, 0) ----+------------ base_length ----- T(tip)
profile_points = [
    [-top_length, height],   // A: top-left
    [0,           height],   // P: top of shared edge
    [base_length, 0],        // T: tip
    [0,           0]         // V: bottom of shared edge
];

// ---------- Part ----------
module profile_2d() {
    polygon(profile_points);
}

// flipped upside down and rotated by the taper angle so the x edge lies flat at y = 0
module profile_2d_cnc() {
    translate([0, height * cos(taper_angle)])
        rotate(-taper_angle)
            mirror([0, 1])
                profile_2d();
}

// plain body in cnc frame: x face flat on z = 0, extruded along Y
module body_cnc() {
    translate([0, depth, 0])
        rotate([90, 0, 0])
            linear_extrude(height = depth)
                profile_2d_cnc();
}

// one raised checker bump: flat-topped bar with sloped sides
module rib() {
    linear_extrude(height = tread_height,
                   scale = [max(0.05, (rib_length - 2 * tread_height) / rib_length),
                            max(0.05, (rib_width  - 2 * tread_height) / rib_width)])
        square([rib_length, rib_width], center = true);
}

// checker field on the x face, ribs alternating +-45 deg, pointing outward (down in cnc frame)
module rib_field() {
    nx = floor(x / tread_pitch);
    ny = floor(depth / tread_pitch);
    intersection() {
        translate([face_x0, 0, -tread_height])
            cube([x - tread_margin, depth, tread_height]);
        for (i = [0 : nx], j = [0 : ny])
            translate([face_x0 + (i + 0.5) * tread_pitch, (j + 0.5) * tread_pitch, 0])
                rotate([0, 0, (i + j) % 2 == 0 ? 45 : -45])
                    mirror([0, 0, 1])
                        rib();
    }
}

// crosshatch of V-grooves: diamond-section bars half-buried in the x face plane
module groove_field() {
    side = tread_height * sqrt(2);   // diamond cross-section -> groove depth = tread_height
    run  = 2 * (x + depth);          // long enough to cross the face diagonally
    n    = ceil((x + depth) / tread_pitch);
    intersection() {
        translate([face_x0, 0, -tread_height])
            cube([x - tread_margin, depth, 2 * tread_height]);
        for (ang = [45, -45])
            rotate([0, 0, ang])
                for (k = [-n : n])
                    translate([0, k * tread_pitch, 0])
                        rotate([45, 0, 0])
                            cube([run, side, side], center = true);
    }
}

// body with the selected tread applied to the x face (still in cnc frame)
module body_textured_cnc() {
    if (tread == "raised")
        union() {
            body_cnc();
            rib_field();
        }
    else if (tread == "grooves")
        difference() {
            body_cnc();
            groove_field();
        }
    else
        body_cnc();
}

module bodenplatte(orient = orientation) {
    if (orient == "cnc")
        // lift so raised bumps (if any) rest on the bed instead of poking below z = 0
        translate([0, 0, tread == "raised" ? tread_height : 0])
            body_textured_cnc();
    else
        // flip back over: base_length face on the floor, textured x face on top
        mirror([0, 0, 1])
            rotate([0, -taper_angle, 0])
                translate([0, 0, -height * cos(taper_angle)])
                    body_textured_cnc();
}

bodenplatte();
