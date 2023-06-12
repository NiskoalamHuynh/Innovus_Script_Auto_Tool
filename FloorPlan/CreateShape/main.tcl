###create shape floorplan

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