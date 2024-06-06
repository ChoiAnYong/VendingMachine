//
//  ManagerViewModel.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/31/24.
//

import Foundation

final class ManagerViewModel: ObservableObject {
    @Published var isPresent = false
    @Published var isPresentChangePrice = false
    @Published var isPresentChangeName = false
    @Published var isPresentDailySalse = false
    @Published var isPresentMonthSalse = false
    @Published var isPresentDrinkDailySalse = false
    @Published var isPresentDrinkMonthSalse = false
    
    enum Present {
        case password
        case price
        case name
    }
    
    func changeIsPresent(_ mode: Present) {
        switch mode {
        case .password:
            isPresent.toggle()
        case .price:
            isPresentChangePrice.toggle()
        case .name:
            isPresentChangeName.toggle()
        }
    }
}
