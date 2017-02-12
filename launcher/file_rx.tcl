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
#!/bin/sh 
# \
exec tclsh $0 $@
    # This is server.tcl.

    # This is a model implementation of file-copying through Tcl's [socket]
    #    facilities.  What follows is the server process, which receives
    #    files through network connections, and deposits them in
    #    $destination_directory.

    # A production version of this model would probably expose parameters,
    #    handle exceptions more gracefully, consider security, and so on.
    #    The purpose of this code is primarily pedagogic.

        # You might want this to come from a command-line argument,
        #    or environment variable, or even let the clients pass
        #    it in.
    set destination_directory /tmp

        # A command-line argument is probably a good way to specify this.
    set service_port 8000 

    proc receive_file {channel_name client_address client_port} {
        fconfigure $channel_name -translation binary
        gets $channel_name line
        foreach {name size} $line {}

        set fully_qualified_filename [file join $::destination_directory $name]
        set fp [open $fully_qualified_filename w]
        fconfigure $fp -translation binary

        fcopy $channel_name $fp -size $size

        close $channel_name
        close $fp
    }

    socket -server receive_file $service_port

    vwait forever

