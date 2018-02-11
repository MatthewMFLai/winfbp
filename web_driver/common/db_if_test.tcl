lappend auto_path $env(DISK2)/tclkit/modules
package require Mk4tcl
source db_if.tcl

set dbpath $env(DISK2_DATA)/scratchpad/db/db
db_if::Init $dbpath