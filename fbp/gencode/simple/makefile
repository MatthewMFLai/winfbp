TCL =
RM = rm
corepanel : byPort.tcl byPortgrp.tcl byBlock.tcl 

byPort.tcl : $(FBP_HOME)/dat/port.tcl
	$(TCL) $(PATTERN_HOME)/genPattern.tcl $(FBP_HOME)/dat/port byPort

byPortgrp.tcl : $(FBP_HOME)/dat/portgrp.tcl
	$(TCL) $(PATTERN_HOME)/genPattern.tcl $(FBP_HOME)/dat/portgrp byPortgrp

byBlock.tcl : $(FBP_HOME)/dat/block.tcl
	$(TCL) $(PATTERN_HOME)/genPattern.tcl $(FBP_HOME)/dat/block byBlock

clean :
	$(RM) byPort.tcl byPortgrp.tcl byBlock.tcl 
