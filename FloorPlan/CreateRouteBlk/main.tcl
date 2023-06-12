#create route blk

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
#CREATE BLOCKAGE BOUNDRAY
#############
proc is_createRouteBlkBoundray {width} {
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