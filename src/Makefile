CC ?= gcc
CFLAGS ?= -Wall -Wextra
LIBS = -lwiringPi

TARGET = blinker_c
SRCS = main.c

all: $(TARGET)

$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRCS) $(LIBS)

install: $(TARGET)
	install -Dm755 $(TARGET) $(DESTDIR)$(out)/bin/$(TARGET)

clean:
	rm -f $(TARGET)

.PHONY: all install clean
