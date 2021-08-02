
# FMC1553 HDL reference design

## Overview

Currently supported carriers:

|  Carrier name | FMC connector |
| ------------- | ------------- |
|  ZCU102       |   HPC0        |

## TODO

* Add 1553 decoder core before DMA (Partial Reconfig?). Alternative is a software solution.

## Bugs

* Sometimes SPI init of the AD9694 comes up with bad address and fails. Restart is required. 
This is due to the 100k resistors missing from the other side of the SPI voltage converter bridge chip.
