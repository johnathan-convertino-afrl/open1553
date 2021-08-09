# UTIL DAC SWITCH
## SWITCH BETWEEN DIFF AND DMA FOR DAC
---

   author: Jay Convertino  
   
   date: 2021.08.05   
   
   details: Simple mux to switch between DAC and dma.  
   
   license: MIT   
   
---

![rtl_img](./rtl.png)

### IP USAGE
#### Parameters

* BYTE_WIDTH : How many bytes wide the data in/out will be.

### COMPONENTS
#### SRC

* util_dac_switch.v
  
#### TB

* tb_dac_switch.v

### Makefile

* Capable of generating simulations and ip cores for the project.

#### Usage

##### Icarus

* make icarus      - Generate project using Icarus.
* make icarus_sim  - Simulate project using Icarus.
* make icarus_view - Open GTKwave to view simulation.

##### XSim (Vivado)

* make xsim      - Generate Vivado project for simulation.
* make xsim_view - Open Vivado to run simulation.
* make xsim_sim  - Run xsim for a certain amount of time.
  * STOP_TIME ... argument can be passed to change time that the simulation stops (+1000ns, default vivado run time).
  * TB_ARCH ... argument can be passed to change the target configuration for simulation.
* make xsim_gtkwave_view - Use gtkwave to view vcd dump file.

##### IP Core (Vivado)

* make - Create Packaged IP core for Vivado, also builds all sims.

