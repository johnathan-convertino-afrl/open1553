set_false_path -from [get_cells -hier -filter {name =~ *control/head*      && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ *control/rd_head*    && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hier -filter {name =~ *control/tail*      && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ *control/wr_tail*    && IS_SEQUENTIAL}]

#set_false_path -from [get_cells -hier -filter {name =~ *control/r_head*    && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ *control/*rd_head*   && IS_SEQUENTIAL}]
#set_false_path -from [get_cells -hier -filter {name =~ *control/r_tail*    && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ *control/*wr_tail*   && IS_SEQUENTIAL}]
#set_false_path -from [get_cells -hier -filter {name =~ *control/r_gr_head* && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ *control/*rd_head*   && IS_SEQUENTIAL}]
#set_false_path -from [get_cells -hier -filter {name =~ *control/r_gr_tail* && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ *control/*wr_tail*   && IS_SEQUENTIAL}]
#set_false_path -from [get_cells -hier -filter {name =~ *control/r_head*    && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ *control/*dc_head*   && IS_SEQUENTIAL}]
#set_false_path -from [get_cells -hier -filter {name =~ *control/r_tail*    && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ *control/*dc_tail*   && IS_SEQUENTIAL}]
