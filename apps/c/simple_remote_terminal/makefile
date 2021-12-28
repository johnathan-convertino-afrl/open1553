SRCDIR = src
SRC = $(wildcard $(SRCDIR)/*.c)
OBJDIR = obj
OBJECTS = $(addprefix $(OBJDIR)/, $(notdir $(SRC:.c=.o)))
RINGBUF_DIR = ../C89_pthread_ring_buffer
LINKDIR = -I$(RINGBUF_DIR)
LIBOUT_STATIC = libringBuffer.a
EXEC = simple_rt

#$(addprefix -l,$(basename $(LIBS)))
#$(notdir $(basename $(SRC)))

CC = gcc
CFLAGS = -Wall -O2 -std=gnu99
LFLAGS = -I. -fPIC -lpthread
EXELFLAGS = $(LINKDIR)

.PHONY: clean

all: lib exe

lib: $(LIBOUT_STATIC)

exe: $(EXEC)

$(EXEC): $(OBJECTS) $(LIBOUT_STATIC)
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $< -o $@ $(LFLAGS) -L$(RINGBUF_DIR) -lringBuffer

$(LIBOUT_STATIC):
	@$(MAKE) -C $(RINGBUF_DIR) $@;
	
$(OBJDIR)/%.o : $(SRCDIR)/%.c
	mkdir -p $(OBJDIR)
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $(LFLAGS) $(EXELFLAGS) -c $< -o $@
	
clean:
	@$(MAKE) -C $(RINGBUF_DIR) clean
	rm -f  $(EXEC)
	rm -rf $(OBJDIR) $(DOXYGEN_GEN)
