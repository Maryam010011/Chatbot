# Makefile for Chatbot Project

CXX = g++
CXXFLAGS = -std=c++14 -Wall -Wextra -O2
TARGET = chatbot
TARGET_SERVER = chatbot_server
SOURCES = main.cpp Chatbot.cpp LinkedList.cpp Queue.cpp Stack.cpp HashMap.cpp
SERVER_SOURCES = server_main.cpp APIServer.cpp FirebaseClient.cpp Chatbot.cpp LinkedList.cpp Queue.cpp Stack.cpp HashMap.cpp
OBJECTS = $(SOURCES:.cpp=.o)
SERVER_OBJECTS = $(SERVER_SOURCES:.cpp=.o)

# Detect OS for library linking
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    LIBS = -lcurl -lpthread
endif
ifeq ($(UNAME_S),Darwin)
    LIBS = -lcurl
endif
ifdef OS
    ifeq ($(OS),Windows_NT)
        LIBS = -lcurl -lws2_32
    endif
endif

# Default target
all: $(TARGET)

# Build server target
server: $(TARGET_SERVER)

# Build the executable
$(TARGET): $(OBJECTS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJECTS)

# Build the server executable
$(TARGET_SERVER): $(SERVER_OBJECTS)
	$(CXX) $(CXXFLAGS) -o $(TARGET_SERVER) $(SERVER_OBJECTS) $(LIBS)

# Compile source files to object files
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean build files
clean:
	rm -f $(OBJECTS) $(SERVER_OBJECTS) $(TARGET) $(TARGET_SERVER)
	@echo "Clean complete!"

# Run the program
run: $(TARGET)
	./$(TARGET)

# Run server
run-server: $(TARGET_SERVER)
	./$(TARGET_SERVER)

# Help
help:
	@echo "Available targets:"
	@echo "  make           - Build the chatbot executable"
	@echo "  make server    - Build the API server"
	@echo "  make clean     - Remove build files"
	@echo "  make run       - Build and run the chatbot"
	@echo "  make run-server - Build and run the API server"
	@echo "  make help      - Show this help message"

.PHONY: all server clean run run-server help

