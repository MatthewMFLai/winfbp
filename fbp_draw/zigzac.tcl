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
 #!/usr/bin/wish8.5
 # This code is in the public domain. Use, enjoy.

namespace eval zig {
    variable m_lastx
    variable m_lasty
    variable m_dot_line_map

proc init {} {
    variable m_lastx
    variable m_lasty
    variable m_dot_line_map

    set m_lastx 0
    set m_lasty 0
    array set m_dot_line_map {}
    return
}

 # Draw a decoration on a vertex
 # All of them have the tag "bendtag"
 proc dot {c x y line_id} {
     variable m_dot_line_map
     set id [$c create polygon [expr {$x + 3}] $y $x [expr {$y - 3}] \
       [expr {$x - 3}] $y $x [expr {$y + 3}] \
       -outline "" -fill "" -tags bendtag]
     set m_dot_line_map($id) $line_id
     return
 }
 
 
 # Find point on segment (p--q) nearest to (xp,yp).
 # Return (xxp yyp, d) where (xxp, yyp) are the coords of this
 # nearest point and d is the distance to the segment.
 proc prox-seg {px py qx qy rx ry} {
   set ux [expr { $qx - $px }]
   set uy [expr { $qy - $py }]
   set vx [expr { $rx - $px }]
   set vy [expr { $ry - $py }]
   set u [expr { hypot($ux, $uy) }]
   set v [expr { hypot($vx, $vy) }]
   # c is the relative position of this point on the segment
   # (0 --> p, 1 --> q, i.e. c < 0  or c > 1 means point is
   # outisde the segment)
   set c [expr {($ux * $vx + $uy * $vy) / ($u * $u)}]
   # if we clamp it to [0,1] we'll never lie outside the segment:
   set c  [expr {$c<0 ? 0 : $c>1 ? 1 : $c}]
   set wx [expr { $ux * $c }]
   set wy [expr { $uy * $c }]
   set d  [expr { hypot($vx - $wx, $vy - $wy) }]
   return [list [expr {$px + $wx}] [expr {$py + $wy}] $c $d]
 }
 
 # Find the point on (multi-)line nearest to given x y
 # Return coords of point, segment number (0..n-1), relative pos
 # whithin that segment and distance to that segment 
 # Note that this gets inaccurate when the nearest point is near
 # the beginning or end of the line: we don't mind, because we
 # just trigger "near" the line
 proc prox-line {c line x y} {
   set nseg -1
   foreach {qx qy} [$c coords $line] {
     if {[info locals px] != ""} { # else we are first time here
       # Current segment is p--q
       set thisseg [prox-seg $px $py $qx $qy $x $y]
       set dist [lindex $thisseg 3]
       if { [info locals mindist] == "" ||
            ( $dist < $mindist && [lindex $thisseg 2] >=0
              && [lindex $thisseg 2] <=1 ) } {
         set minseg  $thisseg
         set mindist $dist
         set minnseg $nseg
       }
     }
     set px $qx
     set py $qy
     incr nseg
   }
   return [list [lindex $minseg 0] [lindex $minseg 1] $minnseg \
           [lindex $minseg 2] [lindex $minseg 3]]
 }
 
 # return no [0..n] of line's vertex next to x y
 proc findvertex {c line x y} {
   set n 0
   foreach {vx vy} [$c coords $line] {
     set d [expr {hypot($x - $vx, $y - $vy)}]
     if {[info locals dmin] == "" || $d  < $dmin} {
       set dmin $d
       set nmin $n
     }
     incr n
   }
   return $nmin
 }
 
 # Add a vertex to zigzag nearest to x y
 proc zig {c x y} {
   variable m_dot_line_map
   set line_id [$c find closest $x $y]
   set pos [prox-line $c $line_id $x $y]
   $c insert $line_id [expr {2 * (1 + [lindex $pos 2])}] [list $x $y]
   dot $c $x $y $line_id
   drag-start $c $x $y
 }
 
 # Dragging vertices (ripped off Tk demo). Three procs manage the dragging
 proc drag-start {c x y} {
   variable m_lastx
   variable m_lasty
   puts [$c find withtag bendtag]
   # Find out which decoration item(s) to drag
   set decolist {}
   foreach it [$c find closest $x $y] {
     puts "$it: [$c gettags $it]"
     if {[lsearch -all -exact -inline [$c gettags $it] bendtag] ne ""} {
         lappend decolist $it
     }
   }
   puts $decolist
   bind $c <B1-Motion> [list zig::dragging %W $decolist %x %y]
   bind $c <ButtonRelease-1> [list zig::drag-end %W %x %y]
   set m_lastx $x
   set m_lasty $y
 }
 
 proc dragging {c it x y} {
   variable m_lastx
   variable m_lasty
   variable m_dot_line_map

   if {$it == ""} {
       return
   }
   set line_id $m_dot_line_map($it)
   $c move $it [expr $x - $m_lastx]  [expr $y - $m_lasty]
   #set v [expr {2 * [findvertex $zigzag(1) $lastx $lasty]}]
   set v [expr {2 * [findvertex $c $line_id $m_lastx $m_lasty]}]
   # insert before v, delete after newly inserted:
   $c insert $line_id $v [list $x $y]
   $c dchars $line_id [expr {$v + 2}] [expr {$v + 3}]
   set m_lastx $x
   set m_lasty $y
 }
 
 proc drag-end {c x y} {
   bind $c <ButtonRelease-1> {}
   bind $c <B1-Motion> {}
 }
}

