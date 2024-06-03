//
//  LoginView.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 3/26/24.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var textFocus
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var vendingViewModel: VendingMachineViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                
                Text("관리자로 로그인")
                    .font(.system(size: 30, weight: .bold))
                    .padding(.bottom, 10)
                
                Rectangle()
                    .frame(height: 4)
                
                TextField("아이디를 입력하세요", text: $viewModel.id)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .overlay {
                        RoundedRectangle(cornerRadius: 1)
                            .stroke(Color.gray, lineWidth: 1)
                    }
                
                SecureField("비밀번호를 입력하세요", text: $viewModel.password)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .overlay {
                        RoundedRectangle(cornerRadius: 1)
                            .stroke(Color.gray, lineWidth: 1)
                    }
                
                Button(action: {
                    if viewModel.checkLogin() {
                        vendingViewModel.send(action: .changePassword(newPassword: viewModel.password))
                        authViewModel.auth = .authentication
                    }
                }, label: {
                    Text("로그인")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .background(Color.black)
                        .cornerRadius(50)
                })
                .padding(.top, 20)
                .disabled(viewModel.id.isEmpty || viewModel.password.isEmpty)
                
            }
            .padding(.horizontal, 20)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(.close)
                            .renderingMode(.template)
                            .foregroundColor(Color.black)
                    })
                }
            }
            .alert("회원정보가 일치하지 않습니다.", isPresented: $viewModel.isPresentAlert) {
                Button(action: {}, label: {
                    Text("확인")
                })
            }
        }
        .onAppear {
            viewModel.userInfoInit(vendingViewModel.userID, vendingViewModel.password)
            print(vendingViewModel.userID)
            print(vendingViewModel.password)
        }
        
    }
}


#Preview {
    LoginView()
}
