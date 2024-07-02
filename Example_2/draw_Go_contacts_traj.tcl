#CREDITS: "Multiscale Modelling of Complex Systems group at the IPPT-PAN"

#This script draws the native contacts (BB atoms) along a trajectory using VMD
#To run it, it is needed a file with the information of the contacts, by pairs, in 2 colums (i.e. 5 9)

#To get this information from the go_martini.itp file run the following command line:
	# awk '/\[ nonbond_params \]/{found=1; next} found{print $1, $2}' go_martini.itp | sed 's/GO_1_//g' > go_contacts.dat

#Bugs can be reported to: apoma@ippt.pan.pl, fcofas@ippt.pan.pll, golivos@ippt.pan.pl


#HOW TO RUN:
#Open VMD and load your protein file (pdb, gro) and trajectories (dcd, xtc)
#Run this script in the TkConsole: source draw_Go_contacts_traj.tcl

#VMD background set-up

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
mol modcolor 1 0 colorID 16

mol addrep 0
mol modselect 1 0 name BB
mol modstyle 1 0 VDW 0.400000 12.000000
mol modcolor 1 0 colorID 16

display resetview
scale by 2.0

#Geometric center function
proc geom_center {selection} {
    set gc [veczero]
    foreach coord [$selection get {x y z}] {
        set gc [vecadd $gc $coord]
    }
    return [vecscale [expr 1.0 /[$selection num]] $gc]
}

#Read Go contact list
set bonds [list]
set flexible_bonds [list]
set filename "go_contacts.dat"
set file [open $filename r]

while {[gets $file line] >= 0} {
    puts "Reading line: $line"
    if {[regexp {(\d+)\s+(\d+)} $line -> atom1 atom2]} {
        puts "Found pair: $atom1 $atom2"
        set atom1 [expr {$atom1}]
        set atom2 [expr {$atom2}]
        lappend bonds [list $atom1 $atom2]
    }
}
close $file

puts "Bonds in $filename:"
foreach bond $bonds {
    puts "$bond"
}

set num_frames [molinfo top get numframes]
set frame 0

draw delete all

#function to draw Go contacts
proc process_frame {} {
    global frame num_frames bonds flexible_bonds
    if {$frame >= $num_frames} {
        return
    }
    draw delete all
    animate goto $frame

    foreach bond $bonds {
        set atom1 [lindex $bond 0]
        set atom2 [lindex $bond 1]
        set sel1 [atomselect top "resid $atom1 and name BB"]
        set sel2 [atomselect top "resid $atom2 and name BB"]
        set coord1 [geom_center $sel1]
        set coord2 [geom_center $sel2]
        draw color red
        draw line $coord1 $coord2 width 7
        $sel1 delete
        $sel2 delete
    }

    foreach bond $flexible_bonds {
        set atom1 [lindex $bond 0]
        set atom2 [lindex $bond 1]
        set sel1 [atomselect top "resid $atom1 and name BB"]
        set sel2 [atomselect top "resid $atom2 and name BB"]
        set coord1 [geom_center $sel1]
        set coord2 [geom_center $sel2]
        draw color blue
        draw line $coord1 $coord2 width 7
        $sel1 delete
        $sel2 delete
    }
    incr frame
    #Change the time here (1000 = 1 second)
    after 1000 process_frame 
}

#Execute the function
process_frame

