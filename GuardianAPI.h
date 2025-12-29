#ifndef GUARDIAN_API_H
#define GUARDIAN_API_H

#include <string>
#include <vector>
#include <curl/curl.h>
#include <iostream>
#include <sstream>
#include "config.h"


class GuardianAPI {
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
        std::string description;
    };

    static std::string fetchNews(const std::string& keyword = "", int pageSize = 5) {
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
                return "{\"error\": \"Failed to fetch news\"}";
            }
        }

        return readBuffer;
    }

    static std::vector<NewsArticle> parseNews(const std::string& jsonResponse) {
        std::vector<NewsArticle> articles;

        // Simple JSON parsing without external library
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

            // Extract date
            size_t datePos = jsonResponse.find("\"webPublicationDate\":\"", pos);
            if (datePos != std::string::npos) {
                datePos += 22;
                size_t dateEnd = jsonResponse.find("\"", datePos);
                article.date = jsonResponse.substr(datePos, dateEnd - datePos);
            }

            articles.push_back(article);
            pos = endPos;

            if (articles.size() >= 5) break;
        }

        return articles;
    }

    static std::string formatNewsResponse(const std::vector<NewsArticle>& articles) {
        if (articles.empty()) {
            return "Sorry, no news found at the moment. Please try again later.";
        }

        std::stringstream response;
        response << " Latest News from The Guardian:\n\n";

        int count = 1;
        for (const auto& article : articles) {
            response << count++ << ". " << article.title << "\n";
            response << "   Section: " << article.section << "\n";
            response  << article.url << "\n\n";
        }

        response << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        response << "Powered by The Guardian\n";

        return response.str();
    }
};

#endif