/*******************************************************************************
 * @file    main.c
 * @author  Jay Convertino
 * @date    2021.12.23
 * @brief   Simple MIL-STD-1553 Bus Controller
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
#define LEN_1553_STRING 21
/* max 1553 data packets */
#define MAX_1553_DATA   32

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
    uint16_t msgError:1;
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
  int blocking = 0;
  
  /* allow CTRL+C to kill producer thread */
  signal(SIGINT,  signalHandler);
  signal(SIGTERM, signalHandler);
  signal(SIGQUIT, signalHandler);

  /* device name */
  char deviceName[256] = {"/dev/ttyUSB1"};
  
  /* file name */
  char inputFileName[256] = {"input.bin"};
  
  struct s_device deviceOpts = {0};
  
  /* threads */
  pthread_t producerThread;
  pthread_t consumerThread;
  
  /* output file */
  FILE *p_inFile = NULL;
  
  /* parse arguments */
  while((opt = getopt(argc, argv, "a:f:d:bh")) != -1)
  {
    switch(opt)
    {
      case 'a':
        deviceOpts.address = atoi(optarg);
        break;
      case 'f':
        strcpy(inputFileName, optarg);
        break;
      case 'd':
        strcpy(deviceName, optarg);
        break;
      case 'b':
        blocking = 1;
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
  deviceOpts.discriptor = open(deviceName, O_RDWR | (blocking ? 0 : O_NONBLOCK));
  /* check for discriptor existance in the next two ifs, exit if they don't exist */
  if(deviceOpts.discriptor < 0)
  {
    perror("Could not open MIL-STD-1553 device.");

    return EXIT_FAILURE;
  }
  
  p_inFile = fopen(inputFileName, "r");
  
  if(!p_inFile)
  {
    perror("Could not open file for reading.");
    
    return EXIT_FAILURE;
  }
  
  printf("CREATING RING BUFFER\n");
  
  p_ringBuffer = initRingBuffer(DATACHUNK, 1);
  
  if(!p_ringBuffer)
  {
    fprintf(stderr, "Failed to create ring buffer.\n");
    
    fclose(p_inFile);
    close(deviceOpts.discriptor);
    
    return EXIT_FAILURE;
  }
  
  printf("CREATING MIL-STD-1553 COM THREAD\n");
  
  error = pthread_create(&producerThread, NULL, producer, p_inFile);
  
  if(error)
  {
    fprintf(stderr, "Failed to create MIL-STD-1553 COM thread.\n");
    
    fclose(p_inFile);
    close(deviceOpts.discriptor);
    
    freeRingBuffer(&p_ringBuffer);
    
    return EXIT_FAILURE;
  }
  
  printf("CREATING WRITER THREAD\n");
  
  error = pthread_create(&consumerThread, NULL, consumer, &deviceOpts);
  
  if(error)
  {
    fprintf(stderr, "Failed to create writer thread.\n");
    
    fclose(p_inFile);
    close(deviceOpts.discriptor);
    
    ringBufferEndBlocking(p_ringBuffer);
    
    pthread_join(producerThread, NULL);
    
    freeRingBuffer(&p_ringBuffer);
    
    return EXIT_FAILURE;
  }
  
  printf("THREADS CREATED, WAITING FOR READER TO TERMINATE\n");
  
  pthread_join(producerThread, NULL);
  
  printf("READER TERMINATED, WAITING FOR MIL-STD-1553 COM.\n");
  
  pthread_join(consumerThread, NULL);
  
  printf("MIL-STD-1553 COM JOINED, ENDING PROGRAM.\n");
  
  freeRingBuffer(&p_ringBuffer);
  
  fclose(p_inFile);
  close(deviceOpts.discriptor);
  
  return EXIT_SUCCESS;
}

void *producer(void *data)
{
  char *p_fileBuffer = NULL;
  
  FILE *p_inFile = NULL;
  
  p_inFile = (FILE *)data;
  
  if(!p_inFile)
  {
    fprintf(stderr, "File discriptor is NULL.\n");
    return NULL;
  }
  
  p_fileBuffer = malloc(DATACHUNK);
  
  if(!p_fileBuffer)
  {
    perror("Could not allocate producer buffer.");
    return NULL;
  }
  
  do
  {
    int numElemRead = 0;
    int numElemWrote = 0;
    
    numElemRead = fread(p_fileBuffer, sizeof(*p_fileBuffer), DATACHUNK, p_inFile);

    do
    {
      numElemWrote += ringBufferBlockingWrite(p_ringBuffer, p_fileBuffer + numElemWrote, numElemRead - numElemWrote, NULL);
    } while(numElemWrote < numElemRead);
    
  } while(!feof(p_inFile) && ringBufferStillBlocking(p_ringBuffer));
  
  ringBufferEndBlocking(p_ringBuffer);
  
  free(p_fileBuffer);
  
  return NULL;
}

/* writer for 1553 data out */
void *consumer(void *data)
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
      printf("\nCTRL+C Caught, Exiting application.\n");
      ringBufferEndBlocking(p_ringBuffer);
      break;
    default:
      break;
  }
}
