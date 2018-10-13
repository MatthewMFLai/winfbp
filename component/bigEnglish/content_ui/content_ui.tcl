namespace eval content_ui {

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

proc map_save {} {
    variable m_localmap

    array set tmpdata {}
    foreach idx [array names m_localmap] {
	if {$m_localmap($idx) > 0} {
	    set tmpdata($idx) $m_localmap($idx)
	}
    }
    return [array get tmpdata]
}

proc map_load {mapdata} {
    variable m_localmap

    array set m_localmap $mapdata
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
	
    content_ui::map_set $item $meanings

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
    content_ui::localmap_default $item $idxlist_new
    return $meanings
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

	set wordlist [content_ui::extract_words $data]
	.frame0.text delete 0.0 end 
	.frame.list delete 0 end 
	.frame2.list delete 0 end 
	.frame2.list1 delete 0 end 
	.frame0.text insert 0.0 $data
         	
    	.frame.list delete 0 end
        foreach word $wordlist {	
    	    .frame.list insert end $word
	}

	# Init the dictionary cache.
	content_ui::init
    }
    unset filename
}
.mbar.file.m add command -label "Load Data" -command {
    send_section_read_rqst  "Get_ContextMeanings" $title \
            0 $g_section_addr_map($g_cur_section)  OUT-2
    server_async_send ""
    #content_ui::map_load $filename
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
    set data [content_ui::map_save]
    send_context_meaning_save_rqst  "Add_ContextMeanings" $title \
            $data $g_section_addr_map($g_cur_section)  OUT-3
    server_async_send ""
}
.mbar.file.m add command -label "Save Words" -command {
    set filename [tk_getSaveFile]
    if {$filename != ""} {
	set fd [open $filename w]
	foreach word [lsort [content_ui::map_get_words]] {
	    puts $fd $word
	}
	close $fd
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
 
    send_content_save_rqst Add_Title_Author $title $author 0 OUT-3

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
    	set tmpdata(outport) OUT-3
    	Fsm::Run content_fsm tmpdata
    }

    if {$curline != ""} {
    	set line [string trim $curline]
    	set tmpdata(line) $line
    	set tmpdata(depth) $depth
    	set tmpdata(doctype) $doctype
    	set tmpdata(title) $title
    	set tmpdata(proc) "send_content_save_rqst"
    	set tmpdata(outport) OUT-3
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
    foreach tokens [content_ui::localmap_get_all_no_repeat] {
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

######################################

frame .frameG
label .frameG.labA -text "Title"
entry .frameG.entA -textvar A -width 50
button .frameG.content -text "CONTENT" -command {
    set depth 4
    if {$A != ""} {
    	.frame0.text delete 0.0 end 
    	send_content_read_rqst  "Get_All_Token" $A $depth OUT-2
    } else {
    	.frame.list delete 0 end
    	send_content_read_rqst  "Get_All_Title" ""  $depth OUT-2
    }
    server_async_send ""
}
pack .frameG
pack .frameG.labA .frameG.entA .frameG.content -in .frameG -side left

######################################

frame .frame -borderwidth 10
pack .frame -side left -expand yes -fill y

scrollbar .frame.scroll -command ".frame.list yview"
listbox .frame.list -yscroll ".frame.scroll set" \
	-width 20 -height 16 -setgrid 1
pack .frame.list .frame.scroll -side top -fill y -expand 1

scrollbar .frame.scroll1 -command ".frame.list1 yview"
listbox .frame.list1 -yscroll ".frame.scroll1 set" \
	-width 20 -height 16 -setgrid 1
pack .frame.list1 .frame.scroll1 -side top -fill y -expand 1

bind .frame.list <Double-1> {
    set title [selection get]
    .frame.list1 delete 0 end 
    
    # Get sections for the selected title.
    set depth 4
    send_content_read_rqst  "Get_Token_At_Level" $title [expr $depth - 1] OUT-2
    server_async_send ""

    unset g_section_addr_map
    array set g_section_addr_map {}
}

bind .frame.list1 <Double-1> {

    # Get paragraphs for the selected section.
    set section [selection get]
    if {[info exists g_section_addr_map($section)]} {
    	set depth 4
    	send_section_read_rqst  "Get_Token_Under_Addr" $title \
            $depth $g_section_addr_map($section)  OUT-2
    	send_section_read_rqst  "Get_Concordance" $title \
            $depth $g_section_addr_map($section)  OUT-2
    	server_async_send ""

    	.frame0.text delete 0.0 end 
    	.frame2.list delete 0 end 
    	.frame2.list1 delete 0 end

	# Init the dictionary cache.
	content_ui::init

	# Clear the backup text.
	set g_text_backup ""

	# Remember the current section.
	set g_cur_section $section
    }
}
######################################

frame .frame0 -borderwidth 10
pack .frame0 -side left -expand yes -fill y

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
    set offset [content_ui::localmap_get $word $idx]
    if {$offset != ""} {
    	set meanings [content_ui::map_get $word]
    	.frame2.list1 delete 0 end
    	foreach mean $meanings {
    	    .frame2.list1 insert end $mean
    	}
    	.frame2.list1 selection clear active
    	.frame2.list1 selection set $offset
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

######################################

frame .frame2 -borderwidth 10
pack .frame2 -side left -expand yes -fill y

scrollbar .frame2.scroll -command ".frame2.list yview"
listbox .frame2.list -yscroll ".frame2.scroll set" \
	-width 20 -height 16 -setgrid 1
pack .frame2.list .frame2.scroll -side top -fill y -expand 1

bind .frame2.list <ButtonRelease-1> {
    set item [selection get]
    set meanings [content_ui::map_get $item]
    .frame2.list1 delete 0 end
    foreach mean $meanings {
    	.frame2.list1 insert end $mean
    }
    
    # Underline the word in the text box.
    .frame0.text tag delete t_underline
    .frame0.text tag configure t_underline -underline 1
    foreach idx [.frame0.text search -all -nocase $item 0.0] {
    	.frame0.text tag add t_underline $idx $idx+[string length $item]c
    }
    .frame0.text see $idx
}

######################################

scrollbar .frame2.scroll1 -command ".frame2.list1 yview"
listbox .frame2.list1 -yscroll ".frame2.scroll1 set" \
	-width 20 -height 16 -setgrid 1
pack .frame2.list1 .frame2.scroll1 -side top -fill y -expand 1

bind .frame2.list1 <ButtonRelease-1> {
    set item [selection get]
    # For some reason the search would not work... issue with unicode?
    # set idx [lsearch [.frame2.list1 get 0 end] $item]
    set idx 0
    foreach meaning [.frame2.list1 get 0 end] {
	if {[string first $item $meaning] == 0} {
    	    content_ui::localmap_set $g_last_word $g_last_idx $idx
	    break
	}
	incr idx
    }
}

###########################################################
# Framework proceudres
###########################################################

proc send_request {word outport} {

    set p_ip [ip::source]
    byList::init $p_ip
    byList::set_list $p_ip [list word $word command READ meanings ""]
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

proc send_section_read_rqst {method title depth addr outport} {
    set p_ip [ip::source]
    byList::init $p_ip
    byList::set_list $p_ip [list cmd $method title $title depth $depth addr $addr]
    server_send $p_ip $outport
    ip::sink $p_ip
    return
}

proc send_context_meaning_save_rqst {method title data addr outport} {
    set p_ip [ip::source]
    byList::init $p_ip
    # We don't care about depth data.
    byList::set_list $p_ip [list cmd $method title $title data $data nodeaddr $addr depth 0]
    server_send $p_ip $outport
    ip::sink $p_ip
    return
}

proc reset_all {data} {
    global g_text_backup

    # Back up text data.
    set g_text_backup $data
    
    set wordlist [content_ui::extract_words $data]
    .frame0.text delete 0.0 end 
    .frame.list delete 0 end 
    .frame2.list delete 0 end 
    .frame2.list1 delete 0 end 
    .frame0.text insert 0.0 $data
         	
    .frame.list delete 0 end
    foreach word $wordlist {	
        .frame.list insert end $word
    }

    # Init the dictionary cache.
    content_ui::init
    return
}

proc process {inport p_ip} {
    global g_request
    global g_text_backup
    global g_chunk_list
    global g_chunk_size
    global g_section_addr_map

    set rc ""
    if {$inport == "IN-1"} {
    	array set tmpdata [byList::get_list $p_ip]
    	set meanings $tmpdata(meanings) 
        set meanings [set_meaning $tmpdata(word) $meanings]

        .frame2.list insert end $tmpdata(word)

	# Check if there are more words to get meaning.
	# Don't send if word is in cache.
	# Send one word at a time.
	while {$g_chunk_list != ""} {
	    set word [lindex $g_chunk_list 0]
	    set g_chunk_list [lrange $g_chunk_list 1 end]
    	    if {[content_ui::map_get $word] == ""} {
	    	send_request $word OUT-1
		break
	    } else {	
        	.frame2.list insert end $word
	    }
	}

    } elseif {$inport == "IN-2"} {
    	array set tmpdata [byList::get_list $p_ip]
    	set cmd $tmpdata(cmd)

	if {$cmd == "Get_All_Token" ||
	    $cmd == "Get_Token_Under_Addr"} {
	    .frame0.text insert end $tmpdata(data)
	    .frame0.text insert end "\n\n"

	    # Update backup text that is used for revert in
	    # the Process menu item.
	    append g_text_backup $tmpdata(data)
	    append g_text_backup "\n\n"

	} elseif {$cmd == "Get_All_Title"} {
            .frame.list insert end $tmpdata(data)

	} elseif {$cmd == "Get_Token_At_Level"} {
	    set section [lindex $tmpdata(data) 0]
	    set nodeaddr [lindex $tmpdata(data) 1]
	    set g_section_addr_map($section) $nodeaddr
            .frame.list1 insert end $section

	} elseif {$cmd == "Get_Concordance"} {
	    set tmplist $tmpdata(data)
	    set count $g_chunk_size
	    set idx 0
	    foreach word $tmplist {
		incr idx
    		if {[content_ui::map_get $word] == ""} {
		    send_request $word OUT-1
		    incr count -1
		    if {$count == 0} {
			break
		    }
		} else {
        	    .frame2.list insert end $word
		}
	    }
	    set g_chunk_list [lrange $tmplist $idx end] 

	} elseif {$cmd == "Get_ContextMeanings"} {
	    set tmplist $tmpdata(data)
	    content_ui::map_load $tmplist

	} else {

	}

    } else {

    }
    return $rc
}

proc init {datalist} {
    global env
    global g_section_addr_map
    global g_chunk_size
    global g_chunk_list

    Fsm::Init
    Fsm::Load_Fsm $env(COMP_HOME)/bigEnglish/content_ui/content_fsm.dat
    Fsm::Init_Fsm content_fsm

    array set g_section_addr_map {}
    set g_chunk_list ""
    set g_chunk_size [lindex $datalist 0]
    if {$g_chunk_size == ""} {
	set g_chunk_size 20
    }

    return
}

proc shutdown {} {
}

source $env(COMP_HOME)/ip2/byList.tcl
source $env(FSM_HOME)/fsm.tcl
source $env(COMP_HOME)/bigEnglish/content_ui/content_fsm.tcl

global g_section_addr_map
global g_cur_section
#package require Tk
