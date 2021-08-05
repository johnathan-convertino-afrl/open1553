
# Configurable parameters

set SAMPLE_RATE_MHZ 500.0
set NUM_OF_CHANNELS 2            ; # M
set SAMPLES_PER_FRAME 1          ; # S
set NUM_OF_LANES 2               ; # L
set ADC_RESOLUTION 8             ; # N & NP

# Auto-computed parameters

set CHANNEL_DATA_WIDTH [expr 32 * $NUM_OF_LANES / $NUM_OF_CHANNELS]
set ADC_DATA_WIDTH [expr $CHANNEL_DATA_WIDTH * $NUM_OF_CHANNELS]
set DMA_DATA_WIDTH [expr $ADC_DATA_WIDTH < 128 ? $ADC_DATA_WIDTH : 128]
set SAMPLE_WIDTH [expr $ADC_RESOLUTION > 8 ? 16 : 8]

# source all the block designs
source $ad_hdl_dir/projects/common/zcu102/zcu102_system_bd.tcl
source ../common/adc_fmc1553_bd.tcl
source ../common/dac_fmc1553_bd.tcl
source ../common/fifo_1553_bd.tcl

#set_property strategy Performance_Explore [get_runs impl_1]
#set_property strategy Flow_PerfOptimized_high [get_runs synth_1]

# System ID instance and configuration
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "[pwd]/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9
set sys_cstring "sys rom custom string placeholder"
sysid_gen_sys_init_file $sys_cstring

