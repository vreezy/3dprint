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

draft_mode  = true;             // fast render while developing
$fn         = draft_mode ? 30 : 60;

// ---------- Computed (the missing values from the sketch) ----------
x = sqrt(base_length * base_length + height * height); // long taper edge
y = sqrt(top_length * top_length + height * height);   // red hypotenuse

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
module bodenplatte() {
    // profile drawn in XZ (side view), extruded along Y, bottom edge on the build plate
    translate([0, depth, 0])
        rotate([90, 0, 0])
            linear_extrude(height = depth)
                polygon(profile_points);
}

bodenplatte();
