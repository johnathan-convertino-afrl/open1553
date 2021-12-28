/***************************************************************************//**
  * @file     ringBuffer.h
  * @brief    ansi-C ring buffer
  * @details  Ring buffer with blocking and non-blocking read/write calls,
  * thread Safe using either method. Blocking read/write will always try to
  * read or write all data non-destructively. Non-Blocking read will get as much
  * data as it can, even if its under the amount requested. Write will write
  * over data even if it has not been read (overwrite). All functions return the 
  * number of elements. BuffSize/elementSize. Not the number of bytes.
  * @author   John Convertino (electrobs@gmail.com)
  * @date     12/01/2016
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

#ifndef __RINGBUFFER_HD
#define __RINGBUFFER_HD

#include <pthread.h>
#include <sys/time.h>

/**
 * @def ERROR_NULL
 * a 0 return is error NULL
 */
#define ERROR_NULL     0

/**
 * @struct s_ringBuffer
 * @brief A struct type for ringbuffer object.
 */
struct s_ringBuffer
{
  /**
  * @var s_ringBuffer::buffSize
  * Size of the whole ring buffer
  */
  unsigned int buffSize;
  /**
  * @var s_ringBuffer::elementSize
  * size of the element the ring buffer stores.
  */
  unsigned int elementSize;
  /**
  * @var s_ringBuffer::indexMask
  * mask off overflow bits to index into the array properly.
  */
  unsigned int indexMask;
  /**
  * @var s_ringBuffer::b_blocking
  * Boolean for blocking state, true is blocking enabled. 
  */
  unsigned int b_blocking;
  /**
  * @var s_ringBuffer::headIndex
  * head index
  */
  unsigned int headIndex;
  /**
  * @var s_ringBuffer::tailIndex
  * tail index
  */
  unsigned int tailIndex;

  /**
  * @var s_ringBuffer::rwMutex
  * mutex to keep read and write at bay.
  */
  pthread_mutex_t rwMutex;
  /**
  * @var s_ringBuffer::condition
  * signal condition of read/write between treads.
  */
  pthread_cond_t condition;
  
  /**
  * @var s_ringBuffer::p_buffer
  * pointer allocated with space for storing elements.
  */
  void *p_buffer;
};

/*********************************************//**
  * @brief Initializes ring buffer,
  * creates ring buffer with a minimum size.
  *
  * Creates ring buffer size based on buffSize,
  * which serves as a minimum since this will find
  * the closest power of two greater then it.
  *
  * @param buffSize a minimum number of elements for
  * the buffer.
  * @param elementSize size of each element in the
  * buffer.
  * 
  * @return  Initialized ring buffer object, or NULL
  * on error.
  *************************************************/
struct s_ringBuffer *initRingBuffer(unsigned int const buffSize, unsigned int const elementSize);
/*********************************************//**
  * @brief Destroys ring buffer object.
  * 
  * Cleans up memory allocated to the ring buffer.
  * 
  * @param iopp_ringBuffer is a double pointer to
  * the ring buffer object to be freed.
  *************************************************/
void freeRingBuffer(struct s_ringBuffer **iopp_ringBuffer);
/*********************************************//**
  * @brief Empty Test,
  * is the buffer empty?
  *
  * Check if the ring buffer is empty by checking
  * if the head index is equal to the tail index.
  *
  * @param ip_ringBuffer is the ring buffer object
  * to operate on.
  * 
  * @return Is the ring buffer empty.
  *************************************************/
unsigned int ringBufferIsEmpty(struct s_ringBuffer * const ip_ringBuffer);
/*********************************************//**
  * @brief Full Test,
  * is the buffer full?
  *
  * Check if the ring buffer is full by checking
  * if the head index is one below the tail index.
  * 
  * @param ip_ringBuffer is the ring buffer object
  * to operate on.
  *
  * @return Is the ring buffer full.
  *************************************************/
