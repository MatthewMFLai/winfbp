namespace eval txlate {

variable m_map
variable m_localmap

proc init {} {
    variable m_map
    variable m_localmap

    if {[info exists m_map]} {
	unset m_map
    }
    array set m_map {}
    if {[info exists m_localmap]} {
	unset m_localmap
    }
    array set m_localmap {}
    return
}

proc extract_words {data} {
    regsub -all "\n" $data " " data
    regsub -all "\"" $data " " data

    foreach word $data {
        set word [string tolower $word]
    	if {[string is alpha $word]} {
	    lappend wordlist $word
    	} else {
	    set newword ""
	    set max [string length $word]
	    set i 0
	    while {$i < $max} {
	    	set char [string index $word $i]
	    	if {[string is alpha $char] ||
		    $char == "-" ||
		    $char == "-"} {
		    append newword $char
	    	}
	        incr i
	    }
	    if {$newword != ""} {
	    	lappend wordlist $newword
	    }
    	}
    }
    set wordlist [lsort -unique $wordlist]
    return $wordlist
}

proc map_set {word meanings} {
    variable m_map

    if {$meanings == ""} {
	return
    }

    if {![info exists m_map($word)]} {
	set m_map($word) $meanings
    }
    return
}

proc map_get {word} {
    variable m_map

    set rc ""
    if {[info exists m_map($word)]} {
	set rc $m_map($word)
    }
    return $rc
}

proc map_get_words {} {
    variable m_map
    return [array names m_map] 
}

proc map_clear {word} {
    variable m_map
    if {[info exists m_map($word)]} {
	unset m_map($word)
    }
    return
}

proc localmap_default {word idxlist} {
    variable m_localmap

    foreach idx $idxlist {
	set m_localmap($word,$idx) 0
    }
    return
}

proc localmap_get {word idx} {
    variable m_localmap

    set rc ""
    if {[info exists m_localmap($word,$idx)]} {
	    set rc $m_localmap($word,$idx)
    }
    return $rc
}

proc localmap_get_all {} {
    variable m_localmap

    set rc ""
    foreach index [array names m_localmap] {
	set offset $m_localmap($index)
	set word [lindex [split $index ","] 0]
	set idx [lindex [split $index ","] 1]
	set meanings [map_get $word]
	if {$meanings == ""} {
	    continue
	}
	lappend rc [list $word $idx [lindex $meanings $offset]]
    }
    return $rc
}

# Similar to localmap_get_all except only return the words without
# the repeating meanings.
# i.e. if we have {woods,5.64 0} {woods,6.21 0} then return the
# first occurence, that is, {woods,5.64 0} only.

proc localmap_get_all_no_repeat {} {
    variable m_localmap

    set rc ""
    set indexlist ""
    array set tmptable {}
    foreach index [lsort [array names m_localmap]] {
	set offset $m_localmap($index)
	set word [lindex [split $index ","] 0]
	if {![info exists tmptable($word,$offset)]} {
	    set tmptable($word,$offset) 1
	    lappend indexlist $index
	}	
    }

    foreach index $indexlist {
	set offset $m_localmap($index)
	set word [lindex [split $index ","] 0]
	set idx [lindex [split $index ","] 1]
	set meanings [map_get $word]
	if {$meanings == ""} {
	    continue
	}
	lappend rc [list $word $idx [lindex $meanings $offset]]
    }
    return $rc
}

proc localmap_set {word idx offset} {
    variable m_localmap

    set m_localmap($word,$idx) $offset
    return
}

proc localmap_clear {word} {
    variable m_localmap

    foreach index [array names m_localmap "$word,*"] {
    	unset m_localmap($index)
    }
    return
}

proc map_save {mapfile} {
    variable m_map
    variable m_localmap

    set fd [open $mapfile w]
    puts $fd [array get m_map]
    puts $fd [array get m_localmap]
    close $fd 
    return
}

proc map_load {mapfile} {
    variable m_map
    variable m_localmap

    if {![file exists $mapfile]} {
	return
    }

    set fd [open $mapfile r]
    if {[gets $fd mapdata] > -1} {
    	if {[info exists m_map]} {
	    unset m_map
    	}
    	array set m_map $mapdata
    }

    if {[gets $fd mapdata] > -1} {
    	if {[info exists m_localmap]} {
	    unset m_localmap
    	}
    	array set m_localmap $mapdata
    }

    close $fd
    return
}

}

# bigEnglish.tcl --
#
# This demonstration script creates a text widget that describes
# the basic editing functions.
#
# To get the index of the current selection in text widget
# .frame0.text dump -mark insert # mark insert 1.516
#

