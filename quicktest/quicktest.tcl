#!/bin/sh
# \
exec tclsh $0 $@
source $env(PATTERN_HOME)/malloc.tcl
source $env(PATTERN_HOME)/assert.tcl

foreach filename [glob $env(QUICKTEST_HOME)/gencode/simple/*.tcl] {
    source $filename
}
foreach filename [glob $env(QUICKTEST_HOME)/gencode/complex/*.tcl] {
    source $filename
}
foreach filename [glob $env(QUICKTEST_HOME)/gencode/dynamic_type/*.tcl] {
    source $filename
}

malloc::init
Assert::Init

set p_root [malloc::getmem]
init_Token $p_root
byText::set_text $p_root "root"

set p_1_0 [malloc::getmem]
init_Token $p_1_0
byText::set_text $p_1_0 "Level 1, node 0"
byTokens::add_node $p_root $p_1_0

set p_1_1 [malloc::getmem]
init_Token $p_1_1
byText::set_text $p_1_1 "Level 1, node 1"
byTokens::add_node $p_root $p_1_1

set p_2_0 [malloc::getmem]
init_Token $p_2_0
byText::set_text $p_2_0 "Level 2, node 0"
byTokens::add_node $p_1_0 $p_2_0

set p_2_1 [malloc::getmem]
init_Token $p_2_1
byText::set_text $p_2_1 "Level 2, node 1"
byTokens::add_node $p_1_0 $p_2_1

set p_2_2 [malloc::getmem]
init_Token $p_2_2
byText::set_text $p_2_2 "Level 2, node 2"
byTokens::add_node $p_1_1 $p_2_2

set p_2_3 [malloc::getmem]
init_Token $p_2_3
byText::set_text $p_2_3 "Level 2, node 3"
byTokens::add_node $p_1_1 $p_2_3

#puts [byTokens::get_node_addr $p_2_0]
puts [byTokens::get_node $p_root "1 1"]
exit 0
