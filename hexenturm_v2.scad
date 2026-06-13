// Quader mit gotischem Spitzbogen-Tunnel

// Quader (unten)
box_w = 100;
box_d = 80;
box_h = 100;
box_y = 20;    // Y-Start (Mitte in Y, 0 = zentriert)

// Quader (oben)
box2_w = 100;
box2_d = 90;
box2_h = 40;
box2_y = 15;   // Y-Start (Mitte in Y, 0 = zentriert)

// Walmdach (trapezförmig)
roof_w       = 100;  // Breite (default = box2_w)
roof_d       = 90;   // Tiefe  (default = box2_d)
roof_h       = 30;   // Firsthöhe
roof_ridge_l = 30;   // Firstlänge (0 = Pyramide)

// Türme (Zylinder links/rechts)
tower_r  = 40;   // Radius
tower_h  = 140;  // Höhe
tower_x  = box_w/2 + 38;  // X-Offset (bündig am Quader)
tower_y  = -20;  // Y-Versatz
tower_z  = 20;   // Z-Versatz (Mitte des Zylinders)

// Schießschächte der Türme (3 Ebenen, oberste hat 2 Schächte)
slit_ang_start = 240;  // Startwinkel Ebene 0 (vorne = -Y)
slit_ang_step  = 25;   // Winkelversatz pro Ebene
slit_top_gap   = 60;   // Winkelabstand der 2 Schächte auf Ebene 3

// Turmdach (unten: rund → Sechseck, oben: Sechseck → Spitze)
tr_r1 = 42;   // Basisradius (etwas größer als Turm)
tr_r2 = 12;   // Radius am Übergang Unter-/Oberteil
tr_h1 = 40;   // Höhe Unterteil
tr_h2 = 60;   // Höhe Oberteil

// Spitzen-Profil: 3 Kontrollpunkte (Radius / Z-Position)
tr_p1_r = 21;  tr_p1_z = 10;
tr_p2_r = 17;  tr_p2_z = 23;
tr_p3_r =  5;  tr_p3_z = 35;

// Dachgaube
dg_w  = 15;   // Breite
dg_h  = 12;   // Höhe Quader
dg_d  =  24;   // Tiefe
dg_rh =  8;   // Höhe Dreieckdach
dg_y  = -16;  // Y-Position
dg_z  = 97;   // Z-Position (Unterkante)

// Box2-Fenster vorne (zwei rechteckige Nischen nebeneinander)
b2win_w     = 10;  // Breite je Fenster
b2win_h     = 14;  // Höhe je Fenster
b2win_gap   = 26;  // Abstand zwischen den beiden Fenstern
b2win_depth =  2;  // Eintiefung (max 2)
b2win_z     = 16;  // Z-Unterkante


// Tunnel
arch_span = 60;
arch_leg  = 10;
arch_r    = arch_span;

// Voussoirs (Bogensteine)
stone_n       = 10;   // Steine pro Bogenhälfte
stone_depth   = 2;   // Vorstand von der Vorderfläche
stone_h_big   = 6;   // radiale Dicke, großer Stein
stone_h_small = 4;   // radiale Dicke, kleiner Stein
stone_w_big   = 8;   // Breite entlang Bogen, großer Stein
stone_w_small = 5;   // Breite, kleiner Stein

// Schießschacht-Fenster (8 Steine: 3 links + 3 rechts + 1 oben + 1 unten)
win_z      = 30;   // Z-Mitte des Fensters
win_gap_w  = 2;    // freier Abstand zwischen linken und rechten Steinen
win_depth  = 2;    // Vorstand von der Vorderfläche

fr_h_big   = 5;
fr_h_small = 5;
fr_w_big   = 7;
fr_w_small = 5;
fr_n       = 3;    // Steine pro Seite → gesamt 3+3+1+1 = 8

function fr_h_at(i)  = (i % 2 == 0) ? fr_h_big  : fr_h_small;
function fr_w_at(i)  = (i % 2 == 0) ? fr_w_big  : fr_w_small;
function fr_cum_h(i) = (i == 0) ? 0 : fr_cum_h(i-1) + fr_h_at(i-1);

// ── Hilfsfunktionen: Breite/Höhe/Winkel pro Stein ────────────────────────────
function stone_w_at(i)   = (i % 2 == 0) ? stone_w_big   : stone_w_small;
function stone_h_at(i)   = (i % 2 == 0) ? stone_h_big   : stone_h_small;
function stone_ang_at(i) = stone_w_at(i) / arch_r * (180/PI);
function cum_ang(i)      = (i == 0) ? 0 : cum_ang(i-1) + stone_ang_at(i-1);

