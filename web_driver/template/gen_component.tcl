# Copyright (C) 2018 by Matthew Lai, email : mmlai@sympatico.ca
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

set compname [lindex $argv 0]

if {[string first "Windows" $env(OS)] > -1} {
    set compdir [pwd]
} else {
    set compdir $env(PWD)
}

regsub "template" $compdir $compname compdir

file mkdir $compdir

set filelist [glob *]
foreach filename $filelist {
    if {$filename == "gen_component.tcl"} {
	    continue
	}
	set fd [open $filename r]
	set filebody [read $fd]
	close $fd
	regsub -all "template" $filebody $compname filebody
	if {$filename == "template_test.tcl"} {
	    # Preserve the "url.template" string.
	    regsub -all "url.$compname" $filebody "url.template" filebody    
	}
	if {$filename != "url.template"} {
	    regsub -all "template" $filename $compname filename    
	}
	set fd [open $compdir/$filename w]
	puts $fd $filebody
	close $fd
}
exit 0
