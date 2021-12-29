SRCDIR = src
SRC = $(wildcard $(SRCDIR)/*.c)
HEADER = $(notdir $(SRC:.c=.h))
OBJDIR = obj
OBJECTS = $(addprefix $(OBJDIR)/, $(notdir $(SRC:.c=.o)))
TESTDIR = test
TESTSRC = $(addprefix $(TESTDIR)/, main.c)
TEXEC = $(addprefix $(TESTDIR)/, test)
LIBOUT_STATIC = $(addprefix lib, $(notdir $(SRC:.c=.a)))
LIBOUT_DYNA = $(addprefix lib, $(notdir $(SRC:.c=.so)))
DOXYGEN_GEN = doxygen
DOXYGEN_CFG = dox.cfg

#$(addprefix -l,$(basename $(LIBS)))

CC = gcc
CFLAGS = -Wall -O2 --std=c89
LFLAGS = -I. -fPIC -lpthread
TLFLAGS = -L. -I. -l$(notdir $(basename $(SRC))) -lpthread
DYNAFLAGS = -shared -fPIC
ARCHIVE = ar
AFLAGS = rcs

.PHONY: clean dox_gen

all: lib exe dox_gen

lib: $(LIBOUT_STATIC) $(LIBOUT_DYNA)

exe: $(TEXEC)

$(TEXEC): $(TESTSRC) $(LIBOUT_STATIC)
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $^ -o $@ $(TLFLAGS)

$(LIBOUT_DYNA)  : $(OBJECTS)
	$(CROSS_COMPILE)$(CC) $(DYNAFLAGS) $^ -o $@
	
$(LIBOUT_STATIC): $(OBJECTS)
	$(CROSS_COMPILE)$(ARCHIVE) $(AFLAGS) $@ $^
	
$(OBJDIR)/%.o : $(SRCDIR)/%.c
	mkdir -p $(OBJDIR)
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $(LFLAGS) -c $< -o $@

dox_gen: 
	$(DOXYGEN_GEN) $(DOXYGEN_CFG) $(HEADER)
	
clean:
	rm -f $(TEXEC) $(OBJECTS) $(LIBOUT_STATIC) $(LIBOUT_DYNA)
	rm -rf $(OBJDIR) $(DOXYGEN_GEN)