// ── Spitzbogen-Profil ─────────────────────────────────────────────────────────
module arch_2d(span, leg_h, r) {
    arch_tip_h = sqrt(r*r - (span/2)*(span/2));
    union() {
        translate([-span/2, 0])
            square([span, leg_h]);
        translate([0, leg_h])
        intersection() {
            translate([-span/2, 0]) circle(r=r, $fn=64);
            translate([ span/2, 0]) circle(r=r, $fn=64);
            translate([-r, 0]) square([2*r, arch_tip_h + 1]);
        }
    }
}

// ── Ein einzelner Voussoir ───────────────────────────────────────────────────
module stone_at(cx, cz, alpha_deg, h, w, depth, front_y) {
    sx = cx + arch_r * cos(alpha_deg);
    sz = cz + arch_r * sin(alpha_deg);
    translate([sx, front_y - depth/2, sz])
    rotate([0, -alpha_deg, 0])
    translate([h/2, 0, 0])
    cube([h, depth, w], center=true);
}

// ── Voussoir-Verzierung (Vorderseite) ────────────────────────────────────────
module arch_verzierung() {
    cr_x = arch_span/2;
    c_z  = arch_leg - box_h/2 - 2;
    fy   = -box_d/2;

    for (i = [0:stone_n-1]) {
        ang = 180 - cum_ang(i) - stone_ang_at(i)/2;
        stone_at(cr_x, c_z, ang, stone_h_at(i), stone_w_at(i), stone_depth, fy);
        mirror([1, 0, 0])
        stone_at(cr_x, c_z, ang, stone_h_at(i), stone_w_at(i), stone_depth, fy);
    }
}

// ── Schießschacht-Rahmensteine ────────────────────────────────────────────────
module fenster_rahmen() {
    fy      = -box_d/2;
    total_h = fr_cum_h(fr_n);
    z_start = win_z - total_h/2;
    cap_w   = win_gap_w + fr_w_big * 2;

    // 3 Seitensteine links und rechts (big-small-big)
    for (i = [0:fr_n-1]) {
        h   = fr_h_at(i);
        w   = fr_w_at(i);
        z_c = z_start + fr_cum_h(i) + h/2;
        for (side = [-1, 1])
            translate([side * (win_gap_w/2 + w/2), fy - win_depth/2, z_c])
            cube([w, win_depth, h], center=true);
    }

    // 1 Stein oben (breiter Abschluss)
    translate([0, fy - win_depth/2, z_start + total_h + fr_h_big/2])
        cube([cap_w, win_depth, fr_h_big], center=true);

    // 1 Stein unten
    translate([0, fy - win_depth/2, z_start - fr_h_small/2])
        cube([cap_w, win_depth, fr_h_small], center=true);
}

// ── Turm-Schießschacht: ein Rahmen auf der Zylinderoberfläche ─────────────────
module turm_koerper() {
    cylinder(r=tower_r, h=tower_h, center=true, $fn=64);
    // Rückseite: Quader von Mitte nach hinten (+Y)
    translate([-tower_r, 0, -tower_h/2])
        cube([2*tower_r, tower_r, tower_h]);
}

module turm_slit_at(ang, z_ctr) {
    total_h = fr_cum_h(fr_n);
    z_start = z_ctr - total_h/2;
    cap_w   = win_gap_w + fr_w_big * 2;

    rotate([0, 0, ang])
    translate([tower_r, 0, 0]) {
        for (i = [0:fr_n-1]) {
            h   = fr_h_at(i);
            w   = fr_w_at(i);
            z_c = z_start + fr_cum_h(i) + h/2;
            for (side = [-1, 1])
                translate([win_depth/2, side*(win_gap_w/2 + w/2), z_c])
                cube([win_depth, w, h], center=true);
        }
        translate([win_depth/2, 0, z_start + total_h + fr_h_big/2])
            cube([win_depth, cap_w, fr_h_big], center=true);
        translate([win_depth/2, 0, z_start - fr_h_small/2])
            cube([win_depth, cap_w, fr_h_small], center=true);
    }
}

module turm_schlitze() {
    for (i = [0:2]) {
        turm_slit_at(slit_ang_start + i * slit_ang_step, -tower_h/3 + i * tower_h/3);
    }
    // 2. Schacht auf oberster Ebene (Winkel via slit_top_gap versetzt)
    turm_slit_at(slit_ang_start + 2*slit_ang_step - slit_top_gap, tower_h/3);
}

