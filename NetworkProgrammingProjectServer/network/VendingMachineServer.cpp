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
#include <arpa/inet.h>

#define SERVER_PORT 9001
#define BUFSIZE 1024
#define DATA_FILE "vending_machine_data.txt" // 음료 정보
#define SALES_FILE "sales_data.txt" // 매출 정보
#define USER_FILE "user_data.txt" // 유저 정보
#define MONEY_FILE "money_data.txt" // 화폐 정보
#define EXHAUSTION_FILE "exhaustion_date.txt" // 재고 소진 음료와 날짜 정보

std::mutex mtx;// 쓰레드 간 공유 자원인 데이터를 보호하기 위한 뮤텍스
std::vector<int> client_sockets;// 클라이언트 소켓을 보관하는 벡터
std::mutex clients_mtx;// 클라이언트 소켓에 대한 동시 접근을 보호하기 위한 뮤텍스

struct Drink {
    int stock;
    int price;
    std::string name;
};

struct User {
    std::string userId;
    std::string password;
};

// 음료 판매 기록
std::map<std::string, std::map<std::string, int>> drink_sales;

// 일 매출을 저장할 맵
std::map<std::string, int> daily_sales; // 트리 구조 사용

// 월 매출을 저장할 맵
std::map<std::string, int> monthly_sales;

// 각 음료별 일 매출을 저장할 맵
std::map<std::string, int> drink_daily_sales;

// 각 음료별 월 매출을 저장할 맵
std::map<std::string, int> drink_monthly_sales;

// 20204-06-07 형식으로 날짜를 생성하는 함수
std::string current_date() {
    time_t t = time(nullptr);
    tm* timePtr = localtime(&t);
    std::stringstream ss;
    ss << (timePtr->tm_year + 1900) << "-"
       << std::setw(2) << std::setfill('0') << (timePtr->tm_mon + 1) << "-"
       << std::setw(2) << std::setfill('0') << timePtr->tm_mday;
    return ss.str();
}

// 20204-06 형식으로 날짜를 생성하는 함수
std::string current_month() {
    time_t t = time(nullptr);
    tm* timePtr = localtime(&t);
    std::stringstream ss;
    ss << (timePtr->tm_year + 1900) << "-"
       << std::setw(2) << std::setfill('0') << (timePtr->tm_mon + 1);
    return ss.str();
}

// 20204-06-07 17:12 형식으로 날짜를 생성하는 함수
std::string current_date_time() {
    time_t t = time(nullptr);
    tm* timePtr = localtime(&t);
    std::stringstream ss;
    ss << (timePtr->tm_year + 1900) << "-"
       << std::setw(2) << std::setfill('0') << (timePtr->tm_mon + 1) << "-"
       << std::setw(2) << std::setfill('0') << timePtr->tm_mday << " "
       << timePtr->tm_hour << ":"
       << timePtr->tm_min;
    return ss.str();
}

// 파일에서 데이터 가져오는 부분
std::map<std::string, std::string> load_eh_date() {
    std::ifstream infile(EXHAUSTION_FILE);
    std::map<std::string, std::string> list;
    std::string date, drink;
    
    while(infile >> date >> drink) {
        list[date] = drink;
    }
    
    return list;
}

// 파일에서 매출 정보를 읽어오는 함수
void load_sales_data_response() {
    std::ifstream infile(SALES_FILE);
    std::string date, drink;
    int amount;

    while (infile >> date >> drink >> amount) {
        // 일 매출 계산
        daily_sales[date] += amount;
        
        // 월 매출 계산
        std::string month = date.substr(0, 7);
        monthly_sales[month] += amount;
        
        // 각 음료별 일 매출 계산
        std::string data = date + ":" + drink;
        drink_daily_sales[data] += amount;
        
        // 각 음료별 월 매출 계산
        std::string drink_month = month + ":" + drink;
        drink_monthly_sales[drink_month] += amount;
    }
}

// 매출 정보를 초기화하는 함수
void clear_sales_data() {
    daily_sales.clear();
    monthly_sales.clear();
    drink_daily_sales.clear();
    drink_monthly_sales.clear();
}

//파일에서 유저 정보를 불러오는 함수
User load_user() {
    std::ifstream infile(USER_FILE);
    User user;
    std::string userId, password;
    
    while(infile >> userId >> password) {
        user = { userId, password };
    }
    
    return user;
}

