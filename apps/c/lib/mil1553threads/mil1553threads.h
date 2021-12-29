/***************************************************************************//**
  * @file     mil1553threads.h
  * @brief    mil-std-1553 example threads
  * @details  pthreads for mil-std-1553 applications. 
  * @author   Jay Convertino
  * @date     2021.12.29
  * @version
  * 0.0 - just started
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


#ifndef __MIL1553THREADS
#define __MIL1553THREADS

#include <pthread.h>
#include <stdint.h>
#include "ringBuffer.h"

#define MAX_1553_DATA     32
#define MIL_1553_STR_LEN  21

/**
 * @union   u_commandPacket
 * @brief   Contains bit fields for command packets.
 */  
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

/**
 * @union   u_statusPacket
 * @brief   Contains bit fields for status packets.
 */  
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

/**
 * @struct  s_threadData
 * @brief   Contains information for threads to communicate via ringBuffers.
 */
struct s_threadData
{
  int fileDescriptor;
  int address;
  uint64_t chunkSize;
  struct s_ringBuffer *p_ringBufferPri;
  struct s_ringBuffer *p_ringBufferSec;
  struct s_ringBuffer *p_ringBufferAux;
};

/*********************************************//**
  * @brief Read file thread, using linux
  * read file operators.
  * 
  * @param data pointer to data struct passed to thread
  * 
  * @return NULL on success
  *************************************************/
void *readFileThread(void *data);

/*********************************************//**
  * @brief Write file thread, using linux write
  * file operators.
  * 
  * @param data pointer to data struct passed to thread
  * 
  * @return NULL on success
  *************************************************/
void *writeFileThread(void *data);

/*********************************************//**
  * @brief remote terminal for file transfer using
  * mil-std-1553. This will parse and create messages.
  * 
  * @param data pointer to data struct passed to thread
  * 
  * @return NULL on success
  *************************************************/
void *remoteTerminalThread(void *data);

/*********************************************//**
  * @brief bus controller for file transfer using
  * mil-std-1553. This will parse and create messages.
  * 
  * @param data pointer to data struct passed to thread
  * 
  * @return NULL on success
  *************************************************/
void *busControllerThread(void *data);

#endif
