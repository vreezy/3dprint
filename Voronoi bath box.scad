// ═══════════════════════════════════════════════════════
//  VORONOI Bath Box  ·  parameterized open-top box with Voronoi pattern
//  Parametric · PETG optimized · open-top box
// ═══════════════════════════════════════════════════════

/* [Box] */
W  = 160;   // outer width  mm
D  = 120;   // outer depth  mm
H  = 80;    // outer height mm
WT = 3.2;   // wall thickness mm
FT = 3.2;   // floor thickness mm
CR = 5;     // vertical corner radius mm

/* [Patterns  —  write "voronoi" or a filename e.g. "logo.svg"] */
// Place SVG files next to this .scad file.
// Expected SVG canvas sizes (in mm, no scaling applied):
//   NORTH / SOUTH  →  AW × AH  =  (W−2×BORDER) × (H−FT−2×BORDER)
//   EAST  / WEST   →  AH × AD  =  (H−FT−2×BORDER) × (D−2×BORDER)
//   BOTTOM         →  AW × AD  =  (W−2×BORDER) × (D−2×BORDER)
NORTH  = "voronoi";  // back  wall  (y = D face)
SOUTH  = "voronoi";  // front wall  (y = 0 face)
EAST   = "voronoi";  // right wall  (x = W face)
WEST   = "voronoi";  // left  wall  (x = 0 face)
BOTTOM = "voronoi";  // floor

/* [Voronoi] */
SEED      = 42;   // random seed (change for different pattern)
CELL_SIZE = 20;   // cell size mm  →  hole ≈ CELL_SIZE − 2×INSET
INSET     = 1.5;  // half-web thickness mm  (web between holes = 2×INSET)
BORDER    = 8;   // solid frame on all sides including top rim mm

/* [Quality  —  full CGAL render may take several minutes] */
$fn = 30;

// ── Derived ───────────────────────────────────────────

CR_IN = max(CR - WT, 1);           // inner corner radius

AW = W - 2*BORDER;                 // voronoi width  (floor / front+back walls)
AD = D - 2*BORDER;                 // voronoi depth  (floor / left+right walls)
AH = H - FT - 2*BORDER;           // voronoi height (all walls, incl. top rim)

// ── Grid-optimized Voronoi ────────────────────────────
//
// Seeds are placed on a jittered grid instead of randomly.
// Each cell only checks its 8 grid neighbors  →  O(8N) instead of O(N²).
// CELL_SIZE controls density; smaller = tighter holes, longer render.

function _gnx(w, s) = floor(w/s) + 1;
function _gny(h, s) = floor(h/s) + 1;

function _gpts(w, h, s, seed) =
    let(nx = _gnx(w,s), ny = _gny(h,s),
        jx = rands(s*0.1, s*0.9, nx*ny, seed),
        jy = rands(s*0.1, s*0.9, nx*ny, seed+7919))
    [for(i=[0:nx-1], j=[0:ny-1]) [i*s + jx[i*ny+j], j*s + jy[i*ny+j]]];

module _gcell(pts, nx, ny, gi, gj, cw, ch) {
    p  = pts[gi*ny + gj];
    nb = [for(di=[-1:1], dj=[-1:1])
             let(ni=gi+di, nj=gj+dj)
             if((ni!=gi||nj!=gj) && ni>=0&&ni<nx && nj>=0&&nj<ny)
             pts[ni*ny+nj]];
    intersection() {
        square([cw, ch]);
        intersection_for(k=[0:len(nb)-1]) {
            q = nb[k];
            m = (p+q)/2;
            translate(m) rotate(atan2(q[1]-p[1], q[0]-p[0]))
            translate([-1000,-500]) square([1000,1000]);
        }
    }
}

module v_holes(w, h, cs, inset, seed) {
    nx = _gnx(w,cs);  ny = _gny(h,cs);
    pts = _gpts(w, h, cs, seed);
    for(i=[0:nx-1], j=[0:ny-1])
        offset(delta=-inset)
        _gcell(pts, nx, ny, i, j, w, h);
}

// ── Box geometry ──────────────────────────────────────
//
// Hull of 4 vertical cylinders → full W×D footprint at z=0,
// rounded vertical edges (radius CR), flat open top.

module outer_form() {
    hull()
    for(x=[CR, W-CR], y=[CR, D-CR]) {
        translate([x, y, CR])  sphere(r=CR);           // bottom edge + corner rounding
        translate([x, y, CR])  cylinder(r=CR, h=H-CR); // vertical body up to sharp top
    }
}

module inner_cavity() {
    translate([WT, WT, FT])
    hull()
    for(x=[CR_IN, W-2*WT-CR_IN], y=[CR_IN, D-2*WT-CR_IN]) {
        translate([x, y, CR_IN])  sphere(r=CR_IN);              // inside bottom fillet
        translate([x, y, CR_IN])  cylinder(r=CR_IN, h=H+1-CR_IN); // body, extends past top
    }
}

// ── Pattern dispatcher ────────────────────────────────
// name == "voronoi"  →  Voronoi grid
// name == "*.svg"    →  import that file (place it next to this .scad)

module _pattern(name, w, h, seed) {
    if (name == "voronoi")
        v_holes(w, h, CELL_SIZE, INSET, seed);
    else
        import(name);
}

// ── Wall / floor cutters ──────────────────────────────

module floor_cut() {
    translate([BORDER, BORDER, -0.01])
    linear_extrude(FT+0.02)
    _pattern(BOTTOM, AW, AD, SEED);
}

module front_wall_cut() {   // SOUTH  (y = 0)
    translate([BORDER, WT+0.01, FT+BORDER])
    rotate([90,0,0]) linear_extrude(WT+0.02)
    _pattern(SOUTH, AW, AH, SEED+1);
}

module back_wall_cut() {    // NORTH  (y = D)
    translate([BORDER, D+0.01, FT+BORDER])
    rotate([90,0,0]) linear_extrude(WT+0.02)
    _pattern(NORTH, AW, AH, SEED+2);
}

module left_wall_cut() {    // WEST   (x = 0)
    translate([WT+0.01, BORDER, FT+BORDER])
    rotate([0,-90,0]) linear_extrude(WT+0.02)
    _pattern(WEST, AH, AD, SEED+3);
}

module right_wall_cut() {   // EAST   (x = W)
    translate([W+0.01, BORDER, FT+BORDER])
    rotate([0,-90,0]) linear_extrude(WT+0.02)
    _pattern(EAST, AH, AD, SEED+4);
}

// ── Assemble ──────────────────────────────────────────

difference() {
    outer_form();
    inner_cavity();
    floor_cut();
    front_wall_cut();
    back_wall_cut();
    left_wall_cut();
    right_wall_cut();
}
