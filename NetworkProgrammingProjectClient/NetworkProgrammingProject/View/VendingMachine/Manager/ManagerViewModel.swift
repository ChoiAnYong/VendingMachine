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
