//
//  ChangeViewModel.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/31/24.
//

import Foundation

enum alert {
    case fail
    case success
    case none
}

final class ChangeViewModel: ObservableObject {
    @Published var password = ""
    @Published var isPresentAlert = false
    @Published var alertMode: alert = .none
    
    // 비밀번호 유효성 검사
    func isPasswordValid() -> Bool {
        let passwordRegex = "^(?=.*[0-9])(?=.*[!@#$%^&*()_+=\\[\\]{}|;:'\",.<>?/~`-]).{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        if passwordPredicate.evaluate(with: password) {
            isPresentAlert = true
            alertMode = .success
            return true
        } else {
            isPresentAlert = true
            alertMode = .fail
            return false
        }
    }
}
