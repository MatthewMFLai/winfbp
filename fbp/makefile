TCL = tclsh
target:
	$(TCL) $(SCDS_HOME)/scds_gen_test.tcl config.dat $(FBP_HOME) FBP_HOME
	make -C $(FBP_HOME)/dat
	make -C $(FBP_HOME)/gencode/simple
	make -C $(FBP_HOME)/gencode/complex

clean :
	make -C $(FBP_HOME)/dat clean
	make -C $(FBP_HOME)/gencode/simple clean
	make -C $(FBP_HOME)/gencode/complex clean
	$(TCL) $(SCDS_HOME)/scds_gen_test.tcl clean $(FBP_HOME)
