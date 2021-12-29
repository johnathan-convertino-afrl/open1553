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
  struct s_threadData *p_threadData = NULL;
  
  char *p_fileBuffer = NULL;
  
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
  
  p_fileBuffer = malloc(p_threadData.chunkSize);
  
  if(!p_fileBuffer)
  {
    perror("Could not allocate buffer.\n");
    return NULL;
  }
  
  do
  {
    int numElemRead = 0;
    int numElemWrote = 0;
    
    numElemRead = read(p_threadData.fileDescriptor, p_fileBuffer, p_threadData.chunkSize);
    
    if(numElemRead <= 0) continue;

    do
    {
      numElemWrote += ringBufferBlockingWrite(p_threadData->p_ringBufferPri, p_fileBuffer + numElemWrote, numElemRead - numElemWrote, NULL);
    } while(numElemWrote < numElemRead);
    
  } while((numElemRead == 0) && ringBufferStillBlocking(p_threadData->p_ringBufferPri));
  
  ringBufferEndBlocking(p_ringBuffer);
  
  free(p_fileBuffer);
  
  return NULL;
}

/* write file thread */
void *writeFileThread(void *data)
{
  struct s_threadData *p_threadData = NULL;
  
  char *p_fileBuffer = NULL;
  
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
  
  p_fileBuffer = malloc(p_threadData.chunkSize);
  
  if(!p_fileBuffer)
  {
    perror("Could not allocate buffer.\n");
    return NULL;
  }
  
  do
  {
    int numElemRead = 0;
    int numElemWrote = 0;
    
    numElemRead = ringBufferBlockingRead(p_threadData->p_ringBufferPri, p_fileBuffer, p_threadData.chunkSize, NULL);

    do
    {
      int sent = 0;
      
      sent = write(p_threadData.fileDescriptor, p_fileBuffer, p_threadData.chunkSize);
      
      numEleWrote += ( sent > 0) ? sent : 0;
      
    } while(numElemRead < numElemWrote);

  } while(ringBufferStillBlocking(p_threadData->p_ringBufferPri) || getRingBufferReadByteSize(p_threadData->p_ringBufferPri));
  
  free(p_fileBuffer);
  
  return NULL;
}

/* remote terminal thread */
void *remoteTerminalThread(void *data)
{
  int recvCount = 0;
  int boolRTaddrOK = 0;
  uint8_t  dataCount = 0;
  uint16_t storedData[MAX_1553_DATA] = {0};
  
  char *p_deviceBuffer = NULL;
  
  union u_commandPacket commandPacket;
  
  union u_statusPacket statusPacket;
  
  struct s_device *p_deviceOpts = NULL;
  
  p_deviceOpts = (struct s_device *)data;
  
  
  
  if(p_deviceOpts < 0)
  {
    fprintf(stderr, "Data pointer is NULL.\n");
    return NULL;
  }
  
  p_deviceBuffer = malloc(LEN_1553_STRING+1);
  
  if(!p_deviceBuffer)
  {
    perror("Could not allocate internal buffer.");
    return NULL;
  }
  
  memset(p_deviceBuffer, '\0', LEN_1553_STRING+1);
  
  statusPacket.data = 0;
  commandPacket.data = 0;
  
  statusPacket.bit.rtAddress  = p_deviceOpts->address;
  commandPacket.bit.rtAddress = 0;
  
  do
  {
    int numElemRead = 0;
    int numElemWrote = 0;
    uint16_t packetData = 0;
    
    char statusString[LEN_1553_STRING+1] = {'\0'};

    /* read till we get all of the elements needed*/
    do
    {
      int received = 0;
      
      received = read(p_deviceOpts->discriptor, &p_deviceBuffer[numElemRead], LEN_1553_STRING - numElemRead);
      
      numElemRead += (received > 0) ? received : 0;
         
    } while ((LEN_1553_STRING - numElemRead) > 0);
    
    /* convert hex data */
    packetData = (uint16_t)strtol(&p_deviceBuffer[16], NULL, 16);
    
    if(!strncmp(p_deviceBuffer, "CMDS", 4))
    {
      commandPacket.data = packetData;
      
      statusPacket.bit.mesgError = 0;
      
      recvCount = 0;
      
      /* check if data is addressed to us */
      if((commandPacket.bit.rtAddress == p_deviceOpts->address) || (commandPacket.bit.rtAddress == ~0))
      {
        /* recv only for this remote terminal, it will not transmit, only status messages at end of data transmissions */
        boolRTaddrOK = ~commandPacket.bit.TR;
      }
      
      dataCount = (commandPacket.bit.count != 0) ? commandPacket.bit.count : 32;
      //command process
      //do not write packet data from commands or status
      continue;
    }
    
    /* PARITY CHECK */
    if(!strncmp(&p_deviceBuffer[9], "P0", 2))
    {
      statusPacket.bit.mesgError = 1;
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
        ringBufferBlockingWrite(p_ringBuffer, storedData, recvCount, NULL);
        
        boolRTaddrOK = 0;
        recvCount    = 0;
        
        sprintf(statusString, "CMDS;D1;P1;I0;Hx%04X\r", statusPacket.data);
        
        printf("STATUS STRING: %s\n", statusString);
        
        sleep(1);
        //fix hangup
        do
        {
          int sent = 0;
          
          sent = write(p_deviceOpts->discriptor, &statusString[numElemWrote], LEN_1553_STRING - numElemWrote);
          
          numElemWrote += (sent > 0) ? sent : 0;
          
        } while(numElemWrote < LEN_1553_STRING);
        
        printf("STATUS STRING WROTE\n");
      }
    }

  } while(ringBufferStillBlocking(p_ringBuffer));
  
  ringBufferEndBlocking(p_ringBuffer);
  
  free(p_deviceBuffer);
  
  return NULL;
}

