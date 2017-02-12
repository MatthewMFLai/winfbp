TCL =
RM = rm
target: port.tcl portgrp.tcl block.tcl 

port.tcl : port.dat
	$(TCL) $(PATTERN_HOME)/genclass.tcl port.dat

portgrp.tcl : portgrp.dat
	$(TCL) $(PATTERN_HOME)/genclass.tcl portgrp.dat

block.tcl : block.dat
	$(TCL) $(PATTERN_HOME)/genclass.tcl block.dat

clean :
	$(RM) port.tcl portgrp.tcl block.tcl 
