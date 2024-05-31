//
//  ChangeView.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/31/24.
//

import SwiftUI

struct ChangeView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ChangeViewModel()
    @FocusState private var textFocus
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                
                Text("비밀번호 변경")
                    .font(.system(size: 30, weight: .bold))
                    .padding(.bottom, 10)
                
                Rectangle()
                    .frame(height: 4)
                
                SecureField("변경할 비밀번호를 입력하세요", text: $viewModel.password)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .overlay {
                        RoundedRectangle(cornerRadius: 1)
                            .stroke(Color.gray, lineWidth: 1)
                    }
                
                Button(action: {
                    if viewModel.isPasswordValid() {
                        print("dk")
                    }
                }, label: {
                    Text("변경하기")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .background(Color.black)
                        .cornerRadius(50)
                })
                .padding(.top, 20)
                .disabled(viewModel.password.isEmpty)
                .alert(isPresented: $viewModel.isPresentAlert) {
                    switch viewModel.alertMode {
                    case .fail:
                        return Alert(title: Text("변경 실패"), message: Text("비밀번호는 특수문자 및 숫자가 각각 하나 이상 포함된 8자리 이상이여야 합니다."), dismissButton: .cancel(Text("확인"), action: {
                            viewModel.alertMode = .none
                        }))
                    case .success:
                        return Alert(title: Text("변경 성공"), message: Text("비밀번호가 변경되었습니다."), dismissButton: .cancel(Text("확인"), action: {
                            dismiss()
                        }))
                    case .none:
                        return Alert(title: Text("오류"))
                    }
                }
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
 
//            .alert("비밀번호는 특수문자 및 숫자가 각각 하나 이상 포함된 8자리 이상이여야 합니다.", isPresented: $viewModel.isPresentFailAlert) {
//                Button(action: {
//                    view
//                }, label: {
//                    Text("확인")
//                })
//            }
        }
        
    }
}

#Preview {
    ChangeView()
}