proc clean_word {word} {
    set word [string tolower $word]
    if {[string index $word end] == ":"} {
	set word [string range $word 0 end-1]
    }
    return $word
}

proc word_rules {word} {
    if {$word == " " ||
        $word == "." ||
        $word == "," ||
        $word == "?" ||
        $word == "\"" ||
        $word == "\'" ||
        $word == "\[" ||
        $word == "\]" ||
        $word == "\{" ||
        $word == "\}" ||
        $word == "\n" ||
        $word == "!" ||
        $word == ":" ||
        $word == ";" ||
        $word == "$"} {
    	return 1
    } else {
    	return 0
    }
}

proc get_meaning {item} {
   send_request $item OUT-1
   server_async_send ""
   return
}

proc trim_meanings {meanings} { 
   # Custom processing specific to the Yahoo English to Chinese Dict
   # Remove the "1." from each meaning phrase.
   # Remove the square bracket contents.
   if {$meanings != ""} {
	set tmp_meanings ""
	foreach meaning $meanings {
	    set index [string first "\[" $meaning]
	    if {$index > 0} {
	    	set index2 [string last "\]" $meaning]
		set meaning [string replace $meaning $index $index2]
	    }
	    set index [string first " " $meaning]
	    incr index
	    lappend tmp_meanings [string range $meaning $index end]
	}
	return $tmp_meanings
    } else {
    	return ""
    }
}

proc set_meaning {item meanings} {
    #set meanings [trim_meanings $meanings]
	
    txlate::map_set $item $meanings

    # Attach meaning to the stand-alone word, not to the word
    # imbedded inside another word. Hence check for white space before and
    # after the word.
    set idxlist_new ""
    set idxlist [.frame0.text search -all -nocase $item 0.0]
    foreach idx $idxlist {
    	set before [.frame0.text get $idx-1c]	
    	set after [.frame0.text get $idx+[string length $item]c]
	if {[word_rules $before] && [word_rules $after]} {
	    lappend idxlist_new $idx
	}
    }
    txlate::localmap_default $item $idxlist_new
    return $meanings
}

proc randomize_words {wordlist} {
    # To randomize a sorted list.
    set rc ""
    set count [llength $wordlist]
    while {$count} {
	set idx [expr (int(rand() * [llength $wordlist]))]
	lappend rc [lindex $wordlist $idx]
	set wordlist [lreplace $wordlist $idx $idx]
	incr count -1
    }
    return $rc
}

package require Tk

tk_setPalette "LavenderBlush3"

if {0} {
set w .text
catch {destroy $w}
toplevel $w
wm title $w "Text Demonstration - Basic Facilities"
wm iconname $w "text"
}

frame .mbar -borderwidth 1 -relief raised
pack .mbar -fill x
menubutton .mbar.file -text "File" -menu .mbar.file.m
pack .mbar.file -side left
menu .mbar.file.m
.mbar.file.m add command -label "Open" -command {
    set filename [tk_getOpenFile]
    if {$filename != ""} {
	set fd [open $filename r]
	set data [read $fd]
	close $fd

	# Back up text data.
	set g_text_backup $data

	set wordlist [txlate::extract_words $data]
	.frame0.text delete 0.0 end 
	.frame.list delete 0 end 
	.frame2.list delete 0 end 
	.frame3.list delete 0 end 
	.frame0.text insert 0.0 $data
         	
    	.frame.list delete 0 end
        foreach word $wordlist {	
    	    .frame.list insert end $word
	}

	# Init the dictionary cache.
	txlate::init
    }
    unset filename
}
.mbar.file.m add command -label "Load Data" -command {
    set filename [tk_getOpenFile]
    if {$filename != ""} {
	txlate::map_load $filename

        # Update frame and frame2 display
        foreach word [lsort [txlate::map_get_words]] {
	    .frame2.list insert end $word	
    	    set idx [lsearch [.frame.list get 0 end] $word]
	    if {$idx != -1} {
    		.frame.list delete $idx
	    }
	}
    }
}
.mbar.file.m add command -label "Save" -command {
    set filename [tk_getSaveFile]
    if {$filename != ""} {
	set fd [open $filename w]
	puts $fd [.frame0.text get 0.0 end]
	close $fd
    }
}
.mbar.file.m add command -label "Save Data" -command {
    set filename [tk_getSaveFile]
    if {$filename != ""} {
    	txlate::map_save $filename
    }
}
.mbar.file.m add command -label "Save Content" -command {

set depth 4 
set doctype "parser_default"
set data [.frame0.text get 0.0 end]

# Get title and author.
set exp {Title: (.*?)\n}
regexp $exp $data -> title

set exp {Author: (.*?)\n}
regexp $exp $data -> author 

if {[info exists title] &&
    [info exists author]} {
 
    send_content_save_rqst Add_Title_Author $title $author 0 OUT-5

    array set tmpdata {}
    set curline ""

    foreach line [split $data "\n"] {
    	if {$line != ""} {
	    append curline " $line"
	    continue
    	}

    	if {$curline == ""} {
	    continue
    	}

    	set line [string trim $curline]
    	set curline ""

    	set tmpdata(line) $line
    	set tmpdata(depth) $depth
    	set tmpdata(doctype) $doctype
    	set tmpdata(title) $title
    	set tmpdata(proc) "send_content_save_rqst"
    	set tmpdata(outport) OUT-5
    	Fsm::Run content_fsm tmpdata
    }

    if {$curline != ""} {
    	set line [string trim $curline]
    	set tmpdata(line) $line
    	set tmpdata(depth) $depth
    	set tmpdata(doctype) $doctype
    	set tmpdata(title) $title
    	set tmpdata(proc) "send_content_save_rqst"
    	set tmpdata(outport) OUT-5
    	Fsm::Run content_fsm tmpdata
    }

    if {[Fsm::Is_In_Service content_fsm] != 1} {
        puts "fsm error: [Fsm::Get_Error content_fsm]"
    }
    server_async_send ""
}

}
.mbar.file.m add command -label "Reset" -command {
    reset_all [.frame0.text get 0.0 end]
}
.mbar.file.m add command -label "Exit" -command {
    #exit
}

