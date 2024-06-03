//
//  VendingMachineViewModel.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/29/24.
//
import Foundation
import Network

enum Action {
    case insertMoney(index: Int)
    case purchase(index: Int)
    case returnMoney
    case fetchStock
    case fetchUser
    case fetchMoney
    case changePassword(newPassword: String)
}

final class VendingMachineViewModel: ObservableObject {
    @Published var drinks: [Drink] = []
    @Published var moneys: [Money] = []
    @Published var userID: String = ""
    @Published var password: String = ""
    
    
    @Published var isDisplayCountAlert: Bool
    @Published var isDisplaySoldoutAlert: Bool
    @Published var insertMoney: Int
    
    var count: Int // 지패 투입 개수 저장
    
    private var drinkIndex: Int = 0
    private var moneyIndex: Int = 0
    
    private var connection: NWConnection?

    init(insertMoney: Int = 0, isDisplayCountAlert: Bool = false, isDisplaySoldoutAlert: Bool = false, count: Int = 0) {
        self.insertMoney = insertMoney
        self.isDisplayCountAlert = isDisplayCountAlert
        self.isDisplaySoldoutAlert = isDisplaySoldoutAlert
        self.count = count
        setupConnection()
        send(action: .fetchStock)
        send(action: .fetchUser)
        send(action: .fetchMoney)
    }

    private func setupConnection() {
        let host = NWEndpoint.Host("127.0.0.1")
        let port = NWEndpoint.Port(integerLiteral: 9000)

        connection = NWConnection(host: host, port: port, using: .tcp)
        connection?.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("Connected to server")
                self.receiveMessage()
            case .failed(let error):
                print("Failed to connect: \(error)")
            default:
                break
            }
        }

        connection?.start(queue: .main)
    }

    private func sendMessage(_ message: String) {
        guard let connection = connection else { return }

        let data = message.data(using: .utf8)
        connection.send(content: data, completion: .contentProcessed({ sendError in
            if let error = sendError {
                print("Failed to send message: \(error)")
            }
        }))
    }

    private func receiveMessage() {
        guard let connection = connection else { return }

        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                if let response = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.handleServerResponse(response)
                    }
                }
            }

            if isComplete {
                print("연결 종료")
                connection.cancel()
            } else if let error = error {
                print("Failed to receive message: \(error)")
                self.receiveMessage()
            } else {
                self.receiveMessage()
            }
        }
    }
    
    private func handleServerResponse(_ response: String) {
        if response.hasPrefix("STOCK:") {
            parseStockResponse(response)
            } else if response.hasPrefix("BUY:") {
                buyResponse(response)
            } else if response.hasPrefix("USERINFO: ") {
                userInfoResponse(response)
            } else if  response.hasPrefix("MONEYINFO: "){
                moneyInfoResponse(response)
            } else if response.hasPrefix("INSERT: "){
                insertResponse(response)
            } else if response.hasPrefix("CHANGEPASSWORD: ") {
                
            } else {
//                parseStockResponse(response)
            }
    }

    private func parseStockResponse(_ response: String) {
        var newDrinks: [Drink] = []
        let lines = response.split(separator: "\n")
        for line in lines {
            let components = line.split(separator: " ")
            if components.count == 4, let stock = Int(components[2]), let price = Int(components[3]) {
                let drink = Drink(name: String(components[1]), price: price, stock: stock)
                newDrinks.append(drink)
            }
        }
        DispatchQueue.main.async {
            self.drinks = newDrinks
        }
    }

    private func buyResponse(_ response: String) {
        let response = response.split(separator: " ")
        
        self.drinks[Int(response[1])!].stock = Int(response[2])!
    }
    
    private func insertResponse(_ response: String) {
        let response = response.split(separator: " ")
        
        self.moneys[Int(response[1])!].stock = Int(response[2])!
    }
    
    private func userInfoResponse(_ response: String) {
        let response = response.split(separator: " ")
        
        self.userID = String(response[1])
        self.password = String(response[2])
    }
    
    private func moneyInfoResponse(_ response: String) {
        var newMoney: [Money] = []
        let lines = response.split(separator: "\n")
        for line in lines {
            let components = line.split(separator: " ")
            if components.count == 3, let stock = Int(components[2]), let price = Int(components[1]) {
                let money = Money(price: price, stock: stock)
                newMoney.append(money)
            }
        }
        DispatchQueue.main.async {
            self.moneys = newMoney
        }
    }
    
    func fetchStock() {
        sendMessage("STOCK")
        receiveMessage()
    }

    func buyDrink(_ name: String) {
        sendMessage("BUY \(name) \(self.drinkIndex) 1")
        receiveMessage()
    }
    
    func fetchMoney() {
        sendMessage("MONEY")
        receiveMessage()
    }
    
    func insertMoney(_ price: Int) {
        sendMessage("INSERTMONEY \(price) \(self.moneyIndex)")
        receiveMessage()
    }
    
    func fetchUserInfo() {
        sendMessage("USERINFO")
        receiveMessage()
    }
//
//    func changeDrinkName() {
//        sendMessage("CHANGE_NAME \(oldName) \(newName)")
//        receiveMessage()
//    }
    
    func send(action: Action) {
        switch action {
        case .insertMoney(let index):
            if insertMoney + moneys[index].price <= 7000 {
                if moneys[index].price == 1000 {
                    count += 1
                }
                insertMoney += moneys[index].price
                moneys[index].stock += 1
                insertMoney(moneys[index].price)
            }
        case .purchase(let index):
            if drinks[index].stock != 0 {
                if insertMoney >= drinks[index].price {
                    drinkIndex = index
                    insertMoney -= drinks[index].price
                    drinks[index].stock -= 1
                    buyDrink(drinks[index].name)
                }
            }
        case .returnMoney:
            break
        case .fetchStock:
            fetchStock()
        case .fetchUser:
            fetchUserInfo()
        case .fetchMoney:
            fetchMoney()
        case .changePassword(newPassword: let newPassword):
            <#code#>
        }
    }
}
