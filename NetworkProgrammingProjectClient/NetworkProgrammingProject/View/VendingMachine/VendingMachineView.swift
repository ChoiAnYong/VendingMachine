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
        VStack {
            loginBtn
            
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
            .padding(.vertical, 15)
            .alert(isPresented: $viewModel.isPresentDrinkAlert) {
                switch viewModel.alertMode {
                case .success:
                    Alert(title: Text("\(viewModel.selectedDrink?.name ?? "오류") 1개를 구매하였습니다."), dismissButton: .default(Text("확인")))
                case .fail:
                    Alert(title: Text("잔돈이 부족하여 \(viewModel.selectedDrink?.name ?? "오류")를 구매할 수 없습니다."), dismissButton: .default(Text("확인")))
                }
            }
            
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
                    viewModel.send(action: .returnMoney)
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
            Spacer()
        }
        .environmentObject(viewModel)
    }
    
    var loginBtn: some View {
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
        .padding(.horizontal, 20)
        .fullScreenCover(isPresented: $isPresent, content: {
            LoginView()
        })
    }
}

#Preview {
    VendingMachineView()
        .environmentObject(VendingMachineViewModel())
}
