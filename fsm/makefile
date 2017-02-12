TCL = tclsh
target:
	$(TCL) $(SCDS_HOME)/scds_gen_test.tcl config.dat $(FSM_HOME) FSM_HOME
	make -C $(FSM_HOME)/dat
	make -C $(FSM_HOME)/gencode/simple
	make -C $(FSM_HOME)/gencode/complex

clean :
	make -C $(FSM_HOME)/dat clean
	make -C $(FSM_HOME)/gencode/simple clean
	make -C $(FSM_HOME)/gencode/complex clean
	$(TCL) $(SCDS_HOME)/scds_gen_test.tcl clean $(FSM_HOME)
