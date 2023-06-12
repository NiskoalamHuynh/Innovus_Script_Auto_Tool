# create pin shape
#############
#create pinBlk Power M5 
#############
proc is_createPinBlkPower {} {
    foreach a [dbShape [dbget [dbget top.pgNets.sWires.layer.name -regexp M5 -p2].box] SIZEX 0.5] {
        echo "createPinBlkg -area {$a} -cell [dbget top.name] -layer {M5}" >> ./gen_script_fp/testBlkPin.tcl  
    }
}

#############
#CREATE PIN
#############
proc is_createPin {} { #CREATE SCRIPT PLACE PIN
    is_checkFile ./gen_script_fp/place_pin.tcl
    is_cls2
    deselectAll
    selectPin [dbget top.terms.name] 
    echo "setPinAssignMode -pinEditInBatch true" >> ./gen_script_fp/place_pin.tcl
    foreach a [dbget selected] {
        set depthPin [dbget $a.depth]
        set widthPin [dbget $a.width]
        set layerName [dbget $a.layer.name]
        set sidePin [dbget $a.side]
        set assignXY [lindex [dbget $a.pt] 0]
        set namePin [lindex [dbget $a.name] 0]
        echo "editPin -fixedPin 1 -pin $namePin -layer $layerName -pinWidth $widthPin -pinDepth $depthPin -side $sidePin -assign $assignXY -snap TRACK"
        echo "editPin -fixedPin 1 -pin $namePin -layer $layerName -pinWidth $widthPin -pinDepth $depthPin -side $sidePin -assign $assignXY -snap TRACK" >> ./gen_script_fp/place_pin.tcl
    }
    echo "setPinAssignMode -pinEditInBatch false" >> ./gen_script_fp/place_pin.tcl
    deselectAll
}