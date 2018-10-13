# text.tcl --
#
# This demonstration script creates a text widget that describes
# the basic editing functions.
#
# To get the index of the current selection in text widget
# $w.frame0.text dump -mark insert
# mark insert 1.516
#
source $env(WEB_DRIVER)/translate/app/extract_words.tcl
source $env(WEB_DRIVER)/translate/app/translate_test.tcl

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

proc get_meaning {item w} {
   set meanings [dict_get $item]
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
	set meanings $tmp_meanings
    }
	
    txlate::map_set $item $meanings

    # Attach meaning to the stand-alone word, not to the word
    # imbedded inside another word. Hence check for white space before and
    # after the word.
    set idxlist_new ""
    set idxlist [$w.frame0.text search -all -nocase $item 0.0]
    foreach idx $idxlist {
    	set before [$w.frame0.text get $idx-1c]	
    	set after [$w.frame0.text get $idx+[string length $item]c]
	if {[word_rules $before] && [word_rules $after]} {
	    lappend idxlist_new $idx
	}
    }
    txlate::localmap_default $item $idxlist_new
    return $meanings
}

tk_setPalette "LavenderBlush3"

set w .text
catch {destroy $w}
toplevel $w
wm title $w "Text Demonstration - Basic Facilities"
wm iconname $w "text"

frame $w.mbar -borderwidth 1 -relief raised
pack $w.mbar -fill x
menubutton $w.mbar.file -text "File" -menu $w.mbar.file.m
pack $w.mbar.file -side left
menu $w.mbar.file.m
$w.mbar.file.m add command -label "Open" -command {
    set filename [tk_getOpenFile]
    if {$filename != ""} {
	set fd [open $filename r]
	set data [read $fd]
	close $fd

	# Back up text data.
	set g_text_backup $data

	set wordlist [txlate::extract_words $data]
	$w.frame0.text delete 0.0 end 
	$w.frame.list delete 0 end 
	$w.frame2.list delete 0 end 
	$w.frame3.list delete 0 end 
	$w.frame0.text insert 0.0 $data
         	
    	$w.frame.list delete 0 end
        foreach word $wordlist {	
    	    $w.frame.list insert end $word
	}

	# Init the dictionary cache.
	txlate::init
    }
    unset filename
}
$w.mbar.file.m add command -label "Load Data" -command {
    set filename [tk_getOpenFile]
    if {$filename != ""} {
	txlate::map_load $filename

        # Update frame and frame2 display
        foreach word [lsort [txlate::map_get_words]] {
	    $w.frame2.list insert end $word	
    	    set idx [lsearch [$w.frame.list get 0 end] $word]
	    if {$idx != -1} {
    		$w.frame.list delete $idx
	    }
	}
    }
}
$w.mbar.file.m add command -label "Save" -command {
    set filename [tk_getSaveFile]
    if {$filename != ""} {
	set fd [open $filename w]
	puts $fd [$w.frame0.text get 0.0 end]
	close $fd
    }
}
$w.mbar.file.m add command -label "Save Data" -command {
    set filename [tk_getSaveFile]
    if {$filename != ""} {
    	txlate::map_save $filename
    }
}
$w.mbar.file.m add command -label "Exit" -command {
    exit
}

menubutton $w.mbar.gen -text "Generate" -menu $w.mbar.gen.m
pack $w.mbar.gen -side left
menu $w.mbar.gen.m
$w.mbar.gen.m add command -label "Process" -command {
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
	if {[catch {$w.frame0.text insert $idx+$tmparray2($idx)c \($tmparray($idx)\)} rc]} {
	    puts "problem with $tmparray($idx)"
	}
    }
    unset tmparray
    unset tmparray2

    # Output the list of words at the end of the article.
    $w.frame0.text insert end "\n"
    $w.frame0.text insert end "\n"
    foreach word [lsort [array names tmparray3]] {
	$w.frame0.text insert end "$word [lsort -unique $tmparray3($word)] \n"
    }
    unset tmparray3 
}
$w.mbar.gen.m add command -label "Revert" -command {
    $w.frame0.text delete 0.0 end 
    $w.frame0.text insert 0.0 $g_text_backup
}

frame $w.frame0 -borderwidth 10
pack $w.frame0 -side top -expand yes -fill y

text $w.frame0.text -yscrollcommand [list $w.frame0.scroll set] -setgrid 1 \
	-height 30 -undo 1 -autosep 1
