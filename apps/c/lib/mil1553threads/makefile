SRCDIR = src
SRC = $(wildcard $(SRCDIR)/*.c)
HEADER = $(notdir $(SRC:.c=.h))
OBJDIR = obj
OBJECTS = $(addprefix $(OBJDIR)/, $(notdir $(SRC:.c=.o)))
LIBOUT_STATIC = $(addprefix lib, $(notdir $(SRC:.c=.a)))
LIBOUT_DYNA = $(addprefix lib, $(notdir $(SRC:.c=.so)))
DOXYGEN_GEN = doxygen
DOXYGEN_CFG = dox.cfg
RINGBUF_DIR = ../ringBuffer
LINKDIR = -I$(RINGBUF_DIR)
LIB_RINGBUFFER = libringBuffer.a

#$(addprefix -l,$(basename $(LIBS)))

CC = gcc
CFLAGS = -Wall -O2 --std=c89
LFLAGS = $(LINKDIR) -I. -fPIC -lpthread -lringBuffer
DYNAFLAGS = -shared -fPIC
ARCHIVE = ar
AFLAGS = rcs

.PHONY: clean dox_gen

all: lib dox_gen

lib: $(LIB_RINGBUFFER) $(LIBOUT_STATIC) $(LIBOUT_DYNA)

$(LIBOUT_DYNA)  : $(OBJECTS)
	$(CROSS_COMPILE)$(CC) $(DYNAFLAGS) $^ -o $@
	
$(LIBOUT_STATIC): $(OBJECTS)
	$(CROSS_COMPILE)$(ARCHIVE) $(AFLAGS) $@ $^
	
$(LIB_RINGBUFFER):
	@$(MAKE) -C $(RINGBUF_DIR) $@;
	
$(OBJDIR)/%.o : $(SRCDIR)/%.c
	mkdir -p $(OBJDIR)
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $(LFLAGS) -c $< -o $@

dox_gen: 
	$(DOXYGEN_GEN) $(DOXYGEN_CFG) $(HEADER)
	
clean:
	rm -f $(OBJECTS) $(LIBOUT_STATIC) $(LIBOUT_DYNA)
	rm -rf $(OBJDIR) $(DOXYGEN_GEN)
