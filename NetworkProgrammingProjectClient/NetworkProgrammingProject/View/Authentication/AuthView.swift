//
//  AuthView.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/30/24.
//

import SwiftUI

struct AuthView: View {
    @StateObject var viewModel: AuthViewModel
    @EnvironmentObject var vendingViewModel: VendingMachineViewModel
    @State private var isLoading: Bool = true
    
    var body: some View {
        VStack {
            switch viewModel.auth {
            case .authentication:
                ManagerView()
            case .unAuthentication:
                if isLoading {
                    ProgressView() // 데이터를 로딩하는 동안에는 ProgressView를 표시
                } else {
                    VendingMachineView()
                }
            }
        }
        .environmentObject(viewModel)
        .onAppear {
            if viewModel.auth == .unAuthentication {
                fetchData() // 데이터 가져오는 비동기 동작 수행
            }
        }
    }
    
    private func fetchData() {
        vendingViewModel.send(action: .fetchStock)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 두 번째 동작(fetchMoney) 수행
            vendingViewModel.send(action: .fetchMoney)
        }
        // 비동기 동작이 완료될 때 isLoading 상태 변경
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
        }
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel())
        .environmentObject(AuthViewModel())
        .environmentObject(VendingMachineViewModel())
}

