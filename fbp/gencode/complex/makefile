TCL =
RM = rm
corepanel : byVport_Port.tcl byBlock_InPort.tcl byBlock_OutPort.tcl byMain_Block.tcl byBlock_Subcircuit.tcl byBlock_Portgrp.tcl byPortgrp_Port.tcl byInPort_OutPort.tcl 

byVport_Port.tcl : $(PATTERN_HOME)/pointer.tcl
	$(TCL) $(PATTERN_HOME)/genPattern.tcl $(PATTERN_HOME)/pointer byVport_Port

byBlock_InPort.tcl : $(PATTERN_HOME)/assoc.tcl
	$(TCL) $(PATTERN_HOME)/genPattern.tcl $(PATTERN_HOME)/assoc byBlock_InPort

byBlock_OutPort.tcl : $(PATTERN_HOME)/assoc.tcl
	$(TCL) $(PATTERN_HOME)/genPattern.tcl $(PATTERN_HOME)/assoc byBlock_OutPort

byMain_Block.tcl : $(PATTERN_HOME)/assoc.tcl
	$(TCL) $(PATTERN_HOME)/genPattern.tcl $(PATTERN_HOME)/assoc byMain_Block

byBlock_Subcircuit.tcl : $(PATTERN_HOME)/assoc.tcl
	$(TCL) $(PATTERN_HOME)/genPattern.tcl $(PATTERN_HOME)/assoc byBlock_Subcircuit

byBlock_Portgrp.tcl : $(PATTERN_HOME)/assoc.tcl
	$(TCL) $(PATTERN_HOME)/genPattern.tcl $(PATTERN_HOME)/assoc byBlock_Portgrp

byPortgrp_Port.tcl : $(PATTERN_HOME)/assoc.tcl
	$(TCL) $(PATTERN_HOME)/genPattern.tcl $(PATTERN_HOME)/assoc byPortgrp_Port

byInPort_OutPort.tcl : $(PATTERN_HOME)/lattice.tcl
	$(TCL) $(PATTERN_HOME)/genPattern.tcl $(PATTERN_HOME)/lattice byInPort_OutPort

clean :
	$(RM) byVport_Port.tcl byBlock_InPort.tcl byBlock_OutPort.tcl byMain_Block.tcl byBlock_Subcircuit.tcl byBlock_Portgrp.tcl byPortgrp_Port.tcl byInPort_OutPort.tcl 