menubutton .mbar.gen -text "Generate" -menu .mbar.gen.m
pack .mbar.gen -side left
menu .mbar.gen.m
.mbar.gen.m add command -label "Process" -command {
    array set tmparray {}
    array set tmparray2 {}
    array set tmparray3 {}
    foreach tokens [txlate::localmap_get_all_no_repeat] {
	set word [lindex $tokens 0]
	set idx [lindex $tokens 1]
	set meaning [lindex $tokens 2]
	set tmparray($idx) $meaning
	set tmparray2($idx) [string length $word]

	# Collect the words.
	if {![info exists tmparray3($word)]} {
	    set tmparray3($word) ""
	}
	lappend tmparray3($word) $meaning	
    }
    foreach idx [lsort -dictionary -decreasing [array names tmparray]] {
	if {[catch {.frame0.text insert $idx+$tmparray2($idx)c \($tmparray($idx)\)} rc]} {
	    puts "problem with $tmparray($idx)"
	}
    }
    unset tmparray
    unset tmparray2

    # Output the list of words at the end of the article.
    .frame0.text insert end "\n"
    .frame0.text insert end "\n"
    foreach word [lsort [array names tmparray3]] {
	.frame0.text insert end "$word [lsort -unique $tmparray3($word)] \n"
    }
    unset tmparray3 
}
.mbar.gen.m add command -label "Revert" -command {
    .frame0.text delete 0.0 end 
    .frame0.text insert 0.0 $g_text_backup
}

menubutton .mbar.dic -text "Dictionary" -menu .mbar.dic.m
pack .mbar.dic -side left
menu .mbar.dic.m
.mbar.dic.m add command -label "Populate" -command {
    set wordlist [randomize_words [txlate::extract_words $g_text_backup]]
    set idx [expr $g_chunk_size - 1]
    set tmplist [lrange $wordlist 0 $idx]
    send_populate_request $tmplist "OUT-2"
    set g_chunk_list [lrange $wordlist $g_chunk_size end]
    server_async_send ""
}

######################################

frame .frameG
label .frameG.labA -text "Title"
entry .frameG.entA -textvar A -width 50
button .frameG.get -text "GET" -command {
    if {$A != ""} {
    	send_request_src $A OUT-3
   	server_async_send ""
    }
}
button .frameG.content -text "CONTENT" -command {
    set depth 4
    if {$A != ""} {
    	.frame0.text delete 0.0 end 
    	send_content_read_rqst  "Get_All_Token" $A $depth OUT-4
   	server_async_send ""
    }
}
pack .frameG
pack .frameG.labA .frameG.entA .frameG.get .frameG.content -in .frameG -side left

######################################

frame .frame0 -borderwidth 10
pack .frame0 -side top -expand yes -fill y

text .frame0.text -yscrollcommand [list .frame0.scroll set] -setgrid 1 \
	-height 30 -undo 1 -autosep 1
