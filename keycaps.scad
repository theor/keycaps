angled_preview = true;
preview_positions = false;

// not the actual dimensions of the keycap, remnant of earlier iterations
keycap_width = 18.0;
keycap_depth = 18.0;
keycap_height = 2.0;

font="JetBrainsMono Nerd Font:style=Regular";

// Margin from left and right of keycap to text
left_right_margin = keycap_width/2.5;
// Margin from top and bottom of keycap to text
top_bottom_margin = keycap_depth/4;
text_size = 4;
text_size_center = 8;
text_extrusion_height = 1.4;
label_offset_x = -0.1; // [-10:0.1:10]
label_offset_y = -1.8; // [-10:0.1:10]

fillet_angle=48;

text = ["Q", "1", "F2", "",""];
$fn=90;

// contains one variable
// keys = [
//   [[top left, top right, bottom left, bottom right, center], is 1.5U],
//   [["Q", "1", "!", "↞"], false],
//   [["␣", "", "", ""], true],
//   [["", "", "", "", "II"], false],
// ];
include <layout.scad>


module lpx(is_thumb){
    rotate([0,0,is_thumb ? 0 : 90])
    import(is_thumb ? "1.5u.stl" : "./1u.stl",$fa=1,center=true);
}

module bottomFillet(){
    rotate([0,0,0])
    #translate([10,0,-1.4])
    rotate([0,fillet_angle,0])
    cube([4,30,10], center=true);
}

module keycap(text, is_thumb){
    rotate([0,$preview && !angled_preview ? 0 : -(90-fillet_angle),$preview ? 0 : -45])
    union(){
        difference() {
            lpx(is_thumb);
            // both angled fillets. one is used to lay on the 3d printer bed
           bottomFillet();
           mirror([1,0,0])
           bottomFillet();
             
            // diff the surface and the label to get the part of the label above the surface, then translate that and remove it from the keycap surface
            translate([0,0,-.5])
            difference() {
                #labels(text);
                lpx(is_thumb);
            }
        }
    }
}
union(){
    // iterate on array, layout as a corne keyboard (split, 3x6+3 thumb keys each side)
    side = 6;
    half = len(keys)/2;
    for(k = [0:len(keys)-1]) {
        key = keys[k];
        if(len(key[0]) != 0){
            first = k < half ? 0 : half;
            x = (k-first)%side;
            p = [k < half
                ? x : (2*side - x), -floor((k-first) / side)] * keycap_width*1.3
               ;
            //    just a cube to help setting the layout
            if($preview && preview_positions){
                translate(p) cube(keycap_width);
            }
            else{
                // in preview mode, render only the first key
                if(!$preview || k == 0)
                    translate(p)
                        keycap(key[0], key[1]);
            }
        }
    }
}

module labels(text){
    union() {
        translate([label_offset_x, label_offset_y, keycap_height]) {
            sizes = [text_size,text_size,text_size,text_size,text_size_center];
            ox = [-1,1,-1,1,0.0];
            aligns = ["left", "right", "left", "right","center"];
            oy = [1,1,-1,-1,-0.5];
            for (i = [0:4]) {
                ll = 1;
                  // Move text down to cut into surface
                translate([ox[i]*left_right_margin*(ll), oy[i]*top_bottom_margin, -text_extrusion_height])
                    linear_extrude(height = text_extrusion_height * 2) {
                        text(text[i], font=font, size = sizes[i], halign = aligns[i], valign = "baseline");
                    }
            }
        }
    }
}
