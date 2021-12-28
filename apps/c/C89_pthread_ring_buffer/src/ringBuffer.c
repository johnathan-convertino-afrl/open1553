/***************************************************************************//**
  * @brief   ansi-C ring buffer
  * @details Ring buffer with blocking and non-blocking read/write calls,
  * thread Safe using either method. Blocking read/write will always try to
  * read or write all data non-destructively. Non-Blocking read will get as much
  * data as it can, even if its under the amount requested. Write will write
  * over data even if it has not been read (overwrite). All functions return the 
  * number of elements. BuffSize/elementSize. Not the number of bytes.
  * @author  John Convertino(electrobs@gmail.com)
  * @date    12/01/2016
  * @version
  * 1.3 - Added private blocking check method to the blocking read/write.
  * 1.2 - Code cleanup, added const.
  * 1.1 - Added timed wait_until to blocking read/write.
  * 
  * @license mit
  * 
  * Copyright 2020 Johnathan Convertino
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

#include <ringBuffer.h>

#define CONT_BLOCKING 1
#define STOP_BLOCKING 0
#define PROC_SUCC 1
#define PROC_FAIL 0

/*  private helper functions */
/*  write size of the ring buffer, no thread protection */
unsigned int writeSize(struct s_ringBuffer const * const ip_ringBuffer);
/*  read size of the ring buffer, no thread protection */
unsigned int readSize(struct s_ringBuffer const * const ip_ringBuffer);
/*  raw write to the ring buffer. No thread protection. */
unsigned int rawWrite(struct s_ringBuffer * const iop_ringBuffer, void *ip_buffer, unsigned int len);
/*  raw read to from the ring buffer. No thread protection. */
unsigned int rawRead(struct s_ringBuffer * const iop_ringBuffer, void *op_buffer, unsigned int len);
/*  General allocate method for the buffer. Used in the init and resize methods. */
unsigned int allocateBuffer(struct s_ringBuffer * const iop_ringBuffer, unsigned int buffSize, unsigned int elementSize);
/*  check the state of blocking, have we timed out? Did we error out? */
unsigned int checkContinueBlocking(struct s_ringBuffer * const iop_ringBuffer, struct timespec *p_timeToWait);

/*  public  functions */
/*  init, calls allocate buffer to setup the size. */
struct s_ringBuffer *initRingBuffer(unsigned int const buffSize, unsigned int const elementSize)
{
  struct s_ringBuffer *p_tempBuffer = NULL;

  p_tempBuffer = malloc(sizeof(struct s_ringBuffer));
  
  if(!p_tempBuffer)
  {
    perror("ANSI-C RING BUFFER: Could not allocate buffer object.");
    return NULL;
  }
  
  memset(p_tempBuffer, 0, sizeof(*p_tempBuffer));

  if(!allocateBuffer(p_tempBuffer, buffSize, elementSize))
  {
    fprintf(stderr, "ANSI-C RING BUFFER: Ring Buffer Object Failed.\n");
    return NULL;
  }
  
  return p_tempBuffer;
}

/*  free the resources allocated to the buffer */
void freeRingBuffer(struct s_ringBuffer **iopp_ringBuffer)
{
  if(!iopp_ringBuffer) return;
  
  if(!*iopp_ringBuffer) return;
  
  free((*iopp_ringBuffer)->p_buffer);
  free(*iopp_ringBuffer);
}

/*  simple true false, are we empty. read size 0 equals 0, we are empty. */
unsigned int ringBufferIsEmpty(struct s_ringBuffer * const ip_ringBuffer)
{
  if(!ip_ringBuffer) return ERROR_NULL;
  
  return getRingBufferReadSize(ip_ringBuffer) == 0;
}

/*simple true false are we full. write size 0 equals 0, we are full. */
unsigned int ringBufferIsFull(struct s_ringBuffer * const ip_ringBuffer)
{
  if(!ip_ringBuffer) return ERROR_NULL;
  
  return getRingBufferWriteSize(ip_ringBuffer) == 0;
}

/*  Simple true false are we blocking. bool is 1 and equals 1, we are blocking (true). */
unsigned int ringBufferStillBlocking(struct s_ringBuffer * const ip_ringBuffer)
{
  unsigned int boolResult = 0;
  
  if(!ip_ringBuffer) return ERROR_NULL;
  
  pthread_mutex_lock(&ip_ringBuffer->rwMutex);
  
  boolResult = ip_ringBuffer->b_blocking == 1;
  
  pthread_mutex_unlock(&ip_ringBuffer->rwMutex);
  
  return boolResult;
}

