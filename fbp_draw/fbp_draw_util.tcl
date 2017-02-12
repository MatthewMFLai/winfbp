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
proc defaultfont {} {
    set f [[button ._] cget -font]
    destroy ._
    set f
 }
 proc ladd {_list what} {
    upvar $_list list
    if {![info exists list] || [lsearch $list $what] == -1} {
        lappend list $what
    }
 }

proc gen_portname {blockname porttype portname} {
    set rc $blockname:$porttype:$portname
    return $rc
}

proc inv_gen_portname {name p_blockname p_porttype p_portname} {
    upvar $p_blockname blockname
    upvar $p_porttype porttype
    upvar $p_portname portname
    foreach {blockname porttype portname} [split $name ":"] break
    return
}

proc is_portname {name} {
    return [string match "*:*:*" $name]
}

proc is_porttype {name porttype} {
    set block ""
    set type ""
    set portname ""
    inv_gen_portname $name block type portname
    if {$type == $porttype} {
	return 1
    } else {
	return 0
    }
}

proc gen_from_to {from to} {
    return "$from\%$to"
}

proc inv_gen_from_to {from_to p_from p_to} {
    upvar $p_from from
    upvar $p_to to

    foreach {from to} [split $from_to "%"] break
    return
}

proc is_from_to {from_to} {
    if {[string match "*%*" $from_to]} {
	return 1
    } else {
	return 0
    }
}

proc find_links {win systemid} {
    set rc ""
    foreach id [$win find withtag edge] {
	foreach tag [$win itemcget $id -tags] {
	    if {[is_from_to $tag] == 0} {
		continue
	    }
	    inv_gen_from_to $tag from to
	    if {[string first $systemid $from] > -1 ||
		[string first $systemid $to] > -1} {
		lappend rc $id
		break	
	    }
	}
    }
    return $rc
}

proc find_links_with_fromto {win systemid} {
    set rc ""
    foreach id [$win find withtag edge] {
	foreach tag [$win itemcget $id -tags] {
	    if {[is_from_to $tag] == 0} {
		continue
	    }
	    inv_gen_from_to $tag from to
	    if {[string first $systemid $from] > -1 ||
		[string first $systemid $to] > -1} {
		lappend rc [list $id $from $to]
		break	
	    }
	}
    }
    return $rc
}

proc get_systemid_from_id {win id} {
    set taglist [$win itemcget $id -tags]
    set idx [lsearch $taglist "system*"]
    if {$idx != -1} {
    	return [lindex $taglist $idx]
    } else {
    	return ""
    }
}

proc get_blockname_map {c blocktag p_systemid_blockname_map {option ID-BLOCK}} {
    upvar $p_systemid_blockname_map blockname_map
    foreach id [$c find all] {
	set taglist [$c itemcget $id -tags]
        if {[lsearch $taglist $blocktag] == -1} {
	    continue 
        }
	# Cpu utilization may change the -text display,
	# so ignore the (xx%) when extracting the block name.
	set block [$c itemcget $id -text]
	set tmpidx [string first "\(" $block]
	if {$tmpidx != -1} {
	    incr tmpidx -1
	    set block [string range $block 0 $tmpidx]
	}

	set idx [lsearch $taglist "system*"]
	if {$option == "ID-BLOCK"} {
	    set blockname_map([lindex $taglist $idx]) $block 
	} else {
	    set blockname_map($block) [lindex $taglist $idx]
	}
    }
}

proc get_systemid {win} {
    set systemids ""
    foreach id [$win find all] {
   	set taglist [$win itemcget $id -tags]
	if {[lsearch $taglist "BLOCK"] == -1} {
	    continue
	}
	set idx [lsearch $taglist "system*"]
	if {$idx == -1} {
	    continue
	}
	lappend systemids [lindex $taglist $idx]
    }
    return $systemids
}

proc gen_systemid {idlist} {
    set toloop 1
    # Set the seed for rand() function
    expr (srand([clock seconds]))
    while {$toloop} {
	set id system[expr round(rand() * 10000)]
	if {[lsearch $idlist $id] == -1} {
	    break
	}
    }
    return $id
}

proc info_dialog {string} {
    tk_dialog .foo "Info" $string "" 0 OK
    return
}

proc error_dialog {string} {
    tk_dialog .foo "Error" $string "" 0 OK
    return
}

