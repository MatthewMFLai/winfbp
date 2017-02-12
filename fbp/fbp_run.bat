tclsh %FBP_HOME%/fbp_test.tcl %1 %2 s0 8000
tclsh %FBP_HOME%/fbp_postproc.tcl task.out
tclsh %FBP_HOME%/gen_task_graph.tcl %1 %2 task.dot
dot -Tpdf task.dot -o task.pdf
