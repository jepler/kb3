// TODO 
// round or bevel top outside edges
// holes for mounting dowels
// check height
// check positions

use <cherryplate.scad>

module tkl() {
    let(
    $min_h = 8, // measured protrusion of switch 4mm, min_h = 8 let battery just clear plate, 1 more for slop/flex

    $pin_l = 20,
    $pin_d = 4,
    $cells_x = 18.5,
    $cells_y = 6.5,

    $layout = [
        [1, -1, 1, 1, 1, 1, -.5, 1, 1, 1, 1, -.5, 1, 1, 1, 1, -.5, 1, 1, 1],
        .5,
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, -.5, 1, 1, 1],
        [1.5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.5, -.5, 1, 1, 1],
        [1.75, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2.25, -.5],
        [2.25, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2.75, -1.5, 1],
        // [1.50, -1, 1.50, 7.0, 1.5, -1, 1.5, -.5, 1, 1, 1],
        [1.25, 1.25, 1.25, 6.25, 1.25, 1.25, 1.25, 1.25, -.5, 1, 1, 1],
    ],

    $cut = [
        [1, 10],
        [1, 10],
        [.5, 10],
        [1, 9.5],
        [1, 10],
        [1, 10.25],
        [1, 9.75],
        [1, 10.25],
        [1, 10.25]
    ],

    $num_holes = 6
    )
    children();

}
module base_cb() {
echo ("num_holes", $num_holes);
        ovl_x = IN(.75 * $cells_x) + 2*$wall;
        ovl_y = IN(.75 * $cells_y) + 2*$wall;
        // Alignment pins for the left and right halves
        if($stage == 1)  {
            translate([ovl_x * .5 - $wall, -.5*$wall, -$min_h/2-1])
            rotate([0,90,0])
            cylinder(d=$pin_d, h=$pin_l, center=true);

            translate([ovl_x * .5 - $wall, ovl_y-1.5*$wall, -$min_h/2-1])
            rotate([0,90,0])
            cylinder(d=$pin_d, h=$pin_l, center=true);

            translate([ovl_x * .5 - $wall, ovl_y-1.5*$wall, -$min_h/2 + 8])
            rotate([0,90,0])
            cylinder(d=$pin_d, h=$pin_l, center=true);
        }
        if($stage == 0 || $stage == 1) {
            for(x=[IN(.5), ovl_x-IN(.5)-2*$wall])
            translate([x, ovl_y/2, -$min_h])
            rotate(90)
            post_neopixel(3, $stage == 1);

            for(x=[ovl_x/2 - IN(3), ovl_x/2 + IN(3)])
            translate([x, IN(.5), -$min_h])
            post_neopixel(3, $stage == 1);
        }
        // itsy bitsy is 1.4 x .7
        if($stage == 0) {
            translate([ovl_x/2 - IN(2), ovl_y-IN(2), -$min_h-1])
            rotate(90)
            clip_itsybitsy(1.2);
        }
        // Anti-bowing posts
        if($stage == 2) {
            SUPP = [ [8.75, 3, 180], [10.5, 3, 0] ];
            intersection() {
                for( s = SUPP )
                {
                    translate([s[0], s[1], 0] * IN(.75))
                    rotate(s[2])
                    translate([-6,-1,-24])
                    linear_extrude(height=24, convexity=2)
                    union() {
                        square([12, 2]);
                        translate([4.5,0])
                        square([3, 5]);
                    }
                }
                rotate([-$angle,0,0])
                translate([0,0,500-$min_h])
                cube(1000, center=true);
            }
        }
        if($stage == 3) {
            // This Micro-B male/female extension cable features a male USB
            // Micro-B plug on one end, and a bulkhead mountable Micro-B female
            // receptacle on the other. The jack half has two mounting 'ears'
            // with 4-40 screws installed, 18mm apart. The ears are flexible so
            // the holes don't have to be drilled very precisely. The screws
            // can be put on from the back for 'reverse' mounting if the box
            // thickness is a problem. The entire unit is about 12" long from
            // tip to tip (with approx 10" cabling between connectors).

            
            translate([45, IN(.75*$cells_y)+$wall-2, -9])
            rotate(180)
            rotate([90,0,0])
            panelmicrob_void(12, 12);
        }
}

module keeb_cb() {
    ovl_x = IN(.75 * $cells_x) + 2*$wall;
    ovl_y = IN(.75 * $cells_y) + 2*$wall;
    if($stage == 1) {
            translate([ovl_x * .5 + IN(.75*.5) - $wall, -.5*$wall, .5*$wall])
            rotate([0,90,0])
            cylinder(d=$pin_d, h=$pin_l, center=true);

            translate([ovl_x * .5 - $wall + IN(.75*.25), ovl_y-1.5*$wall, .5*$wall])
            rotate([0,90,0])
            cylinder(d=$pin_d, h=$pin_l, center=true);
    }
}

part = 0;

tkl() {
echo("num_holes", $num_holes);
    if(part == 0) {
        spart = [0,1,0,1];
        divided_keyboard(spart[0], spart[1]) keeb_cb();;
        if(spart[2])
        color("#eeee77")
        split_base(true, false, inplace=true) base_cb();
        if(spart[3])
        color("#77ee77")
        render() split_base(false, true, inplace=true) base_cb();
    }
    if(part == 1) {
        split_base(true) base_cb();
    }
    if(part == 2) {
        split_base(false, true) base_cb();
    }
    if(part == 3) {
        divided_keyboard(1,0) keeb_cb();;
    }
    if(part == 4) {
        divided_keyboard(0,1) keeb_cb();;
    }

    if(part == -1) {
        projection(cut=true)
        translate([0,0,-4])
        split_base(true) base_cb();
    }
    if(part == -2) {
        projection(cut=true)
        translate([0,0,-4])
        split_base(false, true) base_cb();
    }
}
