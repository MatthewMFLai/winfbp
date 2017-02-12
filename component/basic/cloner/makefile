TCL = tclsh
NODE = cloner
NODEDIR = cloner
TARGETDIR = /tmp/node/basic
PREFIX = /basic/cloner
ENVAR = FACTORY
release:
	$(TCL) $(PATTERN_HOME)/gen_release_node.tcl $(NODE).tcl $(NODE).tcl.new 
	$(TCL) $(PATTERN_HOME)/gen_release_dir.tcl $(TARGETDIR)
	rsync -Cav ../$(NODEDIR) $(TARGETDIR)
	$(TCL) $(PATTERN_HOME)/update_blk_file.tcl $(TARGETDIR)/$(NODEDIR) filepath blk $(PREFIX) $(ENVAR) 
	mv $(TARGETDIR)/$(NODEDIR)/$(NODE).tcl.new $(TARGETDIR)/$(NODEDIR)/$(NODE).tcl
	rm $(TARGETDIR)/$(NODEDIR)/makefile
	rm $(NODE).tcl.new

clean :
	rm -rf $(TARGETDIR)/$(NODEDIR)
