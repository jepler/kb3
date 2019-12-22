// https://media.digikey.com/pdf/Data%20Sheets/Cherry%20PDFs/MX%20Series.pdf

////////////////////////////////////////////////////////////////////////
// micro b panel connector
// Overall width: 25mm
// Max height: 10mm (measured)
// Hole spacing: 18mm (per datasheet adafru.it/3258)
// Mounting screws: #4-40

// Create a void for the panel mount micro USB connector,
// connector pointing towards +Z, mounting holes aligned along X
module panelmicrob_void(d_front, d_back, h_spc = 18, maxh = 12, ovw = 26, h_dia =4.5 ) {
    d_ovl = d_back + d_front;
    // 1. Clearance holes for #4-40 screws, length d_front
    translate([-h_spc/2, 0, -.01])
    cylinder(d=h_dia, h=d_front+.01);
    translate([ h_spc/2, 0, -.01])
    cylinder(d=h_dia, h=d_front+.01);
    // 2. hole for the connector itself est 10x5mm
    translate([ 0, 0, -.01])
    linear_extrude(height=h_dia)
    square([11, 6],center=true);
    
    // 3. Cutout for the thing itself, length d_bac
    translate([0, 0, -d_back])
    linear_extrude(height=d_back)
    hull() {
        translate([-h_spc/2, 0, 0])
        circle(d=maxh);
        translate([ h_spc/2, 0, 0])
        circle(d=maxh);
    }
}
////////////////////////////////////////////////////////////////////////

$fn = 72;

function IN(x) = x * 25.4;

function rest(seq) = [for(i=[1:1:len(seq)-1]) seq[i]];
function reverse(seq) = seq ? concat(reverse(rest(seq)), [seq[0]]) : [];
function isnumber(x) = abs(x) + 1 >= 0;

$layer = 0;

module void_keyswitch() {
    square(IN(.551), center=true);
    if($layer == 1)
    square([IN(.551)/3, IN(.551)+3], center=true);
}

// 1x2, .. 1x2.75: A = .94
// 1x3: A = 1.5
// 1x7: A = 4.5
// 1x8, ..., 10: A = 5.25

$costar_stabilizer_offset_y = 0.65;
$costar_stabilizer_width = 3.3;
$costar_stabilizer_height = 14.2;
$costar_offset_layer = 3;
// kad uses +-1.65 in X and -6.45+7.75 for costar stabilizers
module void_keyswitch_stabilizer(A, B=0) {
    void_keyswitch();

    for(dx = [-A, A]) {
        translate([-dx, 0.65]) {
            square([$costar_stabilizer_width, $costar_stabilizer_height+$costar_offset_layer*$layer], center=true);
        }
    }
}

module void_keyswitch_as(N) {
    if(N <= 1.75) void_keyswitch();
    else if(N <= 2.75) void_keyswitch_stabilizer(11.9);
    else if(N <= 3) void_keyswitch_stabilizer(19.05);
    else if(N <= 4) void_keyswitch_stabilizer(28.575);
    else if(N <= 4.5) void_keyswitch_stabilizer(34.671);
    else if(N <= 5.5) void_keyswitch_stabilizer(42.8625);
    else if(N <= 6) void_keyswitch_stabilizer(47.5);
    else if(N <= 6.25) void_keyswitch_stabilizer(50);
    else if(N <= 7) void_keyswitch_stabilizer(50);
    else void_keyswitch_stabilizer(66.75);
}

module keyrow(widths) {
    if(widths) {
        width = widths[0];
        if(width > 0) {
            translate([IN(.375) * width, 0])
            void_keyswitch_as(width);
        }
        translate([IN(.75) * abs(width), 0])
            keyrow(rest(widths));
    }
}

module keyrowsr(rows) {
    if(rows) {
        row = rows[0];
        if(isnumber(row)) {
            translate([0, IN(.75) * row])
            keyrowsr(rest(rows));
        } else {
            translate([0, IN(.375)])
            keyrow(row);
            translate([0, IN(.75)])
            keyrowsr(rest(rows));
        }
    }
}

module keyrows(rows) { keyrowsr(reverse(rows)); }

