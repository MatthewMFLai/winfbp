# Copyright (C) 2016-2017 by Matthew Lai, email : mmlai@sympatico.ca
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

# This module requires phantomjs to be installed in the windows pc and
# phantomjs to be defined in the system path environment variable.

namespace eval PhantomjsUrl {
    # mode can be one of NORMAL, READ_CACHE, SAVE_CACHE, CACHE_NORMAL
    variable m_mode
    variable m_cachedir

proc geturl {url} {
	# Search for the line
	# var url = 'http://www.tmxmoney.com...';
	set searchstr "var url = '"
	set strlen [string length $searchstr]
	set idx [string first $searchstr $url]
	if {$idx != -1} {
		incr idx $strlen
		set idx2 [string first "'" $url $idx]
		incr idx2 -1
		set url [string range $url $idx $idx2]
	} else {
		set url "defaultfilename"
	}
	return $url
}

proc getit {query} {
    global env
	
    set url [geturl $query]
	set idx [string last "#" $url]
	incr idx
	set group [string range $url $idx end]
	
	# Multiple instances of getphantomjsurl script may be running concurrently
	# and may cause some problem in some platforms!
	# We use a simple server socket as a makeshift monitor to serialize the
	# phantomjs execution here.
	# Loop with 10 seconds wait interval, for a max of 300 seconds.
	set cnt 30
	set interval 10000
	while {$cnt} {
		if {[catch {socket -server localhost 18000} sockfd]} {
			incr cnt -1
		} else {
			break
		}
		after $interval
	}
	if {!$cnt} {
		return ""
	}
	
	set tmpjsfile $env(DISK2)/scratchpad/scrape_$group.js
	set fd [open $tmpjsfile w]
	puts $fd $query
	close $fd
	set data [exec $env(PHANTOMJS)/phantomjs $tmpjsfile]
	file delete $tmpjsfile
	
	# Release server socket.
	close $sockfd

	return $data
}

proc url_to_filename {url} {

	set url [geturl $url]
    regsub "http://" $url "" url
    regsub -all "/" $url "%" url 
    regsub -all {\?} $url "%%" url 
    regsub -all "\&" $url "%%%" url
    regsub -all "=" $url "%%%%" url
    regsub -all {\*} $url "%%%%%" url 
    return $url
}

proc init {{mode NORMAL}} {
    variable m_mode
    variable m_cachedir
    global env

    if {$mode == "NORMAL" ||
	$mode == "CACHE_NORMAL" ||
	$mode == "READ_CACHE" ||
	$mode == "SAVE_CACHE"} {
    	set m_mode $mode
    } else {
		set m_mode "NORMAL"
		puts "Url:: mode $mode not recognized, default to NORMAL"
    }
    set m_cachedir "$env(WEB_DRIVER_HOME)/cache"
    return    
}
proc init_cachedir {cachedir} {
    variable m_cachedir

    if {[file isdirectory $cachedir]} {
		set m_cachedir $cachedir
    }
    return   
}

proc get_no_retry_NORMAL {query} {
    if { [catch {getit $query} token] } {
		set res "geturl: $token"
    } else {
    	set res $token
    }
    return $res
}

proc get_no_retry_SAVE_CACHE {query} {
    variable m_cachedir
    global env 

    if { [catch {getit $query} token] } {
       set res "geturl: $token"
     } else {
    	set res $token
    	set filename [url_to_filename $query]
    	set fd [open $m_cachedir/$filename w]
    	puts $fd $res
    	close $fd
    }
    return $res
}

proc get_no_retry_READ_CACHE {query} {
    variable m_cachedir

    set res ""
    set filename [url_to_filename $query]
    if {[file exists $m_cachedir/$filename]} {
	set fd [open $m_cachedir/$filename r]
    	set res [read $fd]
    	close $fd
    } else {
	# Return error code value 1
	return -code 1 $query
    }
    return $res
}

proc get_no_retry_CACHE_NORMAL {query} {
    variable m_cachedir

    set res ""
    set filename [url_to_filename $query]
    if {[file exists $m_cachedir/$filename]} {
    	set fd [open $m_cachedir/$filename r]
    	set res [read $fd]
    	close $fd
    } else {
    	set res [getit $query]
    }
    return $res
}

proc get_no_retry {query} {
    variable m_mode

    return [get_no_retry_$m_mode $query]
}

proc get_NORMAL {query} {
    set count 180
    while {$count > 0} {
    	if { [catch {getit $query} token] } {
   	    set res "geturl: $token"
	    puts "count: $count"
   	    incr count -1
            after 10000
		} else {
			set res $token
			return $res
		}
    }
    return $res
}

proc get_SAVE_CACHE {query} {
    variable m_cachedir

    set count 180
    while {$count > 0} {
    	if { [catch {getit $query} token] } {
   	    set res "geturl: $token"
	    puts "count: $count"
   	    incr count -1
            after 10000
		} else {
			set res $token
			set filename [url_to_filename $query]
			set fd [open $m_cachedir/$filename w]
			puts $fd $res
			close $fd
			return $res
		}
    }
    return $res
}

proc get_READ_CACHE {query} {
    return [get_no_retry_READ_CACHE $query] 
}

proc get_CACHE_NORMAL {query} {
    return [get_no_retry_CACHE_NORMAL $query] 
}

proc get {query} {
    variable m_mode

    return [get_$m_mode $query]
}
}

