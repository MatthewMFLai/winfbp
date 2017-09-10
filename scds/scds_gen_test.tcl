#!/bin/sh
# \
exec tclsh $0 $@

source $env(SCDS_HOME)/scds_gen.tcl

set homedir [lindex $argv 1]

if {[lindex $argv 0] == "clean"} {
    file delete $homedir/dat/makefile
    file delete $homedir/gencode/simple/makefile
    file delete $homedir/gencode/complex/makefile
    file delete $homedir/gencode/dynamic_type/dynamic_type_init.tcl
    file delete scds.dot

    exit
}

set homevarname [lindex $argv 2]
set datdir "\$\($homevarname\)/dat"
Scds::Init
Scds::Buildit [lindex $argv 0]
Scds::Runit $homedir/dat/makefile $homedir/gencode/simple/makefile $homedir/gencode/complex/makefile $homedir/gencode/dynamic_type/dynamic_type_init.tcl $datdir
Scds::Gen_graph scds.dot
exit
