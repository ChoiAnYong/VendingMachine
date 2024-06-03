//
//  CoinView.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/30/24.
//

import SwiftUI

struct CoinView: View {
    @EnvironmentObject var viewModel: VendingMachineViewModel
    let screenwidth = UIScreen.main.bounds.width
    var money: Money
    let index: Int
    
    init(money: Money, index: Int) {
        self.money = money
        self.index = index
    }
    
    var body: some View {
        Button(action: {
            viewModel.send(action: .insertMoney(index: index))
        }, label: {
            VStack {
                Text("\(money.price)원")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .padding(7)
                    .frame(width: screenwidth/6)
                    .overlay {
                        if ((money.price == 1000 && viewModel.count == 5) || viewModel.insertMoney + money.price > 7000) {
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray, lineWidth: 2)
                                .background(Color.gray)
                                .cornerRadius(25)
                                .opacity(0.8)
                        } else {
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.black, lineWidth: 2)
                        }
                    }
                Text("\(money.stock)")
            }
        })
        .disabled((money.price == 1000 && viewModel.count == 5) || viewModel.insertMoney + money.price > 7000)
    }
}

#Preview {
    CoinView(money: .init(price: 1000, stock: 10), index: 1)
        .environmentObject(VendingMachineViewModel())
}
