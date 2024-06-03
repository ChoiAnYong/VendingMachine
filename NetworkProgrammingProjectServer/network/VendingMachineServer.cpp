//
//  VendingMachineServer.cpp
//  network
//
//  Created by 최안용 on 6/1/24.
//

#include "VendingMachineServer.hpp"
#include <iostream>
#include <fstream>
#include <string>
#include <map>
#include <vector>
#include <thread>
#include <mutex>
#include <sstream>
#include <ctime>
#include <netinet/in.h>
#include <unistd.h>
#include <arpa/inet.h>

#define SERVER_PORT 9000
#define BUFSIZE 1024
#define DATA_FILE "vending_machine_data.txt"
#define SALES_FILE "sales_data.txt"
#define USER_FILE "user_data.txt"
#define MONEY_FILE "money_data.txt"

std::mutex mtx;
std::vector<int> client_sockets;
std::mutex clients_mtx;

struct Drink {
    int stock;
    int price;
};

struct User {
    std::string userId;
    std::string password;
};

User load_user() {
    std::ifstream infile(USER_FILE);
    User user;
    std::string userId, password;
    
    while(infile >> userId >> password) {
        user = { userId, password };
    }
    
    return user;
}

std::map<int, int> load_money() {
    std::ifstream infile(MONEY_FILE);
    std::map<int, int> moneys;
    int price;
    int stock;
    
    while(infile >> price >> stock) {
        moneys[price] = stock;
    }
    
    return moneys;
}

std::map<std::string, Drink> load_data() {
    std::ifstream infile(DATA_FILE);
    std::map<std::string, Drink> data;
    std::string name;
    int stock, price;
    
    while (infile >> name >> stock >> price) {
        data[name] = { stock, price };
    }
    
    return data;
}

std::map<std::string, std::map<std::string, int>> load_sales() {
    std::ifstream infile(SALES_FILE);
    std::map<std::string, std::map<std::string, int>> sales;
    std::string date, drink;
    int amount;
    
    while (infile >> date >> drink >> amount) {
        sales[date][drink] += amount;
    }
    
    return sales;
}

void save_user(User user) {
    std::ofstream outfile(USER_FILE);
    outfile << user.userId << " " << user.password << std::endl;
}

void save_data(const std::map<std::string, Drink>& data) {
    std::ofstream outfile(DATA_FILE);
    for (const auto& item : data) {
        outfile << item.first << " " << item.second.stock << " " << item.second.price << std::endl;
    }
}

void save_money(const std::map<int, int>& data) {
    std::ofstream outfile(MONEY_FILE);
    for (const auto& item : data) {
        outfile << item.first << " " << item.second << std::endl;
    }
}

void save_sales(const std::map<std::string, std::map<std::string, int>>& sales) {
    std::ofstream outfile(SALES_FILE);
    for (const auto& day : sales) {
        for (const auto& item : day.second) {
            outfile << day.first << " " << item.first << " " << item.second << std::endl;
        }
    }
}

std::string current_date() {
    time_t t = time(nullptr);
    tm* timePtr = localtime(&t);
    std::stringstream ss;
    ss << (timePtr->tm_year + 1900) << "-"
       << (timePtr->tm_mon + 1) << "-"
       << timePtr->tm_mday;
    return ss.str();
}

void update_sales_data(const std::string& drink, int quantity, int price) {
    std::lock_guard<std::mutex> lock(mtx);
    auto sales = load_sales();
    std::string date = current_date();
    sales[date][drink] += quantity * price;
    save_sales(sales);
}

void broadcast_message(const std::string& message) {
    std::lock_guard<std::mutex> lock(clients_mtx);
    for (int client_sock : client_sockets) {
        send(client_sock, message.c_str(), message.size(), 0);
    }
}

void handle_buy(int client_sock, const std::string& drink, int index, int quantity) {
    std::lock_guard<std::mutex> lock(mtx);
    auto data = load_data();
    std::string response;

    if (data.count(drink) && data[drink].stock >= quantity) {
        data[drink].stock -= quantity;
        save_data(data);
//        update_sales_data(drink, quantity, data[drink].price);
        response = "BUY: " + std::to_string(index) + " " + std::to_string(data[drink].stock);
        
    } else {
        response = "Failed to buy " + drink + ". Not enough stock or invalid item.\n";
    }

    broadcast_message(response);
}

void handle_insertMoney(int client_sock, int price, int index) {
    std::lock_guard<std::mutex> lock(mtx);
    auto data = load_money();
    std::string response;
    
    if (data.count(price)) {
        data[price] += 1;
        save_money(data);
        response = "INSERT: " + std::to_string(index) + " " + std::to_string(data[price]);
    }
}

void handle_stock(int client_sock) {
    std::lock_guard<std::mutex> lock(mtx);
    auto data = load_data();
    std::stringstream ss;

    for (const auto& item : data) {
        ss << "STOCK: " << item.first << " " << item.second.stock << " " << item.second.price << std::endl;
    }

    std::string response = ss.str();
    broadcast_message(response);
}

