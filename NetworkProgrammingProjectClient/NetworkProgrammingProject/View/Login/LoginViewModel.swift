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
    
    // 서버에 저장된 id, password를 주입받는 함수
    func userInfoInit(_ id: String, _ password: String) {
        self.currentId = id.trimmingCharacters(in: ["\n"])
        self.currentPass = password.trimmingCharacters(in: ["\n"])
    }
    
    // 현재 입력된 id와 password가 서버에서 가져온 정보와 일치하는지 검사
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
