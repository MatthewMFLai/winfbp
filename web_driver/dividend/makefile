TCL = tclsh
NODEDIR = dividend 
TARGETDIR = /tmp/node/stock/common/web_driver
release:
	$(TCL) $(PATTERN_HOME)/gen_release_dir.tcl $(TARGETDIR)/$(NODEDIR)
	rsync -Cav --include='*_fsm.dat' --include='*.template' --include='*.map' --exclude='*.*' --exclude='windows' --exclude='makefile' ../$(NODEDIR) $(TARGETDIR)

clean :
	rm -rf $(TARGETDIR)/$(NODEDIR)
