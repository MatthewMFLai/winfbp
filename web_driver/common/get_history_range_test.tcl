# Copyright (C) 2018 by Matthew Lai, email : mmlai@sympatico.ca
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
exec tclsh $0 "$@"

#-------------------------------------------------------
lappend auto_path $env(DISK2)/tclkit/modules
package require Mk4tcl
source db_if.tcl
source $env(DISK2)/web_driver/common/get_history_range.tcl
source $env(WEB_DRIVER_HOME)/common/history_range.tcl

set dbpath $env(DISK2_DATA)/scratchpad/db/db
db_if::Init $dbpath
#-------------------------------------------------------

# cd C:/winfbp/web_driver/common
# tclsh get_history_range_test.tcl close 1.00 1.00 history_range.cfg date 2017-01-01 2018-02-09 stock_history.dat

set column [lindex $argv 0]
set ref_value_limit [lindex $argv 1]
set value_limit [lindex $argv 2]
set cfgfile [lindex $argv 3]
set column_date [lindex $argv 4]
set min_date [lindex $argv 5]
set max_date [lindex $argv 6]
set outfile [lindex $argv 7]

gen_history_range $column $ref_value_limit $value_limit $cfgfile $column_date $min_date $max_date $outfile
db_if::Shutdown
exit 0

