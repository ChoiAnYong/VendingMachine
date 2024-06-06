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
    private let screenWidth = UIScreen.main.bounds.width
    var colums: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        VStack {
            loginBtn
        
            stateOfMoneyView
                .padding(.bottom, 10)
            stateOfDrinkView
                .padding(.bottom, 10)
            salseView
            
            Spacer()
        }
        .onAppear {
            vendingViewModel.send(action: .fetchSales)
        }
    }
    
    var stateOfMoneyView: some View {
        VStack {
            Rectangle()
                .frame(height: 1)
          
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
        VStack {
            Text("매출 확인")
                .font(.system(size: 25, weight: .bold))
            
            HStack {
                Button(action: {
                    viewModel.isPresentDailySalse = true
                }, label: {
                    Text("일매출")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(Color.black)
                        .padding(.vertical, 10)
                })
                .frame(width: screenWidth/2 - 10)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke()
                }
                .sheet(isPresented: $viewModel.isPresentDailySalse, content: {
                    SalesView(title: "일매출", list: vendingViewModel.sales.dailySales)
                })
                
                Button(action: {
                    viewModel.isPresentMonthSalse = true
                }, label: {
                    Text("월매출")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(Color.black)
                        .padding(.vertical, 10)
                })
                .frame(width: screenWidth/2 - 20)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke()
                }
                .sheet(isPresented: $viewModel.isPresentMonthSalse, content: {
                    SalesView(title: "월매출", list: vendingViewModel.sales.monthSales)
                })
            }
            
            LazyVGrid(columns: colums, spacing: 20) {
                ForEach(Array(zip(vendingViewModel.drinks.indices, vendingViewModel.drinks)), id: \.0) { index, drink in
                    VStack {
                        Text("\(drink.name)")
                            .font(.system(size: 20, weight: .bold))
                        
                        Button(action: {
                            vendingViewModel.drinks[index].isDailyPresent = true
                        }, label: {
                            Text("일매출")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color.black)
                                .padding(.vertical, 10)
                        })
                        .frame(width: screenWidth/3 - 40)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke()
                        }
                        .sheet(isPresented: $vendingViewModel.drinks[index].isDailyPresent, content: {
                            DrinkSalesView(title: "일매출", drink: "\(drink.fixedName)", list: vendingViewModel.sales.drinkDailySales)
                        })
                        
                        Button(action: {
                            vendingViewModel.drinks[index].isMonthPresent = true
                        }, label: {
                            Text("월매출")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color.black)
                                .padding(.vertical, 10)
                        })
                        .frame(width: screenWidth/3 - 40)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke()
                        }
                        .sheet(isPresented: $vendingViewModel.drinks[index].isMonthPresent, content: {
                            DrinkSalesView(title: "월매출", drink: "\(drink.fixedName)", list: vendingViewModel.sales.drinkMonthSales)
                        })
                        
                    }
                    .padding(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke()
                    }
                }
                .overlay {
                    Rectangle()
                        .stroke()
                }
                Spacer()
            }
            .padding(.top, 10)
            .padding(.horizontal, 10)
            
            Button(action: {
                vendingViewModel.send(action: .fetchSales)
            }, label: {
                Text("매출 정보 갱신")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(Color.black)
                    .padding(5)
            })
            .frame(width: screenWidth/3 * 2)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke()
            }
        }
    }
    
    
}

#Preview {
    ManagerView()
        .environmentObject(VendingMachineViewModel())
}
