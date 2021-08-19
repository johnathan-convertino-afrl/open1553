#!/usr/bin/env python
################################################################################
## @file    uart1553_server.py
## @author  Jay Convertino
## @date    2021.08.17
## @brief   Send data from file to client.
## @warning Not sure what will happen with odd bit sizes... will they span? 
################################################################################

import serial
import argparse

## Argument parser, port is the only one that has to be specified
argParser = argparse.ArgumentParser(description="Send data to a serial port using open1553 string format")
argParser.add_argument('port',        type=str, help="Serial port to use for the connection")
argParser.add_argument('--baud',      type=int, default=2000000, help="Optional argument to set port rate... default: 2000000")
argParser.add_argument('--parity',    type=str, default='NONE', choices=['NONE', 'EVEN', 'ODD', 'MARK', 'SPACE'], help="Parity bit for the serial connection... default NONE")
argParser.add_argument('--stopbits',  type=str, default='ONE', choices=['ONE', 'ONE_POINT_FIVE', 'TWO'], help="Number of stop bits for the serial connection... default ONE")
argParser.add_argument('--bytesize',  type=str, default='EIGHT', choices=['FIVE', 'SIX', 'SEVEN', 'EIGHT'], help="Number of data bits... default EIGHT")
argParser.add_argument('--filename',  type=str, default='file.raw', help="What data file to send over UART. This will be a binary file.")

## Parse all arguments and then get the values.
args = argParser.parse_args()

port      = args.port
baud      = args.baud
parity    = 'PARITY_' + args.parity
stopbits  = 'STOPBITS_' + args.stopbits
bytesize  = args.bytesize + 'BITS'
filename  = args.filename

#open file
try:
  dfile = open(filename, 'rb')
except IOError:
  print("\b\bCan not open file" + filename)
  close()

# test of serial interface
serialDev = serial.Serial(port=args.port, baudrate=args.baud, parity=getattr(serial, parity),stopbits=getattr(serial, stopbits), bytesize=getattr(serial, bytesize))

# check if we are open, linux does this when call the interface. Meaning
# opening again fails.
if(not serialDev.isOpen()):
  print("Opening serial port...")
  serialDev.open()

print("Waiting for receiver to connect.")

#wait for receiver to connect
while True:
  commands = serialDev.read_until('\r'.encode('utf-8'))
  cmdsString = commands.decode("utf-8")
  
  #print(serialDev.read())
  
  if("CMDS;" in cmdsString and "HxBEEF" in cmdsString and "P1" in cmdsString):
    print("Receiver connected, transferring data.")
    serialDev.write(('CMDS;D1;P1;I0;HxBABE\r').encode('utf-8'))
    break

print("Sending data to " + args.port)

#preload buffer
data = dfile.read(1024) #1KB

#keep sending data till we run out
while data:
  # loop all data
  for i in range(0, len(data), 2):
    serialDev.write(('DATA;D1;P1;I0;Hx' + data[i:i+2].hex() + '\r').encode('utf-8'))
    
  data = dfile.read(1024) #1KB
  
  #wait for receiver to respond
  while True:
    commands = serialDev.read_until('\r'.encode('utf-8'))
    cmdsString = commands.decode("utf-8")
    
    if("CMDS;" in cmdsString and "HxFEED" in cmdsString and "P1" in cmdsString):
      break

#wait for receiver ask for feed
while True:
  commands = serialDev.read_until('\r'.encode('utf-8'))
  cmdsString = commands.decode("utf-8")
  
  if("CMDS;" in cmdsString and "HxFEED" in cmdsString and "P1" in cmdsString):
    serialDev.write(('CMDS;D1;P1;I0;HxDEAD\r').encode('utf-8'))
    
  if("CMDS;" in cmdsString and "HxCACA" in cmdsString and "P1" in cmdsString):
    print("Server Exiting")
    break

dfile.close()
serialDev.close()