/*  What is the write size in elements? */
unsigned int getRingBufferWriteSize(struct s_ringBuffer * const ip_ringBuffer)
{
  unsigned int tempSize = 0;
  
  if(!ip_ringBuffer) return ERROR_NULL;

  pthread_mutex_lock(&ip_ringBuffer->rwMutex);
  
  tempSize = writeSize(ip_ringBuffer) / ip_ringBuffer->elementSize;
  
  pthread_mutex_unlock(&ip_ringBuffer->rwMutex);
  
  return tempSize;
}

/*  What is the write size in bytes? */
unsigned int getRingBufferWriteByteSize(struct s_ringBuffer * const ip_ringBuffer)
{
  unsigned int tempSize = 0;
  
  if(!ip_ringBuffer) return ERROR_NULL;

  pthread_mutex_lock(&ip_ringBuffer->rwMutex);
  
  tempSize = writeSize(ip_ringBuffer);
  
  pthread_mutex_unlock(&ip_ringBuffer->rwMutex);
  
  return tempSize;
}

/*  What is the read size in elements? */
unsigned int getRingBufferReadSize(struct s_ringBuffer * const ip_ringBuffer)
{
  unsigned int tempSize = 0;
  
  if(!ip_ringBuffer) return ERROR_NULL;

  pthread_mutex_lock(&ip_ringBuffer->rwMutex);
  
  tempSize = readSize(ip_ringBuffer) / ip_ringBuffer->elementSize; 
  
  pthread_mutex_unlock(&ip_ringBuffer->rwMutex);
  
  return tempSize;
}

/*  What is the read size in bytes? */
unsigned int getRingBufferReadByteSize(struct s_ringBuffer * const ip_ringBuffer)
{
  unsigned int tempSize = 0;
  
  if(!ip_ringBuffer) return ERROR_NULL;

  pthread_mutex_lock(&ip_ringBuffer->rwMutex);
  
  tempSize = readSize(ip_ringBuffer); 
  
  pthread_mutex_unlock(&ip_ringBuffer->rwMutex);
  
  return tempSize;
}

/*  What is the size of the elements? */
unsigned int getRingBufferElementSize(struct s_ringBuffer const * const ip_ringBuffer)
{
  if(!ip_ringBuffer) return ERROR_NULL;
  
  return ip_ringBuffer->elementSize;
}

/*  What is the size of the buffer in bytes? */
unsigned int getRingBufferByteSize(struct s_ringBuffer const * const ip_ringBuffer)
{
  if(!ip_ringBuffer) return ERROR_NULL;
  
  return ip_ringBuffer->buffSize;
}

/*  What is the size of the buffer in elements. */
unsigned int getRingBufferSize(struct s_ringBuffer const * const ip_ringBuffer)
{
  if(!ip_ringBuffer) return ERROR_NULL;
  
  return ip_ringBuffer->buffSize / ip_ringBuffer->elementSize;
}

/*  Resize the buffer to a new size. */
unsigned int ringBufferResize(struct s_ringBuffer * const io_ringBuffer, unsigned int bufferSize, unsigned int elementSize)
{
  if(!io_ringBuffer) return ERROR_NULL;
  
  pthread_mutex_lock(&io_ringBuffer->rwMutex);
  
  /* we return a 1 on success, 0 on failure... if we fail the buffer stays at its current size. */
  if(!allocateBuffer(io_ringBuffer, bufferSize, elementSize))
  {
    pthread_mutex_unlock(&io_ringBuffer->rwMutex);
    return ERROR_NULL;
  }
  
  /* change index sizes */
  if(io_ringBuffer->headIndex >= io_ringBuffer->buffSize)
  {
    io_ringBuffer->headIndex = io_ringBuffer->buffSize - 1;
  }
  
  if(io_ringBuffer->tailIndex > io_ringBuffer->buffSize)
  {
    io_ringBuffer->tailIndex = io_ringBuffer->buffSize;
  }
  
  pthread_mutex_unlock(&io_ringBuffer->rwMutex);
  
  return getRingBufferSize(io_ringBuffer);
}

