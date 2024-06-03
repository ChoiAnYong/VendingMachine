//
//  ChangePriceView.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 6/3/24.
//

import SwiftUI

struct ChangeNameView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = ChangeNameViewModel()
    @FocusState private var textFocus
    @EnvironmentObject private var vendingViewModel: VendingMachineViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                
                Text("음료 이름 변경")
                    .font(.system(size: 30, weight: .bold))
                    .padding(.bottom, 10)
                
                Rectangle()
                    .frame(height: 4)
                
                TextField("기존 이름을 입력하세요", text: $viewModel.oldName)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .overlay {
                        RoundedRectangle(cornerRadius: 1)
                            .stroke(Color.gray, lineWidth: 1)
                    }
                
                TextField("새로운 이름을 입력하세요", text: $viewModel.newName)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .overlay {
                        RoundedRectangle(cornerRadius: 1)
                            .stroke(Color.gray, lineWidth: 1)
                    }
                
                Button(action: {
                    if viewModel.isOldNameValid() {
                        vendingViewModel.send(action: .changeName(oldName: viewModel.oldName,
                                                                  newName: viewModel.newName))
                    }
                }, label: {
                    Text("변경")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .background(Color.black)
                        .cornerRadius(50)
                })
                .padding(.top, 20)
                .disabled(viewModel.oldName.isEmpty || viewModel.newName.isEmpty)
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
            .alert(isPresented: $viewModel.isPresentAlert) {
                switch viewModel.alertMode {
                case .noOldName:
                    return Alert(title: Text("변경 실패"), message: Text("기존 음료 이름에 해당되는 음료가 없습니다."), dismissButton: .cancel(Text("확인"), action: {
                        viewModel.alertMode = .none
                    }))
                case .existenceNewName:
                    return Alert(title: Text("변경 실패"), message: Text("이미 존재하는 이름입니다."), dismissButton: .cancel(Text("확인"), action: {
                        viewModel.alertMode = .none
                    }))
                case .success:
                    return Alert(title: Text("변경 성공"), message: Text("음료 이름이 변경되었습니다."), dismissButton: .cancel(Text("확인"), action: {
                        dismiss()
                    }))
                case .none:
                    return Alert(title: Text("오류"))
                }
            }
        }
        .onAppear {
            viewModel.initDrinks(vendingViewModel.drinks)
        }
    }
}

#Preview {
    ChangeNameView()
}
