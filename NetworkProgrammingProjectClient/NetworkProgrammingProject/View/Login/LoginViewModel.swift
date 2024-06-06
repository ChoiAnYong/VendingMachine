//
//  LoginViewModel.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 3/26/24.
//

import Foundation

final class LoginViewModel: ObservableObject {
    private var currentId = ""
    private var currentPass = ""
    
    @Published var id: String = ""
    @Published var password: String = ""
    @Published var isPresentAlert: Bool = false
    
    private let pwRegex =  "^(?=.*[0-9])(?=.*[!@#$%^&*()_+=\\[\\]{}|;:'\",.<>?/~`-]).{8,}$"
    
    func userInfoInit(_ id: String, _ password: String) {
        self.currentId = id.trimmingCharacters(in: ["\n"])
        self.currentPass = password.trimmingCharacters(in: ["\n"])
    }
    
    func checkLogin() -> Bool {
        if id != currentId || password != currentPass {
                isPresentAlert = true
            return false
        } else {
            isPresentAlert = false
            return true
        }
    }    
}
