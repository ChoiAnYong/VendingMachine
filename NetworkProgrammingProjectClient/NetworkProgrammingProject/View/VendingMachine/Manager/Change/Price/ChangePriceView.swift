//
//  ChangePriceVoew.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 6/3/24.
//

import SwiftUI

// 음료의 가격을 바꾸기 위한 View
struct ChangePriceView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = ChangePriceViewModel()
    @FocusState private var textFocus
    @EnvironmentObject private var vendingViewModel: VendingMachineViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                
                Text("음료 가격 변경")
                    .font(.system(size: 30, weight: .bold))
                    .padding(.bottom, 10)
                
                Rectangle()
                    .frame(height: 4)
                
                TextField("가격 변경할 음료 이름을 입력하세요", text: $viewModel.drinkName)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .keyboardType(.emailAddress)
                    .overlay {
                        RoundedRectangle(cornerRadius: 1)
                            .stroke(Color.gray, lineWidth: 1)
                    }
                
                TextField("새로운 가격을 입력하세요", text: $viewModel.priceString)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .overlay {
                        RoundedRectangle(cornerRadius: 1)
                            .stroke(Color.gray, lineWidth: 1)
                    }
                
                Button(action: {
                    if viewModel.isPriceValid() {
                        vendingViewModel.send(action: .changePrice(drinkName: viewModel.drinkName,
                                                                  price: viewModel.priceString))
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
                .disabled(viewModel.drinkName.isEmpty || viewModel.priceString.isEmpty)
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
                case .fail:
                    return Alert(title: Text("변경 실패"), message: Text("음료의 가격은 0 < 음료 가격 <= 7000로 설정해야하며 1의 자리수는 0이여야 합니다."), dismissButton: .cancel(Text("확인"), action: {
                        viewModel.alertMode = .none
                    }))
                case .success:
                    return Alert(title: Text("변경 성공"), message: Text("음료 가격이 변경되었습니다."), dismissButton: .cancel(Text("확인"), action: {
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
    ChangePriceView()
}
