namespace eval translate {

variable g_url_template

proc init {url_template} {
    variable g_url_template

    set g_url_template $url_template
    return
}

proc fsm_if {tag slash param text} {
    set tmpdata(tag) $tag
    set tmpdata(slash) $slash
    set tmpdata(param) $param
    set tmpdata(text) $text
    Fsm::Run translate_fsm tmpdata
}

proc doit {symbol url_template p_data} {
    upvar $p_data web_data

    # Extract main symbol.
    # Change the url i/f as the ei=UTF-8 form ensures "fist" is not searched
    # as "first"!!!
    #set url "http://tw.dictionary.search.yahoo.com/search?p=$symbol&fr2=dict"
    #set url "http://tw.dictionary.search.yahoo.com/search?p=$symbol&ei=UTF-8&norw=1"

    regsub "XXX" $url_template $symbol url

    if {[catch {Url::get_no_retry $url} data]} {
        set web_data(urlerror) "$symbol FAIL url error"
	return
    }
    if {[catch {htmlparse::parse -cmd translate::fsm_if $data} rc]} {
    	Fsm::Init_Fsm translate_fsm
    	Fsm::Set_State translate_fsm FIND_WORD
        set web_data(urlerror) "$symbol FAIL htmlparse error"
	set web_data(htmlparse_error) $rc
	return
    }
    if {[Fsm::Is_In_Service translate_fsm] == 1} {
        array set tmpdata {}
        translate_fsm::Dump_Translate tmpdata
	array set web_data [array get tmpdata]
    	unset tmpdata
    } else {
        set web_data(urlerror) "$symbol FAILfsm [Fsm::Get_Error translate_fsm]"
    	Fsm::Init_Fsm translate_fsm
    	Fsm::Set_State translate_fsm FIND_WORD
    }
    Fsm::Init_Fsm translate_fsm
    Fsm::Set_State translate_fsm FIND_WORD
    return
}

proc extract_data {symbol p_data} {
    variable g_url_template
    upvar $p_data data

    array set web_data {}
    set web_data(symbol) $symbol
    doit $symbol $g_url_template web_data
    if {[info exists web_data(urlerror)] == 0} {
	array set data [array get web_data]
	set data(urlerror) ""
    } else {
	set data(urlerror) $web_data(urlerror)
    }
    return
}

}