//파일에서 화폐 정보를 불러오는 함수
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

// 파일에서 음료 정보를 불러오는 함수
std::map<std::string, Drink> load_data() {
    std::ifstream infile(DATA_FILE);
    std::map<std::string, Drink> data;
    std::string name, fixedName;
    int stock, price;
    
    while (infile >> fixedName >> stock >> price >> name) {
        data[fixedName] = { stock, price, name };
    }
    
    return data;
}

// 재료 소진 정보를 파일에 쓰는 함수
void save_eh_date(const std::string& drink, const std::string& date) {
    std::ofstream outfile(EXHAUSTION_FILE, std::ios::app); // 파일의 제일 마지막에 추가
    outfile << date << " " << drink << " 재고 소진" << std::endl;
}

// 유저 정보를 파일에 쓰는 함수
void save_user(User user) {
    std::ofstream outfile(USER_FILE);
    outfile << user.userId << " " << user.password << std::endl;
}

//음료 정보를 파일에 쓰는 함수
void save_data(const std::map<std::string, Drink>& data) {
    std::ofstream outfile(DATA_FILE);
    for (const auto& item : data) {
        outfile << item.first << " " << item.second.stock << " " << item.second.price << " " << item.second.name << std::endl;
    }
}

//화폐 정보를 파일에 쓰는 함수
void save_money(const std::map<int, int>& data) {
    std::ofstream outfile(MONEY_FILE);
    for (const auto& item : data) {
        outfile << item.first << " " << item.second << std::endl;
    }
}

// 매출 정보를 파일에 쓰는 함수
void save_sales_data() {
    std::ofstream outfile(SALES_FILE);

    for (const auto& date_entry : drink_sales) {
        const std::string& date = date_entry.first;
        const std::map<std::string, int>& daily_sales = date_entry.second;
        for (const auto& drink_entry : daily_sales) {
            const std::string& drink = drink_entry.first;
            int sales_data = drink_entry.second;
            outfile << date << " " << drink << " " << sales_data << std::endl;
        }
    }
}

// 파일에서 매출 정보를 읽어오는 함수
void load_sales_data() {
    std::ifstream infile(SALES_FILE);
    std::string date, drink;
    int sales_data;

    while (infile >> date >> drink >> sales_data) {
        // 매출 데이터를 drink_sales 맵에 추가
        drink_sales[date][drink] = sales_data;
    }
}

// 클라이언트에게 메시지를 브로드캐스트하는 함수
void broadcast_message(const std::string& message) {
    std::lock_guard<std::mutex> lock(clients_mtx);
    for (int client_sock : client_sockets) {
        send(client_sock, message.c_str(), message.size(), 0);
    }
}

// 음료 구매 요청을 처리하는 함수
void handle_buy(int client_sock, const std::string& drink, int index, int quantity) {
    std::lock_guard<std::mutex> lock(mtx);
    auto data = load_data();
    std::string response;
    std::string date_time = current_date_time();
    std::string date = current_date();
    
    if (data.count(drink) && data[drink].stock >= quantity) {
        data[drink].stock -= quantity;
        save_data(data);
        
        drink_sales[date][drink] += data[drink].price;
                
        if (data[drink].stock == 0) {
            save_eh_date(drink, date_time);
        }
        
        response = "BUY: " + std::to_string(index) + " " + std::to_string(data[drink].stock) + "\nEND_OF_RESPONSE";
        
    } else {
        response = "Failed to buy " + drink + ". Not enough stock or invalid item.\n";
    }

    save_sales_data();
    
    broadcast_message(response);
}

// 돈 투입 요청을 처리하는 함수
void handle_insertMoney(int client_sock, int price, int index) {
    std::lock_guard<std::mutex> lock(mtx); // 동시 접근 방지
    auto data = load_money(); //현재 저장된 돈 데이터 불러옴
    std::string response;
    
    if (data.count(price)) {
        data[price] += 1;
        save_money(data);
        response = "INSERT: " + std::to_string(index) + " " + std::to_string(data[price]) + "\nEND_OF_RESPONSE";
    }
    
    broadcast_message(response);
}

