source $env(FSM_HOME)/fsm.tcl
source $env(PATTERN_HOME)/malloc.tcl
source $env(PATTERN_HOME)/geturl.tcl
source $env(WEB_DRIVER)/translate/translate_fsm.tcl
source $env(WEB_DRIVER)/translate/translate.tcl
# For the stand-alone single folder windows install
# This points to the htmlparse package.
if {[string first "Windows" $tcl_platform(os)] > -1} {
    lappend auto_path $env(DISK2)/tclkit/modules
}
# end
package require htmlparse

Url::init
malloc::init
Fsm::Init
Fsm::Load_Fsm $env(WEB_DRIVER)/translate/translate_fsm.dat
Fsm::Init_Fsm translate_fsm

set fd [open $env(WEB_DRIVER)/translate/url.template r]
gets $fd url_template
close $fd
translate::init $url_template
 
proc dict_get {word} { 
    array set tmpdata {} 
    translate::extract_data $word tmpdata
    return $tmpdata(meanings)
}
