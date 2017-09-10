TCL = tclsh
target:
	$(TCL) $(SCDS_HOME)/scds_gen_test.tcl config.dat $(QUICKTEST_HOME) QUICKTEST_HOME
	make -C $(QUICKTEST_HOME)/dat
	make -C $(QUICKTEST_HOME)/gencode/simple
	make -C $(QUICKTEST_HOME)/gencode/complex

clean :
	make -C $(QUICKTEST_HOME)/dat clean
	make -C $(QUICKTEST_HOME)/gencode/simple clean
	make -C $(QUICKTEST_HOME)/gencode/complex clean
	$(TCL) $(SCDS_HOME)/scds_gen_test.tcl clean $(QUICKTEST_HOME)