scrollbar $w.frame0.scroll -command [list $w.frame0.text yview]
$w.frame0.text tag configure t_underline -underline 1
pack $w.frame0.scroll -side right -fill y
pack $w.frame0.text -expand yes -fill both

bind $w.frame0.text <Double-1> {
    set word [$w.frame0.text get "insert wordstart" "insert wordend"]
    set idx [$w.frame0.text index "insert wordstart"] 
    # The word may have punctuation at the end, like a :
    # Need to remove the punctuation, and also the upper case.
    set word [clean_word $word]
    set offset [txlate::localmap_get $word $idx]
    if {$offset != ""} {
    	set meanings [txlate::map_get $word]
    	$w.frame3.list delete 0 end
    	foreach mean $meanings {
    	    $w.frame3.list insert end $mean
    	}
    	$w.frame3.list selection clear active
    	$w.frame3.list selection set $offset
	set g_last_word $word
	set g_last_idx $idx
    } else {
	# The word is most likely not yet exist in the dictionary.
	# Add the word to the dictionary.
	# Use the same logic for double clicking an entry in frame 1.
    	set idx [lsearch [$w.frame.list get 0 end] $word]
    	$w.frame2.list insert end $word
    	$w.frame.list delete $idx

    	set meanings [get_meaning $word $w]
    	$w.frame3.list delete 0 end
    	foreach mean $meanings {
    	    $w.frame3.list insert end $mean
    	}

	set g_last_word $word
	set g_last_idx $idx
    } 
}

frame $w.frame -borderwidth 10
pack $w.frame -side left -expand yes -fill y

scrollbar $w.frame.scroll -command "$w.frame.list yview"
listbox $w.frame.list -yscroll "$w.frame.scroll set" \
	-width 20 -height 16 -setgrid 1
pack $w.frame.list $w.frame.scroll -side left -fill y -expand 1

bind $w.frame.list <Double-1> {
    set item [selection get]
    set idx [lsearch [$w.frame.list get 0 end] $item]
    $w.frame2.list insert end $item 
    $w.frame.list delete $idx
    
    # Get dictionary meaning.
    set meanings [txlate::map_get $item]
    if {$meanings == ""} {
    	set meanings [get_meaning $item $w]
    }
    $w.frame3.list delete 0 end
    foreach mean $meanings {
    	$w.frame3.list insert end $mean
    }
}

frame $w.frame2 -borderwidth 10
pack $w.frame2 -side left -expand yes -fill y

scrollbar $w.frame2.scroll -command "$w.frame2.list yview"
listbox $w.frame2.list -yscroll "$w.frame2.scroll set" \
	-width 20 -height 16 -setgrid 1
pack $w.frame2.list $w.frame2.scroll -side left -fill y -expand 1

bind $w.frame2.list <ButtonRelease-1> {
    set item [selection get]
    set meanings [txlate::map_get $item]
    $w.frame3.list delete 0 end
    foreach mean $meanings {
    	$w.frame3.list insert end $mean
    }
    
    # Underline the word in the text box.
    $w.frame0.text tag delete t_underline
    $w.frame0.text tag configure t_underline -underline 1
    foreach idx [$w.frame0.text search -all -nocase $item 0.0] {
    	$w.frame0.text tag add t_underline $idx $idx+[string length $item]c
    }
    $w.frame0.text see $idx
}

bind $w.frame2.list <ButtonRelease-3> {
    set item [selection get]
    set idx [lsearch [$w.frame2.list get 0 end] $item]
    $w.frame.list insert 0 $item 
    $w.frame2.list delete $idx
    $w.frame3.list delete 0 end

    txlate::map_clear $item
    txlate::localmap_clear $item
}

frame $w.frame3 -borderwidth 10
pack $w.frame3 -side right -expand yes -fill y

scrollbar $w.frame3.scroll -command "$w.frame3.list yview"
listbox $w.frame3.list -yscroll "$w.frame3.scroll set" \
	-width 20 -height 16 -setgrid 1
pack $w.frame3.list $w.frame3.scroll -side left -fill y -expand 1

bind $w.frame3.list <ButtonRelease-1> {
    set item [selection get]
    # For some reason the search would not work... issue with unicode?
    # set idx [lsearch [$w.frame3.list get 0 end] $item]
    set idx 0
    foreach meaning [$w.frame3.list get 0 end] {
	if {[string first $item $meaning] == 0} {
    	    txlate::localmap_set $g_last_word $g_last_idx $idx
	    break
	}
	incr idx
    }
}
