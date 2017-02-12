TCL = tclsh
NODEDIR = stock 
TARGETDIR = /tmp/node/stock/common/web_driver
release:
	$(TCL) $(PATTERN_HOME)/gen_release_dir.tcl $(TARGETDIR)/$(NODEDIR)
	rsync -Cav --include='*_rx.dat' --include='*.template' --exclude='*.*' --exclude='*err*' --exclude='windows' --exclude='makefile' ../$(NODEDIR) $(TARGETDIR)

clean :
	rm -rf $(TARGETDIR)/$(NODEDIR)
