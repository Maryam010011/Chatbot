#ifndef NEWS_MANAGER_H
#define NEWS_MANAGER_H

#include <string>
#include <vector>
#include <curl/curl.h>
#include <iostream>
#include <sstream>
#include "config.h"
#include <ctime>

class NewsManager {
private:
    static size_t WriteCallback(void* contents, size_t size, size_t nmemb, void* userp) {
        ((std::string*)userp)->append((char*)contents, size * nmemb);
        return size * nmemb;
    }

    static std::string urlEncode(const std::string& str) {
        std::string encoded = str;
        size_t pos = 0;
        while ((pos = encoded.find(" ", pos)) != std::string::npos) {
            encoded.replace(pos, 1, "%20");
            pos += 3;
        }
        return encoded;
    }

public:
    struct NewsArticle {
        std::string title;
        std::string url;
        std::string section;
        std::string date;
    };

    // Guardian API se news fetch karo
    static std::string fetchFromGuardian(const std::string& keyword = "", int pageSize = 5) {
        CURL* curl;
        CURLcode res;
        std::string readBuffer;

        curl = curl_easy_init();
        if (curl) {
            std::string url = "https://content.guardianapis.com/search?";
            url += "api-key=a0b5386d-4cd2-48b4-a86f-356a336f112e";
            url += "&show-fields=headline,trailText";
            url += "&page-size=" + std::to_string(pageSize);
            url += "&order-by=newest";

            if (!keyword.empty()) {
                url += "&q=" + urlEncode(keyword);
            }

            curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
            curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10L);

            res = curl_easy_perform(curl);
            curl_easy_cleanup(curl);

            if (res != CURLE_OK) {
                return "";
            }
        }

        return readBuffer;
    }

    // Simple JSON parsing
    static std::vector<NewsArticle> parseNews(const std::string& jsonResponse) {
        std::vector<NewsArticle> articles;

        size_t pos = 0;
        while ((pos = jsonResponse.find("\"webTitle\":\"", pos)) != std::string::npos) {
            NewsArticle article;

            // Extract title
            pos += 12;
            size_t endPos = jsonResponse.find("\"", pos);
            if (endPos != std::string::npos) {
                article.title = jsonResponse.substr(pos, endPos - pos);
            }

            // Extract URL
            size_t urlPos = jsonResponse.find("\"webUrl\":\"", pos);
            if (urlPos != std::string::npos) {
                urlPos += 10;
                size_t urlEnd = jsonResponse.find("\"", urlPos);
                article.url = jsonResponse.substr(urlPos, urlEnd - urlPos);
            }

            // Extract section
            size_t secPos = jsonResponse.find("\"sectionName\":\"", pos);
            if (secPos != std::string::npos) {
                secPos += 15;
                size_t secEnd = jsonResponse.find("\"", secPos);
                article.section = jsonResponse.substr(secPos, secEnd - secPos);
            }

            articles.push_back(article);
            pos = endPos;

            if (articles.size() >= 5) break;
        }

        return articles;
    }

    // Firebase me news store karo
    static bool storeInFirebase(const std::vector<NewsArticle>& articles, const std::string& firebaseUrl) {
        if (articles.empty()) return false;

        CURL* curl;
        CURLcode res;
        bool success = true;

        for (const auto& article : articles) {
            curl = curl_easy_init();
            if (curl) {
                std::string url = firebaseUrl + "/news/articles.json";

                // JSON payload banao
                std::stringstream json;
                json << "{";
                json << "\"title\":\"" << article.title << "\",";
                json << "\"url\":\"" << article.url << "\",";
                json << "\"section\":\"" << article.section << "\",";
                json << "\"timestamp\":" << time(nullptr) << ",";
                json << "\"source\":\"The Guardian\"";
                json << "}";

                std::string jsonStr = json.str();

                curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
                curl_easy_setopt(curl, CURLOPT_POSTFIELDS, jsonStr.c_str());
                curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);

                struct curl_slist* headers = NULL;
                headers = curl_slist_append(headers, "Content-Type: application/json");
                curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);

                res = curl_easy_perform(curl);

                if (res != CURLE_OK) {
                    success = false;
                }

                curl_easy_cleanup(curl);
                curl_slist_free_all(headers);
            }
        }

        return success;
    }

    // Firebase se news fetch karo
    static std::string fetchFromFirebase(const std::string& firebaseUrl) {
        CURL* curl;
        CURLcode res;
        std::string readBuffer;

        curl = curl_easy_init();
        if (curl) {
            std::string url = firebaseUrl + "/news/articles.json";

            curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);

            res = curl_easy_perform(curl);
            curl_easy_cleanup(curl);
        }

        return readBuffer;
    }

    // Format response for user
    static std::string formatNewsResponse(const std::vector<NewsArticle>& articles, const std::string& keyword = "") {
        if (articles.empty()) {
            return "Sorry, no news found at the moment. Try 'update news' to fetch latest articles.";
        }

        std::stringstream response;
        
        if (!keyword.empty()) {
            response << "📰 News about '" << keyword << "':\n\n";
        } else {
            response << "📰 Latest Headlines:\n\n";
        }

        int count = 1;
        for (const auto& article : articles) {
            response << count++ << ". " << article.title << "\n";
            response << "   📂 " << article.section << "\n";
            response << "   🔗 " << article.url << "\n\n";
            
            if (count > 5) break;
        }

        response << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        response << "Powered by The Guardian\n";

        return response.str();
    }

    // Search news in Firebase by keyword
    // Search news in Firebase by keyword
static std::vector<NewsArticle> searchInFirebase(const std::string& firebaseData, const std::string& keyword) {
    std::vector<NewsArticle> matches;
    
    if (firebaseData.empty() || firebaseData == "null") {
        return matches;
    }

    // Convert keyword to lowercase - SIMPLE WAY
    std::string lowerKeyword = "";
    for (char c : keyword) {
        lowerKeyword += std::tolower(c);
    }

    size_t pos = 0;
    while ((pos = firebaseData.find("\"title\":\"", pos)) != std::string::npos) {
        pos += 9;
        size_t endPos = firebaseData.find("\"", pos);
        
        if (endPos != std::string::npos) {
            std::string title = firebaseData.substr(pos, endPos - pos);
            
            // Convert title to lowercase - SIMPLE WAY
            std::string lowerTitle = "";
            for (char c : title) {
                lowerTitle += std::tolower(c);
            }

            if (lowerTitle.find(lowerKeyword) != std::string::npos) {
                NewsArticle article;
                article.title = title;

                // Extract URL
                size_t urlPos = firebaseData.find("\"url\":\"", pos);
                if (urlPos != std::string::npos) {
                    urlPos += 7;
                    size_t urlEnd = firebaseData.find("\"", urlPos);
                    article.url = firebaseData.substr(urlPos, urlEnd - urlPos);
                }

                // Extract section
                size_t secPos = firebaseData.find("\"section\":\"", pos);
                if (secPos != std::string::npos) {
                    secPos += 11;
                    size_t secEnd = firebaseData.find("\"", secPos);
                    article.section = firebaseData.substr(secPos, secEnd - secPos);
                }

                matches.push_back(article);

                if (matches.size() >= 5) break;
            }
        }

        pos = endPos;
    }

    return matches;
}
};

#endif