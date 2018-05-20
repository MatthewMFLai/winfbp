lappend auto_path $env(DISK2)/tclkit/modules

set platform "Linux"
if {[string first "Linux" $tcl_platform(os)] == -1} {
    set platform "Windows"
}

cd $env(DISK2)/web_driver/company
if {$platform == "Linux"} {
    set line "exec ./sanity.tcl &"
} else {
    set line "exec tclsh sanity.tcl &"
}
set rc [eval $line]

cd $env(DISK2)/web_driver/dividend
if {$platform == "Linux"} {
    set line "exec ./sanity.tcl &"
} else {
    set line "exec tclsh sanity.tcl &"
}
set rc [eval $line]

cd $env(DISK2)/web_driver/stock
if {$platform == "Linux"} {
    set line "exec ./sanity.tcl &"
} else {
    set line "exec tclsh sanity.tcl &"
}
set rc [eval $line]

cd $env(DISK2)/web_driver/symbolpage
if {$platform == "Linux"} {
    set line "exec ./sanity.tcl &"
} else {
    set line "exec tclsh sanity.tcl &"
}
set rc [eval $line]

set cachedir $env(DISK2_DATA)/web_driver/cache
if {[file exists "$cachedir/previous"]} {
    file delete -force $cachedir/previous
}
if {[file exists "$cachedir/current"]} {
    file rename $cachedir/current $cachedir/previous
}

if {![file exists "$cachedir/current"]} {
    file mkdir $cachedir/current
}

exit 0