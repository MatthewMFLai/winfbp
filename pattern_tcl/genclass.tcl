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

if {0} {
    This script generates something similar to generic.tcl,
    but with specific attribute names. The argument to this
    script is a text file containing the attribute names,
    each name in a separate line. The generated file will
    assume the name of the given text file.
}

if { [llength $argv] != 1 } {
    puts "Usage: genpattern attrnamefile"
    puts "Example: genclass atmvlancc.dat"
    exit -1
}

set filename [lindex $argv 0]
set classname [lindex [split $filename "."] 0]

set fd [open $filename r]
set fd2 [open $classname.tcl w]
set attrnamelist ""

while {[gets $fd attrname] > -1} {
    # Skip comments.
    if {[string first "#" $attrname] > -1} {
	continue
    }
    # Trim white spaces.
    set attrname [string trim $attrname]
    # Generate the set procedure.
    puts $fd2 "proc set_$attrname \{p_generic attr\} \{"
    puts $fd2 "    upvar #0 \$p_generic generic"
    puts $fd2 ""
    puts $fd2 "    set generic(&$attrname) \$attr"
    puts $fd2 "\}"
    puts $fd2 ""
 
    # Generate the get procedure.
    puts $fd2 "proc get_$attrname \{p_generic\} \{"
    puts $fd2 "    upvar #0 \$p_generic generic"
    puts $fd2 ""
    puts $fd2 "    return \$generic(&$attrname)"
    puts $fd2 "\}"
    puts $fd2 ""

    lappend attrnamelist $attrname
}
close $fd

# Generate the generic set procedure.
puts $fd2 "proc set_all \{p_generic p_data\} \{"
puts $fd2 "    upvar \$p_data data"
puts $fd2 ""
puts $fd2 "    set attrlist \[getattrname\]"
puts $fd2 "    foreach attr \[array names data\] \{"
puts $fd2 "        if \{\[lsearch \$attrlist \$attr\] > -1\} \{"
puts $fd2 "           set_\$attr \$p_generic \$data(\$attr)"
puts $fd2 "        \}"
puts $fd2 "    \}"
puts $fd2 "    return"
puts $fd2 "\}"
puts $fd2 ""

# Generate the init procedure.
puts $fd2 "proc init \{p_generic\} \{"
puts $fd2 "    upvar #0 \$p_generic generic"
foreach attrname $attrnamelist {
    puts $fd2 "    set generic(&$attrname) \"\""
}
puts $fd2 "\}"
puts $fd2 ""

# Generate the remove procedure.
puts $fd2 "proc remove \{p_generic\} \{"
puts $fd2 "    upvar #0 \$p_generic generic"
foreach attrname $attrnamelist {
    puts $fd2 "    unset generic(&$attrname)"
}
puts $fd2 "\}"
puts $fd2 ""

# Generate the procedure to return list of attribute names.
puts $fd2 "proc getattrname \{\} \{"
puts $fd2 "    return \"$attrnamelist\""
puts -nonewline $fd2 "\}"

close $fd2
exit 0