// 잔돈 반환 요청을 처리하는 함수
void handle_return_money(int client_sock, const std::vector<int>& types, const std::vector<int>& counts) {
    std::lock_guard<std::mutex> lock(mtx); // 동시 접근 방지
    auto data = load_money(); //현재 저장된 돈 데이터 불러옴
    std::stringstream ss;
    
    for (size_t i = 0; i < types.size(); i++) {
        int type = types[i];
        int count = counts[i];
        
        data[type] -= count;
    }
    
    save_money(data);
    
    
    for (const auto& item: data) {
        ss << "RETURN: " << std::to_string(item.first) << " " << std::to_string(item.second) << std::endl;
    }
    ss << "END_OF_RESPONSE";
    std::string response = ss.str();
    broadcast_message(response);
}

// 재고 조회 요청을 처리하는 함수
void handle_stock(int client_sock) {
    std::lock_guard<std::mutex> lock(mtx);
    auto data = load_data();
    std::stringstream ss;

    for (const auto& item : data) {
        ss << "STOCK: " << item.first << " " << item.second.stock << " " << item.second.price << " " << item.second.name << std::endl;
    }
    ss << "END_OF_RESPONSE";
    std::string response = ss.str();
    broadcast_message(response);
}

// 음료 이름 변경 요청을 처리하는 함수
void handle_change_name(int client_sock, const std::string& old_name, const std::string& new_name) {
    std::lock_guard<std::mutex> lock(mtx);
    auto data = load_data();
    std::string response;
    
    std::string target;
    
    for (const auto& item : data) {
        if (item.second.name == old_name) {
            target = item.first;
        }
    }
    
    data[target].name = new_name;
    save_data(data);
    response = "CHANGENAME: " + old_name + " " + new_name + "\nEND_OF_RESPONSE";;

    broadcast_message(response);
}

// 사용자 정보 조회 요청을 처리하는 함수
void handle_userInfo(int client_sock) {
    std::lock_guard<std::mutex> lock(mtx);
    auto data = load_user();
    std::stringstream ss;
    
    ss << "USERINFO: " << data.userId << " " << data.password << std::endl;
    ss << "END_OF_RESPONSE";
    std::string response = ss.str();
    
    broadcast_message(response);
}

// 화폐 정보 조회 요청을 처리하는 함수
void handle_money(int client_sock) {
    std::lock_guard<std::mutex> lock(mtx);
    auto data = load_money();
    std::stringstream ss;
    
    for (const auto& item : data) {
        ss << "MONEYINFO: " << item.first << " " << item.second << std::endl;
    }
    ss << "END_OF_RESPONSE";
    std::string response = ss.str();
    broadcast_message(response);
}

// 비밀번호 변경 요청을 처리하는 함수
void handle_change_password(int client_sock, const std::string& new_password) {
    std::lock_guard<std::mutex> lock(mtx);
    auto data = load_user();
    
    User newUser;
    newUser = {data.userId, new_password};
    save_user(newUser);
    
    std::string response;
    
    response = "CHANGEPASSWORD: " + new_password + "\nEND_OF_RESPONSE";
    
    broadcast_message(response);
}

// 음료 가격 변경 요청을 처리하는 함수
void handle_change_price(int client_sock, const std::string& drink_name, const std::string& new_price) {
    std::lock_guard<std::mutex> lock(mtx);
    auto data = load_data();
    std::string response;

    if (data.count(drink_name)) {
        data[drink_name].price = std::stoi(new_price);
        save_data(data);
        response = "CHANGEPRICE: " + drink_name + " " + new_price + "\nEND_OF_RESPONSE";
    } else {
        response = "Failed" + drink_name + " does not exist.\n";
    }

    broadcast_message(response);
}

// 수금 요청을 처리하는 함수
void handle_collect(int client_sock) {
    std::lock_guard<std::mutex> lock(mtx);
    auto data = load_money();
    
    for (auto& money : data) {
        if (money.second > 10) {
            money.second = 10;
        }
    }
    
    save_money(data);
    
    std::string response = "COLLECT: \nEND_OF_RESPONSE";
    
    broadcast_message(response);
}

// 화폐 보충 요청을 처리하는 함수
void handle_moneyreplenishment(int client_sock) {
    std::lock_guard<std::mutex> lock(mtx);
    auto data = load_money();
    
    for (auto& money : data) {
        if (money.second < 10) {
            money.second = 10;
        }
    }
    
    save_money(data);
    
    std::string response = "MONEYREPLENISHMENT: \nEND_OF_RESPONSE";
    
    broadcast_message(response);
}

