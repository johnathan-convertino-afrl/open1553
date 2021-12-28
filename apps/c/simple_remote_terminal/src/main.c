/*******************************************************************************
 * @file    main.c
 * @author  Jay Convertino
 * @date    2021.12.23
 * @brief   Simple MIL-STD-1553 Remote Terminal Emulator
 * @detail  Ladeda
 * 
 * @version 0.0
 * @TODO    TEST STATUS GEN AND CMD PARSER GET TO WORK WITH EMULATOR
 ******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>
#include <pthread.h>

#include "ringBuffer.h"

/* ring buffer size */
#define DATACHUNK (1 << 21)
/* ring buffer read size */
#define READ_BYTES (1 << 5)
/* open1553 string size with return */
#define LEN_1553_STRING (21)

/* Ringbuffer is a global structure for the two threads */
struct s_ringBuffer *p_ringBuffer = NULL;

/* Producer (MIL-STD-1553 COM) is in charge of communicating over the MIL-STD-1553 bus */
void *producer(void *data);
/* consumer(writer) simply takes any received data inserted to the ring buffer and writes it */
void *consumer(void *data);
/* help function to list arguments */
static void help();
/* help kill producer thread to exit application cleanly */
static void signalHandler(int signal);

/* struct to pass data to producer thread */
struct s_device
{
  int address;
  int discriptor;
};

/* move to header? */
union u_commandPacket
{
  struct
  {
    uint16_t count:5;
    uint16_t subMode:5;
    uint16_t TR:1;
    uint16_t rtAddress:5;
  } __attribute__((packed)) bit;
  
  uint16_t data;
};

/* move to header? */
union u_statusPacket
{
  struct
  {
    uint16_t termFlag:1;
    uint16_t dynaCtrl:1;
    uint16_t subsysFlag:1;
    uint16_t busy:1;
    uint16_t broadcastRECV:1;
    uint16_t reserved:3;
    uint16_t servReq:1;
    uint16_t inst:1;
    uint16_t mesgError:1;
    uint16_t rtAddress:5;
  } __attribute__((packed)) bit;
  
  uint16_t data;
};

/* Main oh wounderful main */
int main(int argc, char *argv[])
{
  /* variables */
  int error = 0;
  int opt = 0;
  
  /* allow CTRL+C to kill producer thread */
  signal(SIGINT,  signalHandler);
  signal(SIGTERM, signalHandler);
  signal(SIGQUIT, signalHandler);

  /* device name */
  char deviceName[256] = {"/dev/ttyUSB1"};
  
  /* file name */
  char outputFileName[256] = {"output.bin"};
  
  struct s_device deviceOpts = {0};
  
  /* threads */
  pthread_t producerThread;
  pthread_t consumerThread;
  
  /* output file */
  FILE *p_outFile = NULL;
  
  /* parse arguments */
  while((opt = getopt(argc, argv, "a:f:d:h")) != -1)
  {
    switch(opt)
    {
      case 'a':
        deviceOpts.address = atoi(optarg);
        break;
      case 'f':
        strcpy(outputFileName, optarg);
        break;
      case 'd':
        strcpy(deviceName, optarg);
        break;
      case 'h':
      default:
        help();
        return EXIT_SUCCESS;
    }
  }
  
  if(argc < 4)
  {
    help();
    return EXIT_SUCCESS;
  }
  
  /* open MIL-STD-1553 device that provides open1553 formatted strings */
  deviceOpts.discriptor = open(deviceName, O_RDWR | O_NONBLOCK);
  /* check for discriptor existance in the next two ifs, exit if they don't exist */
  if(deviceOpts.discriptor < 0)
  {
    perror("Could not open MIL-STD-1553 device.");

    return EXIT_FAILURE;
  }
  
  p_outFile = fopen(outputFileName, "w");
  
  if(!p_outFile)
  {
    perror("Could not open file for writing.");
    
    return EXIT_FAILURE;
  }
  
  printf("CREATING RING BUFFER\n");
  
  p_ringBuffer = initRingBuffer(DATACHUNK, 1);
  
  if(!p_ringBuffer)
  {
    fprintf(stderr, "Failed to create ring buffer.\n");
    
    fclose(p_outFile);
    close(deviceOpts.discriptor);
    
    return EXIT_FAILURE;
  }
  
  printf("CREATING MIL-STD-1553 COM THREAD\n");
  
  error = pthread_create(&producerThread, NULL, producer, &deviceOpts);
  
  if(error)
  {
    fprintf(stderr, "Failed to create MIL-STD-1553 COM thread.\n");
    
    fclose(p_outFile);
    close(deviceOpts.discriptor);
    
    freeRingBuffer(&p_ringBuffer);
    
    return EXIT_FAILURE;
  }
  
  printf("CREATING WRITER THREAD\n");
  
  error = pthread_create(&consumerThread, NULL, consumer, p_outFile);
  
  if(error)
  {
    fprintf(stderr, "Failed to create writer thread.\n");
    
    fclose(p_outFile);
    close(deviceOpts.discriptor);
    
    ringBufferEndBlocking(p_ringBuffer);
    
    pthread_join(producerThread, NULL);
    
    freeRingBuffer(&p_ringBuffer);
    
    return EXIT_FAILURE;
  }
  
  printf("THREADS CREATED, WAITING FOR MIL-STD-1553 TO TERMINATE\n");
  
  pthread_join(producerThread, NULL);
  
  printf("MIL-STD-1553 COM TERMINATED, WAITING FOR WRITER.\n");
  
  pthread_join(consumerThread, NULL);
  
  printf("WRITER JOINED, ENDING PROGRAM.\n");
  
  freeRingBuffer(&p_ringBuffer);
  
  fclose(p_outFile);
  close(deviceOpts.discriptor);
  
  return EXIT_SUCCESS;
}

