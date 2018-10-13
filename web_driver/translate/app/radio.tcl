# radio.tcl --
#
# This demonstration script creates a toplevel window containing
# several radiobutton widgets.
#
# RCS: @(#) $Id: radio.tcl,v 1.8 2007/04/23 21:16:01 das Exp $

set w .radio
catch {destroy $w}
toplevel $w
wm title $w "Radiobutton Demonstration"
wm iconname $w "radio"

labelframe $w.left -pady 2 -text "Point Size" -padx 2
labelframe $w.mid -pady 2 -text "Color" -padx 2
labelframe $w.right -pady 2 -text "Alignment" -padx 2
button $w.tristate -text Tristate -command "set size multi; set color multi" \
    -pady 2 -padx 2
if {[tk windowingsystem] eq "aqua"} {
    $w.tristate configure -padx 10
}
grid $w.left     -column 0 -row 1 -pady .5c -padx .5c -rowspan 2
grid $w.mid      -column 1 -row 1 -pady .5c -padx .5c -rowspan 2
grid $w.right    -column 2 -row 1 -pady .5c -padx .5c
grid $w.tristate -column 2 -row 2 -pady .5c -padx .5c

foreach i {10 12 14 18 24} {
    radiobutton $w.left.b$i -text "Point Size $i" -variable size \
	    -relief flat -value $i -tristatevalue "multi"
    pack $w.left.b$i  -side top -pady 2 -anchor w -fill x
}

foreach c {Red Green Blue Yellow Orange Purple} {
    set lower [string tolower $c]
    radiobutton $w.mid.$lower -text $c -variable color \
	    -relief flat -value $lower -anchor w \
	    -command "$w.mid configure -fg \$color" \
	-tristatevalue "multi"
    pack $w.mid.$lower -side top -pady 2 -fill x
}


label $w.right.l -text "Label" -bitmap questhead -compound left
$w.right.l configure -width [winfo reqwidth $w.right.l] -compound top
$w.right.l configure -height [winfo reqheight $w.right.l]
foreach a {Top Left Right Bottom} {
    set lower [string tolower $a]
    radiobutton $w.right.$lower -text $a -variable align \
	    -relief flat -value $lower -indicatoron 0 -width 7 \
	    -command "$w.right.l configure -compound \$align"
}

grid x $w.right.top
grid $w.right.left $w.right.l $w.right.right
grid x $w.right.bottom
