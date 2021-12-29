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
  return NULL;
}

/* writer for 1553 data out */
void *consumer(void *data)
{
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