module cutrows_r(rows, left, ovl) {
    if(rows) {
        row = rows[0];
        height = row[0];
        width = row[1];
        if(left) {
            translate([-IN(.375), -IN(.75)])
            offset(.125) square([width * IN(.75), height * IN(.75)]);
        } else {
            translate([-IN(.375) + width * IN(.75), -IN(.75)])
            offset(.125) square([ovl * IN(.75), height * IN(.75)]);
        }
        translate([0, height*IN(.75)])
        cutrows_r(rest(rows), left, ovl);
    }
}

module cutrows(rows, left=true, ovl=99) { cutrows_r(reverse(rows), left=left, ovl=ovl); }



module layer() {
    difference() {
        square([IN(.75 * $cells_x), IN(.75*$cells_y)]);
        keyrows($layout);
    }
}

$plate_th1 = 1.0;
$plate_th2 = 2.0;
$wall_th = 8;
$num_holes = 6;
$wall = 8;
m3_clearance = 3.6;
m3_counterbore_dia = 5.7;
m3_counterbore_h = 2.5;
m3_threaded_insert = 3.9;
m2_threaded_insert = 3.3;
$angle = 3.5;
$min_h = 8;
function max_h() = $min_h + sin($angle) * (IN(.85*$cells_y) + 2*$wall);
$floor = 2;

module m3_screw_counterbore(len, counterbore_depth=m3_counterbore_h) {
    cylinder(d=m3_clearance, h=len);
    translate([0,0,len-.01])
    cylinder(d=m3_counterbore_dia, h=counterbore_depth);
}

module m3_threaded_insert(len) {
    translate([0,0,-len+.01])
    cylinder(d=m3_threaded_insert, h=len);
}

module distribute(n, t) {
    echo("distribute", n, t);
    for(i=[0:1:n-1]) {
        translate(t * (i / (n-1))) children();
    }
}

module keeb() {

    translate([0,0,$plate_th2])
    linear_extrude($plate_th1, convexity=36) layer($layer=0);

    linear_extrude($plate_th2, convexity=36) layer($layer=1);

    difference() {
        linear_extrude($wall_th, convexity=2)
        difference() {
        translate([-$wall,-$wall,0])
        square([IN(.75 * $cells_x)+2*$wall, IN(.75*$cells_y)+2*$wall]);
        square([IN(.75 * $cells_x), IN(.75*$cells_y)]);
        }

        translate([-$wall/2, -$wall/2])
        distribute($num_holes, [IN(.75 * $cells_x) + $wall,0,0]) {
            m3_screw_counterbore(4, 8);

            translate([0, IN(.75*$cells_y)+$wall/2])
            translate([0, $wall/2])
            m3_screw_counterbore(4, 8);
        }

        let($stage = 1) children();
    }
}

module slice(left, delta, height=32, center=true) {
    linear_extrude(height, center=center, convexity=12)
    offset(delta=delta)
    cutrows($cut, left=left);
}
// %slice(false, delta=.2);

module divided_keyboard(left=1, right=1) {
    if(left)
    color("#ee7777") intersection() { keeb() children(); slice(true, delta=-.2); }
    if(right)
    color("#7777ee") render() intersection() { keeb() children(); slice(false, delta=-.2); }
}

module base_outline() {
    scale([1, 1/cos($angle), 1])
    difference() {
        translate([-$wall,-$wall,0])
        square([IN(.75 * $cells_x)+2*$wall, IN(.75*$cells_y)+2*$wall]);
        square([IN(.75 * $cells_x), IN(.75*$cells_y)]);
    }
}

module shear_yz(v) {
    multmatrix([ [1, 0, 0, 0],
                 [0, 1, v, 0],
                 [0, 0, 1, 0],
                 [0, 0, 0, 1]])
        children();
}

// construct the base with its bottom flat at Z=0
module base0() {
    render() {
        intersection() {
            rotate([$angle, 0, 0]) {
                translate([0,0,-500])
                cube(1000, center=true);
            }
            shear_yz(-tan($angle))
            translate([0, 0, -$min_h]) {
                linear_extrude(height=max_h(), convexity=6) base_outline();

                translate([0,0,-$floor])
                scale([1, 1/cos($angle), 1])
                linear_extrude(height=$floor, convexity=6)
                translate([-$wall,-$wall,0])
                square([IN(.75 * $cells_x)+2*$wall, IN(.75*$cells_y)+2*$wall]);
            }
        }
    }
}

