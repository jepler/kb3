intersection() {
    rotate([90,0,0])
    cylinder(d=3.9, h=16, $fn=32, center=true);

    cube([16, 16, 3.4], center=true);

    linear_extrude(height=6, center=true)
    polygon([
        [-0.5, -8.1],
        [-2.0, -4.1],
        [-2.0,  4.1],
        [-0.5,  8.1],
        [ 0.5,  8.1],
        [ 2.0,  4.1],
        [ 2.0, -4.1],
        [ 0.5, -8.1],
    ]);
}