/*  Write to the buffer, blocking method, will not return till it writes, times out, or blocking is disabled. */
unsigned int ringBufferBlockingWrite(struct s_ringBuffer * const iop_ringBuffer, void *ip_buffer, unsigned int len, struct timespec * p_timeToWait)
{
  unsigned int totalWrote = 0;
  unsigned int wrote = 0;
  unsigned int writeLen = 0;
  
  if(!iop_ringBuffer) return 0;
  
  if(!ip_buffer)
  {
    fprintf(stderr, "ANSI-C RING BUFFER: Input buffer is NULL.\n");
    return 0;
  }

  if(len <= 0) return totalWrote;

  if(!iop_ringBuffer->b_blocking) return ringBufferWrite(iop_ringBuffer, ip_buffer, len);

  pthread_mutex_lock(&iop_ringBuffer->rwMutex);

  len *= iop_ringBuffer->elementSize;
  
  do
  {
    writeLen = (len >= getRingBufferByteSize(iop_ringBuffer) ? getRingBufferByteSize(iop_ringBuffer) - 1 : len);

    while(writeLen > writeSize(iop_ringBuffer))
    {
      if(!checkContinueBlocking(iop_ringBuffer, p_timeToWait)) return totalWrote;
    }

    wrote = rawWrite(iop_ringBuffer, ip_buffer + totalWrote, writeLen);
    totalWrote += wrote;
    len -= wrote;
    
    pthread_cond_signal(&iop_ringBuffer->condition);
  }
  while(len > 0);
  
  pthread_mutex_unlock(&iop_ringBuffer->rwMutex);

  return totalWrote;
}

/*  Read from the buffer, blocking method, will not return till it reads, times out, or blocking is disabled. */
unsigned int ringBufferBlockingRead(struct s_ringBuffer * const iop_ringBuffer, void *op_buffer, unsigned int len, struct timespec *p_timeToWait)
{
  unsigned int totalRead = 0;
  unsigned int read = 0;
  unsigned int readLen = 0;
  
  if(!iop_ringBuffer) return 0;

  if(!op_buffer)
  {
    fprintf(stderr, "ANSI-C RING BUFFER: Output buffer is NULL.\n");
    return 0;
  }

  if(len <= 0) return totalRead;
  
  if(!iop_ringBuffer->b_blocking) return ringBufferRead(iop_ringBuffer,op_buffer, len);

  pthread_mutex_lock(&iop_ringBuffer->rwMutex);
  
  len *= iop_ringBuffer->elementSize;

  do
  {
    
    readLen = (len >= getRingBufferByteSize(iop_ringBuffer) ? getRingBufferByteSize(iop_ringBuffer) - 1 : len);
    
    while(readLen > readSize(iop_ringBuffer))
    {
      if(!checkContinueBlocking(iop_ringBuffer, p_timeToWait)) return totalRead;
    }
    
    read = rawRead(iop_ringBuffer, op_buffer + totalRead, readLen);
    totalRead += read;
    len -= read;
    
    pthread_cond_signal(&iop_ringBuffer->condition);
  }
  while(len > 0);

  pthread_mutex_unlock(&iop_ringBuffer->rwMutex);
  
  return totalRead;
}

/*  non-blocking write */
unsigned int ringBufferWrite(struct s_ringBuffer * const iop_ringBuffer, void *ip_buffer, unsigned int len)
{
  unsigned int totalWrote = 0;
  
  if(!iop_ringBuffer) return 0;

  if(!ip_buffer)
  {
    fprintf(stderr, "ANSI-C RING BUFFER: Input buffer is NULL.\n");
    return 0;
  }

  if(len <= 0) return totalWrote;

  pthread_mutex_lock(&iop_ringBuffer->rwMutex);

  len *= iop_ringBuffer->elementSize;
  
  totalWrote = rawWrite(iop_ringBuffer, ip_buffer, len);

  pthread_cond_signal(&iop_ringBuffer->condition);
  pthread_mutex_unlock(&iop_ringBuffer->rwMutex);

  return totalWrote;
}

/*  non-blocking read */
unsigned int ringBufferRead(struct s_ringBuffer * const iop_ringBuffer, void *op_buffer, unsigned int len)
{
  unsigned int totalRead = 0;
  
  if(!iop_ringBuffer) return 0;

  if(!op_buffer)
  {
    fprintf(stderr, "ANSI-C RING BUFFER: Output buffer is NULL.\n");
    return 0;
  }

  if(len <= 0) return totalRead;

  pthread_mutex_lock(&iop_ringBuffer->rwMutex);
  
  len *= iop_ringBuffer->elementSize;

  if(len > readSize(iop_ringBuffer))
  {
    len = readSize(iop_ringBuffer);
  }
  
  totalRead = rawRead(iop_ringBuffer, op_buffer, len);
  
  pthread_cond_signal(&iop_ringBuffer->condition);
  pthread_mutex_unlock(&iop_ringBuffer->rwMutex);

  return totalRead;
}

