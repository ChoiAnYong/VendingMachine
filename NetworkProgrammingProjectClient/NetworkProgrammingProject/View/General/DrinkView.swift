//
//  DrinkView.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/29/24.
//

import SwiftUI

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
            viewModel.send(action: .purchase(index: index))
        }, label: {
            VStack {
                Image("\(drink.name)")
                    .resizable()
                    .frame(width: 120, height: 140)
                Text("\(drink.price)원")
                    .padding(.horizontal, 10)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.white)
                    .background(Color.purple)
                    .cornerRadius(25)
                Text("\(drink.stock)")
            }
            .padding(10)
            .overlay {
                if drink.stock == 0 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("품절")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(Color.red)
                            Spacer()
                        }
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
    DrinkView(drink: .init(name: "coffee", price: 10, stock: 10), index: 1)
        .environmentObject(VendingMachineViewModel())
}
