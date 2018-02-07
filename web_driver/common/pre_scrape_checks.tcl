lappend auto_path $env(DISK2)/tclkit/modules

cd $env(DISK2)/web_driver/company
set line "exec tclsh sanity.tcl &"
set rc [eval $line]

cd $env(DISK2)/web_driver/dividend
set line "exec tclsh sanity.tcl &"
set rc [eval $line]

cd $env(DISK2)/web_driver/stock
set line "exec tclsh sanity.tcl &"
set rc [eval $line]

cd $env(DISK2)/web_driver/symbolpage
set line "exec tclsh sanity.tcl &"
set rc [eval $line]

set cachedir $env(DISK2_DATA)/web_driver/cache
if {[file exists "$cachedir/previous"]} {
    file delete -force $cachedir/previous
}
if {[file exists "$cachedir/current"]} {
    file rename $cachedir/current $cachedir/previous
}

exit 0