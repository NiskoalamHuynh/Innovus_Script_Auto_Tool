#create region Reg 2 Mem

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

proc is_getListECKreg2Mem {} {
    is_checkFile ./gen_script_fp/listECK_Reg2Mem.tcl
    echo "addInstToInstGroup eck_group \\{ \\" >> ./gen_script_fp/listECK_Reg2Mem.tcl;
    selectPin [dbget [dbget top.insts.instTerms.inst.cell.baseClass core -p3].name -regexp DONT_TOUCH.+ECK]
    foreach a [dbget [dbget selected.net.instTerms.inst.cell.baseClass core -p2].name] {
        echo "$a \\" >> ./gen_script_fp/listECK_Reg2Mem.tcl 
    }
    echo "\\}" >> ./gen_script_fp/listECK_Reg2Mem.tcl;
    deselectAll
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