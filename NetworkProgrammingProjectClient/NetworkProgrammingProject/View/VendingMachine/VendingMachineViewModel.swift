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
    case collectMoney
    case moneyReplenishment
    case drinkReplenishment
    case changeName(oldName: String, newName: String)
    case changePrice(drinkName: String, price: String)
    case fetchSales
}

enum DrinkAlert {
    case success
    case fail
}

final class VendingMachineViewModel: ObservableObject {
    @Published var drinks: [Drink] = []
    @Published var moneys: [Money] = []
    @Published var userID: String = ""
    @Published var password: String = ""
    @Published var insertMoney: Int
    @Published var isPresent: Bool = false
    @Published var selectedDrink: Drink?
    @Published var isPresentDrinkAlert: Bool = false
    @Published var isReturnMoneyAlert: Bool = false
    @Published var sales: Sales = Sales()
    
    var alertMode: DrinkAlert = .success
    var count: Int // 지패 투입 개수 저장
    
    private var drinkIndex: Int = 0
    private var moneyIndex: Int = 0
    private var connection: NWConnection?
    var returnMoneyList: [Int] = Array.init(repeating: 0, count: 5)
    
    init(insertMoney: Int = 0, count: Int = 0) {
        self.insertMoney = insertMoney
        self.count = count
        setupConnection()
        send(action: .fetchUser)
    }
    
    func send(action: Action) {
        switch action {
        case .insertMoney(let index):
            if insertMoney + moneys[index].price <= 7000 {
                if moneys[index].price == 1000 {
                    count += 1
                }
                moneyIndex = index
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
                    buyDrink(drinks[index].fixedName)
                }
            }
        case .returnMoney:
            returnMoney()
        case .fetchStock:
            fetchStock()
        case .fetchUser:
            fetchUserInfo()
        case .fetchMoney:
            fetchMoney()
        case .changePassword(newPassword: let newPassword):
            updateUserInfo(newPassword)
        case .collectMoney:
            collectMoeny()
        case .moneyReplenishment:
            moneyReplenishment()
        case .drinkReplenishment:
            drinkReplenishment()
        case .changeName(oldName: let oldName, newName: let newName):
            changeName(oldName, newName)
        case .changePrice(drinkName: let drinkName, price: let price):
            changePrice(drinkName, price)
        case .fetchSales:
            fetchSales()
        }
    }
    private var receiveData = Data()
}

