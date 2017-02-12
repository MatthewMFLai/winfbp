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

proc update_blk_file {subdir filepathstr suffix_blk prefix envar} {

    # subdir looks like /tmp/node/basic/sink
    # filepathstr looks like filepath
    # suffix_blk looks like blk
    # prefix looks like /basic/sink

    if {[catch {glob $subdir/*$suffix_blk} rc]} {
	return
    }
    foreach filename $rc {
	set fd [open $filename r]
	set fd2 [open $filename.new w]
	while {[gets $fd line] > -1} {
	    if {[string first $filepathstr $line] == -1} {
		puts $fd2 $line
	    } else {
		puts $fd2 "$filepathstr \$env($envar)$prefix"  
	    }
	}
	close $fd
	close $fd2
	file delete $filename
	file rename $filename.new $filename
    }
    return
}

set subdir [lindex $argv 0]
set filepathstr [lindex $argv 1]
set suffix_blk [lindex $argv 2]
set prefix [lindex $argv 3]
set envar [lindex $argv 4]
update_blk_file $subdir $filepathstr $suffix_blk $prefix $envar
exit 0

