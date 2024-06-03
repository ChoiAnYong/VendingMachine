//
//  VendingMachineView.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/29/24.
//

import SwiftUI

struct VendingMachineView: View {
    @EnvironmentObject var viewModel: VendingMachineViewModel
    @EnvironmentObject var AuthViewModel: AuthViewModel
    @State var isPresent = false
    
    var colums: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        ZStack {
            VStack {
                Rectangle()
                    .frame(height: 1)
                
                Text("음료")
                    .font(.system(size: 20, weight: .bold))
                
                Rectangle()
                    .frame(height: 1)
                
                LazyVGrid(columns: colums, content: {
                    ForEach(Array(zip(viewModel.drinks.indices, viewModel.drinks)), id: \.0) { index, drink in
                        DrinkView(drink: drink, index: index)
                    }
                })
                .padding(.horizontal, 12)
                .padding(.vertical, 25)
                
                Rectangle()
                    .frame(height: 1)
                
                Text("동전 투입구")
                    .font(.system(size: 20, weight: .bold))
                
                Rectangle()
                    .frame(height: 1)
                HStack(spacing: 10) {
                    ForEach(Array(zip(viewModel.moneys.indices, viewModel.moneys)), id: \.0) { index, money in
                        CoinView(money: money, index: index)
                    }
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.black)
                .padding(.vertical, 10)
                
                Rectangle()
                    .frame(height: 1)
                HStack {
                    Text("투입 금액: \(viewModel.insertMoney)원")
                        .padding(10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 2)
                        }
                    
                    Button(action: {
                        viewModel.insertMoney = 0
                    }, label: {
                        Text("반환")
                            .foregroundColor(.black)
                            .padding(20)
                            .overlay {
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                            }
                    })
                }
            }
            
            loginBtn
        }
        .environmentObject(viewModel)
        .fullScreenCover(isPresented: $isPresent, content: {
            LoginView()
        })
    }
    
    var loginBtn: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    isPresent.toggle()
                }, label: {
                    Text("관리자 로그인")
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
    }
}

#Preview {
    VendingMachineView()
        .environmentObject(VendingMachineViewModel())
}