// 음료 보충 요청을 처리하는 함수
void handle_drinkreplenishment(int client_sock) {
    std::lock_guard<std::mutex> lock(mtx);
    auto data = load_data();
    
    for (auto& drink : data) {
        drink.second.stock = 10;
    }
    
    save_data(data);
    
    std::string response = "DRINKREPLENISHMENT: \nEND_OF_RESPONSE";
    
    broadcast_message(response);
}

// 매출 정보 조회 요청을 처리하는 함수
void handle_fetch_Sales(int client_sock) {
    std::lock_guard<std::mutex> lok(mtx);
    
    load_sales_data_response();
    
    // 일 매출, 월 매출, 각 음료별 일 매출, 각 음료별 월 매출을 하나의 문자열로 합치기
    std::stringstream response_ss;
    
    response_ss << "SALES: \n";
    
    // 일 매출 추가
    response_ss << "Daily_Sales: ";
    for (const auto& entry : daily_sales) {
        response_ss << entry.first << ":" << entry.second << " ";
    }
    response_ss << "\n";
    
    // 월 매출 추가
    response_ss << "Monthly_Sales: ";
    for (const auto& entry : monthly_sales) {
        response_ss << entry.first << ":" << entry.second << " ";
    }
    response_ss << "\n";
    
    // 각 음료별 일 매출 추가
    response_ss << "Drink_Daily_Sales: ";
    for (const auto& entry : drink_daily_sales) {
        response_ss << entry.first << ":" << entry.second << " ";
    }
    response_ss << "\n";
    
    // 각 음료별 월 매출 추가
    response_ss << "Drink_Monthly_Sales: ";
    for (const auto& entry : drink_monthly_sales) {
        response_ss << entry.first << ":" << entry.second << " ";
    }
    response_ss << "\n";
    
    response_ss << "END_OF_RESPONSE";
    
    clear_sales_data();
    
    std::string response = response_ss.str();
    
    size_t total_bytes_sent = 0;
    size_t response_size = response.size();
    
    while (total_bytes_sent < response_size) {
        ssize_t bytes_sent = send(client_sock, response.c_str() + total_bytes_sent, response_size - total_bytes_sent, 0);
        if (bytes_sent == -1) {
            // 에러 발생 시 처리
            perror("send");
            close(client_sock);
            return;
        }
        total_bytes_sent += bytes_sent;
    }
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
        
        // 클라이언트로부터 받은 명령에 따라 처리하는 부분
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
        } else if (command == "CHANGE_PRICE") {
            std::string drink_name, price_str;
            ss >> drink_name >> price_str;
            handle_change_price(client_sock, drink_name, price_str);
        } else if (command == "CHANGE_PASSWORD") {
            std::string new_password;
            ss >> new_password;
            handle_change_password(client_sock, new_password);
        } else if (command == "CHANGE_PRICE"){
            std::string old_price, new_price;
            ss >> old_price >> new_price;
            handle_change_price(client_sock, old_price, new_price);
        } else if (command == "COLLECT") {
            handle_collect(client_sock);
        } else if (command == "MONEYREPLENISHMENT") {
            handle_moneyreplenishment(client_sock);
        } else if (command == "DRINKREPLENISHMENT") {
            handle_drinkreplenishment(client_sock);
        } else if (command == "RETURN_MONEY") {
            std::vector<int> types(5);
            std::vector<int> counts(5);
            
            for (int i = 0; i < 5; ++i) {
                ss >> types[i] >> counts[i];
            }
            
            handle_return_money(client_sock, types, counts);
        } else if (command == "FETCHSALES") {
            handle_fetch_Sales(client_sock);
        } else {
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
    load_sales_data(); // 매출 데이터 로드
    int server_sock = socket(AF_INET, SOCK_STREAM, 0); // 서버 소켓 생성
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
        // 클라이언트의 IP 주소를 문자열로 변환하여 출력
        char ip_address[INET_ADDRSTRLEN]; // IP 주소를 저장할 버퍼
        inet_ntop(AF_INET, &(client_addr.sin_addr), ip_address, INET_ADDRSTRLEN); // 네트워크 주소를 문자열로 변환
        std::cout << "Client connected, IP: " << ip_address << ", Port: " << ntohs(client_addr.sin_port) << std::endl;
        std::thread(handle_client, client_sock).detach(); // 클라이언트 핸들링을 위한 스레드 생성 및 분리
    }
    
    close(server_sock);
    return 0;
}