unsigned int ringBufferIsFull(struct s_ringBuffer * const ip_ringBuffer);
/********************************************//**
  * @brief Check End Blocking Flag,
  * have the blocking r/w methods been disabled?
  *
  * Return the flag that tells us if blocking is
  * still allowed. True no more blocking, false
  * the blockingRead/Write will work normally.
  * 
  * @param ip_ringBuffer is the ring buffer object
  * to operate on.
  *
  * @return Has blocking functions been disabled.
  ************************************************/
unsigned int ringBufferStillBlocking(struct s_ringBuffer * const ip_ringBuffer);
/*********************************************//**
  * @brief Get Write Size,
  * the amount of available elements to write.
  *
  * Uses a mutex lock to keep from getting stale
  * data. Uses writeSize to get current write size.
  * 
  * @param ip_ringBuffer is the ring buffer object
  * to operate on.
  *
  * @return The number of elements that can be written.
  *************************************************/
unsigned int getRingBufferWriteSize(struct s_ringBuffer * const ip_ringBuffer);
/*********************************************//**
  * @brief Get Write Size,
  * the amount of available bytes to write.
  *
  * Uses a mutex lock to keep from getting stale
  * data. Uses writeSize to get current write size.
  * 
  * @param ip_ringBuffer is the ring buffer object
  * to operate on.
  *
  * @return The number of elements that can be written.
  *************************************************/
unsigned int getRingBufferWriteByteSize(struct s_ringBuffer * const ip_ringBuffer);
/*********************************************//**
  * @brief Get Read Size,
  * the amount of available elements to read.
  *
  * Uses a mutex lock to keep from getting stale
  * data. Uses readSize to get current read size.
  *
  * @param ip_ringBuffer is the ring buffer object
  * to operate on.
  * 
  * @return The number of elements that can be read.
  *************************************************/
unsigned int getRingBufferReadSize(struct s_ringBuffer * const ip_ringBuffer);
/*********************************************//**
  * @brief Get Read Size,
  * the amount of available bytes to read.
  *
  * Uses a mutex lock to keep from getting stale
  * data. Uses readSize to get current read size.
  *
  * @param ip_ringBuffer is the ring buffer object
  * to operate on.
  * 
  * @return The number of elements that can be read.
  *************************************************/
unsigned int getRingBufferReadByteSize(struct s_ringBuffer * const ip_ringBuffer);
/*********************************************//**
  * @brief Get buffer element size in bytes.
  *
  * Return element size created by constructor.
  * 
  * @param ip_ringBuffer is the ring buffer object
  * to operate on.
  *
  * @return The size of the element in bytes.
  *************************************************/
unsigned int getRingBufferElementSize(struct s_ringBuffer const * const ip_ringBuffer);
/*********************************************//**
  * @brief Get Buffer Size, in bytes.
  *
  * Return buffer size in bytes, created by constructor.
  * 
  * @param ip_ringBuffer is the ring buffer object
  * to operate on.
  *
  * @return The total size of the buffer in bytes.
  *************************************************/
unsigned int getRingBufferByteSize(struct s_ringBuffer const * const ip_ringBuffer);
/*********************************************//**
  * @brief Get Buffer Size,
  * the capacity in elements of the buffer.
  *
  * Return buffer size created by constructor.
  * 
  * @param ip_ringBuffer is the ring buffer object
  * to operate on.
  *
  * @return The total size of the buffer.
  *************************************************/
unsigned int getRingBufferSize(struct s_ringBuffer const * const ip_ringBuffer);
/*********************************************//**
  * @brief Resize Buffer,
  * to fit a new capcity, or we run out of space.
  * You can shrink the buffer, and the indexs will
  * be updated.
  * 
  * @param iop_ringBuffer is the ring buffer object
  * to operate on.
  * @param bufferSize is the new size for the buffer
  * @param elementSize is the new elementSize
  * 
  * @return The total size of the buffer.
  *************************************************/
