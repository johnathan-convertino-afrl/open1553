/***************************************************************************//**
  * @brief    mil-std-1553 example threads
  * @details  pthreads for mil-std-1553 applications. 
  * @author   Jay Convertino
  * @date     2021.12.29
  * @version
  * see header
  * 
  * @license mit
  * 
  * Copyright 2021 Jay Convertino
  *
  * Permission is hereby granted, free of charge, to any person obtaining a copy
  * of this software and associated documentation files (the "Software"), to deal
  * in the Software without restriction, including without limitation the rights
  * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
  * copies of the Software, and to permit persons to whom the Software is 
  * furnished to do so, subject to the following conditions:
  * 
  * The above copyright notice and this permission notice shall be included in 
  * all copies or substantial portions of the Software.
  * 
  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
  * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
  * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
  * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
  * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
  * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  * IN THE SOFTWARE.
  *****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <mil1553threads.h>

/* read file thread */
void *readFileThread(void *data)
{
  int numElemRead = 0;
  
  struct s_threadData *p_threadData = NULL;
  
  char *p_dataBuffer = NULL;
  
  p_threadData = (struct s_threadData *)data;
  
  if(!p_threadData)
  {
    fprintf(stderr, "Data struct is NULL.\n");
    return NULL;
  }
  
  if(!p_threadData->p_ringBufferPri)
  {
    fprintf(stderr, "Primary ring buffer is NULL.\n");
    return NULL;
  }
  
  p_dataBuffer = malloc(p_threadData->chunkSize);
  
  if(!p_dataBuffer)
  {
    perror("Could not allocate buffer.\n");
    return NULL;
  }
  
  do
  {
    int numElemWrote = 0;
    
    numElemRead = 0;
    
    numElemRead = read(p_threadData->fileDescriptor, p_dataBuffer, p_threadData->chunkSize);
    
    if(numElemRead <= 0) continue;

    do
    {
      numElemWrote += ringBufferBlockingWrite(p_threadData->p_ringBufferPri, p_dataBuffer + numElemWrote, numElemRead - numElemWrote, NULL);
    } while(numElemWrote < numElemRead);
    
  } while((numElemRead == 0) && ringBufferStillBlocking(p_threadData->p_ringBufferPri));
  
  ringBufferEndBlocking(p_threadData->p_ringBufferPri);
  
  free(p_dataBuffer);
  
  return NULL;
}

/* write file thread */
void *writeFileThread(void *data)
{
  struct s_threadData *p_threadData = NULL;
  
  char *p_dataBuffer = NULL;
  
  p_threadData = (struct s_threadData *)data;
  
  if(!p_threadData)
  {
    fprintf(stderr, "Data struct is NULL.\n");
    return NULL;
  }
  
  if(!p_threadData->p_ringBufferPri)
  {
    fprintf(stderr, "Primary ring buffer is NULL.\n");
    return NULL;
  }
  
  p_dataBuffer = malloc(p_threadData->chunkSize);
  
  if(!p_dataBuffer)
  {
    perror("Could not allocate buffer.\n");
    return NULL;
  }
  
  do
  {
    int numElemRead = 0;
    int numElemWrote = 0;
    
    numElemRead = ringBufferBlockingRead(p_threadData->p_ringBufferPri, p_dataBuffer, p_threadData->chunkSize, NULL);

    do
    {
      int sent = 0;
      
      sent = write(p_threadData->fileDescriptor, p_dataBuffer, p_threadData->chunkSize);
      
      numElemWrote += ( sent > 0) ? sent : 0;
      
    } while(numElemRead < numElemWrote);

  } while(ringBufferStillBlocking(p_threadData->p_ringBufferPri) || getRingBufferReadByteSize(p_threadData->p_ringBufferPri));
  
  free(p_dataBuffer);
  
  return NULL;
}

