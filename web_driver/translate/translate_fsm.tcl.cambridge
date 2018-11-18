namespace eval translate_fsm {

variable gTranslatelist

variable m_text
variable m_param
variable m_slash
variable m_tag

proc init {} {
    variable gTranslatelist
    
    variable m_text
    variable m_param
    variable m_slash
    variable m_tag

    set gTranslatelist ""

    set m_text ""
    set m_param ""
    set m_slash ""
    set m_tag ""
}

proc process_generic {p_arg_array} {
    upvar $p_arg_array arg_array
    variable m_text
    variable m_param
    variable m_slash
    variable m_tag

    set m_text $arg_array(text)
    set m_param $arg_array(param)
    set m_slash $arg_array(slash)
    set m_tag $arg_array(tag)
    return
}

proc eval_title_to_translate {} {
    variable m_param
    if {[string first "def-body" $m_param] > 0} {
	return 1
    }
    return 0
}

proc eval_translate_to_title {} {
    variable m_param

    if {[string first {class="trans"} $m_param] == 0} {
	return 1
    }
    return 0
}

proc eval_title_to_terminate {} {
    variable m_text
    variable m_tag

    if {[string first "(Translation of" $m_text] == 0 &&
        $m_tag == "small"} {
	return 1
    }
    return 0
}

proc act_translate_to_title {} {
    variable gTranslatelist
    variable m_text

    lappend gTranslatelist [string trim $m_text]
    return
}

proc Dump {} {
    variable gTranslatelist

    puts "meanings = $gTranslatelist"
    return
}
proc Dump_Translate {p_tmpdata} {
    variable gTranslatelist
    upvar $p_tmpdata tmpdata

    set tmpdata(meanings) $gTranslatelist
    return
}
}
