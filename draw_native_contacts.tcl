#This script draws the native contact between the alpha atoms of each residue using VMD
#Bugs can be reported to: apoma@ippt.pan.pl, fcofas@ippt.pan.pll, golivos@ippt.pan.pl

#Open vmd and load your protein file
#Run this script in the TkConsole: source draw_native_contacts.tcl

#VMD background nice set-up
color Display Background white
display projection Orthographic
display depthcue off
axes location off
display nearclip set 0.00
display height 6
mol modstyle 0 0 Tube 0.30 12.0
mol modcolor 0 0 ColorID 0
mol modcolor 0 0 ColorID 6
mol modmaterial 0 0 AOChalky
mol modstyle 0 0 Tube 0.30 30.0

#Provide a *.dat file with the list of native contacts in two columns (i.e. 5 2)

set fileId [open "native_contacts.dat" r]

proc geom_center {selection} {
    set gc [veczero]
    foreach coord [$selection get {x y z}] {
        set gc [vecadd $gc $coord]
    }
    return [vecscale [expr 1.0 /[$selection num]] $gc]
}

set lines [split [read $fileId] "\n"]

# Function for asynchronous drawing
proc drawLinesAsync {lines} {
    global fileId
    if {[llength $lines] > 0} {
        set line [lindex $lines 0]
        set lines [lrange $lines 1 end]

        set fields [split $line]
        set i [lindex $fields 0]
        set j [lindex $fields 1]

        set selection1 [atomselect top "resid $i and name BB" frame 0]
        set selection2 [atomselect top "resid $j and name BB" frame 0]

        set coord1 [geom_center $selection1]
        set coord2 [geom_center $selection2]
        puts "$line"
        
        set cord1 [$selection1 get {x y z}]
        set cord2 [$selection2 get {x y z}]
 
        #Verify if corrdinates were writen, if so, then asign x,y,z values to variables
        if {[llength $cord1] > 0 && [llength $cord2] > 0} {
        lassign [lindex $cord1 0] x1 y1 z1
        lassign [lindex $cord2 0] x2 y2 z3
        }
        puts "$x1,$x2,$y1,$y2,$z1,$z3"
 
	set medio_x [expr {($x1 + $x2) / 2.0}]
	set medio_y [expr {($y1 + $y2) / 2.0}]
	set medio_z [expr {($z1 + $z3) / 2.0}]

	puts "Punto medio x: $medio_x"
	puts "Punto medio y: $medio_y"
	puts "Punto medio z: $medio_z"
	
        # Draw the line between coord1 and coord2
        draw color blue
        draw line $coord1 $coord2 width 12\n
        draw text [list $medio_x $medio_y $medio_z] "$line"

        $selection1 delete
        $selection2 delete

        # Set the next iteration after 1 second
        after 1000 [list drawLinesAsync $lines]
    } else {
        # When all the lines have been drawn, wait 1 second before closing the file.
        after 1000 {
            puts "drawing 1"
            close $fileId
        }
    }
}

# Start asynchronous drawing
drawLinesAsync $lines