/* remote terminal thread */
void *remoteTerminalThread(void *data)
{
  int recvCount = 0;
  int boolRTaddrOK = 0;
  uint8_t  dataCount = 0;
  
  uint16_t storedData[MAX_1553_DATA] = {0};
  
  union u_statusPacket  statusPacket  = {0};
  union u_commandPacket commandPacket = {0};
  
  char *p_dataBuffer = NULL;
  
  struct s_threadData *p_threadData = NULL;
  
  p_threadData = (struct s_threadData *)data;
  
  if(!p_threadData)
  {
    fprintf(stderr, "Data struct is NULL.\n");
    return NULL;
  }
  
  if(!p_threadData->p_ringBufferPri)
  {
    fprintf(stderr, "Primary ring buffer is NULL.\n");
    return NULL;
  }
  
  if(!p_threadData->p_ringBufferSec)
  {
    fprintf(stderr, "Secondary ring buffer is NULL.\n");
    return NULL;
  }
  
  if(!p_threadData->p_ringBufferAux)
  {
    fprintf(stderr, "Auxilary ring buffer is NULL.\n");
    return NULL;
  }
  
  p_dataBuffer = malloc(MIL_1553_STR_LEN+1);
  
  if(!p_dataBuffer)
  {
    perror("Could not allocate buffer.\n");
    return NULL;
  }
  
  memset(p_dataBuffer, '\0', MIL_1553_STR_LEN+1);
  
  statusPacket.data   = 0;
  commandPacket.data  = 0;
  
  statusPacket.bit.rtAddress  = p_threadData->address;
  commandPacket.bit.rtAddress = 0;
  
  do
  {
    int numElemRead = 0;
    int numElemWrote = 0;
    uint16_t packetData = 0;
    
    char statusString[MIL_1553_STR_LEN+1] = {'\0'};

    /* read till we get all of the elements needed */
    do
    {
      numElemRead += ringBufferBlockingRead(p_threadData->p_ringBufferPri, p_dataBuffer + numElemRead, MIL_1553_STR_LEN - numElemRead, NULL);
    } while ((MIL_1553_STR_LEN > numElemRead) && ringBufferStillBlocking(p_threadData->p_ringBufferPri));
    
    if(numElemRead == 0) continue;
    
    /* convert hex data */
    packetData = (uint16_t)strtol(&p_dataBuffer[16], NULL, 16);
    
    if(!strncmp(p_dataBuffer, "CMDS", 4))
    {
      commandPacket.data = packetData;
      
      statusPacket.bit.msgError = 0;
      
      recvCount = 0;
      
      /* check if data is addressed to us */
      if((commandPacket.bit.rtAddress == p_threadData->address) || (commandPacket.bit.rtAddress == ~0))
      {
        /* recv only for this remote terminal, it will not transmit, only status messages at end of data transmissions */
        boolRTaddrOK = ~commandPacket.bit.TR;
      }
      
      dataCount = (commandPacket.bit.count != 0) ? commandPacket.bit.count : 32;
      
      /* SPECIAL COMMAND PACKET, KILL PROGRAM */
      if(!strncmp(&p_dataBuffer[16], "DEAD", 4))
      {
        ringBufferEndBlocking(p_threadData->p_ringBufferPri);
      }
      
      /* do not write packet data from commands or status */
      continue;
    }
    
    /* PARITY CHECK */
    if(!strncmp(&p_dataBuffer[9], "P0", 2))
    {
      statusPacket.bit.msgError = 1;
    }
    
    printf("DATA Received %d %d %04x\n", recvCount, dataCount, packetData);
    
    if(boolRTaddrOK)
    {
      if(recvCount < dataCount)
      {
        storedData[recvCount] = packetData;
        recvCount++;
      }
      
      if(recvCount >= dataCount)
      {
        /* data into file writter for received data transfer */
        do
        {
          numElemWrote += ringBufferBlockingWrite(p_threadData->p_ringBufferSec, &storedData[numElemWrote], recvCount - numElemWrote, NULL);
        } while(recvCount > numElemWrote);
        
        printf("STATUS PACKET SENT WITH: %s\n", (statusPacket.bit.msgError ? "FAIL" : "OK"));
        
        numElemWrote = 0;
        boolRTaddrOK = 0;
        recvCount    = 0;
        
        sprintf(statusString, "CMDS;D1;P1;I0;Hx%04X\r", (uint16_t)statusPacket.data);
        
        /* send status string to device (file) writer */
        do
        {
          numElemWrote += ringBufferBlockingWrite(p_threadData->p_ringBufferAux, &statusString[numElemWrote], MIL_1553_STR_LEN - numElemWrote, NULL);
        } while(MIL_1553_STR_LEN > numElemWrote);
      }
    }

  } while(ringBufferStillBlocking(p_threadData->p_ringBufferPri) || getRingBufferReadByteSize(p_threadData->p_ringBufferPri));
  
  ringBufferEndBlocking(p_threadData->p_ringBufferSec);
  
  ringBufferEndBlocking(p_threadData->p_ringBufferAux);
  
  free(p_dataBuffer);
  
  return NULL;
}

