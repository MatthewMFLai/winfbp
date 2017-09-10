# DYNAMIC SOURCE BEGIN
foreach filename [glob $env(CONTENT_HOME)/gencode/simple/*.tcl] {
    source $filename
}
# DYNAMIC SOURCE END
# DYNAMIC SOURCE BEGIN
foreach filename [glob $env(CONTENT_HOME)/gencode/complex/*.tcl] {
    source $filename
}
# DYNAMIC SOURCE END
# DYNAMIC SOURCE BEGIN
foreach filename [glob $env(CONTENT_HOME)/gencode/dynamic_type/*.tcl] {
    source $filename
}
# DYNAMIC SOURCE END

namespace eval Content {

    variable m_content
    variable m_debug

proc get_stop {paragraph} {

    set idxlist ""
    set idx [string first "." $paragraph]
    if {$idx > -1} {
	lappend idxlist $idx
    } 
    set idx [string first "!" $paragraph]
    if {$idx > -1} {
	lappend idxlist $idx
    } 
    set idx [string first "?" $paragraph]
    if {$idx > -1} {
	lappend idxlist $idx
    }
    set idxlist [lsort -integer $idxlist]

    if {$idxlist != ""} {
	set idx [lindex $idxlist 0]

	# To handle case like "abc !"
	incr idx
	if {[string index $paragraph $idx] != "\""} {
	    incr idx -1
	}
    } else {
	set idx -1
    }
    return $idx  
}

proc get_sentences {paragraph} {
    set rc ""

    set idx [get_stop $paragraph]
    while {$idx > -1} {
	lappend rc [string trim [string range $paragraph 0 $idx]]
	incr idx
	set paragraph [string range $paragraph $idx end]
  	set idx [get_stop $paragraph]
    }
    return $rc  
}

proc get_words {sentence} {
    set rc ""

    set sentence [string trim $sentence]
    regsub -all "\"" $sentence "" sentence 
    foreach word $sentence {
	if {[string is alpha $word]} {
	    lappend rc $word
	} else {
	    # Check each character and eliminate the non-alphabets.
	    set newword ""
	    foreach char [split $word ""] {
	    	if {[string is alpha $char]} {
		    append newword $char
		}
	    }
	    lappend rc $newword
	} 
    }
    return $rc 
}

proc fetch_word {word} {
    variable m_content

    set p_word [byAllWords::get_part $m_content $word]
    if {![Assert::Check $p_word]} {
	set p_word [malloc::getmem]
	Assert::Assert $p_word
	init_Word $p_word
	byAllWords::set_key $p_word $word
	byAllWords::add_part $m_content $p_word
    }
    return $p_word	 
}
  
# The wordlist must have the format of list of lists i.e.
# {Words} {connect} {Words} {connect} ... {connect} {Words}
# The minimal sentence is {Words} {connect} {Words} 
proc process_sentence {title wordlist level} {
    variable m_content

    set p_title [byTitle::get_part $m_content $title]
    Assert::Assert $p_title

    set p_prev_word [fetch_word [lindex $wordlist 0]]
    set wordlist [lrange $wordlist 1 end]
    set p_cur_word NULL
    set p_connect NULL
    set is_word 0 
    foreach token $wordlist {
	if {$is_word} {
	    set is_word 0
	    set p_cur_word [fetch_word $token]
	    # Add the graph connection.
	    byConnect::graph_add_edge $p_prev_word $p_cur_word $p_connect
	    set p_prev_word $p_cur_word 

	} else {
	    set is_word 1
	    set p_connect [malloc::getmem]
	    Assert::Assert $p_connect
	    init_Connect $p_connect
	    byText::set_text $p_connect $token
	    set p_parent [byTokens::get_end_node $p_title [expr $level - 1]]
	    Assert::Assert $p_parent
    	    byTokens::add_node $p_parent $p_connect
	}
    }
    return
}

proc Add_Token {title text level} {
    variable m_content

    set p_title [byTitle::get_part $m_content $title]
    Assert::Assert $p_title

    set p_parent $p_title
    if {$level > 1} {
	incr level -1
    	set p_parent [byTokens::get_end_node $p_title $level]
	Assert::Assert $p_parent
    }
    set p_token [malloc::getmem]
    init_Token $p_token
    byText::set_text $p_token $text
    byTokens::add_node $p_parent $p_token
}

proc Display_All_Token {title depth} {
    variable m_content

    set p_title [byTitle::get_part $m_content $title]
    Assert::Assert $p_title

    set level_prev 0 
    set line ""
    foreach pair [byTokens::traverse_depth_first $p_title 0] {
	set p_token [lindex $pair 0]
	set level [lindex $pair 1]
	if {$level < [expr $depth + 1]} {
	    set data [byText::get_text $p_token]
	    if {$level_prev == $level} {
		append line " $data"
		continue
	    }
	    set line [string trim $line]
	    if {[string length $line]} {
	    	puts $line
	    }
	    puts "" 
	    set line $data
	    set level_prev $level
	}
    }
    if {$line != ""} {
	puts $line
    }
    return
}
 
proc Get_All_Token {title depth} {
    variable m_content

    set rc ""
    set p_title [byTitle::get_part $m_content $title]
    if {![Assert::Check $p_title]} {
	return $rc
    }

    set level_prev 0 
    set line ""
    foreach pair [byTokens::traverse_depth_first $p_title 0] {
	set p_token [lindex $pair 0]
	set level [lindex $pair 1]
	if {$level < [expr $depth + 1]} {
	    set data [byText::get_text $p_token]
	    if {$level_prev == $level} {
		append line " $data"
		continue
	    }
	    set line [string trim $line]
	    if {[string length $line]} {
	    	lappend rc $line
	    }
	    set line $data
	    set level_prev $level
	}
    }
    if {$line != ""} {
	lappend rc $line
    }
    return $rc
}

proc Add_Title_Author {title author} {
    variable m_content

    set p_title [byTitle::get_part $m_content $title]
    if {![Assert::Check $p_title]} {
    	set p_author [byAuthor::get_part $m_content $author]
	if {![Assert::Check $p_author]} {
	    set p_author [malloc::getmem]
	    Assert::Assert $p_author
	    init_Author $p_author
	    byText::set_text $p_author $author
	    byAuthor::set_key $p_author $author
	    byAuthor::add_part $m_content $p_author
	}

	set p_title [malloc::getmem]
	Assert::Assert $p_title
	init_Title $p_title
	byText::set_text $p_title $title
	byTitle::set_key $p_title $title
	byTitle::add_part $m_content $p_title

	byAuthor_Title::set_key $p_title $title
	byAuthor_Title::add_part $p_author $p_title
    }
    return
}
  
proc Add_Paragraph {line depth title} {

    Add_Token $title "" $depth
    foreach sentence [get_sentences $line] {
	Add_Token $title $sentence [expr $depth + 1] 
	process_sentence $title [get_words $sentence] [expr $depth + 2] 
    }
    return
}

proc Init {{debug 0}} {

    variable m_content
    variable m_debug

    # Initiailize the main object first.
    set m_content [malloc::getmem]
    set m_debug $debug
    init_ContentMain $m_content
    return
}

proc Dump {} {
    variable m_content

    return
}

proc Save {filename} {
    variable m_content
    variable m_debug
    malloc::set_var fsm_var $m_content
    malloc::set_var fsm_debug $m_debug
    #malloc::save $filename
}

proc Load {filename} {
    variable m_content
    variable m_debug
    #malloc::restore $filename
    set m_content [malloc::get_var fsm_var]
    set m_debug [malloc::get_var fsm_debug]
}

}
