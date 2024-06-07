//
//  ChangePriceViewModel.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 6/3/24.
//

import Foundation

// Alert의 종류
enum PriceAlert {
    case fail // 실패
    case success // 성공
    case none // 초기값
}

final class ChangePriceViewModel: ObservableObject {
    @Published var drinkName = "" // 가격을 바꾸려는 음료의 이름
    @Published var priceString = "" // 새로운 가격
    @Published var isPresentAlert = false // Alert를 띄워야하되는지를 저장할 변수
    @Published var alertMode: PriceAlert = .none // Alert의 종류
    private var currentDrinks: [Drink] = [] // 현재 음료의 정보

    //음료 정보를 외부에서 주입받기 위한 함수
    func initDrinks(_ drinks: [Drink]) {
        currentDrinks = drinks
    }
    
    //변경 가능한 가격인지 검사하는 함수
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