unsigned int ringBufferResize(struct s_ringBuffer * const iop_ringBuffer, unsigned int bufferSize, unsigned int elementSize);
/*********************************************//**
  * @brief Blocking Write,
  * write all data without destroying data in buffer.
  *
  * Write to ring buffer, but don't overwrite its
  * contents. Will continually write till all is
  * data is written. This also has a timeout available
  * if it needs to end in a certain amount of time.
  * There is also a endBlocking call which sets a
  * bool that ends all blocking calls and calls
  * non blocking write instead.
  * 
  * @param iop_ringBuffer is the ring buffer object
  * to operate on.
  * @param ip_buffer an input buffer to use as input
  * to the ring buffer (write to).
  * @param len the length of the input buffer in elements.
  * @param p_timeToWait optional argument to use timeout
  * if blocking for too long.
  * @return The number of elements written.
  *************************************************/
unsigned int ringBufferBlockingWrite(struct s_ringBuffer * const iop_ringBuffer, void *ip_buffer, unsigned int len, struct timespec *p_timeToWait);
/*********************************************//**
  * @brief Blocking Read,
  * read all data in buffer, wait till amount requested
  * is reached.
  *
  * Read from ring buffer, but keep reading till
  * we get all of the data. This also has a timeout
  * available if it needs to end in a certain amount
  * of time. There is also a endBlocking call which
  * sets a bool that ends all blocking calls and calls
  * non blocking read instead.
  *
  * @param iop_ringBuffer is the ring buffer object
  * to operate on.
  * @param op_buffer an output buffer that the ring
  * buffer puts data into (read data from buffer).
  * @param len the number of elements to be read.
  * @param p_timeToWait optional argument to use timeout
  * if blocking for too long.
  * @return The number of elements read.
  *************************************************/
unsigned int ringBufferBlockingRead(struct s_ringBuffer * const iop_ringBuffer, void *op_buffer, unsigned int len, struct timespec *p_timeToWait);
/*********************************************//**
  * @brief Write to the buffer,
  * write all data regardless if it destroys data in buffer.
  *
  * Write to the buffer the amount of data provided
  * by len. This will write over data regardless
  * if it has been read. If len is larger then the
  * buffer it will simply keep writing that data
  * (writing over data already written).
  * Only blocking is waiting for the r/w shared
  * mutex.
  *
  * @param iop_ringBuffer is the ring buffer object
  * to operate on.
  * @param ip_buffer an input buffer to use as input
  * to the ring buffer (write to).
  * @param len the length of the input buffer in elements.
  * @return The number of elements written.
  *************************************************/
unsigned int ringBufferWrite(struct s_ringBuffer * const iop_ringBuffer, void *ip_buffer, unsigned int len);
/*********************************************//**
  * @brief Read from the buffer,
  * read data available, up to length request.
  *
  * Read data up to length, if no more data exists
  * just return the amount read and finish.
  * Only blocking is waiting for the r/w shared
  * mutex.
  *
  * @param iop_ringBuffer is the ring buffer object
  * to operate on.
  * @param op_buffer an output buffer that the ring
  * buffer puts data into (read data from buffer).
  * @param len the number of elements to be read.
  * @return The number of elements read.
  *************************************************/
unsigned int ringBufferRead(struct s_ringBuffer * const iop_ringBuffer, void *op_buffer, unsigned int len);
/*********************************************//**
  * @brief Reset Buffer,
  * reset buffer indexs and end blocking.
  *
  * Set indexs back to 0.
  * Set end blocking back to false.
  * 
  * @param iop_ringBuffer is the ring buffer object
  * to operate on.
  *************************************************/
void ringBufferReset(struct s_ringBuffer * const iop_ringBuffer);
/*********************************************//**
  * @brief End Blocking functions,
  * disable and exit all blocking read/write methods.
  *
  * Notify all condition variables to stop waiting
  * and return the value of their predicate. Also
  * mark endBlocking varaible to true, so blocking
  * write/read calls will now call non-blocking.
  * 
  * @param iop_ringBuffer is the ring buffer object
  * to operate on.
  *************************************************/
void ringBufferEndBlocking(struct s_ringBuffer * const iop_ringBuffer);

#endif
