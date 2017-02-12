TCL =
RM = rm
corepanel : byState.tcl byFSMs.tcl byCurNode.tcl byTransition.tcl 

byState.tcl : $(PATTERN_HOME)/assoc.tcl
	$(TCL) $(PATTERN_HOME)/genPattern.tcl $(PATTERN_HOME)/assoc byState

byFSMs.tcl : $(PATTERN_HOME)/assoc.tcl
	$(TCL) $(PATTERN_HOME)/genPattern.tcl $(PATTERN_HOME)/assoc byFSMs

byCurNode.tcl : $(PATTERN_HOME)/pointer.tcl
	$(TCL) $(PATTERN_HOME)/genPattern.tcl $(PATTERN_HOME)/pointer byCurNode

byTransition.tcl : $(PATTERN_HOME)/graph.tcl
	$(TCL) $(PATTERN_HOME)/genPattern.tcl $(PATTERN_HOME)/graph byTransition

clean :
	$(RM) byState.tcl byFSMs.tcl byCurNode.tcl byTransition.tcl 