module m2_insert_riser(h, do_void) {
    if(do_void) {
        translate([0,0,-.5])
        cylinder(d=m2_threaded_insert, h=h+2);
    } else {
        cylinder(d=m2_threaded_insert + 3, h=h);
    }
}

module m3_insert_riser(h, do_void) {
    if(do_void) {
        translate([0,0,-.5])
        cylinder(d=m3_threaded_insert, h=h+2);
    } else {
        cylinder(d=m3_threaded_insert + 3, h=h);
    }
}

// put the base with the INTENDED TOP at z=0, slice off the unneeded part,
// add mounting holes for threaded insertts
module base_inplace() {
    difference() {

        intersection()  {
            union() {
                rotate([-$angle, 0, 0]) {
                    difference() {
                        union() {
                            render(convexity=4) base0();
                            let($stage=0) children();
                        }
                        let($stage=1) children();
                    }
                }
                let($stage=2) children();
            }
        }


        let($stage=3) children();

        translate([-$wall/2, -$wall/2])
        distribute($num_holes, [IN(.75 * $cells_x) + $wall,0,0]) {
            color("#ff0000")
            m3_threaded_insert(4);

            translate([0, IN(.75*$cells_y)+$wall/2])
            translate([0, $wall/2])
            color("#ff0000")
            m3_threaded_insert(4);
        }
    }
}

module base() {
    translate([0,0,$min_h])
    rotate([$angle, 0, 0])
    base_inplace() children();
}

module split_base(left, right, frac=.5, inplace=false, delta=.2) {
    ovl_x = IN(.75 * $cells_x) + 2*$wall;
    if(left) {
        intersection() {
            translate([ovl_x*.25-delta-$wall,0,0])
            cube([ovl_x * frac, 1000, 1000], center=true);
            if(inplace) base_inplace() children(); else base() children();
        }
    }
    if(right) {
        intersection() {
            if(inplace) base_inplace() children(); else base() children();
            translate([ovl_x*.75+delta-$wall,0,0])
            cube([ovl_x * frac, 1000, 1000], center=true);
        }
    }
}

module sixteen() {
    $cells_x = 4;
    $cells_y = 4;
    $layout = [ [1, 1, 1, 1], [1, 1, 1, 1], [1, 1, 1, 1], [1, 1, 1, 1] ];

    children();
}

module minimal() {
    $wall_th = 4;
    $plate_th2 = 1.0;
    $cells_x = 4;
    $cells_y = 1;
    $layout = [ [1, 3 ] ];
    children();
}

module clip_post(zz=2) {
    rotate([90,0,0])
    linear_extrude(height=3, center=true)
    polygon([
        [1, 0], 
        [1, 3],
        [0, 3],
        [0, 3+zz],
        [1, 4+zz],
        [-1, 5+zz],
        [-2, 0]
    ]);
}

module clip_board(xx, yy, zz=2) {
    translate([-xx/2, -yy/2]) rotate(45) clip_post(zz);
    translate([ xx/2, -yy/2]) rotate(135) clip_post(zz);
    translate([ xx/2,  yy/2]) rotate(-135) clip_post(zz);
    translate([-xx/2,  yy/2]) rotate(-45) clip_post(zz);
}

module post_board(x, y, h, do_void) {
    translate([-x/2, -y/2]) m2_insert_riser(h, do_void);
    translate([ x/2, -y/2]) m2_insert_riser(h, do_void);
    translate([ x/2,  y/2]) m2_insert_riser(h, do_void);
    translate([-x/2,  y/2]) m2_insert_riser(h, do_void);
}

module clip_seesaw() { clip_board(IN(1.3), IN(0.5)); }
module post_neopixel(h, do_void) {
    translate([IN(-.5), IN(.06)])
    m3_insert_riser(h, do_void);
    translate([IN(.5), IN(.06)])
    m3_insert_riser(h, do_void);
}

minimal() { 
    $wall = 1;
    $num_holes = 0;
    keeb();
    // base_inplace() { }
}
// split_base(true, true, inplace=true);

if(1) {
    translate([-$wall-4, -$wall-4,-32]) {
        %cube([200, 150, .1]);
        translate([201,0,0])
        %cube([199, 150, .1]);
    }
}
