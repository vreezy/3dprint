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

orientation = "cnc";  // "print" = base_length edge on the floor, "cnc" = x edge (long taper face) on the floor

draft_mode  = true;             // fast render while developing
$fn         = draft_mode ? 30 : 60;

// ---------- Computed (the missing values from the sketch) ----------
x = sqrt(base_length * base_length + height * height); // long taper edge
y = sqrt(top_length * top_length + height * height);   // red hypotenuse
taper_angle = atan(height / base_length);              // slope of the x edge, ~2.29 deg

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

module bodenplatte(orient = orientation) {
    // profile drawn in XZ (side view), extruded along Y, resting face on the build plate / machine bed
    translate([0, depth, 0])
        rotate([90, 0, 0])
            linear_extrude(height = depth)
                if (orient == "cnc")
                    profile_2d_cnc();
                else
                    profile_2d();
}

bodenplatte();
