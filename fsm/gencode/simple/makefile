TCL =
RM = rm
corepanel : byFsm.tcl byLink.tcl byNode.tcl 

byFsm.tcl : $(FSM_HOME)/dat/fsm.tcl
	$(TCL) $(PATTERN_HOME)/genPattern.tcl $(FSM_HOME)/dat/fsm byFsm

byLink.tcl : $(FSM_HOME)/dat/link.tcl
	$(TCL) $(PATTERN_HOME)/genPattern.tcl $(FSM_HOME)/dat/link byLink

byNode.tcl : $(FSM_HOME)/dat/node.tcl
	$(TCL) $(PATTERN_HOME)/genPattern.tcl $(FSM_HOME)/dat/node byNode

clean :
	$(RM) byFsm.tcl byLink.tcl byNode.tcl 
