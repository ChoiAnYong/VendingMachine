//
//  AuthViewModel.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/30/24.
//

import Foundation

// 로그인 여부를 확인하기 위한 열거형
enum Auth {
    case authentication
    case unAuthentication
}

// AuthView에서 사용되는 로직과 변수를 다루는 ViewModel
final class AuthViewModel: ObservableObject {
    //로그인 여부를 확인하기 위한 변수
    //@published 어노테이션을 설정하면 해당 변수가 변경되면 뷰를 다시 그림
    @Published var auth: Auth = .unAuthentication
     
    // 해당 뷰에서 사용되는 동작를 나타낸 열거형
    enum Action {
        case login
        case logout
    }
    
    // 해당 메서드를 사용하여 action별 로직 수행
    func send(action: Action) {
        switch action {
        case .login:
            auth = .authentication
        case .logout:
            auth = .unAuthentication
        }
    }
}
