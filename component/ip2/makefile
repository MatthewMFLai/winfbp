ip : byList.tcl byGroup.tcl byRetry.tcl byOrder.tcl

byList.tcl : ${PATTERN_HOME}/list.tcl
	${PATTERN_HOME}/genPattern.tcl ${PATTERN_HOME}/list byList

byGroup.tcl : ${PATTERN_HOME}/group.tcl
	${PATTERN_HOME}/genPattern.tcl ${PATTERN_HOME}/group byGroup

byRetry.tcl : ${PATTERN_HOME}/retry.tcl
	${PATTERN_HOME}/genPattern.tcl ${PATTERN_HOME}/retry byRetry

byOrder.tcl : ${PATTERN_HOME}/order.tcl
	${PATTERN_HOME}/genPattern.tcl ${PATTERN_HOME}/order byOrder

clean :
	rm byList.tcl byGroup.tcl byRetry.tcl byOrder.tcl
