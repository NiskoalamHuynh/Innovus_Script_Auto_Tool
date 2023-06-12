source /home/shuynh/autoTool/CreatePlaceBlk/main.tcl
source /home/shuynh/autoTool/CreateRouteBlk/main.tcl
source /home/shuynh/autoTool/CreateShape/main.tcl
source /home/shuynh/autoTool/PlaceMemShape/main.tcl
source /home/shuynh/autoTool/PlacePinShape/main.tcl
source /home/shuynh/autoTool/PlaceRegionReg2Mem/main.tcl

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

#End: create script auto floorplan
#############


# echo "createInstGroup eck_group -region \\{0 0 100 100\\}";
# echo "addInstToInstGroup eck_group \\{ \\"; 
# foreach a [dbget [dbget selected.net.instTerms.inst.cell.baseClass core -p2].name] {
#     echo $a" \\" 
#     }
# echo "\\ \\}";
