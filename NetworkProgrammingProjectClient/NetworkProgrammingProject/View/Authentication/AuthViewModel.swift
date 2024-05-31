//
//  AuthViewModel.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/30/24.
//

import Foundation

enum Auth {
    case authentication
    case unAuthentication
}

final class AuthViewModel: ObservableObject {
    @Published var auth: Auth = .unAuthentication
        
    enum Action {
        case login
        case logout
    }
    
    
    func send(action: Action) {
        switch action {
        case .login:
            auth = .authentication
        case .logout:
            auth = .unAuthentication
        }
    }
}
