module base_body(length, width, height) {
    union() {
        cube([length,width,height]);
        translate([length, width, height/2]) 
            rotate([90,0,0])
                cylinder(width, d1=height, d2=height);
        translate([0, width, height/2]) 
            rotate([90,0,0])
                cylinder(width, d1=height, d2=height);
    }
}

module teeth(count, pitch, offset, height, width, depth) {
    for (i = [0:count-1]) {
        translate([0 - i * pitch, -depth, -1]) 
            union() {
                cube([width, depth*2, 1 + height - width/2]);
                translate([width/2, depth*2, 1 + height - width/2])
                    rotate([90,0,0])
                        cylinder(depth*2, d1=width, d2=width);
            }
    }
}

module prism(l,w,h) {
    polyhedron(
        points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
        faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
    );
}

module lever(length, width, height, hole_d, prism_size = 6) {
    difference() {
        union() {
            cube([length, width, height]);
            translate([length, width, height/2])
                rotate([90,0,0])
                    cylinder(width, d1=height, d2=height);
            // supporting prism, behind the thing
            translate([0,width+prism_size,0])
                rotate([0,90,0])
                    rotate([0,0,180])
                        prism(height, prism_size, prism_size);
            translate([0,-prism_size/2,height])
                rotate([0,90,0])
                        prism(height, prism_size/2, prism_size/2);
        };
        
        translate([length, width*2, height/2])
                rotate([90,0,0])
                    cylinder(width*4, d1=hole_d, d2=hole_d);
    }
}

module duct_lever() {
    // tesselation settings (0.01 mm is fine enough)
    $fs = 0.01;
    
    length = 100;
    width  = 2.5;
    height = 6;
    rounded_end = height/2;
    
    // first tooth is the rightmost one
    // left side of it is 5 mm distant from the total end 
    // of the body
    // body is 106 mm long, but the end is at 106 - 3 
    // (leftmost curvature is below origin)
    tooth_cnt    = 9;
    tooth_offset = 5.0;
    leftmost_tooth = 10;
    
    // X coord of rightmost tooth's start
    rightmost_tooth = length + rounded_end - tooth_offset;
    
    
    // pitch is calculated here, we know the leftmost tooth
    // ends 10 mm away from the origin
    // there's (tooth_cnt - 1) spacers
    // and they occupy (rightmost_tooth - leftmost_tooth)
    tooth_pitch  = (rightmost_tooth - leftmost_tooth)/(tooth_cnt - 1);
     
    tooth_height = 5;
    tooth_width  = 2;
    tooth_depth  = 1.8;
    
    lever_offset = length + rounded_end - 25;
    lever_length = 11;
    lever_width  = 2;
    lever_hole_d = 3;
    
    
    union() {
        difference() {
            // base volume is $length plus round endings
            base_body(length, width, height);
            // subtract the teeth
            translate([rightmost_tooth, 0, 0])
                teeth(tooth_cnt, tooth_pitch, tooth_offset,
                    tooth_height, tooth_width, tooth_depth);
    }   
    
        // push lever part
        translate([lever_offset, width, 0])
            rotate([0,0,90])
                lever(lever_length, lever_width, height, 
                      lever_hole_d, prism_size = 6);
    }   
}

translate([-50,0,6])
    rotate([180,0,0])
        duct_lever();