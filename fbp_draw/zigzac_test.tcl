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
# contents of .c
draw rectangle 313.0 26.0 361.0 78.0 -fill white -tags {system3161 mv}
draw rectangle 16.0 19.0 64.0 71.0 -fill white -tags {system6584 mv}
draw rectangle 37.0 134.0 85.0 186.0 -fill white -tags {system4746 mv}
draw rectangle 162.0 40.0 210.0 92.0 -fill white -tags {system6853 mv}
draw rectangle 241.0 149.0 289.0 201.0 -fill white -tags {system276 mv}
draw text 244.0 149.0 -anchor nw -font fontBold -tags {system276 BLOCK mv} -text cloner
draw text 244.0 164.0 -anchor nw -fill red -font fontNormal -tags {system276 system276:INPORT:1 PORT mv} -text {1     }
draw text 278.0 164.0 -anchor nw -fill blue -font fontNormal -justify right -tags {system276 system276:OUTPORT:1 PORT mv} -text 1
draw text 278.0 184.0 -anchor nw -fill blue -font fontNormal -justify right -tags {system276 system276:OUTPORT:2 PORT mv} -text 2
draw line 241.0 164.0 289.0 164.0 -tags {system276 mv}
draw text 165.0 40.0 -anchor nw -font fontBold -tags {system6853 BLOCK mv} -text cloner
draw text 165.0 55.0 -anchor nw -fill red -font fontNormal -tags {system6853 system6853:INPORT:1 PORT mv} -text {1     }
draw text 199.0 55.0 -anchor nw -fill blue -font fontNormal -justify right -tags {system6853 system6853:OUTPORT:1 PORT mv} -text 1
draw text 199.0 75.0 -anchor nw -fill blue -font fontNormal -justify right -tags {system6853 system6853:OUTPORT:2 PORT mv} -text 2
draw line 162.0 55.0 210.0 55.0 -tags {system6853 mv}
draw text 40.0 134.0 -anchor nw -font fontBold -tags {system4746 BLOCK mv} -text cloner
draw text 40.0 149.0 -anchor nw -fill red -font fontNormal -tags {system4746 system4746:INPORT:1 PORT mv} -text {1     }
draw text 74.0 149.0 -anchor nw -fill blue -font fontNormal -justify right -tags {system4746 system4746:OUTPORT:1 PORT mv} -text 1
draw text 74.0 169.0 -anchor nw -fill blue -font fontNormal -justify right -tags {system4746 system4746:OUTPORT:2 PORT mv} -text 2
draw line 37.0 149.0 85.0 149.0 -tags {system4746 mv}
draw text 19.0 19.0 -anchor nw -font fontBold -tags {system6584 BLOCK mv} -text cloner
draw text 19.0 34.0 -anchor nw -fill red -font fontNormal -tags {system6584 system6584:INPORT:1 PORT mv} -text {1     }
draw text 53.0 34.0 -anchor nw -fill blue -font fontNormal -justify right -tags {system6584 system6584:OUTPORT:1 PORT mv} -text 1
draw text 53.0 54.0 -anchor nw -fill blue -font fontNormal -justify right -tags {system6584 system6584:OUTPORT:2 PORT mv} -text 2
draw line 16.0 34.0 64.0 34.0 -tags {system6584 mv}
draw text 316.0 26.0 -anchor nw -font fontBold -tags {system3161 BLOCK mv} -text cloner
draw text 316.0 41.0 -anchor nw -fill red -font fontNormal -tags {system3161 system3161:INPORT:1 PORT mv} -text {1     }
draw text 350.0 41.0 -anchor nw -fill blue -font fontNormal -justify right -tags {system3161 system3161:OUTPORT:1 PORT mv} -text 1
draw text 350.0 61.0 -anchor nw -fill blue -font fontNormal -justify right -tags {system3161 system3161:OUTPORT:2 PORT mv} -text 2
draw line 313.0 41.0 361.0 41.0 -tags {system3161 mv}
draw line 357.0 67.5 345.0 160.0 243.0 170.5 -tags {edge system3161:OUTPORT:2%system276:INPORT:1}
draw polygon 348.0 160.0 345.0 157.0 342.0 160.0 345.0 163.0 -tags bendtag
draw line 251.0 161.0 243.0 170.5 252.0 178.0 -tags {deco edge system3161:OUTPORT:2%system276:INPORT:1}
draw line 285.0 190.5 346.0 207.0 315.0 47.5 -tags {edge system276:OUTPORT:2%system3161:INPORT:1}
draw polygon 349.0 207.0 346.0 204.0 343.0 207.0 346.0 210.0 -tags bendtag
draw line 325.0 54.0 315.0 47.5 308.0 57.0 -tags {deco edge system276:OUTPORT:2%system3161:INPORT:1}
draw line 60.0 60.5 179.0 177.0 243.0 170.5 -tags {edge system6584:OUTPORT:2%system276:INPORT:1}
draw polygon 182.0 177.0 179.0 174.0 176.0 177.0 179.0 180.0 -tags bendtag
draw line 235.0 180.0 243.0 170.5 234.0 163.0 -tags {deco edge system6584:OUTPORT:2%system276:INPORT:1}
draw line 357.0 47.5 242.0 116.0 18.0 40.5 -tags {edge system3161:OUTPORT:1%system6584:INPORT:1}
draw polygon 245.0 116.0 242.0 113.0 239.0 116.0 242.0 119.0 -tags bendtag
draw line 29.0 35.0 18.0 40.5 23.0 51.0 -tags {deco edge system3161:OUTPORT:1%system6584:INPORT:1}
draw line 206.0 61.5 275.0 16.0 315.0 47.5 -tags {edge system6853:OUTPORT:1%system3161:INPORT:1}
draw polygon 278.0 16.0 275.0 13.0 272.0 16.0 275.0 19.0 -tags bendtag
draw line 303.0 49.0 315.0 47.5 314.0 36.0 -tags {deco edge system6853:OUTPORT:1%system3161:INPORT:1}
draw line 60.0 40.5 100.0 17.0 164.0 61.5 -tags {edge system6584:OUTPORT:1%system6853:INPORT:1}
draw polygon 103.0 17.0 100.0 14.0 97.0 17.0 100.0 20.0 -tags bendtag
draw line 152.0 64.0 164.0 61.5 162.0 50.0 -tags {deco edge system6584:OUTPORT:1%system6853:INPORT:1}
draw line 285.0 170.5 172.0 234.0 39.0 155.5 -tags {edge system276:OUTPORT:1%system4746:INPORT:1}
draw polygon 175.0 234.0 172.0 231.0 169.0 234.0 172.0 237.0 -tags bendtag
draw line 51.0 153.0 39.0 155.5 42.0 167.0 -tags {deco edge system276:OUTPORT:1%system4746:INPORT:1}
draw line 81.0 175.5 20.0 214.0 1.0 131.0 18.0 40.5 -tags {edge system4746:OUTPORT:2%system6584:INPORT:1}
draw polygon 23.0 214.0 20.0 211.0 17.0 214.0 20.0 217.0 -tags bendtag
draw polygon 4.0 131.0 1.0 128.0 -2.0 131.0 1.0 134.0 -tags bendtag
draw line 25.0 50.0 18.0 40.5 8.0 47.0 -tags {deco edge system4746:OUTPORT:2%system6584:INPORT:1}
draw line 206.0 81.5 196.0 143.0 39.0 155.5 -tags {edge system6853:OUTPORT:2%system4746:INPORT:1}
draw polygon 199.0 143.0 196.0 140.0 193.0 143.0 196.0 146.0 -tags bendtag
draw line 47.0 146.0 39.0 155.5 48.0 163.0 -tags {deco edge system6853:OUTPORT:2%system4746:INPORT:1}
draw line 81.0 155.5 131.0 129.0 164.0 61.5 -tags {edge system4746:OUTPORT:1%system6853:INPORT:1}
draw polygon 134.0 129.0 131.0 126.0 128.0 129.0 131.0 132.0 -tags bendtag
draw line 168.0 73.0 164.0 61.5 153.0 65.0 -tags {deco edge system4746:OUTPORT:1%system6853:INPORT:1}

array set m_block "system3161,ipaddr {} system3161,init {} system6584,outports {1 2} system6853,kicker {} system6584,kicker {} system276,filename cloner system4746,ipaddr {} system4746,init {} system3161,inports 1 system6853,ipaddr {} system6853,init {} system6584,init {} system6584,ipaddr {} system276,filepath {\$env(DISK2)/component/basic/cloner} system4746,inports 1 system3161,filename cloner system6853,timeout 0 system276,timeout 0 system4746,filename cloner system6584,inports 1 system6853,filename cloner system276,outports {1 2} system276,kicker {} system6584,filename cloner system3161,filepath {\$env(DISK2)/component/basic/cloner} system4746,filepath {\$env(DISK2)/component/basic/cloner} system3161,timeout 0 system6853,filepath {\$env(DISK2)/component/basic/cloner} system276,ipaddr {} system276,init {} system3161,outports {1 2} system4746,timeout 0 system6584,filepath {\$env(DISK2)/component/basic/cloner} system3161,kicker {} system6853,inports 1 system4746,outports {1 2} system276,inports 1 system6853,outports {1 2} system4746,kicker {} system6584,timeout 0"

