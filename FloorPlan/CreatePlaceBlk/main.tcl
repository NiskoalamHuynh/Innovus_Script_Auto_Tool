# create place blk

#############
#CREATE PLACEBLOCKAGES 
#############
proc is_createPlaceBlockages {} { #CREATE SCRIPT PLACEBLOCKAGES
    is_checkFile ./gen_script_fp/place_blockages.tcl
    is_cls2
    foreach a [dbget top.fPlan.pBlkgs] {
        if { [dbget $a.density] } {
            echo "createPlaceBlockage -noCutByCore -name [dbget $a.name] -type [dbget $a.type] -density [expr int([dbget $a.density])] -box [lindex [dbget $a.boxes] 0]"
            echo "createPlaceBlockage -noCutByCore -name [dbget $a.name] -type [dbget $a.type] -density [expr int([dbget $a.density])] -box [lindex [dbget $a.boxes] 0]" >> ./gen_script_fp/place_blockages.tcl
            #dbget top.fPlan.pBlkgs.shapes.rect
        } else {
            echo "createPlaceBlockage -noCutByCore -name [dbget $a.name] -type [dbget $a.type] -box [lindex [dbget $a.boxes] 0]"
            echo "createPlaceBlockage -noCutByCore -name [dbget $a.name] -type [dbget $a.type] -box [lindex [dbget $a.boxes] 0]" >> ./gen_script_fp/place_blockages.tcl
        }  
    }
}