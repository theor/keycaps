//a = " ";
//b = " ";
//c = " ";
//d = " ";
//e = " ";

angled_preview = true;
preview_positions = !true;

keycap_width = 18.0;
//keycap_width = 25.5; // 17.0 * 1.5 = 25.5 1.5U
keycap_depth = 18.0;
keycap_height = 2.0;

font="JetBrainsMono Nerd Font:style=Regular";
symbol_font="IntoneMono Nerd Font Propo:style=Bold";

// Margin from left and right of keycap to text
left_right_margin = keycap_width/2.5;
// Margin from top and bottom of keycap to text
top_bottom_margin = keycap_depth/4;
text_size = 4;
text_size_big = 8;
//symbol_size = 6;
text_extrusion_height = 1.4;
label_offset_x = -0.1; // [-10:0.1:10]
label_offset_y = -1.8; // [-10:0.1:10]

fillet_angle=48;

text = ["Q", "1", "F2", "",""];
$fn=90;

include <layout.scad>
//keys = [
//    [["Q", "1", "F2", "",""], false],
////    [["Q", "1", "F2", "r","X"], false],
//    [["Q", "1", "F2", "r","X"], false],
//    [["Q", "1", "F2", "r","X"], false],
//];

module lpx(){
//    rotate([0,0,90])
//    translate([-x,y,-6])
//    rotate([48.5,0,0])
//scale([1000,1000,1000])
//$fa=36;
//$fn = 8;
//$fs=64;
rotate([0,0,90])
//import("kea-profile-choc-mx-spaced-1u.stp"); 
//    import("./kea-profile-choc-mx-spaced-1u - Document.stl", center=true);
import("./Key.stl",$fa=1,center=true);
}

module bottomFillet(){
 translate([10,0,-1.4])
        rotate([0,fillet_angle,0])
        cube([4,20,10], center=true);
}

module keycap(text, is_thumb){
    rotate([0,$preview && !angled_preview ? 0 : -(90-fillet_angle),$preview ? 0 : -45])
    union(){
        scale([1  ,is_thumb ? 1.5 : 1   ,1])
        difference() {
            lpx();
            
           bottomFillet();
           mirror([1,0,0])
           bottomFillet();
            
            translate([0,0,-.5])
            difference() {
                #labels(text);
                lpx();
            }
        }
    }
}
//keycap(["Q", "1", "F2", "r","x"]);
union(){
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
            if($preview && preview_positions){
                translate(p) cube(keycap_width);
            }
            else{
                if(!$preview || k == 0)
                    translate(p)
                        keycap(key[0], key[1]);
            }
        }
    }
}

module labels(text){
//    render() 
    union() {
        translate([label_offset_x, label_offset_y, keycap_height]) {
            sizes = [text_size,text_size,text_size,text_size,text_size_big];
            ox = [-1,1,-1,1,0.0];
            aligns = ["left", "right", "left", "right","center"];
//            valigns = ["top", "top", "bottom", "bottom","center"];
            oy = [1,1,-1,-1,-0.5];
            for (i = [0:4]) {
                ll = 1;//1.5;//len(text[i]) >= 2 ? 0.5 : 1;
                // echo(i);
                translate([ox[i]*left_right_margin*(ll), oy[i]*top_bottom_margin, -text_extrusion_height])  // Move text down to cut into surface
                rotate([0, 0, 0])  // Reset rotation to default
                    linear_extrude(height = text_extrusion_height * 2) {
                        text(text[i], font=font, size = sizes[i], halign = aligns[i], valign = "baseline");
                    }
            }
        }
    }
}