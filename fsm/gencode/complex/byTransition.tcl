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
namespace eval byTransition {
# Substitue <graph> with the name of the
# pattern instance.
# Substitue <vertex> and <edge> with the
# names of the application structures.
proc graph_add_edge {p_vertex_from  p_vertex_to p_edge} {
    upvar #0 $p_vertex_from vertex_from
    upvar #0 $p_vertex_to vertex_to
    upvar #0 $p_edge edge

    set edge(graph:byTransition:from_vertex) $p_vertex_from
    set edge(graph:byTransition:to_vertex) $p_vertex_to
    lappend vertex_from(graph:byTransition:from_edge_list) $p_edge
    lappend vertex_to(graph:byTransition:to_edge_list) $p_edge
}

proc graph_remove_edge {p_vertex_from p_vertex_to p_edge} {
    upvar #0 $p_vertex_from vertex_from
    upvar #0 $p_vertex_to vertex_to
    upvar #0 $p_edge edge

    # Robustness checks.
    if {$edge(graph:byTransition:from_vertex) != $p_vertex_from} {
        return -1
    }

    if {$edge(graph:byTransition:to_vertex) != $p_vertex_to} {
        return -2
    }

    set edge(graph:byTransition:from_vertex) ""
    set edge(graph:byTransition:to_vertex) ""
    set data $vertex_from(graph:byTransition:from_edge_list)
    set idx [lsearch $data $p_edge]
    if {$idx > -1} {
        set vertex_from(graph:byTransition:from_edge_list) [lreplace $data $idx $idx]
    } else {
        return -3
    }

    set data $vertex_to(graph:byTransition:to_edge_list)
    set idx [lsearch $data $p_edge]
    if {$idx > -1} {
        set vertex_to(graph:byTransition:to_edge_list) [lreplace $data $idx $idx]
    } else {
        return -4
    }

    return 0
}

proc graph_get_edge {p_vertex_from p_vertex_to} {
    upvar #0 $p_vertex_from vertex_from

    set rc ""
    set edgelist $vertex_from(graph:byTransition:from_edge_list)
    foreach p_edge $edgelist {
        upvar #0 $p_edge edge
        if {$edge(graph:byTransition:to_vertex) != $p_vertex_to} {
            continue
        }
        lappend rc $p_edge
    }
    return $rc
}

proc graph_get_vertex_from {p_edge} {
    upvar #0 $p_edge edge

    return $edge(graph:byTransition:from_vertex)
}

proc graph_get_vertex_to {p_edge} {
    upvar #0 $p_edge edge

    return $edge(graph:byTransition:to_vertex)
}

proc graph_get_from_iterator {p_vertex} {
    upvar #0 $p_vertex vertex

    return $vertex(graph:byTransition:from_edge_list)
}

proc graph_get_to_iterator {p_vertex} {
    upvar #0 $p_vertex vertex

    return $vertex(graph:byTransition:to_edge_list)
}

proc graph_init_edge {p_edge} {
    upvar #0 $p_edge edge
    set edge(graph:byTransition:from_vertex) ""
    set edge(graph:byTransition:to_vertex) ""
}

proc graph_init_vertex {p_vertex} {
    upvar #0 $p_vertex vertex
    set vertex(graph:byTransition:from_edge_list) ""
    set vertex(graph:byTransition:to_edge_list) ""
}

}

