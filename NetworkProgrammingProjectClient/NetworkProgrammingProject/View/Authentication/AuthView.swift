//
//  AuthView.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/30/24.
//

import SwiftUI

struct AuthView: View {
    @StateObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            switch viewModel.auth {
            case .authentication:
                ManagerView()
            case .unAuthentication:
                VendingMachineView(viewModel: VendingMachineViewModel())
            }
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel())
        .environmentObject(AuthViewModel())
}

