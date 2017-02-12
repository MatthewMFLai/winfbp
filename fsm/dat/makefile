TCL =
RM = rm
target: fsm.tcl link.tcl node.tcl 

fsm.tcl : fsm.dat
	$(TCL) $(PATTERN_HOME)/genclass.tcl fsm.dat

link.tcl : link.dat
	$(TCL) $(PATTERN_HOME)/genclass.tcl link.dat

node.tcl : node.dat
	$(TCL) $(PATTERN_HOME)/genclass.tcl node.dat

clean :
	$(RM) fsm.tcl link.tcl node.tcl 