proc update_port_queue {win portqueuelist} {

    array set id_block_map {}
    get_blockname_map $win "BLOCK" id_block_map BLOCK-ID
 
    foreach token $portqueuelist {
	queue_data_get $token block port length
	set portname [gen_portname $id_block_map($block) INPORT $port]
	set id [$win find withtag $portname]
	set displayname [string trim [$win itemcget $id -text]]
	if {$length} {
	    append displayname "\($length\)"
	} else {
	    set idx [string last "\(" $displayname]
	    if {$idx != -1} {
		incr idx -1
		set displayname [string range $displayname 0 $idx]
	    }
	}
	$win itemconfig $id -text $displayname
    }
    return
}

proc update_cpu {win p_cputimes} {
    upvar $p_cputimes cputimes

    array set id_block_map {}
    get_blockname_map $win "BLOCK" id_block_map BLOCK-ID
    foreach block [array names cputimes] {
	if {$block == "CONNECT"} {
	    continue
	}
	set id [$win find withtag "$id_block_map($block) && BLOCK"]
	set displayname [string trim [$win itemcget $id -text]]
	set time $cputimes($block)
	if {$time != "CLEAR"} {
	    append displayname "\($time\)"
	} else {
	    set idx [string last "\(" $displayname]
	    if {$idx != -1} {
		incr idx -1
		set displayname [string range $displayname 0 $idx]
	    }
	}
	$win itemconfig $id -text $displayname
    }
    return
}

proc queue_data_get {token p_block p_port p_length} {
    upvar $p_block block
    upvar $p_port port
    upvar $p_length length

    set block [lindex $token 0]
    set port [lindex $token 1]
    set length [lindex $token 2]
    return
}

proc queue_data_set {block port length} {
    return [list $block $port $length]
}

set custom_dialog_template {
proc custom_dialog_aaa {string idxlist width p_data bbb} {
    upvar $p_data data
    set w [toplevel .[clock seconds]]
    wm resizable $w 0 0

    wm title $w $string 
    wm iconname $w "form"
    set x [winfo pointerx .]
    set y [winfo pointery .]
    wm geometry $w "+$x+$y"

    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.ok -text OK -command "set done 1"
    pack $w.buttons.ok -side left -expand 1

    foreach i $idxlist {
    	frame $w.$i -bd 2
    	entry $w.$i.entry -relief sunken -width $width 
    	$w.$i.entry insert 0 $data($i) 
    	label $w.$i.label
    	$w.$i.label config -text $data($i\_desc) 
    	pack $w.$i.entry -side right
    	pack $w.$i.label -side left
    }
    foreach i $idxlist {
    	pack $w.$i -side top -fill x
    }
    ccc 
    focus $w.f1.entry
    vwait done
    foreach i $idxlist {
        set data($i) [$w.$i.entry get]
    }
    ddd 
    destroy $w
}}

set reset_ip_template {
proc Reset_IP {ipaddrlist p_ipaddr} {
    set w [toplevel .[clock seconds]]
    frame $w.buttons
    pack $w.buttons -side bottom -fill x -pady 2m
    button $w.buttons.ok -text OK -command "set done 1"
    pack $w.buttons.ok -side left -expand 1
    aaa
    vwait done
    bbb
    destroy $w
}}

set radiobutton_template {
    # Radio buttons to select ip address.
    upvar $p_ipaddr ipaddr
    global g_ip_selected
    set g_ip_selected "" 
    labelframe $w.left -pady 2 -text "IP address" -padx 2
    pack $w.left -side left -expand yes  -pady .5c -padx .5c
    foreach token $ipaddrlist {
	regsub -all {\.} $token "_" i
    	radiobutton $w.left.b$i -text "$token" -variable g_ip_selected\
	        -relief flat -value $token
    	pack $w.left.b$i  -side top -pady 2 -anchor w -fill x
	if {$token == $ipaddr} {
	    $w.left.b$i select
	}
    }
}

set radiobutton_template2 {
    if {$g_ip_selected != ""} {
    	set ipaddr $g_ip_selected
    }
    unset g_ip_selected
}
regsub "_aaa" $custom_dialog_template "" dialog_proc
regsub "bbb" $dialog_proc "" dialog_proc
regsub "ccc" $dialog_proc "" dialog_proc
regsub "ddd" $dialog_proc "" dialog_proc
eval $dialog_proc

regsub "_aaa" $custom_dialog_template "_with_ip" dialog_proc
regsub "bbb" $dialog_proc "p_ipaddr ipaddrlist" dialog_proc
regsub "ccc" $dialog_proc $radiobutton_template dialog_proc
regsub "ddd" $dialog_proc $radiobutton_template2 dialog_proc
eval $dialog_proc

regsub "aaa" $reset_ip_template $radiobutton_template dialog_proc
regsub "bbb" $dialog_proc $radiobutton_template2 dialog_proc
eval $dialog_proc

