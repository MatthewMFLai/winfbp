ip : malloc.tcl ip.tcl byMux.tcl

malloc.tcl : ${PATTERN_HOME}/malloc.tcl
	cp ${PATTERN_HOME}/malloc.tcl .

ip.tcl : ${PATTERN_HOME}/ip.tcl
	cp ${PATTERN_HOME}/ip.tcl .

byMux.tcl : ${PATTERN_HOME}/key_value.tcl
	${PATTERN_HOME}/genPattern.tcl ${PATTERN_HOME}/key_value byMux

clean :
	rm ip.tcl malloc.tcl byBall.tcl byMux.tcl