/* bus controller thread */
void *busControllerThread(void *data)
{
  int sent = 0;
  
  char outputString[MIL_1553_STR_LEN+1] = {'\0'};
  
  union u_statusPacket  statusPacket  = {0};
  union u_commandPacket commandPacket = {0};
  
  char *p_dataBuffer = NULL;
  
  struct s_threadData *p_threadData = NULL;
  
  p_threadData = (struct s_threadData *)data;
  
  if(!p_threadData)
  {
    fprintf(stderr, "Data struct is NULL.\n");
    return NULL;
  }
  
  if(!p_threadData->p_ringBufferPri)
  {
    fprintf(stderr, "Primary ring buffer is NULL.\n");
    return NULL;
  }
  
  if(!p_threadData->p_ringBufferSec)
  {
    fprintf(stderr, "Secondary ring buffer is NULL.\n");
    return NULL;
  }
  
  if(!p_threadData->p_ringBufferAux)
  {
    fprintf(stderr, "Auxilary ring buffer is NULL.\n");
    return NULL;
  }
  
  p_dataBuffer = malloc(MAX_1553_DATA*2);
  
  if(!p_dataBuffer)
  {
    perror("Could not allocate buffer.\n");
    return NULL;
  }
  
  memset(p_dataBuffer, '\0', MAX_1553_DATA*2);
  
  statusPacket.data   = 0;
  commandPacket.data  = 0;
  
  statusPacket.bit.rtAddress  = 0;
  commandPacket.bit.rtAddress = p_threadData->address;
  commandPacket.bit.TR = 0;

  do
  {
    int numElemRead = 0;
    /* eat the first 2 written for command packet (index backoff) */
    int numElemWrote = -2;
    int totalReceived = 0;
    uint16_t packetData = 0;
    
    char statusString[MIL_1553_STR_LEN+1] = {'\0'};
    
    if(!statusPacket.bit.msgError)
    {
      memset(p_dataBuffer, 0, MAX_1553_DATA*2);
      
      /* read till we get all of the elements needed */
      do
      {
        numElemRead += ringBufferBlockingRead(p_threadData->p_ringBufferPri, p_dataBuffer + numElemRead, MAX_1553_DATA*2 - numElemRead, NULL);
      } while ((MAX_1553_DATA*2 > numElemRead) && (ringBufferStillBlocking(p_threadData->p_ringBufferPri)));
      
      if(numElemRead == 0) continue;
      /* 32 and higher will be 0, 11111 should be 31... should be perfect. */
      commandPacket.bit.count = (uint16_t)(numElemRead + 1)/2;
    }
    
    statusPacket.data = 0;
    
    /* send command packet */
    sprintf(outputString, "CMDS;D0;P1;I0;Hx%04X\r", (uint16_t)commandPacket.data);
    
    /* enter data loop */
    /* send out 64 bytes of data (32 2 byte words). */
    do
    {
      sent = 0;
      
      do
      {
        sent += ringBufferBlockingWrite(p_threadData->p_ringBufferSec, &outputString[sent], MIL_1553_STR_LEN - sent, NULL);
      } while(MIL_1553_STR_LEN > sent);
      
      numElemWrote += 2;
      
      sprintf(outputString, "DATA;D0;P1;I0;Hx%02X%02X\r", (uint8_t)p_dataBuffer[numElemWrote],  (uint8_t)p_dataBuffer[numElemWrote+1]);
      
    } while(numElemWrote < numElemRead);
    
    /* once looping is done, wait for a status response from RT */
    do
    {
      totalReceived += ringBufferBlockingRead(p_threadData->p_ringBufferAux, &statusString[totalReceived], MIL_1553_STR_LEN - totalReceived, NULL);
    } while (MIL_1553_STR_LEN > totalReceived);
    
    packetData = (uint16_t)strtol(&statusString[16], NULL, 16);
    
    /* do something with the response */
    if(!strncmp(statusString, "CMDS", 4))
    {
      /* PARITY CHECK */
      if(!strncmp(&statusString[9], "P1", 2))
      {
        statusPacket.data = packetData;
        
        if(statusPacket.bit.rtAddress == commandPacket.bit.rtAddress)
        {
          /* reset count, if its not reset we resend the data */
          printf("STATUS PACKET RECEIVED WITH: %s\n", (statusPacket.bit.msgError ? "FAIL" : "OK"));
        }
      }
    }
  } while(ringBufferStillBlocking(p_threadData->p_ringBufferPri) || getRingBufferReadByteSize(p_threadData->p_ringBufferPri));
  
  /* SEND TERMINATION TO REMOTE TERMINAL */
  sprintf(outputString, "CMDS;D0;P1;I0;HxDEAD\r");

  sent = 0;

  do
  {
    sent += ringBufferBlockingWrite(p_threadData->p_ringBufferSec, &outputString[sent], MIL_1553_STR_LEN - sent, NULL);
  } while(MIL_1553_STR_LEN > sent);
  
  ringBufferEndBlocking(p_threadData->p_ringBufferSec);
  
  ringBufferEndBlocking(p_threadData->p_ringBufferAux);
  
  free(p_dataBuffer);
  
  return NULL;
}
