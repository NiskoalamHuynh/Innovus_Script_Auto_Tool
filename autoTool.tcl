#############
#Alias

alias sc source /home/shuynh/autoTool/autoTool.tcl
alias slMem selectInst [dbget [dbget top.insts.instTerms.cellTerm.cell.baseClass -regexp block -p4 -u].name]
#Alias
#############

#############
#Awk: get proc project in script

proc cmd_projectInScript args {
    if { $args < 1 } {
        puts [exec awk { /Project\:/ } /home/shuynh/autoTool/autoTool.tcl | sort -u]
        puts "Ex: cmd_projectInScript unq_fsm"
    } else {
        set reData "Project: $args"
        puts [exec awk -v resultData=$reData { BEGIN { count = 0; } { if ($0 ~ resultData) { count++ } if (count == 1) { print $0 } } } /home/shuynh/autoTool/autoTool.tcl | awk { /proc/ }]
    }
}

proc cmd_createScriptFloorPlan {} {
    puts [exec awk { /Begin/,/End/ } /home/shuynh/autoTool/autoTool.tcl | awk { /proc/ } | grep -v "puts"]
}

#Awk: get proc project in script
#############

#############
#Begin: create script auto floorplan

#############
#list source FLOORPLAN
#############
proc is_listSourceFP {} { #list source FLOORPLAN
    puts [exec egrep -i -A 20 "setCheckMode -netlist true -library true" ./script/floorplan.tcl | awk { /floorplan/,/connect global/ }]
}

#foreach a [dbShape [dbget [dbget top.pgNets.sWires.layer.name -regexp M5 -p2].box] SIZEX 0.5] { echo "createPinBlkg -area {$a} -cell [dbget top.name] -layer {M5}" >> ./gen_script_fp/testBlkPin.tcl  }
#############
#create pinBlk Power M5 
#############
proc is_createPinBlkPower {} {
    foreach a [dbShape [dbget [dbget top.pgNets.sWires.layer.name -regexp M5 -p2].box] SIZEX 0.5] {
        echo "createPinBlkg -area {$a} -cell [dbget top.name] -layer {M5}" >> ./gen_script_fp/testBlkPin.tcl  
    }
}

proc drc {} {
    setMultiCpuUsage -localCpu 4
    clearDrc
    verify_drc
}

#############
#check File Exit
#############
proc is_checkFile { nameFile } { #check File Exit
    set fileERR [file exist $nameFile]
    if {$fileERR == 1} {
        exec rm $nameFile
    }
}

#############
#clear section
#############
proc is_cls2 {} { #clear section
    set a 0
    while {$a < 1000} {
        puts "\n"
        incr a
    }
}

#############
#CREATE FLOORPLAN
#############
proc is_floorplan {} { #CREATE SCRIPT FLOORPLAN
    is_checkFile ./gen_script_fp/floorplan.tcl
    set nameDesign [dbget head.sites.name]
    set widthCoreDesign [dbget top.fPlan.box_sizex]
    set heightCoreDesign [dbget top.fPlan.box_sizey]
    set topDieDesign [dbget top.fPlan.core2Top] 
    set bottomDieDesign [dbget top.fPlan.core2Bot]
    set leftDieDesign [dbget top.fPlan.core2Left]
    set rightDieDesign [dbget top.fPlan.core2Right]
    echo "floorPlan -site ${nameDesign} -d ${widthCoreDesign} ${heightCoreDesign} ${leftDieDesign} ${bottomDieDesign} ${rightDieDesign} ${topDieDesign} -noSnapToGrid" >> ./gen_script_fp/floorplan.tcl
    #is_cls2
    #echo "FloorPlan export file done!"
}

