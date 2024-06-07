//
//  AuthView.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/30/24.
//

import SwiftUI

//로그인 여부에 따라 분기를 시키기 위한 View
struct AuthView: View {
    @StateObject var viewModel: AuthViewModel
    @EnvironmentObject var vendingViewModel: VendingMachineViewModel
    // 로딩중인지 확인하는 변수
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
        // 두 메서드의 소켓통신이 충돌되는 것을 방지하기 위한 텀 설정
        vendingViewModel.send(action: .fetchStock)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 두 번째 동작(fetchMoney) 수행
            vendingViewModel.send(action: .fetchMoney)
        }
        // 데이터가 로드되지 않고 화면이 나오지 않도록 2초의 텀을 주고 프로그래스바가 나오도록 함
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

