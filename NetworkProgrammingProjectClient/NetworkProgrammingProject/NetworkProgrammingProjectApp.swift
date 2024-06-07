//
//  NetworkProgrammingProjectApp.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 3/26/24.
//

import SwiftUI

@main
struct NetworkProgrammingProjectApp: App {
    @StateObject var viewModel = VendingMachineViewModel()
    
    var body: some Scene {
        WindowGroup {
            AuthView(viewModel: AuthViewModel())
                .environmentObject(viewModel) // 모든 자식뷰에서 VendingMachineViewModel를 사용할 수 있도록 의존성 주입
        }
    }
}