/*  clear out data, and restart blocking on the ringbuffer */
void ringBufferReset(struct s_ringBuffer * const iop_ringBuffer)
{
  if(!iop_ringBuffer) return;

  pthread_mutex_lock(&iop_ringBuffer->rwMutex);

  iop_ringBuffer->headIndex = iop_ringBuffer->tailIndex = 0;
  
  iop_ringBuffer->b_blocking = 1;
  
  pthread_cond_signal(&iop_ringBuffer->condition);
  pthread_mutex_unlock(&iop_ringBuffer->rwMutex);
}

/*  disable ring buffer blocking */
void ringBufferEndBlocking(struct s_ringBuffer * const iop_ringBuffer)
{
  if(!iop_ringBuffer) return;
  
  pthread_mutex_lock(&iop_ringBuffer->rwMutex);

  iop_ringBuffer->b_blocking = 0;

  pthread_cond_signal(&iop_ringBuffer->condition);
  pthread_mutex_unlock(&iop_ringBuffer->rwMutex);
}

/*  help function implimentation */
/*  return the write size of the buffer, no thread protection. */
unsigned int writeSize(struct s_ringBuffer const * const ip_ringBuffer)
{
  unsigned int writeSize = 0;
  
  /* using binary methods to roll the number back around if it is negative. */
  /** 
   * rememeber, this is using some binary tricks to do the math. If we have a negative,
   * end up subtracting a value equal to the size of the buffer as an offset.
   * Everything is powers of 2. So a buffer capable of 32 bytes would have a 2^6 size counter.
   * The mask would be 011111, 2^4 downto 2^0 is the actual range of the counter. If it goes over
   * to 2^5 (32) we mask it off, offsetting the value by 32.
   * (TAIL - HEAD) & MASK
   * 20 - 30 = -10 aka 110110
   * 011111 & 110110 = 010110
   * 010110 aka 22. Which is the real difference since this is a ring buffer.
   */
  writeSize = (ip_ringBuffer->tailIndex - ip_ringBuffer->headIndex) & ip_ringBuffer->indexMask;
  writeSize = (writeSize != 0 ? writeSize : ip_ringBuffer->buffSize);

  return (writeSize - 1);
}

/*  return the read size of the buffer, no thread protection. */
unsigned int readSize(struct s_ringBuffer const * const ip_ringBuffer)
{
  /* we are using binary methods to roll the number back around if it is negative. see write for how this actually works*/
  return (ip_ringBuffer->headIndex - ip_ringBuffer->tailIndex) & ip_ringBuffer->indexMask;
}


/*  Write data to the buffer. */
unsigned int rawWrite(struct s_ringBuffer * const iop_ringBuffer, void *ip_buffer, unsigned int len)
{
  unsigned int totalWrote = 0;
  unsigned int availLen = 0;
  unsigned int writeLen = 0;
  
  if(!iop_ringBuffer) return 0;

  do
  {
    availLen = iop_ringBuffer->buffSize - iop_ringBuffer->headIndex;

    writeLen = (len < availLen ? len : availLen);

    memcpy(iop_ringBuffer->p_buffer + iop_ringBuffer->headIndex, ip_buffer + totalWrote, writeLen);

    len -= writeLen;
    totalWrote += writeLen;
    /* if we go over the max buffer size, we loop around */
    iop_ringBuffer->headIndex = (iop_ringBuffer->headIndex + writeLen) & iop_ringBuffer->indexMask;
  }
  while(len > 0);

  return totalWrote;
}

/* Read data from the buffer. */
unsigned int rawRead(struct s_ringBuffer * const iop_ringBuffer, void *op_buffer, unsigned int len)
{
  unsigned int totalRead = 0;
  unsigned int availLen = 0;
  unsigned int readLen = 0;
  
  if(!iop_ringBuffer) return 0;

  do
  {
    availLen = iop_ringBuffer->buffSize - iop_ringBuffer->tailIndex;

    readLen = (len < availLen ? len : availLen);

    memcpy(op_buffer + totalRead, iop_ringBuffer->p_buffer + iop_ringBuffer->tailIndex, readLen);

    len -= readLen;
    totalRead += readLen;
    /* if we go over the maxBuffer size. We loop around. */
    iop_ringBuffer->tailIndex = (iop_ringBuffer->tailIndex + readLen) & iop_ringBuffer->indexMask;
  }
  while(len > 0);

  return totalRead;
}

