//
//  ManagerView.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/30/24.
//

import SwiftUI

struct ManagerView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject var viewModel = ManagerViewModel()
    
    var body: some View {
        ZStack {
            Text("Hello, World!")
            loginBtn
        }
    }
    var loginBtn: some View {
        VStack {
            HStack {
                Button(action: {
                    viewModel.isPresent = true
                }, label: {
                    Text("비밀번호 변경")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.black)
                        .padding(5)
                })
                .overlay {
                    Rectangle()
                        .stroke()
                }
                Spacer()
                Button(action: {
                    authViewModel.auth = .unAuthentication
                }, label: {
                    Text("로그아웃")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.black)
                        .padding(5)
                })
                .overlay {
                    Rectangle()
                        .stroke()
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .fullScreenCover(isPresented: $viewModel.isPresent, content: {
            ChangeView()
        })
    }
}

#Preview {
    ManagerView()
}
