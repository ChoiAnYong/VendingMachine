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
                .environmentObject(viewModel)
                .onAppear {
                    viewModel.send(action: .fetchStock)                    
                    viewModel.send(action: .fetchMoney)
                }
        }
    }
}
