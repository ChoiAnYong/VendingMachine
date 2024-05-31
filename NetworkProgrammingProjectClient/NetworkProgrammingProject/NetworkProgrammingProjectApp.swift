//
//  NetworkProgrammingProjectApp.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 3/26/24.
//

import SwiftUI

@main
struct NetworkProgrammingProjectApp: App {
    var body: some Scene {
        WindowGroup {
            AuthView(viewModel: AuthViewModel())
//            VendingMachineTestView()
        }
    }
}
