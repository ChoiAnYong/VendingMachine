//
//  ChangeViewModel.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/31/24.
//

import Foundation

enum PasswordAlert {
    case fail
    case success
    case none
}

final class ChangePasswordViewModel: ObservableObject {
    @Published var password = "" // 사용자가 입력한 새로운 비밀번호
    @Published var isPresentAlert = false // 알림 표시 여부
    @Published var alertMode: PasswordAlert = .none
    
    // 비밀번호 유효성 검사
    func isPasswordValid() -> Bool {
        //// 비밀번호 유효성 검사를 위한 정규표현식
        let passwordRegex = "^(?=.*[0-9])(?=.*[!@#$%^&*()_+=\\[\\]{}|;:'\",.<>?/~`-]).{8,}$"
        
        //NSPredicate를 사용하여 문자열이 정규 표현식 패턴과 일치하는지 확인
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        
        if passwordPredicate.evaluate(with: password) {// 비밀번호가 유효한 경우
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