extension VendingMachineViewModel {
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
                self.receiveData.append(data)
                if let response = String(data: self.receiveData, encoding: .utf8), response.contains("END_OF_RESPONSE") {
                    let completeResponse = response.replacingOccurrences(of: "END_OF_RESPONSE", with: "")
                    DispatchQueue.global().async {
                        self.handleServerResponse(completeResponse)
                        self.receiveData = Data() // 응답 처리 후 데이터 초기화
                    }
                }
            }
            
            if isComplete {
                print("연결 종료")
                connection.cancel()
            } else if let error = error {
                print("Failed to receive message: \(error)")
                DispatchQueue.global().async {
                    self.receiveMessage()
                }
            } else {
                DispatchQueue.global().async {
                    self.receiveMessage()
                }
            }
        }
    }
    
    private func handleServerResponse(_ response: String) {
        DispatchQueue.main.async {
            if response.hasPrefix("STOCK:") {
                self.parseStockResponse(response)
            } else if response.hasPrefix("BUY:") {
                self.buyResponse(response)
            } else if response.hasPrefix("USERINFO: ") {
                self.userInfoResponse(response)
            } else if  response.hasPrefix("MONEYINFO: "){
                self.moneyInfoResponse(response)
            } else if response.hasPrefix("INSERT: "){
                self.insertResponse(response)
            } else if response.hasPrefix("CHANGEPASSWORD: ") {
                self.changeUserInfoResponse(response)
            } else if response.hasPrefix("COLLECT: ") {
                self.collectResponse()
            } else if response.hasPrefix("MONEYREPLENISHMENT: ") {
                self.moneyReplenishmentResponse()
            } else if response.hasPrefix("DRINKREPLENISHMENT: ") {
                self.drinkReplenishmentResponse()
            } else if response.hasPrefix("CHANGENAME: ") {
                self.changeNameResponse(response)
            } else if response.hasPrefix("CHANGEPRICE: ") {
                self.changePriceResponse(response)
            } else if response.hasPrefix("RETURN: ") {
                self.returnMoneyResponse(response)
            } else if response.hasPrefix("SALES: ") {
                self.salesResponse(response)
            } else {
            }
        }
    }
    
    private func salesResponse(_ response: String) {
        var lines = response.split(separator: "\n")
        lines.remove(at: 0)
        
        var result = Sales()
        for line in lines {
            var components = line.split(separator: " ")
            
            if components[0] == "Daily_Sales:" {
                components.remove(at: 0)
                for i in components.indices {
                    let sales = components[i].split(separator: ":")
                    result.dailySales.append((String(sales[0]), Int(sales[1])!))
                }
            } else if components[0] == "Monthly_Sales:" {
                components.remove(at: 0)
                for i in components.indices {
                    let sales = components[i].split(separator: ":")
                    result.monthSales.append((String(sales[0]), Int(sales[1])!))
                }
            } else if components[0] == "Drink_Daily_Sales:" {
                components.remove(at: 0)
                for i in components.indices {
                    let sales = components[i].split(separator: ":")
                    result.drinkDailySales.append((String(sales[0]), String(sales[1]), Int(sales[2])!))
                }
            } else if components[0] == "Drink_Monthly_Sales:" {
                components.remove(at: 0)
                for i in components.indices {
                    let sales = components[i].split(separator: ":")
                    result.drinkMonthSales.append((String(sales[0]), String(sales[1]), Int(sales[2])!))
                }
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.sales = result
        }
    }
    
    private func parseStockResponse(_ response: String) {
        var newDrinks: [Drink] = []
        let lines = response.split(separator: "\n")
        for line in lines {
            let components = line.split(separator: " ")
            if components.count == 5, let stock = Int(components[2]), let price = Int(components[3]) {
                let drink = Drink(name: String(components[4]), price: price, stock: stock, fixedName: String(components[1]))
                newDrinks.append(drink)
            }
        }
        DispatchQueue.main.async { [weak self] in
            self?.drinks = newDrinks.sorted(by: {$0.price < $1.price}) //버블 정렬
        }
    }
    
    private func returnMoneyResponse(_ response: String) {
        var newMoneys: [Money] = []
        let lines = response.split(separator: "\n")
        for line in lines {
            let components = line.split(separator: " ")
            if components.count == 3, let price = Int(components[1]), let stock = Int(components[2]) {
                let money = Money(price: price, stock: stock)
                newMoneys.append(money)
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.moneys = newMoneys
        }
    }
    
    private func buyResponse(_ response: String) {
        let response = response.split(separator: " ")
        
        DispatchQueue.main.async { [weak self] in
            self?.drinks[Int(response[1])!].stock = Int(response[2].trimmingCharacters(in: ["\n"]))!
        }
    }
    
    private func insertResponse(_ response: String) {
        let response = response.split(separator: " ")
        
        
        self.moneys[Int(response[1])!].stock = Int(response[2].trimmingCharacters(in: ["\n"]))!
        
    }
    
    private func userInfoResponse(_ response: String) {
        let response = response.split(separator: " ")
        
        userID = String(response[1])
        password = String(response[2])
    }
                          
    private func changeUserInfoResponse(_ response: String) {
        let response = response.split(separator: " ")

        password = String(response[1].trimmingCharacters(in: ["\n"]))
    }
    
    private func changeNameResponse(_ response: String) {
        let response = response.split(separator: " ")
        
        let index = drinks.firstIndex(where: { $0.name == String(response[1].trimmingCharacters(in: ["\n"])) })
        
        DispatchQueue.main.async { [weak self] in
            self?.drinks[index!].name = String(response[2].trimmingCharacters(in: ["\n"]))
        }
    }
    
    private func changePriceResponse(_ response: String) {
        let response = response.split(separator: " ")
        
        let index = drinks.firstIndex(where: { $0.name == String(response[1].trimmingCharacters(in: ["\n"])) })
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.drinks[index!].price = Int(response[2].trimmingCharacters(in: ["\n"]))!
            self.drinks = self.drinks.sorted(by: {$0.price < $1.price}) //버블 정렬
        }
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
        
        DispatchQueue.main.async { [weak self] in
            self?.moneys = newMoney
        }
    }
    
    private func collectResponse() {
        DispatchQueue.main.async { [weak self] in
            for i in 0..<5 {
                if self?.moneys[i].stock ?? 0 > 10 {
                    self?.moneys[i].stock = 10
                }
            }
        }
    }
    
    private func moneyReplenishmentResponse() {
        DispatchQueue.main.async { [weak self] in
            for i in 0..<5 {
                if self?.moneys[i].stock ?? 0 < 10 {
                    self?.moneys[i].stock = 10
                }
            }
        }
    }
    
    private func drinkReplenishmentResponse() {
        DispatchQueue.main.async { [weak self] in
            for i in 0..<6 {
                self?.drinks[i].stock = 10
            }
        }
    }
    
    func fetchSales() {
        DispatchQueue.global().async {
            self.sendMessage("FETCHSALES")
            self.receiveMessage()
        }
    }
    
    func fetchStock() {
        DispatchQueue.global().async {
            self.sendMessage("STOCK")
            self.receiveMessage()
        }
    }
    
    func buyDrink(_ name: String) {
        DispatchQueue.global().async {
            self.sendMessage("BUY \(name) \(self.drinkIndex) 1")
            self.receiveMessage()
        }
    }
    
    func fetchMoney() {
        DispatchQueue.global().async {
            self.sendMessage("MONEY")
            self.receiveMessage()
        }
    }
    
    func insertMoney(_ price: Int) {
        DispatchQueue.global().async {
            self.sendMessage("INSERTMONEY \(price) \(self.moneyIndex)")
            self.receiveMessage()
        }
    }
    
    func fetchUserInfo() {
        DispatchQueue.global().async {
            self.sendMessage("USERINFO")
            self.receiveMessage()
        }
    }
    
    func updateUserInfo(_ newPassword: String) {
        DispatchQueue.global().async {
            self.sendMessage("CHANGE_PASSWORD \(newPassword)")
            self.receiveMessage()
        }
    }
    
    func collectMoeny() {
        DispatchQueue.global().async {
            self.sendMessage("COLLECT")
            self.receiveMessage()
        }
    }
    
    func moneyReplenishment() {
        DispatchQueue.global().async {
            self.sendMessage("MONEYREPLENISHMENT")
            self.receiveMessage()
        }
    }
    
    func drinkReplenishment() {
        DispatchQueue.global().async {
            self.sendMessage("DRINKREPLENISHMENT")
            self.receiveMessage()
        }
    }
    
    func changeName(_ oldName: String, _ newName: String) {
        DispatchQueue.global().async {
            self.sendMessage("CHANGE_NAME \(oldName) \(newName)")
            self.receiveMessage()
        }
    }
    
    func changePrice(_ drinkName: String, _ price: String) {
        DispatchQueue.global().async {
            self.sendMessage("CHANGE_PRICE \(drinkName) \(price)")
            self.receiveMessage()
        }
    }
    
    func resetReturnMoney() {
        for i in 0..<5 {
            returnMoneyList[i] = 0
        }
    }
    
    func returnMoney() {
        if checkReturnMoney(0, true) {
            insertMoney = 0
            var requestStr = ""
            
            requestStr.append("10 \(returnMoneyList[0]) ")
            requestStr.append("50 \(returnMoneyList[1])")
            requestStr.append(" 100 \(returnMoneyList[2])")
            requestStr.append(" 500 \(returnMoneyList[3])")
            requestStr.append(" 1000 \(returnMoneyList[4])")
            
            isReturnMoneyAlert = true

            DispatchQueue.global().async {
                self.sendMessage("RETURN_MONEY \(requestStr)")
                self.receiveMessage()
            }
            
        } else {
            print("잔액부족")
        }
    }
    
    func checkReturnMoney(_ price: Int = 0, _ check: Bool = false) -> Bool {
        var checkMoney = insertMoney - price
        var tempMoneys = moneys
        var tempReturnMoneyList = returnMoneyList
                
        for i in stride(from: 4, through: 0, by: -1) {
            while checkMoney >= tempMoneys[i].price && tempMoneys[i].stock != 0 {
                checkMoney -= tempMoneys[i].price
                tempMoneys[i].stock -= 1
                tempReturnMoneyList[i] += 1
            }
        }
                
        if checkMoney != 0 {
            return false
        }
        
        if check {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.moneys = tempMoneys
            }
            returnMoneyList = tempReturnMoneyList
        }
        
        return true
    }
}
