# place mem shape

#############
#CREATE PLACE MEM 
#############
proc is_placeInstMem {} { #CREATE PLACE MEM 
    is_checkFile ./gen_script_fp/place_Inst.tcl
    selectInst [dbget [dbget top.insts.instTerms.cellTerm.cell.baseClass -regexp block -p4 -u].name]
    foreach a [dbget selected] {
        echo "placeInstance [dbget $a.name] [dbget $a.pt] [dbget $a.orient] -fixed" >> ./gen_script_fp/place_Inst.tcl
        echo "placeInstance [dbget $a.name] [dbget $a.pt] [dbget $a.orient] -fixed"
    } 
    deselectAll
}

#############
#CREATE BLOCKAGE MEM
#############
proc is_createBlockageMem { side } { #CREATE BLOCKAGE MEM Ex: is_createBlockageMem {5 5 5 5}
    is_checkFile ./gen_script_fp/placeBlk_hard_mem.tcl
    echo "createPlaceBlockage -name hard_blockage_mems -type hard -allMacro -outerRingByEdge {$side}" >> ./gen_script_fp/placeBlk_hard_mem.tcl
    echo "createPlaceBlockage -name hard_blockage_mems -type hard -allMacro -outerRingByEdge {$side}"
}

#############
#tao soft blockage mem
#############
proc is_createPlaceSoftMem {} {
    is_checkFile ./gen_script_fp/placeBlk_SoftMem.tcl
    set is_orient {R90 MX90}
    foreach l_orient $is_orient {
        foreach box [dbget [dbget [dbget top.insts.cell.baseClass block -p2].orient $l_orient -p1].box] {
            if {$l_orient == "MX90"} {
                echo "createPlaceBlockage -box {[lindex [dbShape [dbShape ${box} SIZEX 15] ANDNOT [dbShape ${box}]] 0]} -type soft" >> ./gen_script_fp/placeBlk_SoftMem.tcl
            }
            if {$l_orient == "R90"} {
                echo "createPlaceBlockage -box {[lindex [dbShape [dbShape ${box} SIZEX 15] ANDNOT [dbShape ${box}]] 1]} -type soft" >> ./gen_script_fp/placeBlk_SoftMem.tcl
            }
        }
    } 
}

#############
#CREATE ROUTE BLOCKAGE MEM
#############
proc is_createRouteBlkMem {} {
    is_checkFile ./gen_script_fp/routeBlk_Mem.tcl
    set namesCout 1
    foreach a [dbShape [dbget [dbget top.insts.cell.baseClass block -p2].box] SIZE 5] { 
        incr namesCout
        echo "createRouteBlk -box {$a} -layer {M1 M2 M3 M4} -name routeBlk_Mem_$namesCout" >> ./gen_script_fp/routeBlk_Mem.tcl 
    }
}