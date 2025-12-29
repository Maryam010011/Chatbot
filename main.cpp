#include "Chatbot.h"
#include "LinkedList.h"
#include "Queue.h"
#include "Stack.h"
#include "HashMap.h"
#include <iostream>
#include <string>
#include <limits>
#include "FirebaseClient.h"
#include "GuardianAPI.h"

void displayMenu() {
    std::cout << "\n========== Chatbot Menu ==========\n";
    std::cout << "1. Chat with bot\n";
    std::cout << "2. View conversation history\n";
    std::cout << "3. View recent messages\n";
    std::cout << "4. Undo last message\n";
    std::cout << "5. Clear history\n";
    std::cout << "6. Add custom response\n";
    std::cout << "7. View message statistics\n";
    std::cout << "8. Search conversation\n";
    std::cout << "9. Exit\n";
    std::cout << "==================================\n";
    std::cout << "Enter your choice: ";
}

void chatMode(Chatbot& bot, FirebaseClient& firebase) {
    std::cout << "\n========== Chat Mode ==========\n";
    std::cout << "Type 'back' to return to menu\n";
    std::cout << "Type 'exit' to quit\n";
    std::cout << "===============================\n\n";
    std::cout << std::flush;
    
    std::string input;
    while (true) {
        std::cout << "You: " << std::flush;
        if (!std::getline(std::cin, input)) {
            // Input stream closed; return to menu
            std::cout << "\nInput closed. Returning to menu.\n";
            return;
        }
        
        if (input.empty()) {
            continue;
        }
        


        std::string lowerInput = input;
        std::transform(lowerInput.begin(), lowerInput.end(), lowerInput.begin(), ::tolower);
        
        if (lowerInput == "back") {
            break;   // Return to menu
        }

        if (lowerInput == "exit" || lowerInput == "quit") {
            std::cout << "Thank you for using the Chatbot! Goodbye!\n";
            exit(0); // Exit program
        }

        
        std::string response = bot.respond(input);

        Message userMsg(input, "user", bot.getCurrentTime());
        Message botMsg(response, "bot", bot.getCurrentTime());

        firebase.saveMessage(userMsg, "cli-user");
        firebase.saveMessage(botMsg, "cli-user");

        std::cout << "Bot: " << response << "\n\n";

    }
}

void viewHistory(Chatbot& bot) {
    bot.displayHistory();
}

void viewRecent(Chatbot& bot) {
    int count;
    std::cout << "How many recent messages do you want to see? ";
    std::cin >> count;
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

    if (count <= 0) {
        std::cout << "Please enter a positive number.\n";
        return;
    }

    bot.displayRecent(count);
}

void undoMessage(Chatbot& bot) {
    bot.undoLastMessage();
}

void clearHistory(Chatbot& bot) {
    char confirm;
    std::cout << "Are you sure you want to clear all history? (y/n): ";
    std::cin >> confirm;
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    
    if (confirm == 'y' || confirm == 'Y') {
        bot.clearHistory();
        std::cout << "History cleared successfully.\n";
    } else {
        std::cout << "Operation cancelled.\n";
    }
}

void addCustomResponse(Chatbot& bot) {
    std::string keyword, response;
    
    std::cout << "Enter keyword: ";
    std::getline(std::cin, keyword);
    
    std::cout << "Enter response: ";
    std::getline(std::cin, response);
    
    bot.addCustomResponse(keyword, response);
}

void viewStatistics(Chatbot& bot) {
    std::cout << "\n========== Statistics ==========\n";
    std::cout << "Total messages: " << bot.getMessageCount() << "\n";
    std::cout << "===============================\n";
}

void searchConversation(Chatbot& bot) {
    std::string keyword;
    std::cout << "Enter keyword to search in conversation: ";
    std::getline(std::cin, keyword);

    if (keyword.empty()) {
        std::cout << "Search keyword cannot be empty.\n";
        return;
    }

    bot.searchConversation(keyword);
}

int main() {
    std::cout << "==========================================\n";
    std::cout << "   Welcome to DSA-Based Chatbot System   \n";
    std::cout << "==========================================\n";
    std::cout << "This chatbot uses various Data Structures:\n";
    std::cout << "- Linked List: Conversation History\n";
    std::cout << "- Queue: Message Processing\n";
    std::cout << "- Stack: Undo Functionality\n";
    std::cout << "- Hash Map: Response Lookup\n";
    std::cout << "==========================================\n";
    
    Chatbot bot;

FirebaseClient firebase(
    "https://chatbot-cec24-default-rtdb.asia-southeast1.firebasedatabase.app/",
    "AIzaSyAIxJ1XU2JxIV_aRDPgyY7WtjQ_EiSvIpE"
);
       
    int choice;
    std::string input;
    
    while (true) {
        displayMenu();
        std::cin >> choice;
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
        
        switch (choice) {
            case 1:
                chatMode(bot, firebase);
                break;
            case 2:
                viewHistory(bot);
                break;
            case 3:
                viewRecent(bot);
                break;
            case 4:
                undoMessage(bot);
                break;
            case 5:
                clearHistory(bot);
                break;
            case 6:
                addCustomResponse(bot);
                break;
            case 7:
                viewStatistics(bot);
                break;
            case 8:
                searchConversation(bot);
                break;
            case 9:
                std::cout << "Thank you for using the Chatbot! Goodbye!\n";
                return 0;
            default:
                std::cout << "Invalid choice. Please try again.\n";
                break;
        }
    }
    
    return 0;
}

