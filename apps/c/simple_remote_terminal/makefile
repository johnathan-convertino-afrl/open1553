SRCDIR = src
SRC = $(wildcard $(SRCDIR)/*.c)
OBJDIR = obj
OBJECTS = $(addprefix $(OBJDIR)/, $(notdir $(SRC:.c=.o)))
LIBS = ../lib/ringBuffer/ringBuffer.a ../lib/mil1553threads/mil1553threads.a
LIBS_DIR = $(addprefix -L, $(dir $(LIBS)))
LINK_DIR = $(addprefix -I, $(dir $(LIBS)))
LINK_LIBS = $(addprefix -l,$(basename $(notdir $(LIBS))))
EXEC = simple_rt

CC = gcc
CFLAGS = -Wall -O2 -std=gnu99
LFLAGS = $(LINK_DIR) $(LIBS_DIR) -I. -fPIC -lpthread $(LINK_LIBS)

.PHONY: clean $(LIBS)

all: lib exe
lib: $(LIBS)

exe: $(EXEC)

$(EXEC): $(OBJECTS) $(LIBS)
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $< -o $@ $(LFLAGS)

$(LIBS):
	@$(MAKE) -C $(@D) lib$(@F);
	
$(OBJDIR)/%.o : $(SRCDIR)/%.c
	mkdir -p $(OBJDIR)
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $(LFLAGS) -c $< -o $@
	
clean:
	rm -f $(EXEC)
	rm -rf $(OBJDIR)