/* bus controller thread */
void *busControllerThread(void *data)
{
  char *p_dataBuffer = NULL;
  
  union u_commandPacket commandPacket;
  
  union u_statusPacket statusPacket;
  
  struct s_device *p_deviceOpts = NULL;
  
  p_deviceOpts = (struct s_device *)data;
  
  if(!p_deviceOpts)
  {
    fprintf(stderr, "Data pointer is NULL.\n");
    return NULL;
  }
  
  p_dataBuffer = malloc(MAX_1553_DATA*2);
  
  if(!p_dataBuffer)
  {
    perror("Could not allocate internal buffer.");
    return NULL;
  }
  
  statusPacket.data = 0;
  commandPacket.data = 0;
  
  statusPacket.bit.rtAddress  = 0;
  commandPacket.bit.rtAddress = p_deviceOpts->address;
  commandPacket.bit.TR = 0; //rt should receive packets of data, not transmit 

  do
  {
    int numElemRead = 0;
    int numElemWrote = -2; //eat the first 2 written for command packet (index backoff)
    int received = 0;
    int totalReceived = 0;
    uint16_t packetData = 0;
    
    char outputString[LEN_1553_STRING+1] = {'\0'};
    char statusString[LEN_1553_STRING+1] = {'\0'};
    
    if(commandPacket.bit.count == 0)
    {
      memset(p_dataBuffer, 0, MAX_1553_DATA*2);
      
      numElemRead = ringBufferBlockingRead(p_ringBuffer, p_dataBuffer, MAX_1553_DATA*2, NULL);
      
      if(numElemRead == 0) continue;
      // send command packet
      commandPacket.bit.count = (uint16_t)(numElemRead + 1)/2; //32 and higher will be 0, 11111 should be 31... should be perfect.
    }
    
    sprintf(outputString, "CMDS;D0;P1;I0;Hx%04X\r", commandPacket.data);
    
    // enter data loop
    // send out 64 bytes of data (32 2 byte words).
    do
    {
      int sent = 0;
      int totalSent = 0;
      
      do
      {
        sent = write(p_deviceOpts->discriptor, &outputString[totalSent], LEN_1553_STRING - totalSent);
        
        totalSent += (sent > 0) ? sent : 0;
        
      } while(totalSent < LEN_1553_STRING);
      
      numElemWrote += 2;
      
      sprintf(outputString, "DATA;D0;P1;I0;Hx%02X%02X\r", (uint8_t)p_dataBuffer[numElemWrote],  (uint8_t)p_dataBuffer[numElemWrote+1]);
      
    // keep looping till all data from numElemRead sent
    } while(numElemWrote < numElemRead);
    
    // once looping is done, wait for a status response from RT
    do
    {
      received += read(p_deviceOpts->discriptor, &statusString[totalReceived], LEN_1553_STRING - totalReceived);
      
      totalReceived += (received > 0) ? received : 0;
      
    } while (totalReceived < LEN_1553_STRING);
    
    packetData = (uint16_t)strtol(&statusString[16], NULL, 16);
    
    // do something with the response
    if(!strncmp(statusString, "CMDS", 4))
    {
      /* PARITY CHECK */
      if(!strncmp(&statusString[9], "P1", 2))
      {
        statusPacket.data = packetData;
        
        if((statusPacket.bit.rtAddress == commandPacket.bit.rtAddress) && !statusPacket.bit.msgError)
        {
          /* reset count, if its not reset we resend the data */
          commandPacket.bit.count = 0;
        }
      }
    }
  } while(ringBufferStillBlocking(p_ringBuffer) || getRingBufferReadByteSize(p_ringBuffer));
  
  ringBufferEndBlocking(p_ringBuffer);
  
  free(p_dataBuffer);
  
  //SEND TERMINATION TO REMOTE TERMINAL
  
  return NULL;
}
