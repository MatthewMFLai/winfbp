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
proc loadit {crawler} {
    global env

    source $env(WEB_DRIVER)/$crawler/$crawler.tcl
    return
}

source $env(FSM_HOME)/fsm.tcl
source $env(PATTERN_HOME)/geturl.tcl
source $env(WEB_DRIVER)/financials/financials_fsm.tcl
source $env(WEB_DRIVER)/financials/company_fsm.tcl
source $env(WEB_DRIVER)/financials/symbol_filter.tcl

source $env(WEB_DRIVER)/fundamental/fundamental_fsm.tcl

source $env(WEB_DRIVER)/dividend/dividend_fsm.tcl

source $env(WEB_DRIVER)/options/options_fsm.tcl

source $env(WEB_DRIVER)/optionlist/optionlist_fsm.tcl

source $env(WEB_DRIVER)/symbolpage/symbolpage_fsm.tcl

source $env(WEB_DRIVER)/table/table_fsm.tcl

Url::init
Fsm::Init

Fsm::Load_Fsm $env(WEB_DRIVER)/financials/financials_fsm.dat
Fsm::Init_Fsm financials_fsm
Fsm::Set_State financials_fsm FIND_FINANCIALS

Fsm::Load_Fsm $env(WEB_DRIVER)/financials/company_fsm.dat
Fsm::Init_Fsm company_fsm
Fsm::Set_State company_fsm FIND_COMPANY

Fsm::Load_Fsm $env(WEB_DRIVER)/fundamental/fundamental_fsm.dat
Fsm::Init_Fsm fundamental_fsm
Fsm::Set_State fundamental_fsm FIND_CHANGE

Fsm::Load_Fsm $env(WEB_DRIVER)/dividend/dividend_fsm.dat
Fsm::Init_Fsm dividend_fsm
Fsm::Set_State dividend_fsm FIND_DIVIDEND

Fsm::Load_Fsm $env(WEB_DRIVER)/options/options_fsm.dat
Fsm::Init_Fsm options_fsm
Fsm::Set_State options_fsm FIND_CALLPUT

Fsm::Load_Fsm $env(WEB_DRIVER)/optionlist/optionlist_fsm.dat
Fsm::Init_Fsm optionlist_fsm
Fsm::Set_State optionlist_fsm FIND_TABLE

Fsm::Load_Fsm $env(WEB_DRIVER)/symbolpage/symbolpage_fsm.dat
Fsm::Init_Fsm symbolpage_fsm
Fsm::Set_State symbolpage_fsm FIND_PAGE

Fsm::Load_Fsm $env(WEB_DRIVER)/table/table_fsm.dat
Fsm::Init_Fsm table_fsm
Fsm::Set_State table_fsm FIND_TABLE
package require htmlparse

