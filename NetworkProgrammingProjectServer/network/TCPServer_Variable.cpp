//
//  TCPServer6.cpp
//  network
//
//  Created by 최안용 on 5/14/24.
//

#include "Common.h"
#include <pthread.h>

#define SERVERPORT 9000
#define BUFSIZE    512

typedef struct {
    char name[50];
    int stock;
    int dailySales;
    int monthlySales;
} Drink;

typedef struct {
    Drink drinks[10];
    int drinkCount;
} VendingMachine;

VendingMachine vendingMachine;

void loadVendingMachineData() {
    FILE *file = fopen("무제.txt", "r");
    if (file == NULL) {
        perror("fopen");
        return;
    }

    char line[BUFSIZE];
    vendingMachine.drinkCount = 0;
    while (fgets(line, sizeof(line), file)) {
        sscanf(line, "%[^:]:%d:%d:%d",
               vendingMachine.drinks[vendingMachine.drinkCount].name,
               &vendingMachine.drinks[vendingMachine.drinkCount].stock,
               &vendingMachine.drinks[vendingMachine.drinkCount].dailySales,
               &vendingMachine.drinks[vendingMachine.drinkCount].monthlySales);
        vendingMachine.drinkCount++;
    }

    fclose(file);
}

void saveVendingMachineData() {
    FILE *file = fopen("vending_machine.txt", "w");
    if (file == NULL) {
        perror("fopen");
        return;
    }

    for (int i = 0; i < vendingMachine.drinkCount; i++) {
        fprintf(file, "%s:%d:%d:%d\n",
                vendingMachine.drinks[i].name,
                vendingMachine.drinks[i].stock,
                vendingMachine.drinks[i].dailySales,
                vendingMachine.drinks[i].monthlySales);
    }

    fclose(file);
}

void initVendingMachine() {
    loadVendingMachineData();

    // 기본 음료 설정 (파일이 없을 경우 초기 설정)
    if (vendingMachine.drinkCount == 0) {
        strcpy(vendingMachine.drinks[0].name, "물");
        vendingMachine.drinks[0].stock = 10;
        vendingMachine.drinks[0].dailySales = 0;
        vendingMachine.drinks[0].monthlySales = 0;

        strcpy(vendingMachine.drinks[1].name, "커피");
        vendingMachine.drinks[1].stock = 10;
        vendingMachine.drinks[1].dailySales = 0;
        vendingMachine.drinks[1].monthlySales = 0;

        vendingMachine.drinkCount = 2;
        saveVendingMachineData();
    }
}


int recvline(SOCKET s, char *buf, int maxlen)
{
    int n, nbytes;
    char c, *ptr = buf;

    for (n = 1; n < maxlen; n++) {
        nbytes = recv(s, &c, 1, 0);
        if (nbytes == 1) {
            *ptr++ = c;
            if (c == '\n')
                break;
        }
        else if (nbytes == 0) {
            *ptr = 0;
            return n - 1;
        }
        else {
            return SOCKET_ERROR;
        }
    }

    *ptr = 0;
    return n;
}

void updateSalesData(char *drinkName, int quantity) {
    for (int i = 0; i < vendingMachine.drinkCount; i++) {
        if (strcmp(vendingMachine.drinks[i].name, drinkName) == 0) {
            vendingMachine.drinks[i].dailySales += quantity;
            vendingMachine.drinks[i].monthlySales += quantity;
            vendingMachine.drinks[i].stock -= quantity;

            if (vendingMachine.drinks[i].stock < 5) {
                printf("관리자 알림: %s 음료 재고가 부족합니다.\n", vendingMachine.drinks[i].name);
            }
            saveVendingMachineData();
            break;
        }
    }
}