#############
#CREATE POLYGON FLOORPLAN
#############
proc is_createPolygonFloorplan {} { #CREATE SCRIPT POLYGON FLOORPLAN
    is_checkFile ./gen_script_fp/floorplan.tcl
    is_floorplan
    echo "setFPlanMode -enableRectilinearDesign true" >> floorplan.tcl
    echo "setObjFPlanPolygon cell [dbget top.name] [getObjFPlanPolygon cell [dbget top.name]]" >> ./gen_script_fp/floorplan.tcl
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

#############
#CREATE ROUTEBLOCKAGES 
#############
proc is_createRouteBlockages {} { #CREATE SCRIPT ROUTEBLOCKAGES
    is_checkFile ./gen_script_fp/route_blockages.tcl
    is_cls2
    foreach a [dbget top.fPlan.rBlkgs] {
        echo "createRouteBlk -name [dbget $a.name] -layer [dbget $a.layer.name]  -box [dbget $a.boxes] -exceptpgnet"
        echo "createRouteBlk -name [dbget $a.name] -layer [dbget $a.layer.name]  -box [dbget $a.boxes] -exceptpgnet" >> ./gen_script_fp/route_blockages.tcl
    }
}

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
#CREATE BLOCKAGE BOUNDRAY
#############
proc is_createRouteBlkBoundray {width} {
    is_checkFile ./gen_script_fp/routeBlk_boundary.tcl
    # set layerPowerY {}
    # foreach layerView {M1 M2 M3 M4 M5 } {
    #     set a [regexp {0.0} [dbget [dbget top.pgNets.sWires.layer.name $layerView -p2].box_lly]]
    #     set b [regexp {0.0} [dbget [dbget top.pgNets.sWires.layer.name $layerView -p2].box_llx]]
    #     if { $a == 1 || $b == 1} {
    #         lappend layerPower $layerView
    #     }
    # }
    # echo $layerPower

    ## Create rectilinear floorplan shape
    #
    set fplanPolygon [dbShape -output polygon [dbGet top.fplan.boxes]]
    # Create routing blockage around inside of block boundary with width $blkgWidth
    set blkgWidth $width
    set sizeValue [expr 0 - $blkgWidth]
    set shrunkBox [dbShape $fplanPolygon SIZE $sizeValue]

    set pinBox [dbShape [dbget top.terms.net.terms.pinShapes.rect] SIZEX 0.5]
    #set netPower [dbShape [dbget [dbget top.pgNets.sWires.layer.name -regexp M5 -p2].box] SIZEX 0.1 SIZEY 1]

    #create routeBlk Floorplan
    set createBlkRouteFloorPlan [dbShape $fplanPolygon ANDNOT $shrunkBox]
    foreach rect $createBlkRouteFloorPlan {
        #createRouteBlk -box $rect -layer {M1 M2 M3}
    }

    #create routeBlk Pin
    set createBlkRoutePinConnect [dbShape $fplanPolygon ANDNOT $shrunkBox ANDNOT $pinBox]
    foreach rect $createBlkRoutePinConnect {
        echo "createRouteBlk -box $rect -layer {M1 M2 M3 M4}" >> ./gen_script_fp/routeBlk_boundary.tcl
    }

    #create routeBlk PowerMesh
    # set createBlkRoutePowerMesh [dbShape $fplanPolygon ANDNOT $shrunkBox ANDNOT $netPower ANDNOT $pinBox]
    # foreach rect $createBlkRoutePowerMesh {
    #     echo "createRouteBlk -box $rect -layer {M5}" >> ./gen_script_fp/routeBlk_boundary.tcl
    # }
}

#############
#CREATE BLOCKAGE BOUNDRAY
#############
proc is_createRouteBlkBoundray1 {width} {
    is_checkFile ./gen_script_fp/routeBlk_boundary.tcl

    #set up data in create route BLK
    set blkgWidth $width
    set layerPowerBoundary {M5}
    set layerSignal {M1 M2 M3 M4}

    #get shape floorplan, pin, powermesh
    #floorPlan
    set fplanPolygon [dbShape -output polygon [dbGet top.fplan.boxes]]
    set sizeValue [expr 0 - $blkgWidth]
    set shrunkBox [dbShape $fplanPolygon SIZE $sizeValue]

    set pinR90 [dbShape [dbget [dbget top.terms.net.terms.pinShapes.term.orient R90 -p2].rect] SIZEX 1 SIZEY 0.1]
    set pinR0 [dbShape [dbget [dbget top.terms.net.terms.pinShapes.term.orient R0 -p2].rect] SIZEX 0.5 SIZEY 1]
    set createBlkRoutePinConnect [dbShape $fplanPolygon ANDNOT $shrunkBox ANDNOT $pinR0 ANDNOT $pinR90]
    foreach rect $createBlkRoutePinConnect {
        echo "createRouteBlk -box $rect -layer {$layerSignal}" >> ./gen_script_fp/routeBlk_boundary.tcl
    }

    set netPower [dbShape [dbget [dbget top.pgNets.sWires.layer.name -regexp M5 -p2].box] SIZEX 0.1 SIZEY 1]
        #create routeBlk PowerMesh
    set createBlkRoutePowerMesh [dbShape $fplanPolygon ANDNOT $shrunkBox ANDNOT $netPower ANDNOT $pinR0]
    foreach rect $createBlkRoutePowerMesh {
             echo "createRouteBlk -box $rect -layer $layerPowerBoundary" >> ./gen_script_fp/routeBlk_boundary.tcl
    }
}

proc is_getListReg2Mem { checkGet } {
    foreach a [dbget selected] {
        if {[regexp {0x0} [dbget [dbget [dbget ${a}.net.instTerms.isInput 1 -p1].inst.cell.baseClass block -p2].name -u] ] ==0 && [regexp {\/Q} [dbget [dbget ${a}.net.instTerms.isInput 0 -p1].name]]} {
            if { $checkGet == 1 } {
                echo "\n\n[dbget [dbget ${a}.net.instTerms.isInput 0 -p1].name] --> [lsort -dictionary [dbget [dbget [dbget ${a}.net.instTerms.isInput 1 -p1].inst.cell.baseClass block -p2].name -u]] --> Total [llength [dbget [dbget [dbget ${a}.net.instTerms.isInput 1 -p1].inst.cell.baseClass block -p2].name -u]]\n" >> reg2Mem_top.tcl
            }
            if { $checkGet == 2 } {
                echo "\n\n[dbget [dbget ${a}.net.instTerms.isInput 0 -p1].name] --> [lsort -dictionary [dbget [dbget [dbget ${a}.net.instTerms.isInput 1 -p1].inst.cell.baseClass block -p2].name -u]] --> Total [llength [dbget [dbget [dbget ${a}.net.instTerms.isInput 1 -p1].inst.cell.baseClass block -p2].name -u]]\n" >> reg2Mem_bottom.tcl
            }
        }
    }
}

proc is_getDontTouchInst {} {
    is_checkFile ./gen_script_fp/list_Inst_DontTouch.tcl
    foreach a [dbget top.insts.name -regexp DONT_TOUCH] {
        echo "$a"
        echo "$a" >> ./gen_script_fp/list_Inst_DontTouch.tcl
    }
}

proc is_createGroupReg2Mem {} { #gen code region reg 2 mem
    #Chon tat ca cac khu vuc region de render code
    is_checkFile ./gen_script_fp/regionReg2Mem.tcl
    foreach a [dbget selected] {
        echo  "createInstGroup [dbget ${a}.name] -region [lindex [dbget ${a}.boxes] 0]\n addInstToInstGroup [dbget ${a}.name] { [join [dbget ${a}.members.name] \\\n] }\n" >> ./gen_script_fp/regionReg2Mem.tcl
    }  
}

#createPlaceBlockage -box [lindex [dbShape [dbShape [lindex [dbget selected.boxes] 0] SIZEX 15] ANDNOT [dbShape [lindex [dbget selected.boxes] 0]]] 0] -type soft
#tao soft blockage mem
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

#echo "createPlaceBlockage -box [lindex [dbShape [dbShape ${box} SIZEX 15] ANDNOT [dbShape ${box}] 0] -type soft"

#End: create script auto floorplan
#############

#############
#Project: unq_fsm
#############
proc get94pin {} { #lay 94 pin
    set i 0
    foreach a [lsort [dbget top.terms.name]] {
        if {$i == 94} { break }
        selectPin $a
        incr i
    }
}

proc getpin {} { #lay so pin con lai sau khi lay 94 pin
    set i 0
    foreach a [lsort [dbget top.terms.name]] {
        if {$i >= 94} { 
            selectPin $a
        }
        incr i
    }
}

proc is_getpin { group } { #lay so pin theo group 1,2,3,4
    deselectAll
    switch $group {
    1 {
        set i 1
        foreach a [lsort [dbget top.terms.name]] {
            if {$i == 49} { break }
            selectPin $a
            incr i
        }
    }
    2 {
        set i 1
        foreach a [lsort [dbget top.terms.name]] {
            if {$i >= 49} {
                selectPin $a
            }
            if {$i == 96} { break }
            incr i
        }
    }
    3 {
        set i 1
        foreach a [lsort [dbget top.terms.name]] {
            if {$i >= 96} {
                selectPin $a
            }
            if {$i == 143} { break }
            incr i
        }
    }
    4 {
        set i 1
        foreach a [lsort [dbget top.terms.name]] {
            if {$i >= 143} {
                selectPin $a
            }
            incr i
        }
    }
    default {
      puts "Invalid group pin EX: is_getpin 1"
    }
}
}
#############
#Project: unq_fsm
#############