scrollbar .frame0.scroll -command [list .frame0.text yview]
.frame0.text tag configure t_underline -underline 1
pack .frame0.scroll -side right -fill y
pack .frame0.text -expand yes -fill both

bind .frame0.text <Double-1> {
    set word [.frame0.text get "insert wordstart" "insert wordend"]
    set idx [.frame0.text index "insert wordstart"] 
    # The word may have punctuation at the end, like a :
    # Need to remove the punctuation, and also the upper case.
    set word [clean_word $word]
    set offset [txlate::localmap_get $word $idx]
    if {$offset != ""} {
    	set meanings [txlate::map_get $word]
    	.frame3.list delete 0 end
    	foreach mean $meanings {
    	    .frame3.list insert end $mean
    	}
    	.frame3.list selection clear active
    	.frame3.list selection set $offset
	set g_last_word $word
	set g_last_idx $idx
    } else {
	# The word is most likely not yet exist in the dictionary.
	# Add the word to the dictionary.
	# Use the same logic for double clicking an entry in frame 1.
    	set idx [lsearch [.frame.list get 0 end] $word]
    	.frame2.list insert end $word
    	.frame.list delete $idx

    	get_meaning $word

	set g_last_word $word
	set g_last_idx $idx
    } 
}

frame .frame -borderwidth 10
pack .frame -side left -expand yes -fill y

scrollbar .frame.scroll -command ".frame.list yview"
listbox .frame.list -yscroll ".frame.scroll set" \
	-width 20 -height 16 -setgrid 1
pack .frame.list .frame.scroll -side left -fill y -expand 1

bind .frame.list <Double-1> {
    set item [selection get]
    set idx [lsearch [.frame.list get 0 end] $item]
    .frame2.list insert end $item 
    .frame.list delete $idx
    
    # Get dictionary meaning.
    set meanings [txlate::map_get $item]
    if {$meanings == ""} {
    	get_meaning $item
    }
}

frame .frame2 -borderwidth 10
pack .frame2 -side left -expand yes -fill y

scrollbar .frame2.scroll -command ".frame2.list yview"
listbox .frame2.list -yscroll ".frame2.scroll set" \
	-width 20 -height 16 -setgrid 1
pack .frame2.list .frame2.scroll -side left -fill y -expand 1

bind .frame2.list <ButtonRelease-1> {
    set item [selection get]
    set meanings [txlate::map_get $item]
    .frame3.list delete 0 end
    foreach mean $meanings {
    	.frame3.list insert end $mean
    }
    
    # Underline the word in the text box.
    .frame0.text tag delete t_underline
    .frame0.text tag configure t_underline -underline 1
    foreach idx [.frame0.text search -all -nocase $item 0.0] {
    	.frame0.text tag add t_underline $idx $idx+[string length $item]c
    }
    .frame0.text see $idx
}

bind .frame2.list <ButtonRelease-3> {
    set item [selection get]
    set idx [lsearch [.frame2.list get 0 end] $item]
    .frame.list insert 0 $item 
    .frame2.list delete $idx
    .frame3.list delete 0 end

    txlate::map_clear $item
    txlate::localmap_clear $item
}

frame .frame3 -borderwidth 10
pack .frame3 -side right -expand yes -fill y

scrollbar .frame3.scroll -command ".frame3.list yview"
listbox .frame3.list -yscroll ".frame3.scroll set" \
	-width 20 -height 16 -setgrid 1
pack .frame3.list .frame3.scroll -side left -fill y -expand 1

bind .frame3.list <ButtonRelease-1> {
    set item [selection get]
    # For some reason the search would not work... issue with unicode?
    # set idx [lsearch [.frame3.list get 0 end] $item]
    set idx 0
    foreach meaning [.frame3.list get 0 end] {
	if {[string first $item $meaning] == 0} {
    	    txlate::localmap_set $g_last_word $g_last_idx $idx
	    break
	}
	incr idx
    }
}

###########################################################
# Framework proceudres
###########################################################

proc send_request {word outport} {
    global g_crawler

    set p_ip [ip::source]
    byRetry::init $p_ip
    byRetry::set_retry $p_ip 0
    byList::init $p_ip
    byList::set_list $p_ip [list word $word command READ meanings ""]
    byList::set_crawler $p_ip $g_crawler
    server_send $p_ip $outport
    ip::sink $p_ip
    return
}

proc send_request_src {title outport} {
    global g_crawler_src

    set p_ip [ip::source]
    byRetry::init $p_ip
    byRetry::set_retry $p_ip 0
    byList::init $p_ip
    byList::set_list $p_ip [list word $title]
    byList::set_crawler $p_ip $g_crawler_src
    server_send $p_ip $outport
    ip::sink $p_ip
    return
}

