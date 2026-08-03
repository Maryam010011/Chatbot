FROM gcc:latest

# Install cURL developer libraries for C++
RUN apt-get update && apt-get install -y libcurl4-openssl-dev

WORKDIR /app
COPY . .

# Compile the C++ backend on Linux
RUN g++ -std=c++17 server_main.cpp APIServer.cpp Chatbot.cpp FirebaseClient.cpp HashMap.cpp LinkedList.cpp Queue.cpp Stack.cpp -o chatbot_server -lpthread -lcurl

EXPOSE 8080

CMD ["./chatbot_server"]