void handle_change_name(int client_sock, const std::string& old_name, const std::string& new_name) {
    std::lock_guard<std::mutex> lock(mtx);
    auto data = load_data();
    std::string response;

    if (data.count(old_name)) {
        data[new_name] = data[old_name];
        data.erase(old_name);
        save_data(data);
        response = "Successfully changed name from " + old_name + " to " + new_name + "\n";
    } else {
        response = "Failed to change name. " + old_name + " does not exist.\n";
    }

    broadcast_message(response);
}

void handle_userInfo(int client_sock) {
    std::lock_guard<std::mutex> lock(mtx);
    auto data = load_user();
    std::stringstream ss;
    
    
    ss << "USERINFO: " << data.userId << " " << data.password << std::endl;
    
    std::string response = ss.str();
    
    broadcast_message(response);
}

void handle_money(int client_sock) {
    std::lock_guard<std::mutex> lock(mtx);
    auto data = load_money();
    std::stringstream ss;
    
    for (const auto& item : data) {
        ss << "MONEYINFO: " << item.first << " " << item.second << std::endl;
    }
    
    std::string response = ss.str();
    broadcast_message(response);
}

void handle_change_password(int client_sock, const std::string& old_password, const std::string& new_password) {
    std::lock_guard<std::mutex> lock(mtx);
    auto data = load_user();
    std::string response;

    
    response = "CHANGEPASSWORD: " + new_password;
    

    broadcast_message(response);
}


void handle_change_price(int client_sock, const std::string& old_price, const std::string& new_price) {
    std::lock_guard<std::mutex> lock(mtx);
    auto data = load_data();
    std::string response;

    if (data.count(old_price)) {
        data[new_price] = data[old_price];
        data.erase(old_price);
        save_data(data);
        response = "Successfully changed price from " + old_price + " to " + new_price + "\n";
    } else {
        response = "Failed to change price. " + old_price + " does not exist.\n";
    }

    broadcast_message(response);
}

void handle_client(int client_sock) {
    {
        std::lock_guard<std::mutex> lock(clients_mtx);
        client_sockets.push_back(client_sock);
    }
    
    char buf[BUFSIZE];
    while (true) {
        int bytes_received = recv(client_sock, buf, BUFSIZE, 0);
        if (bytes_received <= 0) {
            std::cout << "Client disconnected or error occurred, client_sock: " << client_sock << std::endl;
            break;
        }
        buf[bytes_received] = '\0';
        std::string message(buf);

        std::stringstream ss(message);
        std::string command, drink, quantity_str, index_str, price_str;
        ss >> command;

        if (command == "BUY") {
            ss >> drink >> index_str >> quantity_str;
            int quantity = std::stoi(quantity_str);
            int index = std::stoi(index_str);
            handle_buy(client_sock, drink, index, quantity);
        } else if (command == "STOCK") {
            handle_stock(client_sock);
        } else if (command == "USERINFO") {
            handle_userInfo(client_sock);
        } else if (command == "MONEY"){
            handle_money(client_sock);
        } else if (command == "INSERTMONEY") {
            ss >> price_str >> index_str;
            int price = std::stoi(price_str);
            int index = std::stoi(index_str);
            handle_insertMoney(client_sock, price, index);
        }else if (command == "CHANGE_NAME") {
            std::string old_name, new_name;
            ss >> old_name >> new_name;
            handle_change_name(client_sock, old_name, new_name);
        } else if (command == "CHANGE_PASSWORD") {
            std::string old_password, new_password;
            ss >> old_password >> new_password;
            handle_change_password(client_sock, old_password, new_password);
        } else if (command == "CHANGE_PRICE"){
            std::string old_price, new_price;
            ss >> old_price >> new_price;
            handle_change_price(client_sock, old_price, new_price);
        }else {
            std::string response = "Unknown command\n";
            broadcast_message(response);
        }
    }

    close(client_sock);
    {
        std::lock_guard<std::mutex> lock(clients_mtx);
        client_sockets.erase(std::remove(client_sockets.begin(), client_sockets.end(), client_sock), client_sockets.end());
    }
}

int main() {
    int server_sock = socket(AF_INET, SOCK_STREAM, 0);
    if (server_sock == -1) {
        perror("socket");
        return 1;
    }

    sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(SERVER_PORT);

    if (bind(server_sock, (sockaddr*)&server_addr, sizeof(server_addr)) == -1) {
        perror("bind");
        close(server_sock);
        return 1;
    }

    if (listen(server_sock, SOMAXCONN) == -1) {
        perror("listen");
        close(server_sock);
        return 1;
    }

    std::cout << "Server started on port " << SERVER_PORT << std::endl;

    while (true) {
        sockaddr_in client_addr;
        socklen_t client_size = sizeof(client_addr);
        int client_sock = accept(server_sock, (sockaddr*)&client_addr, &client_size);

        if (client_sock == -1) {
            perror("accept");
            continue;
        }
        
        std::cout << "Client connected, client_sock: " << client_sock << std::endl;
        std::thread(handle_client, client_sock).detach();
    }
    
    close(server_sock);
    return 0;
}