proc send_populate_request {words outport} {
    global g_crawler

    set p_ip [ip::source]
    byRetry::init $p_ip
    byRetry::set_retry $p_ip 0
    byList::init $p_ip
    byList::set_list $p_ip [list words $words]
    byList::set_crawler $p_ip $g_crawler
    server_send $p_ip $outport
    ip::sink $p_ip
    return
}

proc send_content_save_rqst {method title data depth outport} {
    set p_ip [ip::source]
    byList::init $p_ip
    byList::set_list $p_ip [list cmd $method title $title depth $depth data $data]
    server_send $p_ip $outport
    ip::sink $p_ip
    return
}

proc send_content_read_rqst {method title depth outport} {
    set p_ip [ip::source]
    byList::init $p_ip
    byList::set_list $p_ip [list cmd $method title $title depth $depth]
    server_send $p_ip $outport
    ip::sink $p_ip
    return
}

proc reset_all {data} {
    global g_text_backup
    global w

    # Back up text data.
    set g_text_backup $data

    set wordlist [txlate::extract_words $data]
    .frame0.text delete 0.0 end 
    .frame.list delete 0 end 
    .frame2.list delete 0 end 
    .frame3.list delete 0 end 
    .frame0.text insert 0.0 $data
         	
    .frame.list delete 0 end
    foreach word $wordlist {	
        .frame.list insert end $word
    }

    # Init the dictionary cache.
    txlate::init
    return
}

proc process {inport p_ip} {
    global g_request
    global g_text_backup
    global w
    global g_chunk_list
    global g_chunk_size

    set rc ""
    if {$inport == "IN-1"} {
    	array set tmpdata [byList::get_list $p_ip]
    	set meanings $tmpdata(meanings) 
        set meanings [set_meaning $tmpdata(word) $meanings]
        .frame3.list delete 0 end
        foreach mean $meanings {
    	    .frame3.list insert end $mean
    	}

    } elseif {$inport == "IN-2"} {
    	array set tmpdata [byList::get_list $p_ip]
    	set words $tmpdata(words) 

 	# Send another chunk
	if {$g_chunk_list != ""} {
    	    set idx [expr $g_chunk_size - 1]
    	    set tmplist [lrange $g_chunk_list 0 $idx]
    	    send_populate_request $tmplist "OUT-2"
    	    set g_chunk_list [lrange $g_chunk_list $g_chunk_size end]
	}
	
    } elseif {$inport == "IN-3"} {
    	array set tmpdata [byList::get_list $p_ip]
	if {[info exists tmpdata(content)]} {

	    set data $tmpdata(content)
	    # Perform inverse substitution of "%%%" with "\n"
	    regsub -all "%%%" $data "\n" data

	    # Back up text data.
	    set g_text_backup $data

	    set wordlist [txlate::extract_words $data]
	    .frame0.text delete 0.0 end 
	    .frame.list delete 0 end 
	    .frame2.list delete 0 end 
	    .frame3.list delete 0 end 
	    .frame0.text insert 0.0 $data
         	
    	    .frame.list delete 0 end
            foreach word $wordlist {	
    	        .frame.list insert end $word
	    }

	    # Init the dictionary cache.
	    txlate::init
	}

    } elseif {$inport == "IN-4"} {
    	array set tmpdata [byList::get_list $p_ip]
    	set cmd $tmpdata(cmd)
	if {$cmd == "Get_All_Token"} {
	    .frame0.text insert end $tmpdata(data)
	    .frame0.text insert end "\n\n"
	}

    } else {

    }
    return $rc
}

proc init {datalist} {
    global env
    global g_crawler
    global g_crawler_src
    global g_chunk_size
    global g_chunk_list

    set g_crawler [lindex $datalist 0]
    set g_crawler_src [lindex $datalist 1]
    set g_chunk_size [lindex $datalist 2]
    if {$g_chunk_size == ""} {
	set g_chunk_size 20
    }
    set g_chunk_list ""

    Fsm::Init
    Fsm::Load_Fsm $env(COMP_HOME)/bigEnglish/translate_ui/content_fsm.dat
    Fsm::Init_Fsm content_fsm
    return
}

proc shutdown {} {
}

source $env(COMP_HOME)/ip2/byList.tcl
source $env(COMP_HOME)/ip2/byRetry.tcl
source $env(FSM_HOME)/fsm.tcl
source $env(COMP_HOME)/bigEnglish/translate_ui/content_fsm.tcl

#package require Tk