void handleRequest(char *request, char *response) {
    char *cmd = strtok(request, ":");
    if (strcmp(cmd, "BUY") == 0) {
        char *drinkName = strtok(NULL, ":");
        int quantity = atoi(strtok(NULL, ":"));

        updateSalesData(drinkName, quantity);
        snprintf(response, BUFSIZE, "PURCHASED:%s:%d\n", drinkName, quantity);
    } else if (strcmp(cmd, "STOCK") == 0) {
        snprintf(response, BUFSIZE, "STOCK:");
        for (int i = 0; i < vendingMachine.drinkCount; i++) {
            char drinkInfo[50];
            snprintf(drinkInfo, 50, "%s:%d,", vendingMachine.drinks[i].name, vendingMachine.drinks[i].stock);
            strcat(response, drinkInfo);
        }
        strcat(response, "\n");
    } else if (strcmp(cmd, "CHANGE_NAME") == 0) {
        char *oldName = strtok(NULL, ":");
        char *newName = strtok(NULL, ":");

        for (int i = 0; i < vendingMachine.drinkCount; i++) {
            if (strcmp(vendingMachine.drinks[i].name, oldName) == 0) {
                strcpy(vendingMachine.drinks[i].name, newName);
                snprintf(response, BUFSIZE, "NAME_CHANGED:%s:%s\n", oldName, newName);
                saveVendingMachineData();
                break;
            }
        }
    }
}


void *handle_client(void *arg) {
    SOCKET client_sock = *(SOCKET *)arg;
    free(arg);

    // 클라이언트와 데이터 통신
    char buf[BUFSIZE + 1];
    int retval;
    struct sockaddr_in clientaddr;
    socklen_t addrlen = sizeof(clientaddr);

    getpeername(client_sock, (struct sockaddr *)&clientaddr, &addrlen);

    char addr[INET_ADDRSTRLEN];
    inet_ntop(AF_INET, &clientaddr.sin_addr, addr, sizeof(addr));

    printf("\n[TCP 서버] 클라이언트 접속: IP 주소=%s, 포트 번호=%d\n",
           addr, ntohs(clientaddr.sin_port));

    while (1) {
        // 데이터 받기
        retval = recvline(client_sock, buf, BUFSIZE + 1);
        if (retval == SOCKET_ERROR) {
            err_display("recv()");
            break;
        }
        else if (retval == 0)
            break;

        // 받은 데이터 출력
        printf("[TCP/%s:%d] %s", addr, ntohs(clientaddr.sin_port), buf);
        
        // 클라이언트에게 데이터 보내기
             const char *response = "Hello from server!\n";
             retval = send(client_sock, response, strlen(response), 0);
             if (retval == SOCKET_ERROR) {
                 err_display("send()");
                 break;
             }
    }

    // 소켓 닫기
    close(client_sock);
    printf("[TCP 서버] 클라이언트 종료: IP 주소=%s, 포트 번호=%d\n",
           addr, ntohs(clientaddr.sin_port));

    return NULL;
}

int main(int argc, char *argv[])
{
    int retval;
    
    initVendingMachine();

    
    
    // 소켓 생성
    SOCKET listen_sock = socket(AF_INET, SOCK_STREAM, 0);
    if (listen_sock == INVALID_SOCKET) err_quit("socket()");

    // bind()
    struct sockaddr_in serveraddr;
    memset(&serveraddr, 0, sizeof(serveraddr));
    serveraddr.sin_family = AF_INET;
    serveraddr.sin_addr.s_addr = htonl(INADDR_ANY);
    serveraddr.sin_port = htons(SERVERPORT);
    retval = bind(listen_sock, (struct sockaddr *)&serveraddr, sizeof(serveraddr));
    if (retval == SOCKET_ERROR) err_quit("bind()");

    // listen()
    retval = listen(listen_sock, SOMAXCONN);
    if (retval == SOCKET_ERROR) err_quit("listen()");

    while (1) {
        // accept()
        SOCKET *client_sock = (SOCKET *)malloc(sizeof(SOCKET));
        if (client_sock == NULL) {
            err_display("malloc()");
            continue;
        }
        
        struct sockaddr_in clientaddr;
        socklen_t addrlen = sizeof(clientaddr);
        *client_sock = accept(listen_sock, (struct sockaddr *)&clientaddr, &addrlen);
        if (*client_sock == INVALID_SOCKET) {
            err_display("accept()");
            free(client_sock);
            continue;
        }

        // 새로운 스레드에서 클라이언트 처리
        pthread_t tid;
        retval = pthread_create(&tid, NULL, handle_client, (void *)client_sock); // 타입 캐스팅 추가
        if (retval != 0) {
            err_display("pthread_create()");
            close(*client_sock);
            free(client_sock);
        } else {
            pthread_detach(tid); // 스레드가 종료되면 리소스를 자동으로 회수하도록 분리
        }
    }

    // 소켓 닫기
    close(listen_sock);
    return 0;
}
