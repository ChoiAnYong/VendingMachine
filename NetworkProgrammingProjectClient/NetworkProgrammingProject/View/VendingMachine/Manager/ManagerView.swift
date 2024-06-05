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
    @EnvironmentObject private var vendingViewModel: VendingMachineViewModel
    var colums: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        VStack {
            loginBtn
        
            stateOfMoneyView
                .padding(.bottom, 10)
            stateOfDrinkView
            
            salseView
        }
    }
    
    var stateOfMoneyView: some View {
        VStack(alignment: .leading) {
            Rectangle()
                .frame(height: 1)
                .padding(.bottom, 1)
          
            HStack {
                Text("화폐 현황")
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
                
                Button {
                    vendingViewModel.send(action: .collectMoney)
                } label: {
                   Text("수금하기")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.black)
                }
                .padding(3)
                .overlay {
                    Rectangle()
                        .stroke()
                }

                
                Button {
                    vendingViewModel.send(action: .moneyReplenishment)
                } label: {
                   Text("재고보충")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.black)
                }
                .padding(3)
                .overlay {
                    Rectangle()
                        .stroke()
                }

            }
            .padding(.horizontal, 20)
            
            Rectangle()
                .frame(height: 1)
            
            LazyVGrid(columns: colums, alignment: .leading) {
                ForEach(vendingViewModel.moneys, id: \.self) { money in
                    Text("\(money.price)원 \(money.stock)개")
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    var stateOfDrinkView: some View {
        VStack(alignment: .leading) {
            Rectangle()
                .frame(height: 1)
          
            HStack {
                Text("음료 현황")
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
                
                Button {
                        viewModel.changeIsPresent(.name)
                } label: {
                   Text("이름변경")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.black)
                }
                .padding(3)
                .overlay {
                    Rectangle()
                        .stroke()
                }
                .fullScreenCover(isPresented: $viewModel.isPresentChangeName) {
                    ChangeNameView()
                }
                
                
                Button {
                        viewModel.changeIsPresent(.price)
                } label: {
                   Text("가격변경")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.black)
                }
                .padding(3)
                .overlay {
                    Rectangle()
                        .stroke()
                }
                .fullScreenCover(isPresented: $viewModel.isPresentChangePrice) {
                    ChangePriceView()
                }
                
                Button {
                    vendingViewModel.send(action: .drinkReplenishment)
                } label: {
                   Text("재고보충")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.black)
                }
                .padding(3)
                .overlay {
                    Rectangle()
                        .stroke()
                }

            }
            .padding(.horizontal, 20)
            
            Rectangle()
                .frame(height: 1)
            
            LazyVGrid(columns: colums, alignment: .leading) {
                ForEach(vendingViewModel.drinks, id: \.self) { drink in
                    Text("\(drink.name) \(drink.stock)개")
                }
            }
            .padding(.horizontal, 20)
            
            Rectangle()
                .frame(height: 1)
        }
    }
    
    var loginBtn: some View {        
        HStack {
            Button(action: {
                viewModel.changeIsPresent(.password)
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
            .fullScreenCover(isPresented: $viewModel.isPresent, content: {
                ChangePasswordView()
            })
        }
        .padding(.horizontal, 20)
    }
    
    var salseView: some View {
        VStack(alignment: .leading) {
            Text("매출 현황")
                .font(.system(size: 20, weight: .bold))
        }
    }
}

#Preview {
    ManagerView()
}
