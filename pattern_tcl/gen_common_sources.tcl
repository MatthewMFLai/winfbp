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
exec tclsh $0 $@

set crawlerlist [lrange $argv 0 end-1]
set outfile [lindex $argv end]
set fd [open $outfile w]

foreach crawler $crawlerlist {
    puts $fd "source \$env(WEB_DRIVER)/$crawler/$crawler.tcl"

    set filelist ""
    catch {glob $env(WEB_DRIVER)/$crawler/*} filelist
    foreach filename $filelist {
	if {[file isdir $filename]} {
	    continue
	}
	if {[string first "_fsm.tcl" $filename] > 0} {
	    # Only keep the name portion.
	    set idx [string last "/" $filename]
	    incr idx
	    set filename [string range $filename $idx end]
    	    puts $fd "source \$env(WEB_DRIVER)/$crawler/$filename"
	} 
    }

    if {$crawler == "financials"} {
        puts $fd "source \$env(WEB_DRIVER)/$crawler/symbol_filter.tcl"
    }	
    puts $fd "source \$env(COMP_HOME)/stock/$crawler/$crawler.tcl"
    puts $fd ""
}
close $fd

exit 0

