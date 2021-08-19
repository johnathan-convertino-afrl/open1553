#!/usr/bin/env python
################################################################################
## @file    fifo1553_client.py
## @author  Jay Convertino
## @date    2021.08.17
## @brief   Receive data from server and save to file. ONLY WORKS IN PYTHON 2
################################################################################

import argparse

## Argument parser, port is the only one that has to be specified
argParser = argparse.ArgumentParser(description="Send data to a Xilinx AXIS FIFO using open1553 string format")
argParser.add_argument('fifoname',    type=str, help="Axis FIFO to use for the connection")
argParser.add_argument('--filename',  type=str, default='file.raw', help="File to save data to. This will be a binary file.")

## Parse all arguments and then get the values.
args = argParser.parse_args()

fifoname  = args.fifoname
filename  = args.filename

#open file
try:
  dfile = open(filename, 'ab')
except IOError:
  print("\b\bCan not open file " + filename)
  close()
  
#open fifo
try:
  dfifo = open(fifoname, "r+b", buffering=0)
except IOError:
  print("\b\bCan not open fifo " + fifoname)
  close()

print("Connecting to Server.")

dfifo.write("CMDS;D1;P1;I0;HxBEEF\r".decode('utf-8'))

#wait for server to accept
while True:
  try:
    commands = dfifo.read(21)
  except IOError:
    print("No data to read, trying to connect again.")
    dfifo.write("CMDS;D1;P1;I0;HxBEEF\r".decode('utf-8'))
  else:
    cmdsString = commands.decode("utf-8")
    
    if("CMDS;" in cmdsString and "HxBABE" in cmdsString and "P1" in cmdsString):
      print("Server connected, receiving data.")
      break

#receive data
while True:
  # loop all data
  try:
    data = dfifo.read(21)
  except IOError:
    dfifo.write("CMDS;D1;P1;I0;HxFEED\r".decode('utf-8'))
  else:
    cmdsString = data.decode("utf-8")
    
    if("CMDS;" in cmdsString and "HxDEAD" in cmdsString and "P1" in cmdsString):
      dfifo.write("CMDS;D1;P1;I0;HxCACA\r".decode('utf-8'))
      print("Transfer finished, exiting.")
      break
    
    dataSplit = data.split(';')
    
    if(dataSplit[2] == "P0"):
      print("Data parity check failed, written anyways.")
    
    dfile.write(bytearray.fromhex(dataSplit[4][2:6]))

dfile.flush()
dfile.close()
dfifo.close()
