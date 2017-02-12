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
namespace eval UtilTime {

variable m_holidaylist

proc Init {} {
    variable m_holidaylist

    set m_holidaylist ""
    lappend m_holidaylist "2011-01-01"
    lappend m_holidaylist "2011-04-22"
    lappend m_holidaylist "2011-05-23"
    lappend m_holidaylist "2011-07-01"
    lappend m_holidaylist "2011-08-01"
    lappend m_holidaylist "2011-09-05"
    lappend m_holidaylist "2011-10-10"
    lappend m_holidaylist "2011-12-25"
    lappend m_holidaylist "2011-12-26"
    lappend m_holidaylist "2012-01-01"
    lappend m_holidaylist "2012-02-20"
    lappend m_holidaylist "2012-04-06"
    lappend m_holidaylist "2012-05-21"
    lappend m_holidaylist "2012-07-01"
    lappend m_holidaylist "2012-08-06"
    lappend m_holidaylist "2012-09-03"
    lappend m_holidaylist "2012-10-08"
    lappend m_holidaylist "2012-12-25"
    lappend m_holidaylist "2012-12-26"
    lappend m_holidaylist "2013-01-01"
    lappend m_holidaylist "2013-02-18"
    lappend m_holidaylist "2013-03-29"
    lappend m_holidaylist "2013-05-20"
    lappend m_holidaylist "2013-07-01"
    lappend m_holidaylist "2013-09-02"
    lappend m_holidaylist "2013-10-14"
    lappend m_holidaylist "2013-12-25"
    lappend m_holidaylist "2013-12-26"
    lappend m_holidaylist "2014-2-17"
    lappend m_holidaylist "2014-4-18"
    lappend m_holidaylist "2014-5-19"
    lappend m_holidaylist "2014-7-1"
    lappend m_holidaylist "2014-8-4"
    lappend m_holidaylist "2014-9-1"
    lappend m_holidaylist "2014-10-13"
    lappend m_holidaylist "2014-12-25"
    lappend m_holidaylist "2014-12-26"

    return
}

proc GetDayofWeek {datestr p_day p_round} {
    upvar $p_day day
    upvar $p_round round    

    # datestr must be of format <yy>-<month>-<day>
    # eg. 2012-8-2
    if {[catch {clock format [clock scan $datestr] -format "%w"} day]} {
	return "Invalid $datestr"
    }
    # 1 => Mon, 2 => Tue,... 6 => Sat, 0 => Sun

    # Round is the nth Mon/Tue/.../Sun
    # Get the numeric day value and use modulo math to find the round.
    set day_val [lindex [split $datestr "-"] end]
    incr day_val -1
    set round [expr $day_val / 7]
    incr round
    return 0
}

proc GetDayStr {year month dayofweek round} {
    if {[catch {clock scan $year-$month-1}]} {
	return "Invalid $year $month"
    }
    set tmpdayofweek [clock format [clock scan $year-$month-1] -format "%w"]
    if {$dayofweek < $tmpdayofweek} {
	incr dayofweek 7
    }
    set day [expr 1 + $dayofweek - $tmpdayofweek]
    set day [expr ($day + (($round - 1)* 7))]
    return $year-$month-$day 
}

proc Convert {timestr} {
    # timestr should look like
    # Jul 31, 2012 or Jul 31 2012
    # or something like
    # Jul 01, 2012 or Jul 1, 2012
    return [clock scan $timestr]
}

proc Compare {timestr1 timestr2} {
    set diff [expr $timestr1 - $timestr2]
    if {$diff > 0} {
	return 1
    } elseif {$diff == 0} {
	return 0
    } else {
	return -1
    }
}

proc Convert_Month {monthstr} {
    return [string map {Jan 1 Feb 2 Mar 3 Apr 4 May 5 Jun 6 Jul 7 Aug 8 Sep 9 Oct 10 Nov 11 Dec 12} $monthstr]     
}

proc Is_Holiday {timestamp} {
    variable m_holidaylist

    set datestr [clock format $timestamp -format "%Y-%m-%d"]
    if {[lsearch $m_holidaylist $datestr] > -1} {
	return 1
    }
    return 0
}

proc Split_Years {from to p_data} {
    # Both from and to must be of the format "Dec 1, 2013" or
    # "12/01/2013".
    # If input is "Jul 1, 2012" to "Dec 1, 2012" then output is
    # data(2012) {07/01/2012 12/01/2012}
    # If input is "Jul 1, 2012" to "Jul 1, 2013" then output is
    # data(2012) {07/01/2012 12/31/2012}
    # data(2013) {01/01/2013 07/01/2013}
    # If input is "Jul 1, 2012" to "Jul 1, 2014" then output is
    # data(2012) {07/01/2012 12/31/2012}
    # data(2013) {01/01/2013 12/31/2013}
    # data(2014) {01/01/2014 07/01/2014}
    upvar $p_data data
    
    set from_year [clock format [clock scan $from] -format "%Y"]
    set to_year [clock format [clock scan $to] -format "%Y"]
    if {$from_year == $to_year} {
	set data($from_year) [list $from $to]
	return
    }
    set data($from_year) [list $from "12/31/$from_year"]
    set data($to_year) [list "01/01/$to_year" $to]
    incr from_year
    while {$from_year < $to_year} {
    	set data($from_year) [list "01/01/$from_year" "12/31/$from_year"]
	incr from_year
    }
    return
}

proc Dash_To_Abs {datestr} {
    # Argument string must be of the form <Month>-<Day>-<Year>
    # eg. Sep-23-2013
    set month [Convert_Month [lindex [split $datestr "-"] 0]]
    set day [lindex [split $datestr "-"] 1]
    set year [lindex [split $datestr "-"] 2]
    return [clock scan $month/$day/$year] 
}

proc Get_Today {} {
    return  [clock format [clock seconds] -format %D]
}

proc Get_Tomorrow {} {
    set timestamp [clock scan [clock format [clock seconds] -format %D]]
    set timestamp [expr ($timestamp + (24 * 3600))]
    return [clock format $timestamp -format %D]
}

proc Get_Seconds_to_Tomorrow {} {
    set cur_time [clock seconds]
    set new_time [clock scan [clock format $cur_time -format %D]]
    set new_time [expr ($new_time + (24 * 3600))]
    return [expr $new_time - $cur_time]
}

proc Datecmp {datestr datestr2} {
    set abstime [clock scan $datestr]
    set abstime2 [clock scan $datestr2]
    return [expr $abstime2 - $abstime]
}

}

