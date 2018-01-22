# Copyright (C) 2016 by Matthew Lai, email : mmlai@sympatico.ca
#
# The author  hereby grants permission to use,  copy, modify, distribute,
# and  license this  software  and its  documentation  for any  purpose,
# provided that  existing copyright notices  are retained in  all copies
# and that  this notice  is included verbatim  in any  distributions. No
# written agreement, license, or royalty  fee is required for any of the
# authorized uses.  Modifications to this software may be copyrighted by
# their authors and need not  follow the licensing terms described here,
# provided that the new terms are clearly indicated on the first page of
# each file where they apply.
#
# IN NO  EVENT SHALL THE AUTHOR  OR DISTRIBUTORS BE LIABLE  TO ANY PARTY
# FOR  DIRECT, INDIRECT, SPECIAL,  INCIDENTAL, OR  CONSEQUENTIAL DAMAGES
# ARISING OUT  OF THE  USE OF THIS  SOFTWARE, ITS DOCUMENTATION,  OR ANY
# DERIVATIVES  THEREOF, EVEN  IF THE  AUTHOR  HAVE BEEN  ADVISED OF  THE
# POSSIBILITY OF SUCH DAMAGE.
#
# THE  AUTHOR  AND DISTRIBUTORS  SPECIFICALLY  DISCLAIM ANY  WARRANTIES,
# INCLUDING,   BUT   NOT  LIMITED   TO,   THE   IMPLIED  WARRANTIES   OF
# MERCHANTABILITY,  FITNESS   FOR  A  PARTICULAR   PURPOSE,  AND
# NON-INFRINGEMENT.  THIS  SOFTWARE IS PROVIDED  ON AN "AS  IS" BASIS,
# AND  THE  AUTHOR  AND  DISTRIBUTORS  HAVE  NO  OBLIGATION  TO  PROVIDE
# MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
#!/bin/sh
# \
exec tclsh $0 "$@"
lappend auto_path $env(DISK2)/tclkit/modules

source $env(FSM_HOME)/fsm.tcl
source $env(PATTERN_HOME)/malloc.tcl
source $env(PATTERN_HOME)/geturl.tcl
source $env(PATTERN_HOME)/stock_util.tcl
source $env(WEB_DRIVER_HOME)/history/history_fsm.tcl
source $env(WEB_DRIVER_HOME)/history/history.tcl

source $env(WEB_DRIVER_HOME)/common/stock.tcl

Url::init
malloc::init
Fsm::Init

Fsm::Load_Fsm $env(WEB_DRIVER_HOME)/history/history_fsm.dat
Fsm::Init_Fsm history_fsm

set fd [open $env(WEB_DRIVER_HOME)/history/url.template r]
gets $fd url_temp
close $fd
history::init $url_temp

# cd C:/winfbp/web_driver/common folder
# tclsh get_history.tcl T c:/winfbp_data/web_driver/common/company_T c:/winfbp_data/scratchpad/history 2017-01-02 2018-01-12

set exchange [lindex $argv 0]
set datafile [lindex $argv 1]
set outdir [lindex $argv 2]
set startdate [lindex $argv 3]
set enddate [lindex $argv 4]

stock::init $datafile
foreach cur_symbol [stock::get_all_symbols] {
    if {$cur_symbol == "AUX" || $cur_symbol == "PRN"} {
	    continue
	}
	
    set description [stock::get_info_imp $cur_symbol "description"]
	if {$description == ""} {
	    continue
	}
	if {[lindex $description 1] == "nul"} {
	    continue
	}

    array set data {}
	history::extract_data $exchange $cur_symbol $startdate $enddate data

	if {$data(history) == ""} {
	    unset data
	    continue
	}
	
	puts "Processing $cur_symbol ..."
    set fd [open $outdir/$cur_symbol w]	
	foreach token $data(history) {
	    puts $fd $token
	}

	unset data
	close $fd
}
exit 0

