//
//  VendingMachineViewModel.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/29/24.
//

import Foundation

final class VendingMachineViewModel: ObservableObject {
    @Published var drinks: [Drink] = [
        .init(name: .water, price: 450, stock: 10),
        .init(name: .coffee, price: 500, stock: 10),
        .init(name: .pocari, price: 550, stock: 10),
        .init(name: .highCoffee, price: 750, stock: 10),
        .init(name: .cola, price: 750, stock: 10),
        .init(name: .oronamin, price: 800, stock: 10)
    ]
    @Published var moneys: [Money] = [
        .init(price: 10, stock: 10),
        .init(price: 50, stock: 10),
        .init(price: 100, stock: 10),
        .init(price: 500, stock: 10),
        .init(price: 1000, stock: 10)
    ]
    
    @Published var isDisplayCountAlert: Bool
    @Published var isDisplaySoldoutAlert: Bool
    @Published var insertMoney: Int
    
    var count: Int // 지패 투입 개수 저장
    
    init(insertMoney: Int = 0, isDisplayCountAlert: Bool = false, isDisplaySoldoutAlert: Bool = false, count: Int = 0) {
        self.insertMoney = insertMoney
        self.isDisplayCountAlert = isDisplayCountAlert
        self.isDisplaySoldoutAlert = isDisplaySoldoutAlert
        self.count = count
    }
    
    enum Action {
        case insertMoney(index: Int)
        case purchase(index: Int)
        case returnMoney
    }
    
    
    func send(action: Action) {
        switch action {
        case .insertMoney(let index):
            if insertMoney + moneys[index].price <= 7000 {
                if moneys[index].price == 1000 {
                    count += 1
                }
                insertMoney += moneys[index].price
                moneys[index].stock += 1
            }
            
        case .purchase(let index):
            if drinks[index].stock != 0 {
                if insertMoney >= drinks[index].price {
                    drinks[index].stock -= 1
                    insertMoney -= drinks[index].price
                }
            }
            
        case .returnMoney:
            break
        }
    }
}
    
