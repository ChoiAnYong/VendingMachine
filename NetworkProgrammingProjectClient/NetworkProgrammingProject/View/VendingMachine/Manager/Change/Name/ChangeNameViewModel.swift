//
//  ChangeNameViewModel.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 6/3/24.
//

import Foundation

enum NameAlert {
    case noOldName
    case existenceNewName
    case success
    case none
}

final class ChangeNameViewModel: ObservableObject {
    @Published var oldName = ""
    @Published var newName = ""
    @Published var isPresentAlert = false
    @Published var alertMode: NameAlert = .none
    private var currentDrinks: [Drink] = []

    func initDrinks(_ drinks: [Drink]) {
        currentDrinks = drinks
    }
    
    func isOldNameValid() -> Bool {
        var oldNameExistence = false
        var newNameExistence = false
        
        currentDrinks.forEach { drink in
            if drink.name == oldName {
                oldNameExistence = true
            }
            
            if drink.name == newName {
                newNameExistence = true
            }
        }
        
        if oldNameExistence && !newNameExistence {
            isPresentAlert = true
            alertMode = .success
            return true
        } else {
            if !oldNameExistence {
                alertMode = .noOldName
            } else if newNameExistence {
                alertMode = .existenceNewName
            }
            isPresentAlert = true
            
            return false
        }
    }
}
