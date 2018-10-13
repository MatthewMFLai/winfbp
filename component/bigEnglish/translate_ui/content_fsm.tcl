namespace eval parser_default {

proc eval_level_1 {line} {

    if {$line != ""} {
	regsub -all " " $line "" tmpdata	
        if {[string is upper $tmpdata]} {
	    return 1
    	}
    }
    return 0
}

}

namespace eval content_fsm {

variable m_line
variable m_depth
variable m_parser
variable m_title
variable m_proc
variable m_outport

proc init {} {
    variable m_line
    variable m_depth
    variable m_parser
    variable m_title
    variable m_proc
    variable m_outport
  
    set m_line ""
    set m_depth 0
    set m_parser ""
    set m_title ""
    set m_proc ""
    set m_outport -1
}

proc process_generic {p_arg_array} {
    upvar $p_arg_array arg_array
    variable m_line
    variable m_depth
    variable m_parser
    variable m_title
    variable m_proc
    variable m_outport

    set m_line [string trim $arg_array(line)]
    set m_depth $arg_array(depth)
    set m_parser $arg_array(doctype)
    set m_title $arg_array(title)
    set m_proc $arg_array(proc)
    set m_outport $arg_array(outport)
    return
}

proc eval_level_4 {} {
    variable m_line

    # Always return 0 for now i.e. does not support the level 5 state.
    return 0
}

proc eval_level_3 {} {
    variable m_line

    if {[string first "Title: " $m_line] > -1} {
	return 1
    }
    if {[string first "End of the Project Gutenberg" $m_line] > -1} {
	return 1
    }
    return 0
}

proc eval_level_2 {} {
    variable m_line

    if {[string first "Author: " $m_line] > -1} {
	return 1
    }
    return 0
}

proc eval_level_1 {} {
    variable m_line
    variable m_parser

    return [${m_parser}::eval_level_1 $m_line] 
}

proc eval_line {} {
    variable m_line

    if {[string first "Title: " $m_line] > -1} {
	return 0 
    }
    if {[string first "Author: " $m_line] > -1} {
	return 0 
    }
    if {[string first "End of the Project Gutenberg" $m_line] > -1} {
	return 0 
    }
    if {$m_line != ""} {
	regsub -all " " $m_line "" tmpdata	
        if {![string is upper $tmpdata]} {
	    return 1
    	}
    }
    return 0
}

proc act_level_3 {} {
    variable m_line
    variable m_depth
    variable m_title
    variable m_proc
    variable m_outport

    set idx [string first "Title: " $m_line]
    set idx [expr $idx + [string length "Title: "]]
    $m_proc Add_Token $m_title [string range $m_line $idx end] [expr $m_depth - 1 - 3] $m_outport
    return
}

proc act_level_2 {} {
    variable m_line
    variable m_depth
    variable m_title
    variable m_proc
    variable m_outport

    set idx [string first "Author: " $m_line]
    set idx [expr $idx + [string length "Author: "]]
    $m_proc Add_Token $m_title [string range $m_line $idx end] [expr $m_depth - 1 - 2] $m_outport
    return
}

proc act_level_1 {} {
    variable m_line
    variable m_depth
    variable m_title
    variable m_proc
    variable m_outport

    $m_proc Add_Token $m_title $m_line [expr $m_depth - 1 - 1] $m_outport
    return
}

proc act_content {} {
    variable m_line
    variable m_depth
    variable m_title
    variable m_proc
    variable m_outport

    $m_proc Add_Paragraph $m_title $m_line [expr $m_depth -1] $m_outport
    return
}

proc Dump {} {
    variable m_line 

    return
}

}