/*  allocate the buffer, will also preform reallocations if it is already allocated. */
unsigned int allocateBuffer(struct s_ringBuffer * const iop_ringBuffer, unsigned int buffSize, unsigned int elementSize)
{
  unsigned int maxBuffSize = 0;
  unsigned int back_buffersize = 0;
  unsigned int back_elementSize = 0;
  
  struct s_ringBuffer backupBuffer;
  void *p_temp = NULL;
  
  /* The buffer can't be any larger then 0111111... since 1000... is are mask to loop the buffer around. */
  maxBuffSize = (unsigned int)~0 >> 1;
  
  if(!iop_ringBuffer)
  {
    fprintf(stderr, "ANSI-C RING BUFFER: Ring buffer pointer NULL.\n");
    return PROC_FAIL;
  }
  
  if(elementSize <= 0)
  {
    fprintf(stderr, "ANSI-C RING BUFFER: Element size less then or equal to 0.\n");
    return PROC_FAIL;
  }

  if(buffSize <= 0)
  {
    fprintf(stderr, ("ANSI-C RING BUFFER: Size must be greater then 0.\n"));
    return PROC_FAIL;
  }
  
  if((buffSize * elementSize) > maxBuffSize)
  {
    fprintf(stderr, "ANSI-C RING BUFFER: Size is too large, must be equal to or less then %d.\n", maxBuffSize);
    return PROC_FAIL;
  }
  
  /* keep a copy of the buffer incase realloc fails */
  memcpy(&backupBuffer, iop_ringBuffer, sizeof(backupBuffer));
  
  back_buffersize = iop_ringBuffer->buffSize;
  back_elementSize = elementSize;
  
  iop_ringBuffer->buffSize = 1;
  
  /* find the greatest binary bit */
  while((iop_ringBuffer->buffSize <<= 1) < (buffSize * elementSize));
  
  /* create a index mask to get rid of all bits over buffsize. */
  /* we subtract one to create a mask of 01111 from the size of 1000, we include 0 remember! */
  iop_ringBuffer->indexMask = iop_ringBuffer->buffSize - 1;
  iop_ringBuffer->elementSize = elementSize;
  iop_ringBuffer->b_blocking = 1;

  /* realloc will allocate NULL buffers */
  p_temp = realloc(iop_ringBuffer->p_buffer, iop_ringBuffer->buffSize * iop_ringBuffer->elementSize);
  
  if(!p_temp)
  {
    perror("ANSI-C RING BUFFER: Could not allocate buffer.");
    /* copy original sizes back to the ring buffer object */
    memcpy(iop_ringBuffer, &backupBuffer, sizeof(*iop_ringBuffer));
    
    /* restore buffer size */
    iop_ringBuffer->buffSize = back_buffersize;
    iop_ringBuffer->indexMask = iop_ringBuffer->buffSize - 1;
    iop_ringBuffer->elementSize = back_elementSize;
    iop_ringBuffer->b_blocking = 1;
    
    return PROC_FAIL;
  }
  
  iop_ringBuffer->p_buffer = p_temp;

  return PROC_SUCC;
}

/* deal with the blocking check in the function. The method is the same for read and write. */
unsigned int checkContinueBlocking(struct s_ringBuffer * const iop_ringBuffer, struct timespec *p_timeToWait)
{
  if(!iop_ringBuffer) return STOP_BLOCKING;
  
  /* if we pass it a time to wait, do a timed wait. Otherwise we just wait. */
  if(p_timeToWait)
  {
    struct timeval timeNow;
    
    /* current time of day. */
    if(gettimeofday(&timeNow, NULL))
    { 
      pthread_mutex_unlock(&iop_ringBuffer->rwMutex);
      return STOP_BLOCKING;
    }
    
    /* add our offset time to wait, convert micro to milli */
    p_timeToWait->tv_sec += timeNow.tv_sec;
    p_timeToWait->tv_nsec += timeNow.tv_usec * 1000UL;

    /* wait for timed wait, if we time out, we return. */
    if(pthread_cond_timedwait(&iop_ringBuffer->condition, &iop_ringBuffer->rwMutex, p_timeToWait))
    {
      pthread_cond_signal(&iop_ringBuffer->condition);
      return STOP_BLOCKING;
    }
  }
  else
  {
    /* if we don't have a wait time, and not enough space to read data we 
     * are going to wait. This method will release the mutex, and wait for
     * the condition to be signaled. If this is successful, a 0 value is returned.
     * if it fails, we signal such and return what we did read.
     */
    if(pthread_cond_wait(&iop_ringBuffer->condition, &iop_ringBuffer->rwMutex))
    {
      pthread_cond_signal(&iop_ringBuffer->condition);
      return STOP_BLOCKING;
    }
  }

  if(!iop_ringBuffer->b_blocking)
  {
    pthread_mutex_unlock(&iop_ringBuffer->rwMutex);
    return STOP_BLOCKING;
  }
  
  return CONT_BLOCKING;
}
