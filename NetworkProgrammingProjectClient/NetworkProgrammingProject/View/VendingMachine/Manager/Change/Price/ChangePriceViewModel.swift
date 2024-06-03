//
//  ChangePriceViewModel.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 6/3/24.
//

import Foundation

enum PriceAlert {
    case fail
    case success
    case none
}

final class ChangePriceViewModel: ObservableObject {
    @Published var drinkName = ""
    @Published var priceString = ""
    @Published var isPresentAlert = false
    @Published var alertMode: PriceAlert = .none
    private var currentDrinks: [Drink] = []

    func initDrinks(_ drinks: [Drink]) {
        currentDrinks = drinks
    }
    
    func isPriceValid() -> Bool {
        let price = Int(priceString)!
        
        if price > 0 && price <= 7000 && price % 10 == 0 { // 투입 금액이 최대 7천원이고 1원 단위가 없으므로 검사
            isPresentAlert = true
            alertMode = .success
            return true
        }
        
        isPresentAlert = true
        alertMode = .fail
        return false
    }
}
