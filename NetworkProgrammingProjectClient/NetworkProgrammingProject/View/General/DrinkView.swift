//
//  DrinkView.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/29/24.
//

import SwiftUI

// 자판기의 음료 정보를 나타낼 View
struct DrinkView: View {
    @EnvironmentObject var viewModel: VendingMachineViewModel
    let screenwidth = UIScreen.main.bounds.width
    var drink: Drink
    let index: Int
    
    init(drink: Drink, index: Int) {
        self.drink = drink
        self.index = index
    }
    
    var body: some View {
        Button(action: {
            if viewModel.checkReturnMoney(drink.price) {
                viewModel.send(action: .purchase(index: index))
                viewModel.selectedDrink = drink
                viewModel.isPresentDrinkAlert = true
                viewModel.alertMode = .success
            } else {
                viewModel.isPresentDrinkAlert = true
                viewModel.selectedDrink = drink
                viewModel.alertMode = .fail
            }
        }, label: {
            VStack {
                Text("\(drink.name)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.black)
                Image("\(drink.fixedName)")
                    .resizable()
                    .frame(width: 120, height: 100)
                Text("\(drink.price)원")
                    .padding(.horizontal, 10)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.white)
                    .background(Color.purple)
                    .cornerRadius(25)
            }
            .padding(10)
            .overlay {
                if drink.stock == 0 {
                    VStack {
                        Spacer()
                        Image("soldout")
                            .resizable()
                            .scaledToFit()
                        Spacer()
                    }
                    .foregroundColor(.black)
                    .background(Color.gray)
                    .opacity(0.8)
                } else if drink.price > viewModel.insertMoney {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                        }
                        Spacer()
                    }
                    .foregroundColor(.black)
                    .background(Color.gray)
                    .opacity(0.8)
                }
            }
            .animation(.easeInOut(duration: 0.5))
        })
        .disabled(drink.stock == 0 || drink.price > viewModel.insertMoney)
        .frame(width: screenwidth/4 + 10)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

#Preview {
    DrinkView(drink: .init(name: "coffee", price: 10, stock: 0, fixedName: "물"), index: 1)
        .environmentObject(VendingMachineViewModel())
}
