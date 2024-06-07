//
//  ChangeNameViewModel.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 6/3/24.
//

import Foundation

// Alert의 종류를 나타낼 열거형
enum NameAlert {
    case noOldName // 기존 이름이 없는 경우
    case existenceNewName // 바꾸려는 이름이 이미 존재하는 경우
    case success // 성공한 경우
    case none // 초기값
}

final class ChangeNameViewModel: ObservableObject {
    @Published var oldName = "" // 바꾸고자 하는 기존 음료의 현재 이름
    @Published var newName = "" // 바꾸려는 이름
    @Published var isPresentAlert = false // Alert를 띄워야하되는지를 저장할 변수
    @Published var alertMode: NameAlert = .none // Alert 모드
    private var currentDrinks: [Drink] = [] // 현재 서버에서 불러온 음료의 정보

    //음료 정보를 외부에서 주입받기 위한 함수
    func initDrinks(_ drinks: [Drink]) {
        currentDrinks = drinks
    }
    
    // 이름 변경이 가능하는 검사하는 함수
    func isOldNameValid() -> Bool {
        var oldNameExistence = false // 바꾸고자 하는 기존 음료의 이름이 존재하는지를 저장할 변수
        var newNameExistence = false // 바꾸려는 음료의 이름이 현재 존재하는지를 저장할 변수
        
        currentDrinks.forEach { drink in // 현재 음료를 정보와 비교하기 위한 반복문
            if drink.name == oldName { // 현재 음료 정보에 바꾸고자 하는 기존 음료의 이름이 존재
                oldNameExistence = true
            }
            
            if drink.name == newName { // 현재 음료 정보에 바꾸려고 하는 음료의 이름이 존재
                newNameExistence = true
            }
        }
        
        if oldNameExistence && !newNameExistence { // 기존 이름이 있고, 바꾸려고 하는 이름이 없는 경우
            isPresentAlert = true
            alertMode = .success
            return true
        } else {
            if !oldNameExistence { // 기존 음료의 이름이 없는 경우
                alertMode = .noOldName
            } else if newNameExistence { // 바꾸려는 음료의 이름이 이미 존재하는 경우
                alertMode = .existenceNewName
            }
            isPresentAlert = true
            
            return false
        }
    }
}
