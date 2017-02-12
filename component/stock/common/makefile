TCL = tclsh
NODE = common
NODEDIR = common
TARGETDIR = /tmp/node/stock
PREFIX = /stock/common
ENVAR = FACTORY
release:
	$(TCL) $(PATTERN_HOME)/gen_common_sources.tcl symbolpage fundamental financials dividend hp optionlist options table dummy 
	$(TCL) $(PATTERN_HOME)/gen_merged_file.tcl dummy $(NODE).tcl dummy2 
	$(TCL) $(PATTERN_HOME)/gen_release_node.tcl dummy2 $(NODE).tcl.new
	rm dummy dummy2
	$(TCL) $(PATTERN_HOME)/gen_release_dir.tcl $(TARGETDIR)
	rsync -Cav ../$(NODEDIR) $(TARGETDIR) 
	$(TCL) $(PATTERN_HOME)/update_blk_file.tcl $(TARGETDIR)/$(NODEDIR) filepath blk $(PREFIX) $(ENVAR) 
	mv $(TARGETDIR)/$(NODEDIR)/$(NODE).tcl.new $(TARGETDIR)/$(NODEDIR)/$(NODE).tcl
	rm $(TARGETDIR)/$(NODEDIR)/makefile
	rm $(NODE).tcl.new

clean :
	rm -rf $(TARGETDIR)/$(NODEDIR)