/* respond to bus controller command, status and data packets */
void *producer(void *data)
{
  int recvCount = 0;
  int boolRTaddrOK = 0;
  
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
      numElemRead += read(p_deviceOpts->discriptor, &p_deviceBuffer[numElemRead], LEN_1553_STRING - numElemRead);
    } while ((LEN_1553_STRING - numElemRead) > 0);
    
    
    if(numElemRead <= 0) continue;
    
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
        printf("CMD Received\n");
      }
      //command process
      //do not write packet data from commands or status
      continue;
    }
    
    /* PARITY CHECK */
    if(!strncmp(&p_deviceBuffer[9], "P0", 2))
    {
      statusPacket.bit.mesgError = 1;
    }
    
    printf("DATA Received %d\n", recvCount);
    
    if(boolRTaddrOK)
    {
      if(recvCount < commandPacket.bit.count)
      {
        ringBufferBlockingWrite(p_ringBuffer, &packetData, 2, NULL);
        recvCount++;
      }
      
      if(recvCount >= commandPacket.bit.count)
      {
        boolRTaddrOK = 0;
        recvCount    = 0;
        
        sprintf(statusString, "CMDS;D0;P1;I0;Hx%04X\r", statusPacket.data);
        
        //fix hangup
        do
        {
          numElemWrote += write(p_deviceOpts->discriptor, &statusString[numElemWrote], LEN_1553_STRING - numElemWrote);
        } while((LEN_1553_STRING - numElemWrote) > 0);
      }
    }

  } while(ringBufferStillBlocking(p_ringBuffer));
  
  ringBufferEndBlocking(p_ringBuffer);
  
  free(p_deviceBuffer);
  
  return NULL;
}

/* writer for received 1553 data */
void *consumer(void *data)
{
  char *p_stringBuffer = NULL;
  
  FILE *p_outFile = NULL;
  
  p_outFile = (FILE *)data;
  
  if(!p_outFile)
  {
    fprintf(stderr, "Output file discriptor is NULL.\n");
    return NULL;
  }
  
  p_stringBuffer = malloc(READ_BYTES);
  
  if(!p_stringBuffer)
  {
    perror("Could not allocate internal buffer.");
    return NULL;
  }
  
  do
  {
    int numElemRead = 0;
    int numElemWrote = 0;
    
    numElemRead = ringBufferBlockingRead(p_ringBuffer, p_stringBuffer, READ_BYTES, NULL);

    do
    {
      numElemWrote += fwrite(p_stringBuffer + numElemWrote, sizeof(*p_stringBuffer), numElemRead - numElemWrote, p_outFile);
    } while(numElemRead < numElemWrote);

  } while(ringBufferStillBlocking(p_ringBuffer) || getRingBufferReadByteSize(p_ringBuffer));
  
  free(p_stringBuffer);
  
  return NULL;
}

static void help()
{
  printf("NOTHING AT THE MOMENT, -a -f -d\n");
}

static void signalHandler(int signal)
{
  switch(signal) 
  {
    case SIGINT:
    case SIGTERM:
    case SIGQUIT:
      /* Ending blocking will cause the logic of the producer to exit */
      printf("\nCTRL+C Caught Exiting application.\n");
      ringBufferEndBlocking(p_ringBuffer);
      break;
    default:
      break;
  }
}