// ── Turmdach (Kreis → Sechseck → Kugel → Spitze) ────────────────────────────
module turmdach_spitze(r_base, h) {
    profile = [
        [r_base,  0      ],
        [tr_p1_r, tr_p1_z],
        [tr_p2_r, tr_p2_z],
        [tr_p3_r, tr_p3_z],
        [0.01,    h      ],
    ];
    for (i = [0:len(profile)-2]) {
        r0 = profile[i][0];    z0 = profile[i][1];
        r1 = profile[i+1][0];  z1 = profile[i+1][1];
        translate([0, 0, z0])
        hull() {
            cylinder(r=r0, h=0.01, $fn=6);
            translate([0, 0, z1-z0])
                cylinder(r=r1, h=0.01, $fn=6);
        }
    }
}

module turmdach(r1, r2, h1, h2) {
    // Unterteil: D-förmiger Fuß (Zylinder + Rückseite) → Sechseck oben
    hull() {
        cylinder(r=r1, h=0.01, $fn=64);
        translate([-r1, 0, 0])
            cube([2*r1, r1, 0.01]);
        translate([0, 0, h1])
            cylinder(r=r2, h=0.01, $fn=6);
    }
    // Oberteil: sechseckige Kontur → Spitze
    translate([0, 0, h1])
        turmdach_spitze(r2, h2);
}

// ── Dachgaube (Quader + Satteldach) ──────────────────────────────────────────
module dachgaube(w, h, d, rh) {
    cube([w, d, h], center=true);
    translate([0, 0, h/2])
    hull() {
        cube([w, d, 0.01], center=true);
        translate([0, 0, rh])
            cube([0.01, d, 0.01], center=true);
    }
}

// ── Box2-Fenster: zwei rechteckige Nischen nebeneinander ─────────────────────
module fenster_box2_paar() {
    // intersection: zwei tiefe Schlitze × Tiefenbegrenzer = max b2win_depth tief
    intersection() {
        union() {
            translate([-(b2win_gap/2 + b2win_w), -0.01, 0])
                cube([b2win_w, 100, b2win_h]);
            translate([b2win_gap/2, -0.01, 0])
                cube([b2win_w, 100, b2win_h]);
        }
        translate([-(b2win_gap/2 + b2win_w) - 1, -0.01, -1])
            cube([2*b2win_w + b2win_gap + 2, b2win_depth + 0.02, b2win_h + 2]);
    }
}


// ── Walmdach ──────────────────────────────────────────────────────────────────
module walmdach(w, d, h, ridge_l) {
    hull() {
        cube([w, d, 0.01], center=true);
        translate([0, 0, h])
            cube([max(ridge_l, 0.01), 0.01, 0.01], center=true);
    }
}

// ── Szene ─────────────────────────────────────────────────────────────────────
translate([0, box_y, 0]) {
    difference() {
        cube([box_w, box_d, box_h], true);
        translate([0, box_d/2 + 2, -box_h/2 - 2])
        rotate([90, 0, 0])
        linear_extrude(box_d + 5)
        arch_2d(arch_span, arch_leg, arch_r);
    }
    arch_verzierung();
    fenster_rahmen();
}

// Türme
translate([-tower_x, tower_y, tower_z]) {
    turm_koerper();
    turm_schlitze();
}
mirror([1, 0, 0])
translate([-tower_x, tower_y, tower_z]) {
    turm_koerper();
    turm_schlitze();
}

// Turmdächer
translate([-tower_x, tower_y, tower_z + tower_h/2])
    turmdach(tr_r1, tr_r2, tr_h1, tr_h2);
mirror([1, 0, 0])
translate([-tower_x, tower_y, tower_z + tower_h/2])
    turmdach(tr_r1, tr_r2, tr_h1, tr_h2);

// Quader oben mit Fensternischen
translate([0, box2_y, box_h/2 + box2_h/2])
difference() {
    cube([box2_w, box2_d, box2_h], true);
    // Vorderfenster: 1 Ebene
    translate([0, -box2_d/2, b2win_z - box2_h/2])
        fenster_box2_paar();
}

// Dach
translate([0, box2_y, box_h/2 + box2_h])
    walmdach(roof_w, roof_d, roof_h, roof_ridge_l);

// Dachgaube
translate([0, dg_y, dg_z + dg_h/2])
    dachgaube(dg_w, dg_h, dg_d, dg_rh);
